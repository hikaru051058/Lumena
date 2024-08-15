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

protocol CameraViewControllerDelegate: AnyObject {
    func didToggleCameraMode(_ cameraMode: CameraMode)
    func didUpdateDuration(_ duration: CGFloat)
    func didUpdateCameraStatus(_ cameraStatus: CameraProcessStatus)
    func didUpdateLumeContent(_ lumeContent: [LumeContent])
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
    
    private var recordedDuration: CGFloat = 0.0
    private var recordingTimer: Timer?
    private var maxRecordingDuration: CGFloat = 60.0  // Max duration in seconds (1:30 minutes)
    
    public var cameraMode: CameraMode = .video {
        didSet {
            delegate?.didUpdateDuration(self.recordedDuration)
            delegate?.didToggleCameraMode(self.cameraMode)
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
    
    public var content: [LumeContent] = [] {
        didSet {
            delegate?.didUpdateLumeContent(self.content)
        }
    }
    
    weak var delegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check camera permission
        checkCameraPermission()
        
        // Setup the UI
        setupUI()
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
        DispatchQueue.main.async { [weak self] in
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
                    }
                }
                
                // Set up outputs
                if self.captureSession.canAddOutput(self.movieOutput) {
                    self.captureSession.addOutput(self.movieOutput)
                }
                
                if self.captureSession.canAddOutput(self.photoOutput) {
                    self.captureSession.addOutput(self.photoOutput)
                }
                
                self.captureSession.commitConfiguration()
                
                self.setupPreviewLayer()
                
            } catch {
                print("Error configuring camera: \(error.localizedDescription)")
            }
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


// MARK: - UI
extension CameraViewController {
    
    func setupPreviewLayer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Ensure that all UI-related tasks are performed on the main thread
            self.videoPreviewLayer?.removeFromSuperlayer()
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.videoPreviewLayer?.videoGravity = .resizeAspectFill
            self.videoPreviewLayer?.frame = self.cameraView.bounds
            self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
            
            // Start the session on a background thread to avoid UI blocking
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func setupUI() {
        view.addSubview(cameraView)
        cameraView.frame = view.bounds
        addFadeOutLayer()
        setupPreviewButton()
        updateCameraProcessStatus(.ready)
    }
    
    func setupPreviewButton() {
        previewButton.setTitle("Preview", for: .normal)
        previewButton.isHidden = true
        previewButton.addTarget(self, action: #selector(previewMergedVideo), for: .touchUpInside)
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewButton)
        NSLayoutConstraint.activate([
            previewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            previewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    @objc func previewMergedVideo() {
        guard let previewURL = previewURL else { return }
        
        let player = AVPlayer(url: previewURL)
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
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
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }
    }
    
    @objc func toggleCameraMode() {
        delegate?.didUpdateDuration(self.recordedDuration)
        cameraMode = cameraMode == .photo ? .video : .photo
        view.layoutIfNeeded()
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
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    @objc func capturePhoto() {
        let formats = photoOutput.supportedPhotoPixelFormatTypes(for: .tif)
        
        if let uncompressedPixelType = formats.first {
            let settings = AVCapturePhotoSettings(format: [
                kCVPixelBufferPixelFormatTypeKey as String : uncompressedPixelType
            ])
            photoOutput.capturePhoto(with: settings, delegate: self)
            updateCameraProcessStatus(.ready)
        } else {
            print("No pixel format types available for TIFF")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
        } else if let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) {
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let temporaryFilename = ProcessInfo().globallyUniqueString + ".jpg"
            _ = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            content.append(.image(LumeImage(image: image)))
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
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
                let exporter = try await mergeVideosProcess(assets: assets)
                let finalURL = try await exportVideo(exporter: exporter)
                
                DispatchQueue.main.async {
                    self.previewURL = finalURL
                    self.updateUIAfterRecording()  // Update UI after successful export
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
                
                guard !videoTracks.isEmpty else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No video tracks found in asset at \(asset.url.absoluteString)"])
                }

                // Directly use the time range without scaling
                let timeRange = CMTimeRange(start: .zero, duration: duration)
                
                try videoTrack.insertTimeRange(timeRange, of: videoTracks[0], at: lastTime)
                print("Inserted video track at time: \(CMTimeGetSeconds(lastTime))")
                
                // Safe Check if Video has Audio
                if !audioTracks.isEmpty {
                    try audioTrack.insertTimeRange(timeRange, of: audioTracks[0], at: lastTime)
                    print("Inserted audio track at time: \(CMTimeGetSeconds(lastTime))")
                } else {
                    print("No audio tracks found for this asset.")
                }
                
                // Update last time to keep track of the total duration
                lastTime = CMTimeAdd(lastTime, duration)
            } catch {
                print("Error processing asset: \(asset.url), error: \(error.localizedDescription)")
                throw error
            }
        }
        
        // Ensure the composition has content before proceeding
        guard composition.tracks.count > 0 else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No valid tracks found in the composition."])
        }
        
        // MARK: Temp Output URL
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "Lume-\(Date()).mp4")
        
        // Create a video composition to apply the rotation
        let videoComposition = AVMutableVideoComposition()
        
        // Rotate the frame by 90 degrees
        let videoSize = videoTrack.naturalSize
        videoComposition.renderSize = CGSize(width: videoSize.height, height: videoSize.width)
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // Apply 90-degree rotation at the center without translating
        let rotationTransform = CGAffineTransform(translationX: videoSize.height, y: 0)
            .rotated(by: .pi / 2)
        
        layerInstruction.setTransform(rotationTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        // Create an export session
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"])
        }
        
        exporter.outputFileType = .mov
        exporter.outputURL = tempURL
        exporter.videoComposition = videoComposition
        
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
                    if let unwrappedPreviewURL = self.previewURL {
                        print("\(unwrappedPreviewURL) : \(finalURL)")
                        self.previewURL = unwrappedPreviewURL
                    } else {
                        print("\(finalURL) : nil")
                        self.previewURL = finalURL
                    }
                    
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
            }
            
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
    func setFlashlight(level: Float) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            print("Device does not support flashlight functionality")
            return
        }
        
        do {
            try device.lockForConfiguration()
            if level > 0 {
                try device.setTorchModeOn(level: level)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to set flashlight level: \(error)")
        }
    }
}
