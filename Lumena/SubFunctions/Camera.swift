//
//  Camera.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/25.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation
import AVKit

class CameraViewModel: NSObject,ObservableObject,AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate{
    @Published var session: AVCaptureSession
    @Published var alert = false
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview : AVCaptureVideoPreviewLayer?
    
    
    // MARK: Video Recorder Properties
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    @Published var useMic: Bool = true
    
    // Top Progress Bar
    @Published var recordedDuration: CGFloat = 0
    // YOUR OWN TIMING
    @Published var maxDuration: CGFloat = 20
    
    @Published var currentZoomScale: CGFloat = 1.0
    
    @Published var currentCameraType: CameraType = .ultraWide
    @Published var currentCameraPosition: CameraPosition = .back
    
    @Published var showLight = false
    
    //Picture
    var photoOutput = AVCapturePhotoOutput()
    @Published var capturedImage: UIImage?
    @Published var onImageCaptured: ((UIImage) -> Void)?
    
    init(session: AVCaptureSession) {
        self.session = session
        super.init()
        self.preview = AVCaptureVideoPreviewLayer(session: session)
        // Additional setup...
    }
    
    func checkPermission() {

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setUp()
            }
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (status) in
                DispatchQueue.main.async {
                    if status {
                        self?.setUp()
                    } else {
                        self?.alert = true // Ensure this update is also on the main thread
                    }
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp(type: CameraType = .wide, position: AVCaptureDevice.Position = .back) {
        DispatchQueue.main.async { [weak self] in
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                self.session.beginConfiguration()
                
                let deviceType: AVCaptureDevice.DeviceType
                switch type {
                case .ultraWide:
                    deviceType = .builtInUltraWideCamera
                case .wide:
                    deviceType = .builtInWideAngleCamera
                case .telephoto:
                    deviceType = .builtInTelephotoCamera
                }
                
                DispatchQueue.main.async {
                    self.currentCameraType = type
                }
                
                // Check if the requested camera is available
                if AVCaptureDevice.default(deviceType, for: .video, position: position) == nil {
                    print("Requested camera not available")
                    
                    // If not, revert to wide camera as default
                    currentCameraType = .wide
                    guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) != nil else {
                        print("Wide camera not available")
                        return
                    }
                }
                
                guard let cameraDevice = AVCaptureDevice.default(deviceType, for: .video, position: position) else {
                    print("Requested camera not available")
                    return
                }
                
                let videoInput = try AVCaptureDeviceInput(device: cameraDevice)
                let audioDevice = AVCaptureDevice.default(for: .audio)
                let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
                
                // Remove all inputs before adding a new one
                for input in self.session.inputs {
                    self.session.removeInput(input)
                }
                
                if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput) {
                    self.session.addInput(videoInput)
                    self.session.addInput(audioInput)
                    
                    // Set the zoom scale to 1.0 when switching cameras
                    do {
                        try videoInput.device.lockForConfiguration()
                        
                        if(currentCameraType == .telephoto){
                            videoInput.device.videoZoomFactor = 1.5
                        } else {
                            videoInput.device.videoZoomFactor = 1.0
                        }
                        videoInput.device.unlockForConfiguration()
                    } catch {
                        print("Failed to set videoZoomFactor: \(error)")
                    }
                }
                
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                
                if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                } else {
                    print("Could not add photo output to session")
                }
                
