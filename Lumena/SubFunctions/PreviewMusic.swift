//
//  PreviewMusic.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/27.
//

import Foundation
import SwiftUI
import UIKit
import CoreImage
import AVFoundation
import AVKit
import Combine


class AudioPlayer {
    
    /*
     
     fetching music ->
     
        fetch using spotify api
     
        on init, it will receive all the music within the trending music album
        this will append the musics in the public tracks array
     
        then user will be able to tag and the tagMusicIndex will change from -1 to the tagging index muber
     
        when user searches using search term, would it erase the tracks array or should I keep the most trending tracks and create another array called searchResult tracks
     
     
        -> Maybe create two tracks, trending and searchResult arrays
            -> there will be one tagMusicIndex for to maintain consistency
            
        But isnt it unprofessional to use index number of the music in the tracks instead of the UUID cuz then, what if the user searches up and selects song A and when they go back to the trend array, it does not show thta the track was not selected? -> this is inconvenient and not logical
     
     
        how can i fetch the UUID of the music from spotify?
        
        
     */
    
    static let shared = AudioPlayer()
    
    var access_token: String = "null"
    public var tracks: [Track] = []
    
    
    func fetchData(from urlString: String, completion: @escaping (Data?) -> Void) {
        getAccessToken {
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(self.access_token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        completion(data)
                    }
                } else if let error = error {
                    print("HTTP Request Failed \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            
            task.resume()
        }
    }

    func getPlaylist(completion: @escaping (Result<[Track], Error>) -> Void) {
        fetchData(from: "https://api.spotify.com/v1/playlists/37i9dQZEVXbKXQ4mDTEBXq") { jsonData in
            guard let jsonData = jsonData else {
                print("Failed to fetch JSON data")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch JSON data"])))
                return
            }
            
            self.parseJsonDataPlaylist(jsonData: jsonData) { result in
                switch result {
                case .success(let tracks):
                    completion(.success(tracks))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func parseJsonDataPlaylist(jsonData: Data, completion: @escaping (Result<[Track], Error>) -> Void) {
        var tracks: [Track] = []
        
        do {
            guard
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String: Any],
                let tracksJSON = jsonResult["tracks"] as? [String: Any],
                let items = tracksJSON["items"] as? [[String: Any]]
            else {
                // Handle error: JSON structure doesn't match expectation
                completion(.failure(NSError(domain: "com.nucr.gotdns.org.MyPalette", code: 1000, userInfo: ["Description": "Invalid JSON structure"])))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            let dispatchGroup = DispatchGroup() // Create a dispatch group
            
            for item in items {
                if let track = item["track"] as? [String: Any],
                   let trackData = try? JSONSerialization.data(withJSONObject: track, options: .prettyPrinted) {
                    do {
                        let trackDetail = try jsonDecoder.decode(TrackDetail.self, from: trackData)
                        
                        if let imageUrlString = trackDetail.album.images.first?.url,
                           let imageUrl = URL(string: imageUrlString) {
                            
                            dispatchGroup.enter() // Enter the dispatch group
                            downloadImage(from: imageUrl) { downloadedImage in
                                
                                tracks.append(Track(from: trackDetail, image: downloadedImage))
                                dispatchGroup.leave() // Leave the dispatch group
                            }
                        } else {
                            tracks.append(Track(from: trackDetail))
                        }
                    } catch {
                        print("Error decoding track: \(error)")
                        completion(.failure(error))
                        return
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(.success(tracks))
            }
            
        } catch {
            print("Unknown error in decoding track: \(error)")
            completion(.failure(error))
        }
    }

    
    
    func getSearchResult(query: String, type: String, completion: @escaping ([Track]) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        fetchData(from: "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=\(type)") { jsonData in
            guard let jsonData = jsonData else {
                print("Failed to fetch JSON data")
                completion([])
                return
            }
            
            self.parseJsonDataSearchResult(jsonData: jsonData) { tracks in
                completion(tracks)
            }
        }
    }
    
    
    func parseJsonDataSearchResult(jsonData: Data, completion: @escaping ([Track]) -> Void) {
        var tracks: [Track] = []

        do {
            let jsonDecoder = JSONDecoder()
            let searchResponse = try jsonDecoder.decode(SpotifySearchResponse.self, from: jsonData)

            let dispatchGroup = DispatchGroup() // Create a dispatch group

            for item in searchResponse.tracks.items {
                if let imageUrlString = item.album.images.first?.url,
                   let imageUrl = URL(string: imageUrlString) {

                    dispatchGroup.enter() // Enter the dispatch group
                    downloadImage(from: imageUrl) { downloadedImage in
                        DispatchQueue.main.async {
                            let track = Track(from: item, image: downloadedImage)
                            tracks.append(track)
                            dispatchGroup.leave() // Leave the dispatch group
                        }
                    }
                } else {
                    let track = Track(from: item)
                    tracks.append(track)
                }
            }

            // Call the completion handler once all image download tasks have completed
            dispatchGroup.notify(queue: .main) {
                self.tracks = tracks
                completion(tracks)
            }

        } catch {
            print("Unknown error in decoding track: \(error)")
            completion([]) // Ensure to call completion even on error to not block the UI
        }
    }
    
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check for cached image
        if let cachedImage = ImageCacheManager.shared.getCachedImage(for: url.absoluteString) {
            completion(cachedImage)
            return
        }
        
        // Download if not cached
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
            } else if let data = data {
                let image = UIImage(data: data)
                if let image = image {
                    ImageCacheManager.shared.cacheImage(image, for: url.absoluteString)
                }
                completion(image)
            }
        }
        task.resume()
    }
    
    func getAccessToken(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic MGE1YTMzZGY4MzRmNDQ1Y2I1OWM2YmNjOGI4YTRiNDU6YmFlNmJlZGQyNjVkNDUwYmFkYjI5YzBmN2MwODNkYzE=", forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                        if let accessToken = jsonResult["access_token"] as? String {
                            // Save the access token
                            UserDefaults.standard.set(accessToken, forKey: "AccessToken")
                            print("Access Token Saved: \(accessToken)")
                            self.access_token = accessToken
                            completion()
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }

        task.resume()
    }
}


class ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() {}
    
    private var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    func cacheImage(_ image: UIImage, for key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func getCachedImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}


struct AudioPreviewModel: Hashable {
    var magnitude: Float
    var color: Color
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

protocol ServiceProtocol {
    func buffer(url: URL, samplesCount: Int, completion: @escaping([AudioPreviewModel]) -> ())
}


class Service {
    static let shared: ServiceProtocol = Service()
    private init() { }
}

extension Service: ServiceProtocol {
    func buffer(url: URL, samplesCount: Int, completion: @escaping([AudioPreviewModel]) -> ()) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                var cur_url = url
                if url.absoluteString.hasPrefix("https://") {
                    let data = try Data(contentsOf: url)
                    
                    let directory = FileManager.default.temporaryDirectory
                    let fileName = "chunk.m4a"
                    cur_url = directory.appendingPathComponent(fileName)
                    
                    try data.write(to: cur_url)
                }
                
                let file = try AVAudioFile(forReading: cur_url)
                if let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                              sampleRate: file.fileFormat.sampleRate,
                                              channels: file.fileFormat.channelCount, interleaved: false),
                   let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) {
                    
                    try file.read(into: buf)
                    guard let floatChannelData = buf.floatChannelData else { return }
                    let frameLength = Int(buf.frameLength)
                    
                    let samples = Array(UnsafeBufferPointer(start:floatChannelData[0], count:frameLength))
                    
                    var result = [AudioPreviewModel]()
                    
                    let chunked = samples.chunked(into: samples.count / samplesCount)
                    for row in chunked {
                        var accumulator: Float = 0
                        let newRow = row.map{ $0 * $0 }
                        accumulator = newRow.reduce(0, +)
                        let power: Float = accumulator / Float(row.count)
                        let decibles = 20 * log10f(power)
                        
                        result.append(AudioPreviewModel(magnitude: decibles, color: .gray))
                        
                    }
                    
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            } catch {
                print("Audio Error: \(error)")
            }
        }
    }
}

