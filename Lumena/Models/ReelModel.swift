//
//  ReelModel.swift
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


class LumeVideo: Identifiable {
    
    let id = UUID()
    var player: AVPlayer?
    
    init(player: AVPlayer? = nil) {
        self.player = player
    }
    
    func mute(muteBool: Bool = true) {
        player?.isMuted = muteBool
    }
    
    func generateThumbnail() async -> UIImage? {
        guard let asset = player?.currentItem?.asset as? AVURLAsset else { return nil }
        
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: img)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

class LumeImage: Identifiable, ObservableObject {
    let id = UUID()
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    var url: URL?
    
    init(url: URL?) {
        self.url = url
        loadImage()
    }
    
    init(image: UIImage, url: URL? = nil) {
        self.image = image
        self.url = url
    }

    private func normalizeUrl(url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil  // Remove query to normalize
        return components?.url?.absoluteString ?? url.absoluteString
    }
    
    private func loadImage() {
        guard let url = url, image == nil else { return }
        
        let normalizedUrl = normalizeUrl(url: url)
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            self.image = cachedImage
            return
        }
        
        // Use Combine to handle image downloading if not in cache
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
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
    
    deinit {
        cancellable?.cancel()
    }
    
    static func fetchThumbnail(from url: URL) async -> UIImage? {
        let normalizedUrl = normalizeUrl(url: url)
        
        // Check cache first for thumbnail
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            return cachedImage
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("HTTP Error: Status code is not 200 for URL: \(url)")
                return nil
            }
            
            let image = UIImage(data: data)

            if let image = image {
                ImageCache.shared.store(image: image, forId: normalizedUrl)
            }
            return image
        } catch {
            print("Network Error: \(error.localizedDescription)")
            return nil
        }
    }

    // Helper method used in static context to normalize URL
    private static func normalizeUrl(url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil  // Remove query to normalize
        return components?.url?.absoluteString ?? url.absoluteString
    }
}


enum Content: Identifiable {
    case video(LumeVideo)
    case image(LumeImage)
    