                self.session.commitConfiguration()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func startRecording(){
        // MARK: Temporary URL for recording Video
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording(){
        output.stopRecording()
        isRecording = false
    }
    
    func takePhoto() {
        let formats = photoOutput.supportedPhotoPixelFormatTypes(for: .tif)
        
        if let uncompressedPixelType = formats.first {
            let settings = AVCapturePhotoSettings(format: [
                kCVPixelBufferPixelFormatTypeKey as String : uncompressedPixelType
            ])
            
            photoOutput.capturePhoto(with: settings, delegate: self)
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
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            
            self.capturedImage = image
            
            do {
                try imageData.write(to: temporaryFileURL)
                self.previewURL = temporaryFileURL
                self.showPreview = true
                // Call the closure with the captured image
                DispatchQueue.main.async {
                    self.onImageCaptured?(image)
                }
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }

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
    
    func setFocusPoint(_ focusPoint: CGPoint) {
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                try device.lockForConfiguration()

                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }

                // Check if device supports exposure point of interest and set it
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }

                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
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
    
    func zoom(_ scale: CGFloat) {
        guard let currentCameraInput = session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) else {
            return
        }
        
        let device = currentCameraInput.device
        
        do {
            try device.lockForConfiguration()
            
            let desiredZoomFactor = currentZoomScale * scale
            let zoomFactor = min(max(desiredZoomFactor, 1.0), 6.5)
            
            // Determine the appropriate camera based on the zoom factor
            if currentCameraPosition == .front {
                // Front camera, apply zoom directly
                device.videoZoomFactor = zoomFactor
            } else {
                // Handle rear cameras with different types
                switch currentCameraType {
                case .ultraWide:
                    if zoomFactor >= 1.5 {
                        switchCameraType(to: .wide)
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 1.5, fromRangeMax: 3.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    } else {
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 1.0, fromRangeMax: 1.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    }
                case .wide:
                    if zoomFactor < 1.5 {
                        switchCameraType(to: .ultraWide)
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 1.0, fromRangeMax: 1.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    } else if zoomFactor > 3.5 {
                        switchCameraType(to: .telephoto)
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 3.5, fromRangeMax: 6.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    } else {
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 1.5, fromRangeMax: 3.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    }
                case .telephoto:
                    if zoomFactor <= 3.5 {
                        switchCameraType(to: .wide)
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 1.5, fromRangeMax: 3.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    } else {
                        device.videoZoomFactor = remapZoomFactor(zoomFactor, fromRangeMin: 3.5, fromRangeMax: 6.5, toRangeMin: 1.0, toRangeMax: 3.0)
                    }
                }
            }
            
            currentZoomScale = device.videoZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Failed to set zoom factor: \(error)")
        }
    }
    
    func remapZoomFactor(_ zoomFactor: CGFloat, fromRangeMin: CGFloat, fromRangeMax: CGFloat, toRangeMin: CGFloat, toRangeMax: CGFloat) -> CGFloat {
        return toRangeMin + (zoomFactor - fromRangeMin) * (toRangeMax - toRangeMin) / (fromRangeMax - fromRangeMin)
    }
    
    private func toDeviceType(type: CameraType) -> AVCaptureDevice.DeviceType? {
        switch self.currentCameraType {
        case .ultraWide:
            return .builtInUltraWideCamera
        case .wide:
            return .builtInWideAngleCamera
        case .telephoto:
            return .builtInTelephotoCamera
        }
    }
    
    func switchCameraType(to type: CameraType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Ensure we're working with the back camera
            if self.currentCameraPosition != .back {
                print("Switching camera type is only supported for the back camera.")
                return
            }

            guard let newCameraType = toDeviceType(type: type) else {
                print("Requested camera type is not supported.")
                return
            }
            
            guard let newCamera = self.cameraWithType(newCameraType, position: .back) else {
                print("Requested camera type not available.")
                return
            }

            // Switch the camera
            self.session.beginConfiguration()
            if let currentCameraInput = self.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) {
                self.session.removeInput(currentCameraInput)
            }
            
            do {
                let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
                
                if self.session.canAddInput(newVideoInput) {
                    self.session.addInput(newVideoInput)
                    self.currentCameraType = type // Make sure to update the currentCameraType
                } else {
                    print("Could not add video input.")
                }
            } catch {
                print("Error configuring capture session: \(error)")
            }
            
            self.session.commitConfiguration()
        }
    }
    
    func switchCamera() {
        if let currentCameraInput = session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) {
            
            // Check if currently recording
            let wasRecording = isRecording
            
            // Stop the current recording if it was recording
            if wasRecording {
                // Save the URL of the recording that was ongoing
                if let currentOutputFileURL = output.outputFileURL {
                    recordedURLs.append(currentOutputFileURL)
                }
                output.stopRecording()
            }
            
            // Switch the camera
            session.beginConfiguration()
            session.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice?
            if currentCameraInput.device.position == .back {
                newCamera = self.cameraWithPosition(.front)
            } else {
                newCamera = self.cameraWithPosition(.back)
            }
            
            if let newCamera = newCamera, let newVideoInput = try? AVCaptureDeviceInput(device: newCamera) {
                if session.canAddInput(newVideoInput) {
                    session.addInput(newVideoInput)
                }
            }
            session.commitConfiguration()
            
            // Start a new recording with the new camera if it was recording
            if wasRecording {
                let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
                output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
            }
            
            if currentCameraInput.device.position == .back {
                currentCameraPosition = .front
            } else {
                currentCameraPosition = .back
            }
        }
    }
        
    private func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        return discoverySession.devices.first(where: { $0.position == position })
    }
    
    private func cameraWithType(_ type: AVCaptureDevice.DeviceType, position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // Include all possible device types that your application might use.
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera,
            .builtInTelephotoCamera,
            .builtInUltraWideCamera
        ]

        // Specify the position if you want a camera on a specific side (front or back).
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: position)

        // Return the first device that matches the desired device type.
        return discoverySession.devices.first(where: { $0.deviceType == type })
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // CREATED SUCCESSFULLY
        print(outputFileURL)
        
        let finalOutputURL = outputFileURL
        
        self.recordedURLs.append(finalOutputURL)
        
        if self.recordedURLs.count == 1 {
            self.previewURL = finalOutputURL
            return
        }
        
        // CONVERTING URLs TO ASSETS
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }
        
        self.previewURL = nil
        // MERGING VIDEOS
        
        Task.init {
            do {
                let exporter = try await mergeVideos(assets: assets)
                try await exporter.exportAsync()
                if exporter.status == .completed, let finalURL = exporter.outputURL {
                    print(finalURL)
                    DispatchQueue.main.async {
                        self.previewURL = finalURL
                        
                        if let unwrappedPreviewURL = self.previewURL {
                            self.previewURL = unwrappedPreviewURL
                        }
                    }
                }
            } catch {
                // HANDLE ERROR
                print(error)
            }
        }
    }
    
    func mergeVideos(assets: [AVURLAsset]) async throws -> AVAssetExportSession {
            
        let compostion = AVMutableComposition()
        var lastTime: CMTime = .zero
            
        guard let videoTrack = compostion.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create video track"])
        }
        guard let audioTrack = compostion.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create audio track"])
        }
            
        for asset in assets {
            // Linking Audio and Video
            do {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                let audioTracks = try await asset.loadTracks(withMediaType: .audio)
                let duration = try await asset.load(.duration)
                    
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: videoTracks[0], at: lastTime)
                    
                // Safe Check if Video has Audio
                if !audioTracks.isEmpty {
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: audioTracks[0], at: lastTime)
                }
            } catch {
                // HANDLE ERROR
                print(error.localizedDescription)
            }
                
            // Updating Last Time
            let duration = try await asset.load(.duration)
            lastTime = CMTimeAdd(lastTime, duration)
        }
        
        // MARK: Temp Output URL
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "Reel-\(Date()).mp4")
        
        // VIDEO IS ROTATED
        // BRINGING BACK TO ORIGNINAL TRANSFORM
        
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // MARK: Transform
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: 90 * (.pi / 180))
        transform = transform.translatedBy(x: 0, y: -videoTrack.naturalSize.height)
        layerInstructions.setTransform(transform, at: .zero)
        
        let instructions = AVMutableVideoCompositionInstruction()
        instructions.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        instructions.layerInstructions = [layerInstructions]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.instructions = [instructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        
        let exporter = AVAssetExportSession(asset: compostion, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputFileType = .mp4
        exporter?.outputURL = tempURL
        exporter?.videoComposition = videoComposition

        if let exporter = exporter {
            return exporter
        } else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"])
        }
    }
    
    func saveSelectedImageToPreviewURL(image: UIImage) {
        // Convert the image to Data
        if let data = image.pngData() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = documentsDirectory?.appendingPathComponent("selectedImage.png")
            
            do {
                // Write the image data to the fileURL
                try data.write(to: fileURL!)
                self.previewURL = fileURL
            } catch {
                print("Error writing selected image to file: \(error)")
            }
        }
    }
    
    func removeLastVideo() {
        // Check if there is more than one video recorded
        guard recordedURLs.count > 1 else { return }

        // Remove the last video URL
        recordedURLs.removeLast()

        // Merge the remaining videos
        let assets = recordedURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }

        Task.init {
            do {
                let exporter = try await mergeVideos(assets: assets)
                try await exporter.exportAsync()
                if exporter.status == .completed, let finalURL = exporter.outputURL {
                    //print(finalURL)
                    DispatchQueue.main.async {
                        self.previewURL = finalURL

                        if let unwrappedPreviewURL = self.previewURL {
                            print("\(unwrappedPreviewURL) : \(finalURL)")
                            self.previewURL = unwrappedPreviewURL
                        } else {
                            print("\(finalURL) : nil")
                        }

                        // Updating the total duration of the final merged video
                        let asset = AVURLAsset(url: finalURL)
                        Task.init {
                            do {
                                let duration = try await asset.load(.duration)
                                withAnimation {
                                    self.recordedDuration = CGFloat(CMTimeGetSeconds(duration))
                                }
                            } catch {
                                print("Failed to load duration: \(error)")
                            }
                        }
                    }
                }
            } catch {
                // HANDLE ERROR
                print(error)
            }
        }
    }
}

