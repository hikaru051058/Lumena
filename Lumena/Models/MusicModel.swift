//
//  MusicModel.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/09/27.
//

import Foundation
import UIKit
import SwiftUI
import AVFAudio
import AVFoundation

//create audioplayer for each tracks
class Track: ObservableObject, Equatable, Identifiable {
    var id: String { uri }
    var trackID: String {
        didSet {
            Task {
                self.previewUrl = await LumeAudioPlayer.shared.getTrackByID(id: self.trackID)
                let _ = await self.initializeAudioPlayer()
            }
        }
    }
    let artistName: String
    let trackName: String
    var previewUrl: URL?
    var image: UIImage?
    var uri: String {
        didSet {
            Task {
                self.previewUrl = await LumeAudioPlayer.shared.getTrackByID(id: self.uri)
                let _ = await self.initializeAudioPlayer()
            }
        }
    }
    
    //for selecting tagging range of the music
    var tagMusicRange: ClosedRange<Float> = 0...30
    
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var isMuted: Bool = false {
        didSet {
            self.mute(mute: self.isMuted)
        }
    }
    
    private var playbackTimer: Timer?
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.uri == rhs.uri
    }
    
    init(trackID: String = "", artistName: String = "", trackName: String = "", previewUrl: URL? = nil, image: UIImage? = nil, uri: String = "", audioPlayer: AVAudioPlayer? = nil, tagMusicRange: ClosedRange<Float> = 0...30){
        self.trackID = trackID
        self.artistName = artistName
        self.trackName = trackName
        self.previewUrl = previewUrl
        self.image = image
        self.uri = uri
        self.tagMusicRange = tagMusicRange
        self.audioPlayer = audioPlayer
    }
    
    
    init(ql: TagTrackQL) {
        self.trackID = ql.trackID // uri
        self.artistName = ""
        self.trackName = ""
        self.uri = ql.trackID
        
        self.previewUrl = nil
        self.image = nil
        self.audioPlayer = nil

        if ql.tagMusicRange.count == 2 {
            let lowerBound = Float(ql.tagMusicRange[0])
            let upperBound = Float(ql.tagMusicRange[1])
            self.tagMusicRange = lowerBound...upperBound
        } else {
            // Handle the case where tagMusicRange is not properly formatted
            self.tagMusicRange = 0...30 // Default value
        }
    }
    
    
    // Playlist
    init(from trackDetail: TrackDetail, image: UIImage? = nil, audioPlayer: AVAudioPlayer? = nil, tagMusicRange: ClosedRange<Float> = 0...30){
        self.trackID = trackDetail.id
        self.artistName = trackDetail.artists.first?.name ?? "Unknown Artist"
        self.trackName = trackDetail.name
        
        // Safely unwrap and assign previewUrl
        if let urlString = trackDetail.preview_url {
            self.previewUrl = URL(string: urlString)
        } else {
            self.previewUrl = nil
        }
        
        self.image = image
        self.uri = trackDetail.uri
        self.tagMusicRange = tagMusicRange
        self.audioPlayer = audioPlayer
    }
    
    // Search
    init(from trackItem: TrackItem, image: UIImage? = nil, audioPlayer: AVAudioPlayer? = nil, tagMusicRange: ClosedRange<Float> = 0...30){
        self.trackID = trackItem.id
        self.artistName = trackItem.artists.first?.name ?? "Unknown Artist"
        self.trackName = trackItem.name
        
        // Safely unwrap and assign previewUrl
        if let urlString = trackItem.preview_url {
            self.previewUrl = URL(string: urlString)
        } else {
            self.previewUrl = nil
        }
        
        self.image = image
        self.uri = trackItem.uri
        self.tagMusicRange = tagMusicRange
        self.audioPlayer = audioPlayer
    }
    
    
    // Play the audio
    func playAudio(repeat: Bool = false) {
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        isPlaying = true
        startPlaybackTimer(repeat: `repeat`)
    }

    func playAudio(from time: Float, repeat: Bool = false) {
        audioPlayer?.currentTime = TimeInterval(time)
        audioPlayer?.play()
        isPlaying = true
        startPlaybackTimer(repeat: `repeat`)
    }

    func playAudio(from startTime: Float, to endTime: Float, repeat: Bool = false) {
        audioPlayer?.currentTime = TimeInterval(startTime)
        audioPlayer?.play()
        isPlaying = true
        startPlaybackTimer(endTime: endTime, repeat: `repeat`, startTime: startTime)
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        playbackTimer?.invalidate() // stop the timer when audio stops
    }
    
    func resetAudioPlayer() {
        audioPlayer?.stop()
        isPlaying = false
        audioPlayer?.currentTime = 0
        audioPlayer?.prepareToPlay()
        playbackTimer?.invalidate() // stop the timer when audio resets
    }
    
    private func startPlaybackTimer(endTime: Float? = nil, repeat: Bool = false, startTime: Float? = nil) {
        // Invalidate any existing timer
        playbackTimer?.invalidate()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            guard let currentTime = self.audioPlayer?.currentTime,
                  let duration = self.audioPlayer?.duration else {
                return
            }
            
            if let endTime = endTime {
                if Float(currentTime) >= endTime {
                    DispatchQueue.main.async {
                        self.stopAudio()
                        if `repeat` {
                            self.playAudio(from: startTime ?? 0, to: endTime, repeat: `repeat`)
                        }
                    }
                }
            } else if currentTime >= duration {
                DispatchQueue.main.async {
                    self.stopAudio()
                    if `repeat` {
                        self.playAudio(repeat: `repeat`)
                    }
                }
            }
        }
    }
    
    func getCurrentTrackDuration() -> TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    func initializeAudioPlayer(completion: @escaping (Bool) -> Void) {
        // Check if audioPlayer is nil
        if self.audioPlayer == nil {
            print("AudioPlayer for \(trackName) needs to be initialized")
            
            // Check if previewUrl is available
            if let previewURL = previewUrl {
                // Try to initialize AVAudioPlayer with previewUrl
                
                downloadFileFromURL(url: previewURL) { [self] url in
                    if let url = url {
                        do {
                            let player = try AVAudioPlayer(contentsOf: url)
                            self.audioPlayer = player
                                                        
                            completion(true)
                        } catch {
                            print("Error initializing AVAudioPlayer for \(trackName): \(error.localizedDescription)")
                            completion(false)
                        }
                    }
                }
            } else {
                print("Error initializing AVAudioPlayer for \(trackName): No Preview URL available.")
                completion(false)
            }
        } else {
            // AudioPlayer is already initialized
            completion(true)
        }
    }
    
    func initializeAudioPlayer() async -> Bool {
        if self.audioPlayer == nil {
            print("AudioPlayer for \(trackName) needs to be initialized")
            
            if let previewURL = previewUrl {
                do {
                    if let url = try await downloadFileFromURL(url: previewURL) {
                        let player = try AVAudioPlayer(contentsOf: url)
                        self.audioPlayer = player
                        return true
                    }
                } catch {
                    print("Error initializing AVAudioPlayer for \(trackName): \(error.localizedDescription)")
                    return false
                }
            } else {
                print("Error initializing AVAudioPlayer for \(trackName): No Preview URL available.")
                return false
            }
        }
        
        return true
    }
    
    
    // Tagging music
    // Use two Floats to define the range
    func tagMusic(start: Float, end: Float) {
        tagMusic(range: start...end)
    }
    
    // Use a ClosedRange<Float> to define the range
    func tagMusic(range: ClosedRange<Float>) {
        // Ensure start and end times are valid
        guard range.lowerBound >= 0,
              range.upperBound > range.lowerBound,
              let duration = audioPlayer?.duration,
              Float(duration) >= range.upperBound else {
            print("Invalid tag range: start must be >= 0, end must be > start, and end must be <= track duration.")
            return
        }
        
        // Assign the new range
        tagMusicRange = range
    }
    
    // Sub Functions
    func downloadFileFromURL(url: URL, completion: @escaping (URL?) -> Void){
        let downloadTask = URLSession.shared.downloadTask(with: url) { customURL, response, error in
            if let error = error {
                print("Error downloading file: \(error)")
                completion(nil)
            } else if let customURL = customURL {
                completion(customURL)
            }
        }
        downloadTask.resume()
    }
    
    func downloadFileFromURL(url: URL) async throws -> URL? {
        do {
            let (fileURL, _) = try await URLSession.shared.download(from: url)
            return fileURL
        } catch {
            print("Error downloading file: \(error)")
            throw error
        }
    }
    
    private func mute(mute: Bool = false) {
        self.audioPlayer?.volume = mute ? 0.0 : 1.0
    }
    
    func hasMusic() -> Bool {
        return self.trackID != ""
    }
}

