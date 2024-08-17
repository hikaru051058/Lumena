//
//  LumeModel.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/09/27.
//

import SwiftUI
import AVKit
import Amplify
import Foundation
import Zip
import UIKit
import Combine
import ACThumbnailGenerator_Swift

class VideoThumbnailGeneratorManager: ACThumbnailGeneratorDelegate {
    static let shared = VideoThumbnailGeneratorManager()
    private var generator: ACThumbnailGenerator?
    private var currentUrl: URL?
    
    private init() {}
    
    func generator(_ generator: ACThumbnailGenerator_Swift.ACThumbnailGenerator, didCapture image: UIImage, at position: Double) {
        completion?(image)
        continuation?.resume(returning: image)
        continuation = nil
    }
    
    func getGenerator(for url: URL) -> ACThumbnailGenerator {
        if generator == nil || currentUrl != url {
            generator = ACThumbnailGenerator(streamUrl: url)
            generator?.delegate = self
            currentUrl = url
        }
        return generator!
    }
    
    func clearGenerator() {
        generator = nil
        currentUrl = nil
    }
    
    // Completion handler approach
    func captureThumbnail(for url: URL, at position: Double, completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        let generator = getGenerator(for: url)
        generator.captureImage(at: position)
    }
    
    // Swift concurrency approach
    private var continuation: CheckedContinuation<UIImage?, Never>?
    private var completion: ((UIImage?) -> Void)?
    
    func captureThumbnail(for url: URL, at position: Double) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            let generator = getGenerator(for: url)
            generator.captureImage(at: position)
        }
    }
}

class LumeVideo: Identifiable {
    
    let id = UUID()
    var player: AVPlayer?
    var url: URL?
    var thumbnail: UIImage?
    var lumeVideoAuth: Bool = false
    
    init(player: AVPlayer? = nil, url: URL? = nil, lumeAuth: Bool = false) {
        self.player = player
        self.url = url
        if let url = url {
            self.player = AVPlayer(url: url)
        }
        self.lumeVideoAuth = lumeAuth
    }
    
