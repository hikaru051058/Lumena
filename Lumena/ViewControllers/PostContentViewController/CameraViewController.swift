//
//  CameraViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/10.
//

import UIKit
import AVFoundation
import SwiftUI
import AVKit
import Combine

enum CameraMode {
    case photo
    case video
    
    mutating func toggle() {
        if self == .photo {
            self = .video
        } else {
            self = .photo
        }
    }
}

enum CameraType {
    case ultraWide
    case wide
    case telephoto
}

enum CameraPosition {
    case front
    case back
}

enum CameraProcessStatus {
    case ready
    
    case takePic
    case recording
    
    case processing
    case error
    
    case camerError
    case audioError
    
    case prepping
    case toggling
}

enum TimerState: Int {
    case noTimer = 0
    case threeSeconds = 3
    case tenSeconds = 10
}

protocol CameraViewControllerDelegate: AnyObject {
    func didToggleCameraMode(_ cameraMode: CameraMode)
    func didToggleCameraPosition(_ cameraPosition: CameraPosition)
    func didUpdateDuration(_ duration: CGFloat)
    func didUpdateCameraStatus(_ cameraStatus: CameraProcessStatus)
    func didAddLumeContent(_ lumeContent: LumeContent)
    func didRemoveLumeContent(_ lumeContent: LumeContent)
}

class CameraViewController: UIViewController {
    
    private var captureSession: AVCaptureSession = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let cameraView = UIView()
    private var currentDevice: AVCaptureDevice?
    private var currentZoomFactor: CGFloat = 1.6
    private let minZoomFactor: CGFloat = 1.0
    private var maxZoomFactor: CGFloat = 5.0
    private var addBottomShadow: Bool = false
    
    private var wideCamera: AVCaptureDevice?
    private var telephotoCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    
    private let toggleCameraButton = UIButton(type: .system)
    
    private var photoOutput = AVCapturePhotoOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    public var isRecording = false
//    {
//        didSet {
//            delegate?.didUpdateRecordStatus(self.isRecording)
//        }
//    }
    private var recordedURLs: [URL] = []
    private var previewURL: URL?
    private var saveImageToLibrary: Bool = false
    
    private var recordedDuration: CGFloat = 0.0
    private var recordingTimer: Timer?
    private var maxRecordingDuration: CGFloat = 60.0  // Max duration in seconds (1:30 minutes)
    
    private var cameraPermissionChecked: Bool = false
    
    public var cameraMode: CameraMode = .video {
        didSet {
            delegate?.didUpdateDuration(self.recordedDuration)
            delegate?.didToggleCameraMode(self.cameraMode)
            
            removeExistingOutputs()
            
            if cameraMode == .photo {
                configurePhotoOutput()
            } else {
                configureVideoOutput()
            }
        }
    }
    public var currentCameraType: CameraType = .wide {
        didSet {
            switchCameraType(to: currentCameraType, position: currentCameraPosition)
        }
    }
    public var currentCameraPosition: CameraPosition = .back {
        didSet {
            switchCameraType(to: currentCameraType, position: currentCameraPosition)
        }
    }
    public var currentCameraProcessStatus: CameraProcessStatus = .prepping {
        didSet {
            print("CameraProcessStat: \(self.currentCameraProcessStatus)")
        }
    }
    
    private let previewButton = UIButton(type: .system)
    
    public var content: [LumeContent] = []
    
    weak var delegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray
        
        checkCameraPermission()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure the session is configured properly
        if captureSession.inputs.isEmpty {
            configureCameraSession(type: currentCameraType, position: .back)
        }
        
