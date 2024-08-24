//
//  AudioRecorder.swift
//  Lumena
//
//  Created by 島田晃 on 2024/07/29.
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI

class AudioRecordingData: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var audioSegments: [URL] = [] {
        didSet {
            self.saveRecording()
        }
    }
    @Published var audioLevels: [Float] = []
    @Published var recordingDuration: TimeInterval = 0.0
    @Published var audioPlayer: AVPlayer?
    @Published var finalAudioURL: URL?
    
    @Published var isRecording = false {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updateRecordButtonLabel, object: self.isRecording ? "stop.fill" : "record.circle.fill")
            }
        }
    }
    @Published var isPlaying = false {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updatePlayButtonLabel, object: self.isPlaying ? "pause.fill" : "play.fill")
            }
        }
    }
    
    @Published var isMuted = false {
        didSet {
            self.mute(mute: self.isMuted)
        }
    }
    
    var hasRecording: Bool {
        return !audioSegments.isEmpty || (finalAudioURL != nil)
    }
    
    private var audioRecorder: AVAudioRecorder?
    private var currentAudioFilename: URL?
    private var timer: Timer?
    private var playbackTimer: Timer?
    private let interval: CGFloat = 0.5
    
    func reset() {
        DispatchQueue.main.async {
            self.audioSegments.removeAll()
            self.audioLevels.removeAll()
            self.recordingDuration = 0.0
            self.audioPlayer = nil
        }
    }
    
    func addSegment(_ url: URL) {
        DispatchQueue.main.async {
            self.audioSegments.append(url)
        }
    }
    
    func addLevel(_ level: Float) {
        audioLevels.append(level)
    }
    
    func setDuration(_ duration: TimeInterval) {
        recordingDuration = duration
    }
    
    func setAudioPlayer(_ player: AVPlayer?) {
        audioPlayer = player
    }
    
    func setAudioPlayerURL(url: URL) {
        finalAudioURL = url
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc private func audioPlayerDidFinishPlaying(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem, playerItem == audioPlayer?.currentItem else {
            return
        }
        
        if isPlaying {
            DispatchQueue.main.async {
                self.play(repeatAudio: true)
            }
        } else {
            DispatchQueue.main.async {
                self.stop()
            }
        }
    }
    
    func play(repeatAudio: Bool = false) {
        guard let finalAudioURL = finalAudioURL else { return }
        
        // Create and set up the player only if it's not already playing
        if audioPlayer == nil || audioPlayer?.currentItem?.asset != AVURLAsset(url: finalAudioURL) {
            let playerItem = AVPlayerItem(url: finalAudioURL)
            audioPlayer = AVPlayer(playerItem: playerItem)
        }
        audioPlayer?.isMuted = self.isMuted
        audioPlayer?.play()
        isPlaying = true
    }
    
    // Play the audio from a specific start time to an end time
    func play(from startTime: TimeInterval, to endTime: TimeInterval, repeatAudio: Bool = false) {
        guard let finalAudioURL = finalAudioURL else { return }
        
        // Create and set up the player only if it's not already playing
        if audioPlayer == nil || audioPlayer?.currentItem?.asset != AVURLAsset(url: finalAudioURL) {
            let playerItem = AVPlayerItem(url: finalAudioURL)
            audioPlayer = AVPlayer(playerItem: playerItem)
        }

        self.isMuted = VideoDataStore.shared.mute
        audioPlayer?.isMuted = self.isMuted
        
        audioPlayer?.seek(to: CMTime(seconds: startTime, preferredTimescale: 600))
        audioPlayer?.play()
        isPlaying = true
        
        playbackTimer?.invalidate() // Invalidate any existing timer
        playbackTimer = Timer.scheduledTimer(withTimeInterval: endTime - startTime, repeats: false) { [weak self] _ in
            if repeatAudio {
                self?.play(from: startTime, to: endTime, repeatAudio: true) // Play again with repeating
            } else {
                self?.stop()
            }
        }
    }
    
    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        playbackTimer?.invalidate()
        playbackTimer = nil
        isPlaying = false
    }
    
    func updateRecordingDuration() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .updateRecordingDuration, object: self.recordingDuration)
        }
    }
    
    func calculateDuration(of url: URL) async -> TimeInterval {
        let asset = AVURLAsset(url: url)
        return (try? await asset.load(.duration).seconds) ?? 0
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func combineAudioSegments(outputURL: URL) async throws {
        let composition = AVMutableComposition()
        var insertTime = CMTime.zero
        
        for segment in self.audioSegments {
            let asset = AVURLAsset(url: segment)
            
            let audioTracks = try await asset.loadTracks(withMediaType: .audio)
            guard let assetTrack = audioTracks.first else {
                print("No audio track found in segment: \(segment)")
                continue
            }
            
            let duration = try await asset.load(.duration)
            
            guard let track = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                print("Failed to add mutable track to composition")
                throw NSError(domain: "combineAudioSegments", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to add mutable track to composition"])
            }
            
            do {
                try track.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: assetTrack, at: insertTime)
                insertTime = CMTimeAdd(insertTime, duration)
            } catch {
                print("Failed to insert time range: \(error)")
                throw error
            }
        }
        
        // Log composition details for debugging
        if composition.tracks.isEmpty {
            print("Composition has no tracks")
            throw NSError(domain: "combineAudioSegments", code: -3, userInfo: [NSLocalizedDescriptionKey: "Composition has no tracks"])
        } else {
            print("Composition has \(composition.tracks.count) tracks")
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A) else {
            print("Failed to create AVAssetExportSession")
            throw NSError(domain: "combineAudioSegments", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"])
        }
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL = outputURL
        
        try await exportSession.exportAsync()
        
        if exportSession.status != .completed {
            print("Export session failed: \(String(describing: exportSession.error))")
            throw exportSession.error ?? NSError(domain: "combineAudioSegments", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unknown export error"])
        }
    }
    
    func handleFinalAudioFile(_ fileURL: URL) {
        DispatchQueue.main.async {
            let playerItem = AVPlayerItem(url: fileURL)
            let player = AVPlayer(playerItem: playerItem)
            self.setAudioPlayer(player)
            print("Final audio file is ready for playback")
        }
    }
}

extension AudioRecordingData {
    func startOver() async {
        if isRecording {
            stopRecording()
        }
        DispatchQueue.main.async {
            for segment in self.audioSegments {
                try? FileManager.default.removeItem(at: segment)
            }
        }
        reset()
        updateRecordingDuration()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .updateAudioVisualizer, object: self.audioLevels)
        }
    }
    
    func clearLastRecordingLevels() async {
        if let lastSegment = audioSegments.last {
            let lastSegmentDuration = await calculateDuration(of: lastSegment)
            let levelsToRemove = Int(lastSegmentDuration / interval)
            audioLevels.removeLast(levelsToRemove)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updateAudioVisualizer, object: self.audioLevels)
            }
        }
    }
    
    func recalculateDuration() async {
        var totalDuration: TimeInterval = 0.0
        
        for segment in audioSegments {
            let asset = AVURLAsset(url: segment)
            
            do {
                let duration = try await asset.load(.duration)
                totalDuration += duration.seconds
            } catch {
                print("Failed to load duration: \(error)")
            }
        }
        self.setDuration(totalDuration)
        self.updateRecordingDuration()
    }
    
    func startLevelTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.updateAudioLevels()
            self.setDuration(self.recordingDuration + self.interval)
        }
    }
                
    func stopLevelTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateAudioLevels() {
        audioRecorder?.updateMeters()
        
        guard let averagePower = audioRecorder?.averagePower(forChannel: 0) else { return }
        
        let level = self.normalizedPowerLevel(fromDecibels: averagePower)
        
        addLevel(level)
        NotificationCenter.default.post(name: .updateAudioVisualizer, object: audioLevels)
    }

    func normalizedPowerLevel(fromDecibels decibels: Float) -> Float {
        if decibels < -80 {
            return 0.0
        } else if decibels >= 0 {
            return 1.0
        } else {
            return (80 + decibels) / 80
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording-\(audioSegments.count + 1).m4a")
        currentAudioFilename = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // AAC format
            AVSampleRateKey: 44100, // 44.1 kHz sample rate
            AVNumberOfChannelsKey: 1, // Mono audio
            AVEncoderBitRateKey: 96000, // 128 kbps bit rate
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // High audio quality
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            startLevelTimer()
        } catch {
            print("Failed to start recording: \(error)")
            stopRecording()
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        if let currentAudioFilename = currentAudioFilename {
            addSegment(currentAudioFilename)
        }
        audioRecorder = nil
        currentAudioFilename = nil
        
        isRecording = false
        stopLevelTimer()
    }

    func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            playRecording()
        }
    }

    func playRecording() {
        let combinedAudioFilename = getDocumentsDirectory().appendingPathComponent("combinedRecording-\(UUID().uuidString).m4a")
        Task {
            do {
                print("Combining audio segments...")
                try await combineAudioSegments(outputURL: combinedAudioFilename)
                print("Audio segments combined, playing audio...")

                let playerItem = AVPlayerItem(url: combinedAudioFilename)
                let player = AVPlayer(playerItem: playerItem)

                let duration = try await playerItem.asset.load(.duration)
                self.setAudioPlayer(player)
                DispatchQueue.main.async {
                    player.play()
                    self.setDuration(CMTimeGetSeconds(duration))
                    self.updateRecordingDuration()
                    self.isPlaying = true
                }
            } catch {
                print("Failed to play recording: \(error)")
            }
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    private func mute(mute: Bool = false) {
        audioPlayer?.isMuted = mute
    }

    func saveRecording() {
        finalAudioURL = getDocumentsDirectory().appendingPathComponent("finalRecording-\(UUID().uuidString).m4a")

        // Ensure combinedAudioFilename is not nil
        guard let combinedAudioFilename = finalAudioURL else {
            print("Failed to create final audio file URL.")
            return
        }

        Task {
            do {
                print("Combining audio segments for saving...")
                try await combineAudioSegments(outputURL: combinedAudioFilename)
                print("Audio segments combined, saving audio...")
                
                // Initialize AVAudioPlayer with the combined audio file
                DispatchQueue.main.async {
                    self.handleFinalAudioFile(combinedAudioFilename)
                    
                    // Notify SwiftUI that saving is complete
                    NotificationCenter.default.post(name: .audioRecordingSaved, object: nil)
                    
                    // Print the file size
                    self.printFileSize(of: combinedAudioFilename)
                }
            } catch {
                print("Failed to save recording: \(error.localizedDescription)")
            }
        }
    }

    func printFileSize(of fileURL: URL) {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? NSNumber {
                print("File size: \(fileSize.int64Value) bytes")
            } else {
                print("Failed to retrieve file size.")
            }
        } catch {
            print("Failed to get file attributes: \(error.localizedDescription)")
        }
    }
    
    @objc func deleteLatestSegment() {
        if isRecording {
            stopRecording()
        }
        if let lastSegment = self.audioSegments.popLast() {
            try? FileManager.default.removeItem(at: lastSegment)
            Task {
                await recalculateDuration()
                await clearLastRecordingLevels()
            }
        }
    }
    
    func getFinalAudioData() -> Data? {
        guard let finalURL = finalAudioURL else {
            print("No final audio file URL available.")
            return nil
        }

        do {
            let audioData = try Data(contentsOf: finalURL)
            return audioData
        } catch {
            print("Failed to convert final audio to Data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func uploadFinalAudio(filePath: String) async -> String {
        guard let audioData = getFinalAudioData() else {
            print("Failed to retrieve final audio data.")
            return ""
        }

        let fileName = "\(filePath)/voiceOver.m4a"
        let s3Prefix = "s3://lumena225d91d9ee5c43d99341141978c6b54c25223-lumenaenv/public/"
        
        do {
            _ = try await S3.shared.storeDataAsync(name: fileName, data: audioData, progressHandler: { progress in
                print("Upload progress: \(progress * 100)%")
            })
            return "\(s3Prefix)\(fileName)"
        } catch {
            print("Upload failed with error: \(error)")
        }
        return ""
    }
}

extension AudioRecordingData {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished successfully")
        } else {
            print("Recording failed")
        }
    }
}