    func mute(muteBool: Bool = true) {
        player?.isMuted = muteBool
    }
    
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        guard let url = self.url else {
            completion(nil)
            return
        }
        VideoThumbnailGeneratorManager.shared.captureThumbnail(for: url, at: 1) { [weak self] image in
            self?.thumbnail = image
            completion(image)
        }
    }
    
    func generateThumbnailAsync() async -> UIImage? {
        await withCheckedContinuation { continuation in
            generateThumbnail { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    func seekVideo(to progress: CGFloat) {
        guard let duration = player?.currentItem?.duration else {
            return
        }
        let totalSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = CGFloat(totalSeconds) * progress
        let seekTime = CMTimeMakeWithSeconds(Float64(seekTimeInSeconds), preferredTimescale: Int32(NSEC_PER_SEC))
        player?.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    /// Returns the current playback progress as a percentage.
    func currentPlaybackProgress() -> CGFloat? {
        guard let currentTime = player?.currentTime(), let duration = player?.currentItem?.duration else {
            return nil
        }
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let durationSeconds = CMTimeGetSeconds(duration)
        if durationSeconds > 0 {
            return CGFloat(currentSeconds / durationSeconds)
        } else {
            return nil
        }
    }
    
    func getTotalDuration(completion: @escaping (CMTime) -> Void) {
        guard let player = player, let currentItem = player.currentItem else {
            completion(CMTime(seconds: 0, preferredTimescale: 1))
            return
        }

        let asset = currentItem.asset

        Task {
            do {
                let duration = try await asset.load(.duration)
                DispatchQueue.main.async {
                    completion(duration)
                }
            } catch {
                print("Failed to load duration: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(CMTime(seconds: 0, preferredTimescale: 1))
                }
            }
        }
    }
    
    func getTotalDuration() async throws -> CMTime {
        guard let player = player, let currentItem = player.currentItem else {
            return CMTime(seconds: 0, preferredTimescale: 1)
        }
        
        let asset = currentItem.asset
        return try await asset.load(.duration)
    }
    
    // New method to get the URL of the video
    func getVideoURL() -> URL? {
        return url
    }

    func replaceAudio(with track: Track, completion: @escaping (Bool) -> Void) {
        guard let currentItem = self.player?.currentItem else {
            completion(false)
            return
        }
        
        track.initializeAudioPlayer { success in
            guard success, let audioURL = track.previewUrl else {
                completion(false)
                return
            }

            let audioAsset = AVAsset(url: audioURL)
            let composition = AVMutableComposition()

            Task {
                do {
                    // Load video tracks asynchronously
                    let videoTracks = try await currentItem.asset.loadTracks(withMediaType: .video)
                    if let videoTrack = videoTracks.first {
                        let videoCompositionTrack = composition.addMutableTrack(
                            withMediaType: .video,
                            preferredTrackID: kCMPersistentTrackID_Invalid
                        )
                        let videoDuration = try await currentItem.asset.load(.duration)
                        let preferredTransform = try await videoTrack.load(.preferredTransform)
                        try videoCompositionTrack?.insertTimeRange(
                            CMTimeRange(start: .zero, duration: videoDuration),
                            of: videoTrack,
                            at: .zero
                        )
                        
                        // Set the preferred transform to maintain orientation
                        videoCompositionTrack?.preferredTransform = preferredTransform
                    }

                    // Load audio tracks asynchronously
                    let audioTracks = try await audioAsset.loadTracks(withMediaType: .audio)
                    if let audioTrack = audioTracks.first {
                        let audioCompositionTrack = composition.addMutableTrack(
                            withMediaType: .audio,
                            preferredTrackID: kCMPersistentTrackID_Invalid
                        )
                        let audioDuration = try await audioAsset.load(.duration)
                        try audioCompositionTrack?.insertTimeRange(
                            CMTimeRange(start: .zero, duration: audioDuration),
                            of: audioTrack,
                            at: .zero
                        )
                    }

                    let playerItem = AVPlayerItem(asset: composition)
                    self.player?.replaceCurrentItem(with: playerItem)
                    completion(true)
                } catch {
                    print("Error loading tracks or inserting time range: \(error)")
                    completion(false)
                }
            }
        }
    }
    
    // Function to remove audio from the video
    func removeAudio(completion: @escaping (Bool) -> Void) {
        guard let currentItem = self.player?.currentItem else {
            completion(false)
            return
        }
        
        let composition = AVMutableComposition()

        Task {
            do {
                // Load video tracks asynchronously
                let videoTracks = try await currentItem.asset.loadTracks(withMediaType: .video)
                if let videoTrack = videoTracks.first {
                    let videoCompositionTrack = composition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID: kCMPersistentTrackID_Invalid
                    )
                    let videoDuration = try await currentItem.asset.load(.duration)
                    let preferredTransform = try await videoTrack.load(.preferredTransform)
                    try videoCompositionTrack?.insertTimeRange(
                        CMTimeRange(start: .zero, duration: videoDuration),
                        of: videoTrack,
                        at: .zero
                    )
                    
                    // Set the preferred transform to maintain orientation
                    videoCompositionTrack?.preferredTransform = preferredTransform
                }

                // Do not add any audio tracks to the composition

                let playerItem = AVPlayerItem(asset: composition)
                self.player?.replaceCurrentItem(with: playerItem)
                completion(true)
            } catch {
                print("Error loading tracks or inserting time range: \(error)")
                completion(false)
            }
        }
    }
}

class LumeImage: Identifiable, ObservableObject {
    let id = UUID()
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    var url: URL?
    var lumeImageAuth: Bool = false
    
    init(url: URL?) {
        self.url = url
        loadImage()
    }
    
    init(image: UIImage, url: URL? = nil, lumeAuth: Bool = false) {
        self.image = image
        self.url = url
        self.lumeImageAuth = lumeAuth
    }

    private func normalizeUrl(url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil  // Remove query to normalize
        return components?.url?.absoluteString ?? url.absoluteString
    }
    
    private func adjustImageOrientationIfNeeded(_ image: UIImage) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        let targetAspectRatio = 1080.0 / 608.0 // This is roughly 1.7763

        let epsilon = 0.01
        if abs(aspectRatio - targetAspectRatio) < epsilon {
            return UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }
        return image
    }

    
    func loadImage() {
        guard let url = url, image == nil else { return }
        
        let normalizedUrl = normalizeUrl(url: url)
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            DispatchQueue.main.async {
                self.image = self.adjustImageOrientationIfNeeded(cachedImage)
            }
            return
        }
        
        // Use Combine to handle image downloading if not in cache
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .compactMap { UIImage(data: $0) }
            .map(adjustImageOrientationIfNeeded)
            .catch { _ in Just(nil) }
            .handleEvents(receiveOutput: { downloadedImage in
                if let downloadedImage = downloadedImage {
                    DispatchQueue.main.async {
                        ImageCache.shared.store(image: downloadedImage, forId: normalizedUrl)
                    }
                }
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] downloadedImage in
                self?.image = downloadedImage
            })
    }
    
    func loadAgain() async -> UIImage? {
        guard let url = url else { return nil }
        
        let normalizedUrl = normalizeUrl(url: url)
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            return adjustImageOrientationIfNeeded(cachedImage)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("HTTP Error: Status code is not 200 for URL in loadAgain: \(url)")
                return nil
            }
            
            if let image = UIImage(data: data) {
                let adjustedImage = adjustImageOrientationIfNeeded(image)
                ImageCache.shared.store(image: adjustedImage, forId: normalizedUrl)
                return adjustedImage
            } else {
                return nil
            }
        } catch {
            print("Network Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    deinit {
        cancellable?.cancel()
    }
        
    func fetchThumbnail(from url: URL) async -> UIImage? {
        let normalizedUrl = normalizeUrl(url: url)
        
        // Check cache first for thumbnail
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            return cachedImage
        }
        
        var retryCount = 0
        let maxRetries = 3
        
        while retryCount < maxRetries {
            if let image = await loadAgain() {
                ImageCache.shared.store(image: image, forId: normalizedUrl)
                return image
            } else {
                retryCount += 1
                print("Failed to fetch thumbnail after \(maxRetries) attempts for URL: \(url)")
            }
        }
        
        return nil
    }

    // Helper method used in static context to normalize URL
    private static func normalizeUrl(url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil  // Remove query to normalize
        return components?.url?.absoluteString ?? url.absoluteString
    }
    
    // New method to get the URL of the thumbnail
    func getThumbnailURL() -> URL? {
        return url
    }
}

enum LumeContent: Identifiable {
    case video(LumeVideo)
    case image(LumeImage)
    
    var id: UUID {
        switch self {
        case .video(let lumeVideo):
            return lumeVideo.id
        case .image(let lumeImage):
            return lumeImage.id
        }
    }
    