extension CameraViewModel {
    // Function to get content from previewURL
    func getContentFromPreview() -> LumeContent? {
        guard let previewURL = previewURL else {
            return nil
        }

        if isVideoFile(url: previewURL) {
            let player = AVPlayer(url: previewURL)
            let reelVideo = LumeVideo(player: player, lumeAuth: true)
            return .video(reelVideo)
        } else {
            if let image = UIImage(contentsOfFile: previewURL.path) {
                let reelImage = LumeImage(image: image, url: previewURL, lumeAuth: true)
                return .image(reelImage)
            }
        }
        return nil
    }

    // Helper function to determine if a URL is a video file
    private func isVideoFile(url: URL) -> Bool {
        let videoExtensions = ["mov", "mp4"]
        return videoExtensions.contains(url.pathExtension.lowercased())
    }

    // Function to reset the CameraViewModel
    func resetCameraViewModel() {
        //session = AVCaptureSession()
        //alert = false
        //output = AVCaptureMovieFileOutput()
        //preview = AVCaptureVideoPreviewLayer(session: session)
        //isRecording = false
        recordedURLs = []
        previewURL = nil
        //showPreview = false
        //useMic = true
        recordedDuration = 0
        //currentZoomScale = 1.0
        //currentCameraType = .wide
        //currentCameraPosition = .back
        //showLight = false
        //photoOutput = AVCapturePhotoOutput()
        capturedImage = nil
    }
}