class AudioRecorderViewController: UIViewController {
    @ObservedObject var recordingData: AudioRecordingData
    
    var buttonsHost: UIHostingController<AudioRecorderButtonsView>!
    
    init(recordingData: AudioRecordingData) {
        _recordingData = ObservedObject(wrappedValue: recordingData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRecorder()
    }
    
    func setupUI() {
        let buttonsView = AudioRecorderButtonsView(
            toggleRecording: recordingData.toggleRecording,
            togglePlayback: recordingData.togglePlayback,
            deleteLatestSegment: {
                self.recordingData.deleteLatestSegment()
            },
            startOver: {
                Task {
                    await self.recordingData.startOver()
                }
            }
//            ,saveRecording: recordingData.saveRecording
        )
        
        buttonsHost = UIHostingController(rootView: buttonsView)
        
        addChild(buttonsHost)
        view.addSubview(buttonsHost.view)
        
        buttonsHost.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsHost.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsHost.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsHost.view.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            buttonsHost.view.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        buttonsHost.didMove(toParent: self)
    }
    
    func setupRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        // Microphone access granted
                    } else {
                        // Microphone access denied
                        let alert = UIAlertController(title: "Permission Denied", message: "Please allow microphone access in settings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
}

struct AudioRecorderButtonsView: View {
    @State var recordButtonLabel: String = "record.circle.fill"
    @State var playButtonLabel: String = "play.fill"
    @State var deleteButtonLabel: String = "arrow.counterclockwise"
    @State var startOverButtonLabel: String = "trash.fill"
//    @State var saveButtonLabel: String = "square.and.arrow.down.fill"
    
    var toggleRecording: () -> Void
    var togglePlayback: () -> Void
    var deleteLatestSegment: () -> Void
    var startOver: () -> Void
//    var saveRecording: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            CustomButtonView(systemName: $recordButtonLabel, action: toggleRecording)
            CustomButtonView(systemName: $playButtonLabel, action: togglePlayback)
            CustomButtonView(systemName: $deleteButtonLabel, action: deleteLatestSegment)
            CustomButtonView(systemName: $startOverButtonLabel, action: startOver)
//            CustomButtonView(systemName: $saveButtonLabel, action: saveRecording)
        }
    }
}