        // Ensure the session is running
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func checkCameraPermission() {
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.checkAudioPermission()
                } else {
                    DispatchQueue.main.async {
                        self.showPermissionAlert()
                    }
                }
            }
        case .authorized:
            self.configureAudioSession()
            self.checkAudioPermission()
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            updateCameraProcessStatus(.camerError)
            fatalError("Unknown camera authorization status")
        }
    }
    
    func checkAudioPermission() {
        let audioAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch audioAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCamera()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showPermissionAlert()
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                self.setupCamera()
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            updateCameraProcessStatus(.audioError)
            fatalError("Unknown audio authorization status")
        }
    }
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Permission Required", message: "Please allow camera access in Settings to use the camera features.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupCamera() {
        detectAvailableCameras()
        configureCameraSession(type: .wide, position: .back)
        setupUI()
        addPinchGestureRecognizer()
        addTapToFocusGestureRecognizer()
        addDoubleTapToFlipGestureRecognizer()
    }
    
    func configureCameraView() {
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.frame = view.frame
        cameraView.layer.cornerRadius = 30
        cameraView.layer.masksToBounds = true
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    func detectAvailableCameras() {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera, .builtInUltraWideCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified).devices
        
        for device in devices {
            if device.deviceType == .builtInWideAngleCamera && device.position == .back {
                wideCamera = device
            } else if device.deviceType == .builtInTelephotoCamera {
                telephotoCamera = device
            } else if device.deviceType == .builtInUltraWideCamera {
                ultraWideCamera = device
            } else if device.deviceType == .builtInWideAngleCamera && device.position == .front {
                frontCamera = device
            }
        }
        
        currentDevice = wideCamera
    }
    
    func configureCameraSession(type: CameraType, position: AVCaptureDevice.Position) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                self.captureSession.beginConfiguration()
                
                // Add video input
                let deviceType: AVCaptureDevice.DeviceType
                switch type {
                case .ultraWide:
                    deviceType = .builtInUltraWideCamera
                case .wide:
                    deviceType = .builtInWideAngleCamera
                case .telephoto:
                    deviceType = .builtInTelephotoCamera
                }
                
                guard let cameraDevice = AVCaptureDevice.default(deviceType, for: .video, position: position) else {
                    print("Requested camera not available")
                    return
                }
                
                let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
                
                // Remove all inputs before adding new ones
                for input in self.captureSession.inputs {
                    self.captureSession.removeInput(input)
                }
                
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                    self.currentDevice = cameraDevice
                }
                
                // Add audio input
                if let audioDevice = AVCaptureDevice.default(for: .audio) {
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                    if self.captureSession.canAddInput(audioInput) {
                        self.captureSession.addInput(audioInput)
                    } else {
                        print("Could not add audio input")
                    }
                } else {
                    print("No audio device available")
                }
                
                self.setupFrameRate(cameraDevice: cameraDevice)
                
                if cameraMode == .photo {
                    configurePhotoOutput()
                } else {
                    configureVideoOutput()
                }
                
                // Commit configuration changes before starting the session
                self.captureSession.commitConfiguration()

                // Start the session after configuration is done
                self.startCamera()
                
                self.setupPreviewLayer()

            } catch {
                print("Error configuring camera: \(error.localizedDescription)")
            }
        }
    }

    private func setupFrameRate(cameraDevice: AVCaptureDevice) {
        // Configure the video device to use 60 FPS if supported
        do{
            try cameraDevice.lockForConfiguration()
            if let bestFormat = self.findBestFormat(for: cameraDevice, frameRate: 60) {
                cameraDevice.activeFormat = bestFormat
                cameraDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
                cameraDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
            } else {
                print("60 FPS is not supported on this device.")
            }
            cameraDevice.unlockForConfiguration()
            
            // Check for supported frame rates
            let supportedFrameRates = cameraDevice.activeFormat.videoSupportedFrameRateRanges
            guard let firstSupportedFrameRateRange = supportedFrameRates.first else {
                print("No supported frame rates available.")
                return
            }
            let maxSupportedFrameRate = firstSupportedFrameRateRange.maxFrameRate

            if let bestFormat = self.findBestFormat(for: cameraDevice, frameRate: 60) {
                try cameraDevice.lockForConfiguration()
                cameraDevice.activeFormat = bestFormat
                if maxSupportedFrameRate >= 60 {
                    // 60 fps supported, setting frame duration
                    cameraDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
                    cameraDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
                } else {
                    // Fallback to the highest supported frame rate within range
                    cameraDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: Int32(maxSupportedFrameRate))
                    cameraDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: Int32(maxSupportedFrameRate))
                    print("60 fps not supported, using \(maxSupportedFrameRate) fps instead.")
                }
                cameraDevice.unlockForConfiguration()
            }
        } catch {
            print(error)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = cameraView.bounds
    }
}