class AudioPlayViewModel: ObservableObject {
    
    private var timer: Timer?
    
    @Published var isPlaying: Bool = false
    @Published public var soundSamples = [AudioPreviewModel]()
    
    let sample_count: Int
    var index = 0
    var track: Track
    var dataManager: ServiceProtocol
    var pausedTime: Float = 0.0
    
    let maximumDuration: Float = 30.0
    
    init(track: Track, samples_count: Int, dataManager: ServiceProtocol = Service.shared) {
        self.track = track
        self.sample_count = samples_count
        self.dataManager = dataManager
        
        visualizeAudio()
    }

    func startTimer(from selectedRange: ClosedRange<Float>) {
        count_duration { [self] duration in
            let time_interval = duration / Double(self.sample_count)
            self.index = Int(Double(self.sample_count) * Double(selectedRange.lowerBound / self.maximumDuration))
            
            //print("\(selectedRange.lowerBound) \(selectedRange.upperBound)")
            
            self.timer = Timer.scheduledTimer(withTimeInterval: time_interval, repeats: true, block: { (timer) in
                if self.index < self.soundSamples.count {
                    withAnimation(Animation.linear) {
                        self.soundSamples[self.index].color = Color.black
                    }
                    self.index += 1
                }
                
                // Check if the current time has reached or surpassed the upper bound.
                if let currentTime = self.track.audioPlayer?.currentTime,
                   Float(currentTime) >= selectedRange.upperBound {
                    self.timer?.invalidate()
                    self.isPlaying = false
                }
            })
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.track.stopAudio()
        self.timer?.invalidate()
        self.isPlaying = false
        self.index = 0
        self.pausedTime = 0.0
        self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
            var cur = tmp
            cur.color = Color.gray
            return cur
        }
    }
    