struct CustomButtonView: View {
    @Binding var systemName: String
    var action: () -> Void
    let generator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button {
            generator.impactOccurred()
            action()
        } label: {
            ZStack {
                Rectangle()
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
                    .foregroundColor(Color(UIColor.arinBlue))
                
                Image(systemName: systemName)
                    .foregroundColor(Color(UIColor.background))
            }
        }
    }
}

struct AudioRecorderView: UIViewControllerRepresentable {
    @ObservedObject var recordingData: AudioRecordingData

    func makeUIViewController(context: Context) -> AudioRecorderViewController {
        let viewController = AudioRecorderViewController(recordingData: recordingData)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: AudioRecorderViewController, context: Context) {
        uiViewController.recordingData = recordingData // Update the recordingData if needed
    }
}

struct AudioRecordContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var recordingData: AudioRecordingData
    @State private var scrollViewProxy: ScrollViewProxy?
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                AudioVisualizerView(levels: $recordingData.audioLevels, duration: recordingData.recordingDuration)
                    .onAppear {
                        scrollViewProxy = proxy
                    }
            }
            
            AudioRecorderView(recordingData: recordingData) // Pass the recordingData
        }
        .padding([.horizontal, .bottom])
        .onReceive(NotificationCenter.default.publisher(for: .updateAudioVisualizer)) { notification in
            if notification.object is [Float] {
                scrollToLatest()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateRecordingDuration)) { notification in
            if notification.object is TimeInterval {
                // No need to do anything since recordingData is already updated
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .audioRecordingSaved)) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func scrollToLatest() {
        if let proxy = scrollViewProxy {
            withAnimation {
                proxy.scrollTo(recordingData.audioLevels.count - 1, anchor: .trailing)
            }
        }
    }
}

struct AudioVisualizerView: View {
    @Binding var levels: [Float]
    var duration: TimeInterval
    
    var body: some View {
        
        HStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(alignment: .center, spacing: 2) {
                        ForEach(levels.indices, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(width: 4, height: CGFloat(levels[index]) * 40)
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: levels) { _ in
                    withAnimation {
                        scrollViewProxy.scrollTo(levels.count - 1, anchor: .trailing)
                    }
                }
            }
            .frame(height: 50)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            
            Text(formatTime(duration))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 5)
                .frame(width: 30)
        }
        .padding(.horizontal, 20)
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}