extension CameraViewController {
    
    private func updateCameraProcessStatus(_ cameraStatus: CameraProcessStatus) {
        self.currentCameraProcessStatus = cameraStatus
        delegate?.didUpdateCameraStatus(self.currentCameraProcessStatus)
    }
}

extension CameraViewController {

    func startCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Ensure the capture session is not already running
            guard !self.captureSession.isRunning else { return }
            
            // Commit any configuration changes if necessary
            self.captureSession.commitConfiguration()
            
            // Safely start the capture session
            self.captureSession.startRunning()
        }
    }

    func stopCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Ensure the capture session is running
            guard self.captureSession.isRunning else { return }
            
            // Safely stop the capture session
            self.captureSession.stopRunning()
        }
    }
}

// MARK: - UI
extension CameraViewController {
    
    func setupPreviewLayer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Remove any existing preview layer before setting up a new one
            self.videoPreviewLayer?.removeFromSuperlayer()
            
            // Create a new preview layer with the capture session
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer?.videoGravity = .resizeAspectFill
            self.videoPreviewLayer?.frame = self.cameraView.bounds
            
            // Add the preview layer to the view
            self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
            
            // Start the capture session on a background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func setupUI() {
        view.addSubview(cameraView)
        cameraView.frame = view.bounds
        addFadeOutLayer()
//        setupPreviewButton()
        updateCameraProcessStatus(.ready)
    }
    
//    func setupPreviewButton() {
//        previewButton.setTitle("Preview", for: .normal)
//        previewButton.isHidden = true
//        previewButton.addTarget(self, action: #selector(previewMergedVideo), for: .touchUpInside)
//        previewButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(previewButton)
//        NSLayoutConstraint.activate([
//            previewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
//            previewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
//        ])
//    }
//    
//    @objc func previewMergedVideo() {
//        guard let previewURL = previewURL else { return }
//        
//        let player = AVPlayer(url: previewURL)
//        let playerViewController = AVPlayerViewController()
//        
//        playerViewController.player = player
//        present(playerViewController, animated: true) {
//            playerViewController.player?.play()
//        }
//    }
    
    func saveVideo() -> LumeContent? {
        guard let previewURL = previewURL else { return nil }
        
        var lumeVideo = LumeContent.video(LumeVideo(player: AVPlayer(url: previewURL)))
        lumeVideo.setAuthenticity(to: true)
        content.append(lumeVideo)
        
        // Notify delegate that content has been added
        delegate?.didAddLumeContent(lumeVideo)
        
        recordedURLs.removeAll()
        self.previewURL = nil
        recordedDuration = 0.0
        delegate?.didUpdateDuration(recordedDuration)
        
        updateCameraProcessStatus(.ready)
        
        return lumeVideo
    }
    
    private func addFadeOutLayer() {
        
        guard addBottomShadow else { return }
        
        let fadeLayer = CAGradientLayer()

        // Visible colors for fade
        fadeLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor  // Adjusted for better visibility
        ]
        
        fadeLayer.locations = [0.0, 1.0]
        fadeLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        fadeLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        fadeLayer.frame = CGRect(
            x: 0,
            y: view.frame.height * 0.8,
            width: view.frame.width,
            height: view.frame.height * 0.2
        )

        view.layer.addSublayer(fadeLayer)
    }
}

// MARK: - capture selection and UI
extension CameraViewController {
    