    func playAudio(with selectedRange: ClosedRange<Float>, hasMovedBar: Bool) {
        
        if track.audioPlayer == nil {
            track.initializeAudioPlayer() { _ in}
        }
        
        if isPlaying {
            pauseAudio(with: selectedRange)
        } else {
            if hasMovedBar {
                let startTime = TimeInterval(selectedRange.lowerBound)
                let endTime = TimeInterval(selectedRange.upperBound)
                track.playAudio(from: Float(startTime), to: Float(endTime))
            } else {
                if pausedTime == 0 {
                    track.playAudio()
                } else {
                    track.playAudio(from: pausedTime)
                }
            }
            
            isPlaying.toggle()
            startTimer(from: selectedRange)
            count_duration { _ in }
        }
    }
    
    func pauseAudio(with selectedRange: ClosedRange<Float>) {
        pausedTime = Float(track.audioPlayer?.currentTime ?? 0.0)
        track.stopAudio()
        timer?.invalidate()
        self.isPlaying = false
    }
    
    func pauseAudio() {
        track.stopAudio()
        timer?.invalidate()
        self.isPlaying = false
    }

    func count_duration(completion: @escaping(Float64) -> ()) {
        let duration = track.getCurrentTrackDuration()
        DispatchQueue.main.async {
            completion(duration)
        }
    }

    func resetBars() {
        self.soundSamples = self.soundSamples.map { tmp -> AudioPreviewModel in
            var cur = tmp
            cur.color = Color.gray
            return cur
        }
    }
    
    func visualizeAudio() {
        guard let url = track.previewUrl else {
            print("Track does not have a preview URL")
            return
        }
        dataManager.buffer(url: url, samplesCount: sample_count) { results in
            self.soundSamples = results
        }
    }
    
    func removeAudio() {
        guard let url = track.previewUrl else {
            print("Track does not have a preview URL")
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
            NotificationCenter.default.post(name: Notification.Name("hide_audio_preview"), object: nil)
            
        } catch {
            print(error)
        }
    }
}