    func lumeAuth(auth: Bool) {
        switch self {
        case .video(let lumeVideo):
            lumeVideo.lumeVideoAuth = auth
        case .image(let lumeImage):
            lumeImage.lumeImageAuth = auth
        }
    }
}

class LumesWrapper: ObservableObject {
    @Published var Lumes: [Lume] = []
}

class LumeManager: ObservableObject {
    
    static let shared = LumeManager()
    
    @Published var lumes: [String: Lume] = [:]
    
    private init() {}
    
    func getLume(withID id: String) async throws -> Lume {
        if let existing = lumes[id] {
            return existing
        } else {
            let lume = Lume(id: id)
            LumeManager.shared.updateLume(lume)
            DispatchQueue.main.async {
                self.lumes[id] = lume
            }
            return lume
        }
    }
    
    func getLume(withID id: String) -> Lume {
        if let existing = lumes[id] {
            return existing
        } else {
            return Lume(id: id)
        }
    }
    
    func getLumes(withID ids: [String]) -> [Lume] {
        return ids.compactMap { lumes[$0] }
    }
        
    func getLumes(withID ids: [String]) async throws -> [Lume] {
        var result: [Lume] = []
        for id in ids {
            if let existing = lumes[id] {
                result.append(existing)
            } else {
                let lume = try await getLume(withID: id)
                result.append(lume)
            }
        }
        return result
    }
    
    func getUserPostLumes(withID identityID: String) -> [Lume] {
        Task {
            do {
                let lumeIDs = try await GraphQL.shared.fetchUserLumas(userProfileID: identityID)
                let notFetchedLumeIDs = lumeIDs.filter { lumes[$0] == nil }
                if !notFetchedLumeIDs.isEmpty {
                    let _ = try await LumeManager.shared.getLumes(withID: notFetchedLumeIDs)
                }
            } catch {
                print(error)
            }
        }
        return lumes.values.filter { $0.postUserIID == identityID}
    }
    
    func getUserLikedLumes(withID identityID: String) async throws -> [Lume] {
        var lumeIDs: [String] = []
        
        do {
            let userLikedPostsResponse = try await GraphQL.shared.fetchUserLikedPosts(userID: identityID)
            lumeIDs = userLikedPostsResponse.likes.map { $0.lumeQLID }
            let notFetchedLumeIDs = lumeIDs.filter { lumes[$0] == nil }
            if !notFetchedLumeIDs.isEmpty {
                _ = try await LumeManager.shared.getLumes(withID: notFetchedLumeIDs)
            }
            return lumeIDs.compactMap { lumes[$0] }
        } catch {
            print(error)
            throw error
        }
    }
    
    func getLumeQueue(withID id: String) {
        if lumes[id] == nil {
            let lume = Lume(id: id)
            LumeManager.shared.updateLume(lume)
        }
    }
    
    func updateLume(_ lume: Lume) {
        DispatchQueue.main.async { [self] in
            lumes[lume.postID] = lume
            objectWillChange.send()
        }
    }
    
    func setNewLume(_ lume: Lume) {
        if lumes.first(where: { $0.value.postID == lume.postID }) == nil {
            DispatchQueue.main.async { [self] in
                lumes[lume.postID] = lume
                objectWillChange.send()
            }
        }
    }
}

extension Lume {
    
    static func getCachedOrNew(postID: String) async -> Lume? {
        do {
            let result = try await LumeManager.shared.getLume(withID: postID)
            return result
        } catch {
            print(error)
        }
        return nil
    }
    
    func updateLume(with postID: String) async throws {
        do {
            let lumeFetched = try await GraphQL.shared.fetchSingleReelQL(reelQLId: postID)
            self.setProperties(with: lumeFetched)
            LumeManager.shared.updateLume(self)
        } catch {
            // Handle error
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unknown error occured while updating profile: \(error)"])
        }
    }
}

class Lume: Identifiable, ObservableObject, Hashable, Reflectable {
    
    var id: UUID = UUID()
    
    var postID: String = ""
    var postUserIID: String = ""
    
    var postURL: [String] = []
    var voiceOverURL: [String] = [] {
        didSet {
            self.muteVideos(mute: !voiceOverURL.isEmpty)
        }
    }
    
    var timestamp: Date = Date()
    var awsTimestamp: Double {
        return timestamp.timeIntervalSince1970
    }
    
    static func == (lhs: Lume, rhs: Lume) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    