    @objc func captureAction() {
        switch cameraMode {
        case .photo:
            capturePhoto()
        case .video:
            toggleRecording() // Use a new method to toggle recording status
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc func toggleCameraMode() {
        delegate?.didUpdateDuration(self.recordedDuration)
        cameraMode = cameraMode == .photo ? .video : .photo
        
        removeExistingOutputs()
        
        if cameraMode == .photo {
            configurePhotoOutput()
        } else {
            configureVideoOutput()
        }
    }
    
    private func removeExistingOutputs() {
        // Remove photo output if it exists
        if captureSession.outputs.contains(photoOutput) {
            captureSession.removeOutput(photoOutput)
        }
        
        // Remove video output if it exists
        if captureSession.outputs.contains(movieOutput) {
            captureSession.removeOutput(movieOutput)
        }
    }
    
    func setCameraMode(_ cameraMode: CameraMode) {
        delegate?.didUpdateDuration(self.recordedDuration)
        self.cameraMode = cameraMode
        view.layoutIfNeeded()
    }
    
    func updateUIAfterRecording() {
        if !recordedURLs.isEmpty {
            previewButton.isHidden = false
        }
    }
    
    func recordedVideoCount() -> Int {
        return self.recordedURLs.count
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    private func configurePhotoOutput() {
        
        // Add photo output to the capture session if possible
        if self.captureSession.canAddOutput(self.photoOutput) {
            self.captureSession.addOutput(self.photoOutput)
            print("Photo output added to the capture session.")
        } else {
            print("Error: Could not add photo output to the capture session.")
        }
        
        // Ensure the current device is available
        guard let currentDevice = self.currentDevice else {
            print("Error: Current device is not available.")
            return
        }
        
        // Get the supported maximum photo dimensions for the current format
        let supportedMaxPhotoDimensions = currentDevice.activeFormat.supportedMaxPhotoDimensions
        if let largestDimension = supportedMaxPhotoDimensions.last {
            self.photoOutput.maxPhotoDimensions = largestDimension
            print("Photo output configured with the largest dimension: \(largestDimension).")
        } else {
            print("Error: Could not determine the largest dimension.")
            return
        }
        
        self.photoOutput.maxPhotoQualityPrioritization = .quality
        
        // Enable Live Photo capture if supported
//        if self.photoOutput.isLivePhotoCaptureSupported {
//            self.photoOutput.isLivePhotoCaptureEnabled = true
//            print("Live Photo capture is enabled.")
//        } else {
//            self.photoOutput.isLivePhotoCaptureEnabled = false
//            print("Live Photo capture is not supported on this device.")
//        }
        
//        // Set the flash mode based on device capabilities
//        if currentDevice.isFlashAvailable {
//            self.photoOutput.photoSettingsForSceneMonitoring?.flashMode = .auto
//        }
    }

    @objc func capturePhoto() {
        var settings: AVCapturePhotoSettings
        
        // Configure settings based on available codecs
        if photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
            settings = AVCapturePhotoSettings(format: [
                AVVideoCodecKey: AVVideoCodecType.jpeg
            ])
        } else if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [
                AVVideoCodecKey: AVVideoCodecType.hevc
            ])
        } else {
            // Default to system settings if specific formats are unavailable
            settings = AVCapturePhotoSettings()
        }
        
        // Set maximum photo dimensions instead of high resolution
        if let currentDevice = currentDevice {
            if let largestDimension = currentDevice.activeFormat.supportedMaxPhotoDimensions.last {
                settings.maxPhotoDimensions = largestDimension
            }
        }
        
        // Capture the photo with the specified settings
        photoOutput.capturePhoto(with: settings, delegate: self)
        updateCameraProcessStatus(.ready)
    }
    