struct AudioVisualizer: View {
    
    @StateObject private var audioVM: AudioPlayViewModel
    
    @Binding var track: Track
    
    @State private var selectedRange: ClosedRange<Float> = 0...30
    @State private var hasMovedBar: Bool = false
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 30) // between 0.1 and 35
        return CGFloat(level * (60/35))
    }
    
    init(track: Binding<Track>) {
        _track = track
        _audioVM = StateObject(wrappedValue: AudioPlayViewModel(track: track.wrappedValue, samples_count: Int(UIScreen.main.bounds.width * 0.6 / 4)))
    }
    
    var body: some View {
        VStack( alignment: .leading ) {
                    
                LazyHStack(alignment: .center, spacing: 10) {
                    
                    Button {
                        if audioVM.isPlaying {
                            
                            audioVM.pauseAudio(with: selectedRange)
                        } else {
                            
                            audioVM.playAudio(with: selectedRange, hasMovedBar: hasMovedBar)
                        }
                    } label: {
                        Image(systemName: !(audioVM.isPlaying) ? "play.fill" : "pause.fill" )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary)
                    }
                
                ZStack{
                    
                    HStack(alignment: .center, spacing: 2) {
                        
                        if audioVM.soundSamples.isEmpty {
                            ProgressView()
                            
                        } else {
                            ForEach(audioVM.soundSamples, id: \.self) { model in
                                BarView(value: self.normalizeSoundLevel(level: model.magnitude), color: model.color)
                            }
                        }
                    }
                    
                    RangeSlider(viewModel: .init(sliderPosition: selectedRange,
                                                             sliderBounds: 0...30),
                        sliderPositionChanged: { newRange in
                            selectedRange = newRange
                            track.tagMusic(range: newRange)
                            hasMovedBar = true
                        }
                    )
                    .onChange(of: selectedRange) { _ in
                        
                        
                        if hasMovedBar {
                            track.stopAudio()
                            audioVM.isPlaying = false
                            audioVM.resetBars()
                            audioVM.pauseAudio()
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.6)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .frame(minHeight: 0, maxHeight: 50)
        .background(Color(track.image?.dominantColor ?? UIColor.gray).opacity(0.3))
        .cornerRadius(10)
        .onAppear{
            track.initializeAudioPlayer() { _ in}
        }
    }
}

struct BarView: View {
    let value: CGFloat
    var color: Color = Color.gray
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .cornerRadius(10)
                .frame(width: 2, height: value)
        }
    }
}