    @Published var likedUsers: [String] = [] {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    @Published var likeCnt: Int = 0 {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    
    var postDescription: String?
    
    
    @Published var userComments: [Comment] = [] {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    var commentLastToken: String? {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    var userCommentFetchedAll: Bool = false
    
    var tagProducts: [TagCosmetic] = []
    var tagMusic: Track = Track() {
        didSet{
            if self.tagMusic.trackID != "" {
                musicTag = true
            } else {
                musicTag = false
            }
        }
    }
    var musicTag: Bool = false
    var longestDuration: CGFloat = 0.0
    
    @Published var voiceOver: AudioRecordingData = AudioRecordingData() {
        didSet {
            handleVoiceOverChange()
            LumeManager.shared.updateLume(self)
        }
    }
    
    @Published var userLiked: Bool = false {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    
    var contents: [LumeContent] = [] {
        didSet {
            self.lumeAuth = checkAuth()
            Task {
                self.longestDuration = await checkLongestVideoDuration()
                print(longestDuration)
            }
        }
    }
    
    var currentContent: UUID = UUID()
    var previousContent: UUID = UUID()
    
    @Published var thumbnail: UIImage? {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    
    @Published var thumbnailURL: URL? {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    
    var lumeAuth: Bool = false
    
    var userAlgoStruct: userAlgorithm = userAlgorithm()
    
    var zipURL: String = ""
    
    init() {}
    
    init(id: UUID = UUID(), postID: String = "", postUserIID: String = "", postURL: [String] = [], voiceOverURL: [String] = [], likedUsers: [String] = [], postDescription: String = "", userComments: [Comment] = [], tagProducts: [TagCosmetic] = [], tagMusic: Track = Track(), userLiked: Bool = false, likeCnt: Int = 0, contents: [LumeContent] = [], currentContent: UUID = UUID(), userAlgoStruct: userAlgorithm = userAlgorithm(), timestamp: Date = Date(), zipURL: String = "", lumeAuth: Bool = false) {
        
        if let postUUID = UUID(uuidString: postID) {
            self.id = postUUID
        } else {
            self.id = id
        }
        
        self.postID = postID
        self.postUserIID = postUserIID
        self.postURL = postURL
        self.voiceOverURL = voiceOverURL
        self.likedUsers = likedUsers
        self.likeCnt = likeCnt
        self.postDescription = postDescription
        self.userComments = userComments
        self.tagProducts = tagProducts
        self.tagMusic = tagMusic
        self.userLiked = userLiked
        self.contents = contents
        
        // Set currentContent to the UUID of the first item in contents if it's not empty
        if let firstContent = contents.first {
            self.currentContent = firstContent.id
        } else {
            self.currentContent = currentContent
        }
        
        self.userAlgoStruct = userAlgoStruct
        self.timestamp = timestamp
        self.zipURL = zipURL
        self.lumeAuth = lumeAuth
        
        LumeManager.shared.updateLume(self)
    }
    
    func setProperties(with lume: Lume) {
        DispatchQueue.main.async {
            self.id = UUID()  // Ensure a unique ID for the new instance
            self.postID = lume.postID
            self.postUserIID = lume.postUserIID
            self.postURL = lume.postURL.map { String($0) }  // Deep copy of URLs
            self.voiceOverURL = lume.voiceOverURL.map { String($0) }  // Deep copy of URLs
            self.timestamp = lume.timestamp
            self.likedUsers = lume.likedUsers  // Assuming deep copy is required
            self.likeCnt = lume.likeCnt
            self.postDescription = lume.postDescription
            self.userComments = lume.userComments
            self.tagProducts = lume.tagProducts
            self.tagMusic = lume.tagMusic
            self.userLiked = lume.userLiked
            self.contents = lume.contents
            self.currentContent = lume.currentContent
            self.previousContent = lume.previousContent
            self.thumbnail = lume.thumbnail
            self.userAlgoStruct = lume.userAlgoStruct
            self.zipURL = lume.zipURL
            self.lumeAuth = lume.lumeAuth
        }
    }
    
    convenience init(ql: LumeQL, autoDownload: Bool = true) {
        let postID = UUID(uuidString: ql.id) ?? UUID()
        let tagProducts = ql.tagProducts?.compactMap {TagCosmetic(ql: $0)} ?? []
        let tagMusic = Track(trackID: ql.tagMusic?.trackID ?? "")
        let postDescription = ql.description ?? ""
        
        // Handle optional timestamp
        let timestamp = Date(timeIntervalSince1970: Double(ql.timestamp))
        
        let likeCnt = ql.likeCount ?? 0
        let likedUsers: [String] = []
        
        var postUserID = ""
        let postUserIDParts = ql.id.split(separator: ":")
        if postUserIDParts.count >= 2 {
            postUserID = "\(postUserIDParts[0]):\(postUserIDParts[1])"
        } else {
            postUserID = ql.userprofileqlID
        }
        
        let userLiked = false
        
        // Calling designated initializer
        self.init(
            id: postID,
            postID: ql.id,
            postUserIID: postUserID,
            postURL: ql.postURL?.compactMap { $0 } ?? [],
            voiceOverURL: ql.voiceOverURL?.compactMap { $0 } ?? [],
            likedUsers: likedUsers,
            postDescription: postDescription,
            userComments: [],
            tagProducts: tagProducts,
            tagMusic: tagMusic,
            userLiked: userLiked,
            likeCnt: likeCnt,
            contents: [],
            currentContent: UUID(),
            userAlgoStruct: userAlgorithm(),
            timestamp: timestamp,
            zipURL: ql.zipURL ?? "",
            lumeAuth: ql.lumeAuth ?? false
        )
        
        self.fetchAndProcessLume { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("Failed to process reel: \(error)")
            }
        }
        
        setupVoiceOver()
        userLikedPost()
        
        DispatchQueue.main.async {
            Task {
                self.thumbnail = await self.getThumbnailImage()
                LumeManager.shared.updateLume(self)
            }
        }
    }
    
    convenience init(id: String) {
        self.init(postID: id)
        
        Task {
            
            let cachedOrNewLume = try await LumeManager.shared.getLume(withID: id)
            
            setProperties(with: cachedOrNewLume)
            
            var postUserID = ""
            
            let postUserIDParts = self.postID.split(separator: ":")
            if postUserIDParts.count >= 2 {
                postUserID = "\(postUserIDParts[0]):\(postUserIDParts[1])"
            } else {
                postUserID = self.postUserIID
            }
            
            self.postUserIID = postUserID
            
            self.fetchAndProcessLume { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Failed to process reel: \(error)")
                }
            }
            
            self.thumbnail = await self.getThumbnailImage()
            
            setupVoiceOver()
            userLikedPost()
            
//            fetchComment(commentLimit: 10)
            
            LumeManager.shared.updateLume(self)
        }
    }
    
    func toLumeQL() -> LumeQL {
        return LumeQL(
            id: self.postID,
            postURL: self.postURL,
            timestamp: Int(self.awsTimestamp),
            tagProducts: self.tagProducts.map {
                $0.toTagCosmeticQL()
            },
            tagMusic: TagTrackQL(trackID: self.tagMusic.uri, tagMusicRange: [Double(self.tagMusic.tagMusicRange.lowerBound), Double(self.tagMusic.tagMusicRange.upperBound)]),
            description: self.postDescription,
            userprofileqlID: self.postUserIID,
            lumeAuth: self.lumeAuth,
            voiceOverURL: self.voiceOverURL
        )
    }
    
    
    //download process
    func fetchAndProcessLume(completion: @escaping (fetchAndProcessReelResult) -> Void) {
        
        Task {
            do {
                getProfileQueue()
            }
        }
        
        for url in self.postURL {
            if url.hasPrefix("https://") {
                // Handle direct URLs
                if let url = URL(string: url) {
                    if url.path.hasSuffix(".jpg") || url.path.hasSuffix(".png") {
                        self.contents.append(.image(LumeImage(url:url)))
                    } else if url.path.hasSuffix(".mp4") || url.path.hasSuffix(".mov") || url.path.hasSuffix(".MOV") || url.path.hasSuffix(".m3u8") {
                        // Handle video content
                        let player = AVPlayer(url: url)
                        self.contents.append(.video(LumeVideo(player: player, url: url)))
                    } else {
                        print("Unsupported media format in URL: \(url)")
                        continue
                    }
                    
                } else {
                    print("Invalid URL: \(url)")
                }
            } else {
                // Handle any other URL formats or errors
                print("Unsupported URL format: \(url)")
            }
        }
        
        if let firstContent = self.contents.first {
            switch firstContent {
            case .video(let lumeVideo):
                currentContent = lumeVideo.id
                previousContent = lumeVideo.id
            case .image(let lumeImage):
                currentContent = lumeImage.id
                previousContent = lumeImage.id
            }
        }
        
        completion(.success(self))
    }
    
    //upload process
    func uploadLumeQL(completion: @escaping (Result<Void, LumeUploadError>) -> Void) {
        let s3Prefix = "s3://lumena225d91d9ee5c43d99341141978c6b54c25223-lumenaenv/public/"
        
        let ReelID = "\(GI.shared.identityID ?? "null"):\(Int(Date.now.timeIntervalSince1970))"
        let ReelLocationS3 = "\(GI.shared.identityID ?? "null")/\(ReelID)"
        
        self.postUserIID = GI.shared.identityID!
        
        self.postID = ReelID
        postURL.removeAll()
        
        Task {
            do {
                let totalContentCount = Double(self.contents.count)
                var overallProgressReported = 0.0
                
                GI.shared.postUploading = true
                
                for (index, content) in self.contents.enumerated() {
                    
                    let partProgress = 1.0 / totalContentCount
                    
                    let updateProgress: (Double) -> Void = { progress in
                        
                        let contentProgress = partProgress * progress
                        let newOverallProgress = overallProgressReported + contentProgress
                        let overallProgress = min(newOverallProgress * 0.95, 0.95)
                        
                        if progress >= 1.0 {
                            overallProgressReported += partProgress
                        }
                        
                        NotificationCenter.default.post(name: .uploadProgressUpdated, object: nil, userInfo: [
                            "postID": self.postID,
                            "progress": overallProgress,
                            "status": UploadProgressBarView.CompletionState.inProgress,
                            "index": index
                        ])
                    }
                    
                    switch content {
                    case .video(let reelVideo):
                        let videoName = try await handleVideoUpload(video: reelVideo, index: index, ReelLocationS3: ReelLocationS3, progressUpdate: updateProgress)
                        self.postURL.append("\(s3Prefix)\(videoName)")
                        
                    case .image(let reelImage):
                        let imageName = try await handleImageUpload(image: reelImage, index: index, ReelLocationS3: ReelLocationS3, progressUpdate: updateProgress)
                        self.postURL.append("\(s3Prefix)\(imageName)")
                    }
                }
                
                let voiceOverURLPath = await self.voiceOver.uploadFinalAudio(filePath: ReelLocationS3)
                self.voiceOverURL.append("\(voiceOverURLPath)")
                
                let _ = try await GraphQL.shared.createModel(self.toLumeQL())
                
                NotificationCenter.default.post(name: .uploadProgressUpdated, object: nil, userInfo: [
                    "postID": self.postID,
                    "progress": 1.0,
                    "status": UploadProgressBarView.CompletionState.successful,
                    "index": index
                ])
                
                LumeManager.shared.updateLume(self)
                
                completion(.success(()))
                
            } catch {
                print("Failed during upload process: \(error)")
                NotificationCenter.default.post(name: .uploadProgressUpdated, object: nil, userInfo: [
                                "postID": self.postID,
                                "status": UploadProgressBarView.CompletionState.failed,
                                "error": error.localizedDescription
                ])
                completion(.failure(.custom(error.localizedDescription)))
            }
            
            
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    func handleVideoUpload(video reelVideo: LumeVideo, index: Int, ReelLocationS3: String, progressUpdate: @escaping (Double) -> Void) async throws -> String {
        guard let asset = reelVideo.player?.currentItem?.asset else {
            fatalError("Video asset is unavailable.")
        }
        
        var outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
        var currentPreset = AVAssetExportPresetHEVCHighestQuality
        var videoData: Data?
        let maxInitialSize: Int = 4000 * 1_024 * 1_024 // 4GB in bytes
        
        func exportVideo() async throws -> URL {
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: currentPreset) else {
                fatalError("Unable to create AVAssetExportSession.")
            }
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            await exportSession.export()
            
            switch exportSession.status {
            case .completed:
                return outputURL
            case .failed, .cancelled:
                if let error = exportSession.error {
                    throw error
                } else {
                    fatalError("Video export failed without an error.")
                }
            default:
                fatalError("Unexpected export session status: \(exportSession.status)")
            }
        }
        
        // Try exporting with the highest quality preset first.
        outputURL = try await exportVideo()
        videoData = try Data(contentsOf: outputURL)
        
        // Step down in quality presets if the file size is too large.
        let qualityPresets = [AVAssetExportPresetHEVC1920x1080, AVAssetExportPreset1280x720]
        for preset in qualityPresets {
            if let size = videoData?.count, size > maxInitialSize {
                currentPreset = preset
                outputURL = try await exportVideo()
                videoData = try Data(contentsOf: outputURL)
            }
        }
        
        let videoName = "\(ReelLocationS3)/video\(index + 1).mp4"
        _ = try await S3.shared.storeDataAsync(name: videoName, data: videoData!, accessLevel: "public", progressHandler: progressUpdate)
        return videoName
    }
    
    func handleImageUpload(image reelImage: LumeImage, index: Int, ReelLocationS3: String, progressUpdate: @escaping (Double) -> Void) async throws -> String {
        guard let image = reelImage.image else {
            fatalError("Image is unavailable.")
        }
        let maxSize: Int = 3_072 * 1_024 // 3 MB
        var compressionQuality: CGFloat = 1.0

        func compressImage() -> Data? {
            var imageData = image.jpegData(compressionQuality: compressionQuality)
            while let data = imageData, data.count > maxSize {
                compressionQuality -= 0.05
                imageData = image.jpegData(compressionQuality: compressionQuality)
            }
            return imageData
        }

        guard let imageData = compressImage() else {
            fatalError("Failed to compress image.")
        }

        let imageName = "\(ReelLocationS3)/image\(index + 1).jpg"
        _ = try await S3.shared.storeDataAsync(name: imageName, data: imageData, accessLevel: "public", progressHandler: progressUpdate)
        return imageName
    }
    
    //video actions
    func muteVideos(mute: Bool = true) {
        for i in 0..<contents.count {
            if case .video(let reelVideo) = contents[i] {
                reelVideo.mute(muteBool: mute)
                contents[i] = .video(reelVideo) // Update the muted video back to the contents
            }
        }
    }
    
    func stopVideos() {
        for i in 0..<contents.count {
            if case .video(let reelVideo) = contents[i] {
                reelVideo.player?.pause()
                contents[i] = .video(reelVideo)
            }
        }
    }
    
    func stopVideo() {
        if let perviousContentPlaying = self.contents.first(where: {$0.id == self.previousContent}) {
            if case .video(let videoPlayer) = perviousContentPlaying {
                videoPlayer.player?.pause()
                videoPlayer.player?.isMuted = true
            }
        }
    }
    
    func playVideo(mute: Bool = false, seek: CMTime = CMTime.zero) {
        
        self.stopVideo()
        
        if let currentContentToPlay = self.contents.first(where: {$0.id == self.currentContent}){
            if case .video(let videoPlayer) = currentContentToPlay {
                videoPlayer.player?.play()
                videoPlayer.player?.seek(to: seek)
                videoPlayer.player?.isMuted = mute
            }
            
            self.previousContent = self.currentContent
        }
    }
    
    private func handleVoiceOverChange() {
        if voiceOver.audioLevels.count != 0 {
            tagMusic.audioPlayer?.volume = 0.7
        } else {
            tagMusic.audioPlayer?.volume = 1.0
        }
    }
    
    private func checkAuth() -> Bool {
        for indivContent in self.contents {
            switch indivContent {
            case .video(let lumeVideo):
                if lumeVideo.lumeVideoAuth == false {
                    return false
                }
            case .image(let lumeImage):
                if lumeImage.lumeImageAuth == false {
                    return false
                }
            }
        }
        return true
    }
    
    func checkLongestVideoDuration() async -> CGFloat {
        var longestDuration: CGFloat = 0
        
        for indivContent in self.contents {
            switch indivContent {
            case .video(let lumeVideo):
                do {
                    let duration = try await lumeVideo.getTotalDuration()
                    let totalSeconds = CMTimeGetSeconds(duration)
                    if CGFloat(totalSeconds) > longestDuration {
                        longestDuration = CGFloat(totalSeconds)
                    }
                } catch {
                    print("Failed to get duration: \(error.localizedDescription)")
                }
            case .image:
                continue
            }
        }
        
        return longestDuration
    }
    
    func playAudio(repeatAudio: Bool = false) {
        if self.voiceOver.hasRecording {
            self.muteVideos(mute: true)
            self.voiceOver.play(repeatAudio: repeatAudio)
        }
        self.tagMusic.playAudio(from: 0.0, to: Float(self.voiceOver.recordingDuration), repeat: repeatAudio)
    }
    
    func stopAudio() {
        self.voiceOver.stop()
        self.tagMusic.stopAudio()
    }
    
    private func setupVoiceOver() {
        guard let stringURL = self.voiceOverURL.first, let url = URL(string: stringURL) else { return }
        self.voiceOver.setAudioPlayerURL(url: url)
    }
    
    //like
    
    private var lastConfirmedLiked: Bool?
    private var lastServerConfirmedLikeCount: Int = 0
    private var likeDebounceTimer: Timer?
    
    func likedLume(userLikeInput: Bool) {
        userLiked = userLikeInput
        
        // Update UI immediately and manage local counts
        if let userProfile = GI.shared.identityID {
            if userLiked {
                if !likedUsers.contains(userProfile) {
                    likedUsers.append(userProfile)
                    self.likeCnt = max(likeCnt + 1, 0)  // Ensure it doesn't go negative
                }
            } else {
                if let index = likedUsers.firstIndex(where: { $0 == userProfile }) {
                    likedUsers.remove(at: index)
                    self.likeCnt = max(likeCnt - 1, 0)  // Ensure it doesn't go negative
                }
            }
        }
        
        // Schedule a network update
        scheduleLikeLumeNetworkCall()
    }
    
    private func scheduleLikeLumeNetworkCall() {
        likeDebounceTimer?.invalidate()
        
        likeDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.likeLumeNetworkCall()
        }
    }

    private func likeLumeNetworkCall() {
        guard let identityID = GI.shared.identityID else {
            return
        }
        
        // Check if the final state differs from the last confirmed state
        if lastConfirmedLiked == nil || lastConfirmedLiked != userLiked {
            lastConfirmedLiked = userLiked
            
            Task {
                do {
                    let newLikeCnt = try await GraphQL.shared.likeLume(LumeID: self.postID, identityID: identityID, likeUnlike: userLiked)
                    DispatchQueue.main.async {
                        // Update the like count with the latest from the server, synchronize it
                        self.likeCnt = newLikeCnt
                        self.lastServerConfirmedLikeCount = newLikeCnt
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    func checkUserLikedPost() -> Bool {
        guard let userIdentityID = GI.shared.identityID else {
            return false
        }
        // Check if user's like status can be determined immediately
        if likedUsers.contains(userIdentityID) {
            return true
        } else {
            userLiked = false
        }
        return false
    }
    
    func userLikedPost() {
        
        if checkUserLikedPost() {
            return
        }
        
        guard let userIdentityID = GI.shared.identityID else {
            return
        }
        
        Task {
            let response = try await GraphQL.shared.SearchUserLikedPost(userID: userIdentityID, postId: self.postID)
            
            DispatchQueue.main.async {
                self.userLiked = response
                if response {
                    if !self.likedUsers.contains(userIdentityID) {
                        self.likedUsers.append(userIdentityID)
                    }
                    
                } else {
                    self.likedUsers.removeAll { $0 == userIdentityID }
                    
                }
            }
        }
    }
    
    
    //comment
    func fetchComment(commentLimit: Int = 20) {
        if !self.userCommentFetchedAll {
            Task {
                do {
                    let (comments, nextToken) = try await GraphQL.shared.fetchLumeComments(LumeID: self.postID, commentLimit: commentLimit, lastToken: self.commentLastToken ?? "")
                    
                    DispatchQueue.main.async {
                        self.userComments = comments
                        self.commentLastToken = nextToken
                        
                        if comments.count < commentLimit {
                            self.userCommentFetchedAll = true
                        }
                        
                        LumeManager.shared.updateLume(self)
                    }
                } catch {
                    print(error)
                }
            }
        } else {
            print("Fetched all the associated comments for this Lume")
        }
    }
    
    func returnPostUser() -> ProfileSettings {
        return ProfileManager.shared.getProfile(withID: self.postUserIID)
    }
    
    // queue fetching profile in the ProfileManager so it will be donwloaded when in needed
    func getProfileQueue() {
        Task {
            do {
                try await ProfileManager.shared.getProfileQueue(withID: self.postUserIID)
            } catch {
                print(error)
            }
        }
    }
    
    private func dateFromTimestamp(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    // audio
    func mute(mute: Bool = false) {
        self.muteVideos(mute: mute)
        self.voiceOver.isMuted = mute
        self.tagMusic.isMuted = mute
    }
}


// MARK: thumbnails
extension Lume {
    
    func getThumbnailImage() async -> UIImage? {
        guard let firstContent = contents.first else { return nil }

        switch firstContent {
        case .video(let reelVideo):
            // Use the async method from LumeVideo class
            if let videoThumbnail = await reelVideo.generateThumbnailAsync() {
                self.thumbnail = videoThumbnail
                print("Thumbnail generated successfully.")
                return videoThumbnail
            } else {
                // Handle the case where thumbnail generation failed
                print("Failed to generate thumbnail.")
                return nil
            }

        case .image(let reelImage):
            // Directly return the image if available, otherwise fetch from URL
            if let image = reelImage.image {
                self.thumbnail = image
                return image
            } else if let url = reelImage.url {
                // Use a static method or initializer from LumeImage class that fetches the image
                let fetchedThumbnail = await reelImage.fetchThumbnail(from: url)
                self.thumbnail = fetchedThumbnail
                return fetchedThumbnail
            } else {
                return nil
            }
        }
    }
    
    func getThumbnailURL() -> URL? {
        guard let firstContent = contents.first else { return nil }
        
        switch firstContent {
        case .video(let reelVideo):
            // Use the method from LumeVideo class
            return reelVideo.getVideoURL()
            
        case .image(let reelImage):
            // Directly return the image if available, otherwise fetch from URL
            return reelImage.getThumbnailURL()
        }
    }
    
    func loadThumbnailAsync() {
        // Asynchronous thumbnail loading logic
        Task {
            if let url = self.thumbnailURL {
                let image = await loadImage(from: url) // An async method to fetch the image
                DispatchQueue.main.async {
                    self.thumbnail = image
                }
            }
        }
    }
    
    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
}



enum LumeUploadError: Error {
    case exportFailed(Error)
    case noContent
    case fileSystemError(Error)
    case custom(String)
}

struct LumeMinimalResponse: Codable {
    var id: String
    var timestamp: Int
    var userprofileqlID: String
}

struct LumeContainer: Codable {
    var items: [LumeMinimalResponse]
    var lastEvaluatedKey: String?
}

struct UserFollowingLumesResponse: Codable {
    var message: String
    var lumes: [LumeContainer]
    var followingsNextToken: String?
}

enum fetchAndProcessReelResult {
    case success(Lume)
    case failure(fetchAndProcessLumeError)
}

enum fetchAndProcessLumeError: Error {
    case unsuccessfulRetrieval
    case dataProcessingError
    case networkError
    case unknownError
}

class LumeErrorCollector {
    private var errors: [Error] = []
    private let queue = DispatchQueue(label: "com.yourapp.errorCollector")

    func add(_ error: Error) {
        queue.async {
            self.errors.append(error)
        }
    }

    func all() -> [Error] {
        return queue.sync { errors }
    }
}


extension fetchAndProcessLumeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsuccessfulRetrieval:
            return NSLocalizedString("Failed to retrieve data.", comment: "Unsuccessful Retrieval")
        case .dataProcessingError:
            return NSLocalizedString("Error occurred while processing data.", comment: "Data Processing Error")
        case .networkError:
            return NSLocalizedString("Network error occurred.", comment: "Network Error")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred.", comment: "Unknown Error")
        }
    }
}





struct userAlgorithm {
    
    var postDescription: String = ""
    var watchCnt: Int = 0
    
    // Default initializer
    init() {
        self.postDescription = ""
        self.watchCnt = 0
    }
    
    init(postDescription: String = "", watchCnt: Int = 0) {
        self.postDescription = postDescription
        self.watchCnt = watchCnt
    }
}


struct UserProfileInfo {
    
    var username: String?
    var userSub: String?
    var firstName: String?
    var bio: String?
    
    var profileImage: UIImage?
    var backgroundImage: UIImage?
    
    var postContents: [Lume]?
    
    var followingUsers: [UserProfileInfo]?
    var followerUsers: [UserProfileInfo]?
    
    init() {
        self.username = nil
        self.userSub = nil
        self.firstName = nil
        self.bio = nil
        self.profileImage = nil
        self.backgroundImage = nil
        self.postContents = nil
        self.followingUsers = nil
        self.followerUsers = nil
    }
}



struct SearchUserLikedResponse: Codable {
    let likeExists: Bool
}

struct UserLikedPostsResponse: Codable {
    let likes: [LikedPosts]
    let nextToken: String?
}

// Define the Like structure that corresponds to each like in the "likes" array
struct LikedPosts: Codable {
    let id: String
    let lumeQLID: String
    let timestamp: Int
}

struct LikeResponse: Codable {
    let message: String
    let data: LikeData
}

struct LikeData: Codable {
    let likeCount: Int
}

struct CommentResponse: Decodable {
    let comments: [CommentQL]
    let nextToken: String?
}

class Comment: Identifiable, ObservableObject {
    let id = UUID()
    var commentID: String
    
    var userProfile: ProfileSettings
    
    var timestamp: Date = Date()
    var awsTimestamp: Double {
        return timestamp.timeIntervalSince1970
    }
    var content: String
    var lumeQLID: String
    
    // Computed property to get timestamp as a String
    var timestampString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: timestamp)
    }
    
    init(commentID: String = "",
         userProfile: ProfileSettings = ProfileSettings(),
         timestamp: Date = Date(),
         content: String = "",
         lumeQLID: String = ""
    ){
        self.commentID = commentID
        self.userProfile = userProfile
        self.timestamp = timestamp
        self.content = content
        self.lumeQLID = lumeQLID
    }
    
    convenience init(ql: CommentQL) {
        let timestampInt = Date(timeIntervalSince1970: TimeInterval(ql.timestamp))
        self.init(
            commentID: ql.id,
            timestamp: timestampInt,
            content: ql.comment,
            lumeQLID: ql.lumeQLID
        )
        Task {
            do {
                self.userProfile = try await ProfileManager.shared.getProfile(withID: ql.userprofileqlID)
            } catch {
                print(error)
            }
        }
    }
    
    func toCommentQL() -> CommentQL {
        return CommentQL(
            id: commentID,
            timestamp: Int(awsTimestamp),
            comment: content,
            lumeQLID: lumeQLID,
            userprofileqlID: userProfile.identityID
        )
    }
    
    func postComment() async throws -> String {
        do {
            let result = try await GraphQL.shared.createModel(self.toCommentQL())
            return (result ?? "Successfully created comment for \(lumeQLID) with \(commentID)")
        } catch {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unable to upload comment for \(lumeQLID) with \(commentID)"])
        }
    }
}