    @objc private func captureLivePhoto() {
        guard photoOutput.connection(with: .video) != nil else { return }

        let settings = AVCapturePhotoSettings()
        
        let supportedMaxPhotoDimensions = self.currentDevice?.activeFormat.supportedMaxPhotoDimensions
        let largestDimesnion = supportedMaxPhotoDimensions?.last
        
        settings.maxPhotoDimensions = largestDimesnion!
        
        if photoOutput.isLivePhotoCaptureSupported {
            let livePhotoFileName = UUID().uuidString
            let livePhotoDirectory = FileManager.default.temporaryDirectory
            let livePhotoFileURL = livePhotoDirectory.appendingPathComponent(livePhotoFileName)
            settings.livePhotoMovieFileURL = livePhotoFileURL
        }

        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
        } else if let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) {
            // Create LumeContent from the captured image
            var lumeImage = LumeContent.image(LumeImage(image: image))
            lumeImage.setAuthenticity(to: true)
            content.append(lumeImage)
            
            // Notify the delegate that a new LumeContent (image) has been added
            delegate?.didAddLumeContent(lumeImage)
            
            // Optionally save the image to the library
            if saveImageToLibrary {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Handle the completion of Live Photo capture
        print("Live Photo captured at \(outputFileURL)")
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func configureVideoOutput() {
        captureSession.beginConfiguration()
        
        movieOutput = AVCaptureMovieFileOutput()
        
        // Set a maximum duration for the recording if desired
        movieOutput.maxRecordedDuration = CMTimeMake(value: 300, timescale: 1) // 5 minutes max

        // Ensure the session can add the movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        } else {
            print("Could not add movie output to capture session")
            updateCameraProcessStatus(.camerError)
            return
        }

        // Configure the connection
        if let connection = movieOutput.connection(with: .video) {
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto  // Best stabilization option
            }
            
            // Set video orientation to match the current device orientation
            connection.videoOrientation = currentVideoOrientation()
        }

        captureSession.commitConfiguration()
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        let deviceOrientation = UIDevice.current.orientation

        switch deviceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight // Note: This is flipped because when the device is landscapeLeft, the home button is on the right.
        case .landscapeRight:
            return .landscapeLeft // Note: This is flipped because when the device is landscapeRight, the home button is on the left.
        default:
            return .portrait
        }
    }
    
    func findBestFormat(for device: AVCaptureDevice, frameRate: Int32) -> AVCaptureDevice.Format? {
        let formats = device.formats
        var bestFormat: AVCaptureDevice.Format?
        var maxDimensions: CMVideoDimensions = CMVideoDimensions(width: 0, height: 0)
        
        for format in formats {
            for range in format.videoSupportedFrameRateRanges {
                let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
                if range.minFrameRate <= Float64(frameRate) && range.maxFrameRate >= Float64(frameRate) {
                    if bestFormat == nil || (dimensions.width >= maxDimensions.width && dimensions.height >= maxDimensions.height) {
                        bestFormat = format
                        maxDimensions = dimensions
                    }
                }
            }
        }
        
        return bestFormat
    }
    
    func startRecording() {
        updateCameraProcessStatus(.recording)
        isRecording = true
        startRecordingTimer()
        let outputPath = NSTemporaryDirectory() + "output-\(UUID().uuidString).mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        movieOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }
    
    func stopRecording(isCameraSwitch: Bool = false) {
        updateCameraProcessStatus(isCameraSwitch ? .toggling : .processing)
        isRecording = isCameraSwitch
        stopRecordingTimer()
        if let currentOutputFileURL = movieOutput.outputFileURL {
            recordedURLs.append(currentOutputFileURL)
        }
        movieOutput.stopRecording()
    }
    
    // Timer methods
    func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            self.recordedDuration += 0.25
            let progress = self.recordedDuration / self.maxRecordingDuration
            
            delegate?.didUpdateDuration(progress)
            
            if self.recordedDuration >= self.maxRecordingDuration {
                // Stop recording when the max duration is reached
                self.stopRecording()
            }
        }
    }
    
    func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // Video created successfully
        let finalOutputURL = outputFileURL
        
        if self.recordedURLs.count == 1 {
            self.previewURL = finalOutputURL
            updateUIAfterRecording()  // Call here to ensure the UI updates
            updateCameraProcessStatus(.ready)
            return
        }
        
        // Convert URLs to assets
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }
        
        self.previewURL = nil
        
        if !isRecording {
            DispatchQueue.main.async {
                self.mergeVideos(assets: assets)
            }
        }
    }
    
    func mergeVideos(assets: [AVURLAsset]) {
        Task.init {
            do {
                self.updateCameraProcessStatus(.processing)
                let exporter = try await mergeVideosProcess(assets: assets)
                let finalURL = try await exportVideo(exporter: exporter)
                
                DispatchQueue.main.async {
                    self.previewURL = finalURL
                    self.updateUIAfterRecording()  // Update UI after successful export
                    self.updateCameraProcessStatus(.ready)
                }
            } catch {
                // Handle error
                print(error)
            }
        }
    }
    
    func exportVideo(exporter: AVAssetExportSession) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            exporter.exportAsynchronously {
                switch exporter.status {
                case .completed:
                    print("Export completed successfully")
                    self.updateCameraProcessStatus(.ready)
                    if let finalURL = exporter.outputURL {
                        continuation.resume(returning: finalURL)
                    }
                case .failed:
                    if let error = exporter.error {
                        print("Export failed with error: \(error.localizedDescription)")
                        self.updateCameraProcessStatus(.error)
                        continuation.resume(throwing: error)
                    }
                case .cancelled:
                    print("Export was cancelled")
                    self.updateCameraProcessStatus(.error)
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"]))
                default:
                    print("Export in progress or unknown status")
                    self.updateCameraProcessStatus(.error)
                }
            }

        }
    }
    
    func mergeVideosProcess(assets: [AVURLAsset]) async throws -> AVAssetExportSession {
        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero
        let targetFrameRate: Float64 = 60.0  // Targeting 60 FPS
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create video track"])
        }
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create audio track"])
        }
        
        for (_, asset) in assets.enumerated() {
            do {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                let audioTracks = try await asset.loadTracks(withMediaType: .audio)
                let duration = try await asset.load(.duration)
                
                guard let videoAssetTrack = videoTracks.first else {
                    continue
                }
                
                // Check the asset's nominal frame rate
                let nominalFrameRate: Float = try await videoAssetTrack.load(.nominalFrameRate)
                if Double(nominalFrameRate) < targetFrameRate {
                    print("Warning: Asset frame rate is lower than 60 fps (\(nominalFrameRate) fps). Adjusting...")
                }
                
                let timeRange = CMTimeRange(start: .zero, duration: duration)
                try videoTrack.insertTimeRange(timeRange, of: videoAssetTrack, at: lastTime)
                if let audioAssetTrack = audioTracks.first {
                    try audioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: lastTime)
                }
                lastTime = CMTimeAdd(lastTime, duration)
            } catch {
                print("Error processing asset: \(asset.url), error: \(error.localizedDescription)")
                throw error
            }
        }
        
        // Temp Output URL
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "Lume-\(UUID().uuidString).mp4")
        
        // Create a video composition to enforce 60 FPS and apply the rotation
        let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(targetFrameRate))
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // Apply rotation transform for 90 degrees clockwise with origin at the center
        let rotationTransform = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0)
            .rotated(by: .pi / 2)
        
        layerInstruction.setTransform(rotationTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Create an export session with enforced 60 FPS
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"])
        }
        
        exporter.outputFileType = .mp4
        exporter.outputURL = tempURL
        exporter.videoComposition = videoComposition
        
        // Set the expected frame rate for the export
        exporter.videoComposition = videoComposition
        exporter.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        
        return exporter
    }

    func removeLastVideo() {
        // Check if there is more than one video recorded
        guard recordedURLs.count > 1 else { return }
        
        updateCameraProcessStatus(.processing)
        
        // Remove the last video URL
        recordedURLs.removeLast()
        
        // Merge the remaining videos
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }
        
        Task.init {
            do {
                let exporter = try await mergeVideosProcess(assets: assets)
                let finalURL = try await exportVideo(exporter: exporter)
                
                DispatchQueue.main.async {
                    self.previewURL = finalURL
                    
                    // Update the total duration of the final merged video
                    let asset = AVURLAsset(url: finalURL)
                    Task.init {
                        do {
                            let duration = try await asset.load(.duration)
                            withAnimation {
                                self.recordedDuration = CGFloat(CMTimeGetSeconds(duration))
                                self.updateCameraProcessStatus(.ready)
                            }
                        } catch {
                            print("Failed to load duration: \(error)")
                        }
                    }
                }
            } catch {
                // Handle error
                print(error)
            }
        }
    }
}