struct RangeSlider: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isActive: Bool = false
    let sliderPositionChanged: (ClosedRange<Float>) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack{
                sliderView(sliderSize: geometry.size,
                           sliderViewYCenter: geometry.size.height / 2)
            }
        }
        .frame(height: 50)
        .onAppear{

            //強制的に起動
            isActive = true
        }
    }

    @ViewBuilder private func sliderView(sliderSize: CGSize, sliderViewYCenter: CGFloat) -> some View {
        lineBetweenThumbs(from: viewModel.leftThumbLocation(width: sliderSize.width,
                                                            sliderViewYCenter: sliderViewYCenter),
                          to: viewModel.rightThumbLocation(width: sliderSize.width,
                                                           sliderViewYCenter: sliderViewYCenter))

        thumbView(position: viewModel.leftThumbLocation(width: sliderSize.width,
                                                        sliderViewYCenter: sliderViewYCenter),
                  value: Float(viewModel.sliderPosition.lowerBound))
        .highPriorityGesture(DragGesture().onChanged { dragValue in
            let newValue = viewModel.newThumbLocation(dragLocation: dragValue.location,
                                                      width: sliderSize.width)
            
            //print("Left thumb dragged to: \(dragValue.location.x), Calculated value: \(newValue)")
            
            if newValue < viewModel.sliderPosition.upperBound {
                viewModel.sliderPosition = newValue...viewModel.sliderPosition.upperBound
                sliderPositionChanged(viewModel.sliderPosition)
                isActive = true
            }
        })

        thumbView(position: viewModel.rightThumbLocation(width: sliderSize.width,
                                                         sliderViewYCenter: sliderViewYCenter),
                  value: Float(viewModel.sliderPosition.upperBound))
        .highPriorityGesture(DragGesture().onChanged { dragValue in
            let newValue = viewModel.newThumbLocation(dragLocation: dragValue.location,
                                                      width: sliderSize.width)
            
            //print("Right thumb dragged to: \(dragValue.location.x), Calculated value: \(newValue)")
            
            if newValue > viewModel.sliderPosition.lowerBound {
                viewModel.sliderPosition = viewModel.sliderPosition.lowerBound...newValue
                sliderPositionChanged(viewModel.sliderPosition)
                isActive = true
            }
        })
    }

    @ViewBuilder func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
        ZStack {
            /*RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.3))
                .frame(height: 5)
             
             */

            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(isActive ? Color.black.opacity(0.2) : Color.clear,
                    lineWidth: 50)
        }
    }

    @ViewBuilder func thumbView(position: CGPoint, value: Float) -> some View {
        Rectangle()
            .frame(width: 5, height: 50)
            .foregroundColor(isActive ? Color.orange.opacity(0.5) : Color.clear)
            .contentShape(Rectangle())
            .position(x: position.x, y: position.y)
            .animation(.spring(), value: isActive)
    }
}

extension CGSize {
    static let rangeSliderThumb = CGSize(width: 20, height: 20)
}

extension RangeSlider {
    
    final class ViewModel: ObservableObject {
        
        @Published var sliderPosition: ClosedRange<Float> 
        /*
        {
            didSet {
                print("Slider position set to: \(sliderPosition)")
            }
        }
         */

        let sliderBounds: ClosedRange<Int>

        let sliderBoundDifference: Int

        init(sliderPosition: ClosedRange<Float>,
             sliderBounds: ClosedRange<Int>) {
            self.sliderPosition = sliderPosition
            self.sliderBounds = sliderBounds
            self.sliderBoundDifference = sliderBounds.count - 1
        }

        func leftThumbLocation(width: CGFloat, sliderViewYCenter: CGFloat = 0) -> CGPoint {
            let sliderLeftPosition = CGFloat(sliderPosition.lowerBound - Float(sliderBounds.lowerBound))
            let point = CGPoint(x: sliderLeftPosition * stepWidthInPixel(width: width),
                                y: sliderViewYCenter)
            //print("Left thumb should be at: \(point)")
            return point
        }

        func rightThumbLocation(width: CGFloat, sliderViewYCenter: CGFloat = 0) -> CGPoint {
            let sliderRightPosition = CGFloat(sliderPosition.upperBound - Float(sliderBounds.lowerBound))
            let point = CGPoint(x: sliderRightPosition * stepWidthInPixel(width: width),
                                y: sliderViewYCenter)
            //print("Right thumb should be at: \(point)")
            return point
        }


        func newThumbLocation(dragLocation: CGPoint, width: CGFloat) -> Float {
            let xThumbOffset = min(max(0, dragLocation.x), width)
            let newValue = Float(sliderBounds.lowerBound) + Float(xThumbOffset / stepWidthInPixel(width: width))
            //print("DragLocation: \(dragLocation.x), Width: \(width), Calculated New Value: \(newValue)")
            return newValue
        }


        private func stepWidthInPixel(width: CGFloat) -> CGFloat {
            width / CGFloat(sliderBoundDifference)
        }
    }
}


extension UIImage {
    var dominantColor: UIColor {
        let inputImage = CIImage(image: self)
        let extentVector = CIVector(x: inputImage!.extent.origin.x, y: inputImage!.extent.origin.y, z: inputImage!.extent.size.width, w: inputImage!.extent.size.height)

        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage!, kCIInputExtentKey: extentVector])!
        let outputImage = filter.outputImage!

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