    var id: UUID {
        switch self {
        case .video(let lumeImage):
            return lumeImage.id
        case .image(let lumeImage):
            return lumeImage.id
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
        return ids.compactMap { getLume(withID: $0) }
    }
    
    func getUserLumes(withID identityID: String) -> [Lume] {
        return lumes.values.filter { $0.postUserIID == identityID}
    }
    
    func getLumeQueue(withID id: String) {
        Task {
            let lume = Lume(id: id)
            LumeManager.shared.updateLume(lume)
            DispatchQueue.main.async {
                self.lumes[id] = lume
            }
        }
    }
    
    func updateLume(_ lume: Lume) {
        DispatchQueue.main.async { [self] in
            lumes[lume.postID] = lume
            objectWillChange.send()
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


class Lume: Identifiable, ObservableObject {
    
    var id: UUID = UUID()
    
    var postID: String = ""
    var postUserIID: String = ""
    
    var postURL: [String] = []
    
    var timestamp: Date = Date()
    var awsTimestamp: Double {
        return timestamp.timeIntervalSince1970
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
    var tagMusic: Track = Track()
    
    @Published var userLiked: Bool = false {
        didSet {
            LumeManager.shared.updateLume(self)
        }
    }
    
    var likeDebounceTimer: Timer?
    
    var contents: [Content] = []
    var currentContent: UUID = UUID()
    var previousContent: UUID = UUID()
    
    var thumbnail: UIImage?
    
    var userAlgoStruct: userAlgorithm = userAlgorithm()
    
    var zipURL: String = ""
    
    init() {}
    
    init(id: UUID = UUID(), postID: String = "", postUserIID: String = "", postURL: [String] = [], likedUsers: [String] = [], postDescription: String = "", userComments: [Comment] = [], tagProducts: [TagCosmetic] = [], tagMusic: Track = Track(), userLiked: Bool = false, likeCnt: Int = 0, contents: [Content] = [], currentContent: UUID = UUID(), userAlgoStruct: userAlgorithm = userAlgorithm(), timestamp: Date = Date(), zipURL: String = "") {
        
        if let postUUID = UUID(uuidString: postID) {
            self.id = postUUID
        } else {
            self.id = id
        }
        
        self.postID = postID
        self.postUserIID = postUserIID
        self.postURL = postURL
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
        
        LumeManager.shared.updateLume(self)
    }
    
    func setProperties(with lume: Lume) {
        DispatchQueue.main.async {
            self.id = UUID()  // Ensure a unique ID for the new instance
            self.postID = lume.postID
            self.postUserIID = lume.postUserIID
            self.postURL = lume.postURL.map { String($0) }  // Deep copy of URLs
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
        }
    }
    
    convenience init(ql: LumeQL, autoDownload: Bool = true) {
        
        let postID = UUID(uuidString: ql.id) ?? UUID()
        
        let tagProducts = ql.tagProducts?.compactMap { $0 != nil ? TagCosmetic(ql: $0!) : nil } ?? []
        
        //let tagProducts:[TagCosmetic] = []
        
        let tagMusic = Track(trackID: ql.tagMusic?.trackID ?? "")

        let postDescription = ql.description!
        let timestamp = Date(timeIntervalSince1970: Double(ql.timestamp))
        let likeCnt = ql.likeCount ?? 0
        let likedUsers: [String] = []
        
        var postUserID = ""
        
        let postUserIDParts = ql.id.split(separator: ":")
        if postUserIDParts.count >= 2 {
            postUserID = "\(postUserIDParts[0]):\(postUserIDParts[1])"
        } else {
            postUserID = ql.userprofile?.id ?? ""
        }
        
        let userLiked = false
        
        // Calling designated initializer
        self.init(
            id: postID,
            postID: ql.id,
            postUserIID: postUserID,
            postURL: ql.postURL?.compactMap { $0 } ?? [],
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
            zipURL: ql.zipURL ?? ""
        )
        
        self.fetchAndProcessReel { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("Failed to process reel: \(error)")
            }
        }
        
        userLikedPost()
        
        Task {
            let _ = await self.generateThumbnail()
            
//            fetchComment(commentLimit: 10)
            
            LumeManager.shared.updateLume(self)
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
            
            self.fetchAndProcessReel { result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print("Failed to process reel: \(error)")
                }
            }
            
            let _ = await self.generateThumbnail()
            
            userLikedPost()
            
//            fetchComment(commentLimit: 10)
            
            LumeManager.shared.updateLume(self)
        }
    }
    
    func toLumeQL() -> LumeQL {
        
        let postUser = ProfileManager.shared.profiles[self.postUserIID]!.toUserProfileQL()
        
        return LumeQL(
            id: self.postID,
            postURL: self.postURL,
            timestamp: Int(self.awsTimestamp),
            tagProducts: self.tagProducts.map {
                $0.toTagCosmeticQL()
            },
            tagMusic: TagTrackQL(trackID: self.tagMusic.uri, tagMusicRange: [Double(self.tagMusic.tagMusicRange.lowerBound), Double(self.tagMusic.tagMusicRange.upperBound)]),
            description: self.postDescription,
            userprofile: postUser
        )
    }
    
    
    //download process
    func fetchAndProcessReel(completion: @escaping (fetchAndProcessReelResult) -> Void) {
        
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
                        self.contents.append(.video(LumeVideo(player: player)))
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
        //let cloudFrontBaseURL = "https://d1s4m1vkr1js6q.cloudfront.net/public/"
        
        let ReelID = "\(GI.shared.profileSettings?.identityID ?? "null"):\(Int(Date.now.timeIntervalSince1970))"
        let ReelLocationS3 = "\(GI.shared.profileSettings?.identityID ?? "null")/\(ReelID)"
        
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
                        // Calculate the contribution of this content's progress to the overall progress.
                        let contentProgress = partProgress * progress
                        // Calculate and adjust the overall progress reported to account for this content's progress.
                        let newOverallProgress = overallProgressReported + contentProgress
                        // Ensure overall progress does not exceed 100%
                        let overallProgress = min(newOverallProgress * 0.95, 0.95)
                        print("Overall progress: \(overallProgress * 100)%")
                        GI.shared.postUploadProgress = overallProgress
                        
                        // Update the overallProgressReported if the content upload is complete
                        if progress >= 1.0 {
                            overallProgressReported += partProgress
                        }
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
                
                if let result = try await GraphQL.shared.createModel(self.toLumeQL()) {
                    
                    print(result)
                    
                    // process upload
                    let lumePostProcessResult = try await GraphQL.shared.lumePostProcess(postID: self.postID)
                    print(lumePostProcessResult)
                    
                } else {
                    print("Error: Could not create ReelQL")
                }
                
                GI.shared.postUploadProgress = 1.0
                GI.shared.postUploading = false
                
                LumeManager.shared.updateLume(self)
                
                completion(.success(()))
                
            } catch {
                print("Failed during upload process: \(error)")
                GI.shared.postUploading = false
                GI.shared.postUploadProgress = 0
                completion(.failure(.custom(error.localizedDescription)))
            }
        }
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
        _ = try await S3.shared.storeDataAsync(name: videoName, data: videoData!, accessLevel: .guest, progressHandler: progressUpdate)
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
        _ = try await S3.shared.storeDataAsync(name: imageName, data: imageData, accessLevel: .guest, progressHandler: progressUpdate)
        return imageName
    }

    
    //thumbnails
    func generateThumbnail() async -> UIImage? {
        guard let firstContent = contents.first else { return nil }
        
        switch firstContent {
        case .video(let reelVideo):
            // Use the method from LumeVideo class
            if let videoThumbnail = await reelVideo.generateThumbnail() {
                self.thumbnail = videoThumbnail
                return videoThumbnail
            } else {
                return nil
            }
            
        case .image(let reelImage):
            // Directly return the image if available, otherwise fetch from URL
            if let image = reelImage.image {
                self.thumbnail = image
                return image
            } else if let url = reelImage.url {
                // Use a static method or initializer from LumeImage class that fetches the image
                let fetchedThumbnail = await LumeImage.fetchThumbnail(from: url)
                self.thumbnail = fetchedThumbnail
                return fetchedThumbnail
            } else {
                return nil
            }
        }
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
    
    
    //like
    func likedLume(userLikeInput: Bool) {
        userLiked = userLikeInput

        if let userProfile = GI.shared.identityID
        {
            if userLiked {
                likedUsers.append(userProfile)
                self.likeCnt += 1
            } else {
                if let index = likedUsers.firstIndex(where: { $0 == userProfile }) {
                    likedUsers.remove(at: index)
                    self.likeCnt -= 1
                }
            }
        }
        
        likedLumeDebounced()
    }

    func likedLumeDebounced() {
        likeDebounceTimer?.invalidate()
        likeDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.likeLumeNetworkCall()
        }
    }

    func likeLumeNetworkCall() {
        // Your existing network call logic here, extracted from likedLume
        if let identityID = GI.shared.profileSettings?.identityID {
            Task {
                do {
                    let newLikeCnt = try await GraphQL.shared.likeLume(LumeID: self.postID, identityID: identityID, likeUnlike: userLiked)
                    self.likeCnt = newLikeCnt
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func userLikedPost() {
        Task {
            if let userIdentityID = GI.shared.identityID {
                let response = try await GraphQL.shared.SearchUserLikedPost(userID: userIdentityID, postId: self.postID)
                
                DispatchQueue.main.async {
                    self.userLiked = response
                    if let userIdentityID = GI.shared.identityID {
                        self.likedUsers.append(userIdentityID)
                    }
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