struct CameraView: View {
    @EnvironmentObject var cameraModel: CameraViewModel
    @Binding var musicPlaying: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            CameraPreview(size: size)
                .environmentObject(cameraModel)
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let locationInView = value.location
                        let locationInCamera = CGPoint(x: locationInView.x / size.width, y: locationInView.y / size.height)
                        cameraModel.setFocusPoint(locationInCamera)
                    })
                .gesture(MagnificationGesture()
                    .onChanged { scale in
                        cameraModel.zoom(scale)
                    }
                )
                .simultaneousGesture(TapGesture(count: 2)
                    .onEnded { _ in
                        if !musicPlaying {
                            cameraModel.switchCamera()
                        }
                    }
                )

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black.opacity(0.25))

                Rectangle()
                    .fill(Color(red: 0.723, green: 0.88, blue: 0.825))
                    .frame(width: size.width * (cameraModel.recordedDuration / cameraModel.maxDuration))
            }
            .frame(height: 8)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onAppear {
            cameraModel.checkPermission()
        }
        .alert(isPresented: $cameraModel.alert) {
            Alert(title: Text("Please Enable cameraModel Access Or Microphone Access"))
        }
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if cameraModel.recordedDuration <= cameraModel.maxDuration && cameraModel.isRecording {
                cameraModel.recordedDuration += 0.01
            }

            if cameraModel.recordedDuration >= cameraModel.maxDuration && cameraModel.isRecording {
                // Stopping the Recording
                cameraModel.stopRecording()
                cameraModel.isRecording = false
            }
        }
    }
}

extension AVAssetExportSession {
    func exportAsync() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            exportAsynchronously {
                if let error = self.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @EnvironmentObject var cameraModel : CameraViewModel
    var size: CGSize
    
    func makeUIView(context: Context) ->  UIView {
        let view = UIView()
        if let preview = cameraModel.preview {
            preview.frame.size = size
            view.layer.addSublayer(preview)
        }
        cameraModel.preview?.videoGravity = .resizeAspectFill
        
        // Add pinch gesture recognizer
        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak cameraModel] in
            if let session = cameraModel?.session {
                session.startRunning()
            }
        }
        
        return view
    }

    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
        
    class Coordinator: NSObject {
        var parent: CameraPreview
        
        init(_ parent: CameraPreview) {
            self.parent = parent
        }
        
        @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
            if recognizer.state == .ended {
//                print("Pinch gesture ended with scale: \(recognizer.scale)")
                parent.cameraModel.zoom(recognizer.scale)
            }
        }
    }
}


struct FinalPreview: View {
    
    @EnvironmentObject var cameraModel: CameraViewModel
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    var url: URL
    let player: AVPlayer  // Here is the new property
    let back: Bool
    
    init(url: URL, back: Bool) {
        self.url = url
        self.player = AVPlayer(url: url)
        self.back = back
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack{
                if url.pathExtension == "mov" ||  url.pathExtension == "mp4" {
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height-40)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                } else {
                    Image(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height-40)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }
            }
            // Back Button
            .overlay(alignment: .topLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label {
                        Text("Back")
                    } icon: {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(.white)
                }
                .padding(.leading)
                .padding(.top,22)
                .opacity(back ? 1 : 0)
            }
        }
        .navigationBarHidden(true)
    }
}