// MARK: - double tap flip camera
extension CameraViewController {
    
    func addDoubleTapToFlipGestureRecognizer() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToFlip(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        cameraView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc func handleDoubleTapToFlip(_ gesture: UITapGestureRecognizer) {
        currentZoomFactor = 1.0
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        delegate?.didToggleCameraPosition(currentCameraPosition)
    }
}

// MARK: - single tap focus
extension CameraViewController {
    
    func addTapToFocusGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapToFocus(_:)))
        cameraView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTapToFocus(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: cameraView)
        
        guard let device = currentDevice else {
            print("Error: Could not fetch current device")
            return
        }
        
        do {
            try device.lockForConfiguration()
            
            // Convert the touch point to a focus point in the camera's coordinate system
            let focusPoint = CGPoint(x: touchPoint.x / cameraView.frame.width, y: touchPoint.y / cameraView.frame.height)
            
            // Set the focus and exposure modes
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Failed to configure focus: \(error)")
        }
    }
}

// MARK: - pinch to zoom
extension CameraViewController {
    
    func addPinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        cameraView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard currentDevice != nil else { return }

        if gesture.state == .changed {
            let desiredZoomFactor = currentZoomFactor * gesture.scale
            let clampedZoomFactor = min(max(desiredZoomFactor, 1.0), 7.0)
            
            if currentCameraPosition == .front {
                // Apply zoom directly for front camera
                applyZoomFactor(clampedZoomFactor)
            } else {
                // Handle rear cameras with smoother transitions
                let mappedZoomFactor: CGFloat

                switch clampedZoomFactor {
                case 1.0..<1.5:
                    if currentCameraType != .ultraWide {
                        currentCameraType = .ultraWide
                    }
                    mappedZoomFactor = remapZoomFactor(clampedZoomFactor, fromRangeMin: 1.0, fromRangeMax: 1.5, toRangeMin: 1.0, toRangeMax: 2.5)
                    
                case 1.5..<4.0:
                    if currentCameraType != .wide {
                        currentCameraType = .wide
                    }
                    mappedZoomFactor = remapZoomFactor(clampedZoomFactor, fromRangeMin: 1.5, fromRangeMax: 4.0, toRangeMin: 1.0, toRangeMax: 4.0)
                    
                case 4.0...7.0:
                    if currentCameraType != .telephoto {
                        currentCameraType = .telephoto
                    }
                    mappedZoomFactor = remapZoomFactor(clampedZoomFactor, fromRangeMin: 4.0, fromRangeMax: 7.0, toRangeMin: 1.0, toRangeMax: 5.0)
                    
                default:
                    mappedZoomFactor = clampedZoomFactor
                }

                applyZoomFactor(mappedZoomFactor)
            }
            
            currentZoomFactor = clampedZoomFactor
        }