struct TrackDetail: Equatable, Codable {
    let id: String
    let name: String
    let uri: String
    let preview_url: String?
    let album: AlbumDetail
    let artists: [ArtistDetail]
    
    static func == (lhs: TrackDetail, rhs: TrackDetail) -> Bool {
        return lhs.uri == rhs.uri && lhs.preview_url == rhs.preview_url && lhs.name == rhs.name
    }
    
    init(id: String = "",
         name: String = "",
         uri: String = "",
         preview_url: String = "",
         album: AlbumDetail = AlbumDetail(),
         artists: [ArtistDetail] = []) {
        self.id = id
        self.name = name
        self.uri = uri
        self.preview_url = preview_url
        self.album = album
        self.artists = artists
    }
    
    struct AlbumDetail: Codable {
        let images: [ImageDetail]
        
        init(images: [ImageDetail] = []) {
            self.images = images
        }
        
        struct ImageDetail: Codable {
            let height: Int
            let width: Int
            let url: String
            
            init(height: Int = 0, width: Int = 0, url: String = "") {
                self.height = height
                self.width = width
                self.url = url
            }
        }
    }
    
    struct ArtistDetail: Codable {
        let name: String
        
        init(name: String = "") {
            self.name = name
        }
    }
}

// Track Search Result

struct SpotifySearchResponse: Codable {
    let tracks: TracksResponse
}

struct TracksResponse: Codable {
    let href: String
    let items: [TrackItem]
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
}

struct TrackItem: Codable {
    let album: Album
    let artists: [Artist]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_ids: ExternalID
    let external_urls: ExternalURL
    let href: String
    let id: String
    let is_local: Bool
    let name: String
    let popularity: Int
    let preview_url: String?
    let track_number: Int
    let type: String
    let uri: String
}

struct Album: Codable {
    let album_type: String
    let artists: [Artist]
    let external_urls: ExternalURL
    let href: String
    let id: String
    let images: [ImageDetail]
    let name: String
    let release_date: String
    let release_date_precision: String
    let total_tracks: Int
    let type: String
    let uri: String
}

struct Artist: Codable {
    let external_urls: ExternalURL
    let href: String
    let id: String
    let name: String
    let type: String
    let uri: String
}

struct ExternalURL: Codable {
    let spotify: String
}

struct ExternalID: Codable {
    let isrc: String
}

struct ImageDetail: Codable {
    let height: Int
    let url: String
    let width: Int
}