        gesture.scale = 1.0
    }

    func remapZoomFactor(_ zoomFactor: CGFloat, fromRangeMin: CGFloat, fromRangeMax: CGFloat, toRangeMin: CGFloat, toRangeMax: CGFloat) -> CGFloat {
        return toRangeMin + (zoomFactor - fromRangeMin) * (toRangeMax - toRangeMin) / (fromRangeMax - fromRangeMin)
    }
    
    func switchCameraType(to type: CameraType, position: CameraPosition) {
        // Stop the ongoing recording if it's in progress
        if isRecording {
            stopRecording(isCameraSwitch: true)
            performCameraSwitch(to: type, position: position)
            startRecording()
        } else {
            performCameraSwitch(to: type, position: position)
        }
    }

    func performCameraSwitch(to type: CameraType, position: CameraPosition) {
        guard let currentDevice = currentDevice else { return }
        
        // Determine the device based on the requested type and position
        let newDevice: AVCaptureDevice?
        
        switch position {
        case .front:
            newDevice = frontCamera
        case .back:
            switch type {
            case .ultraWide:
                newDevice = ultraWideCamera
            case .wide:
                newDevice = wideCamera
            case .telephoto:
                newDevice = telephotoCamera
            }
        }
        
        guard let device = newDevice, device != currentDevice else {
            print("Requested camera not available or already in use")
            return
        }
        
        do {
            // Begin reconfiguration of the capture session
            captureSession.beginConfiguration()
            
            // Remove the old input, add the new input
            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
                captureSession.removeInput(currentInput)
            }
            
            let newInput = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
                self.currentDevice = device
                
                // Configure the video device to use 60 FPS if supported
                try device.lockForConfiguration()
                if let bestFormat = self.findBestFormat(for: device, frameRate: 60) {
                    device.activeFormat = bestFormat
                    device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
                    device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
                } else {
                    print("60 FPS is not supported on this device.")
                }
                device.unlockForConfiguration()
            }
//            
//            // Re-add the audio input if it was removed
//            if let audioDevice = AVCaptureDevice.default(for: .audio) {
//                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
//                if captureSession.canAddInput(audioInput) {
//                    captureSession.addInput(audioInput)
//                    print("Audio input re-added successfully after camera switch.")
//                } else {
//                    print("Failed to re-add audio input after camera switch.")
//                }
//            }
//            
            // Commit the configuration to apply changes
            captureSession.commitConfiguration()
            
        } catch {
            print("Failed to switch camera: \(error)")
        }
    }

    func getCameraDevice(for type: CameraType) -> AVCaptureDevice? {
        switch type {
        case .ultraWide:
            return ultraWideCamera
        case .wide:
            return wideCamera
        case .telephoto:
            return telephotoCamera
        }
    }
    
    func switchToNextCamera() {
        // Reset the zoom factor when switching cameras
        currentZoomFactor = 1.0
        
        // Determine the next camera to switch to based on the current device
        if currentDevice == wideCamera {
            currentCameraType = .telephoto
        } else if currentDevice == telephotoCamera {
            currentCameraType = .ultraWide
        } else if currentDevice == ultraWideCamera {
            currentCameraType = .wide
        }
    }
    
    func applyZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Failed to set zoom factor: \(error)")
        }
    }
}

// MARK: - Audio
extension CameraViewController {
    func stripAudioFromVideo(at videoURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                // Create an AVAsset from the video URL
                let asset = AVURLAsset(url: videoURL)

                // Check if the asset has a video track
                guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                    throw NSError(domain: "com.nucr.gotdns.org.Lumena", code: 0, userInfo: [NSLocalizedDescriptionKey: "The video doesn't have a video track."])
                }

                // Create a composition to hold the video track without audio
                let composition = AVMutableComposition()
                let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)

                // Insert the video track into the composition
                try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: try await asset.load(.duration)), of: videoTrack, at: .zero)

                // Create an export session to save the composition as a new video
                guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                    throw NSError(domain: "com.nucr.gotdns.org.Lumena", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session."])
                }

                // Create a URL for the new video
                let newVideoURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("strippedVideo.mp4")

                // Configure the export session
                exportSession.outputFileType = .mp4
                exportSession.outputURL = newVideoURL

                // Perform the export asynchronously
                let exportStatus = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<AVAssetExportSession.Status, Error>) in
                    exportSession.exportAsynchronously {
                        if let error = exportSession.error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: exportSession.status)
                        }
                    }
                }

                // Check the export status and return the appropriate result
                switch exportStatus {
                case .completed:
                    completion(.success(newVideoURL))
                case .failed, .cancelled:
                    let errorDescription = exportSession.error?.localizedDescription ?? "Video export failed."
                    let error = NSError(domain: "com.nucr.gotdns.org.Lumena", code: 0, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                    completion(.failure(error))
                default:
                    let error = NSError(domain: "com.nucr.gotdns.org.Lumena", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown export error."])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - flash light
extension CameraViewController {
    func setFlashlight(level: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            print("Device does not support flashlight functionality")
            return
        }
        
        do {
            try device.lockForConfiguration()
            if level > 0 {
                try device.setTorchModeOn(level: Float(level))
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to set flashlight level: \(error)")
        }
    }
}
