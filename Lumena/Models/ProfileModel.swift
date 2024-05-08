//
//  ProfileModel.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/09/27.
//
import Amplify
import Foundation
import UIKit
import SwiftUI

class ProfileManager: ObservableObject {
    
    static let shared = ProfileManager()
    
    @Published var profiles: [String: ProfileSettings] = [:]
    @Published var relationships: [String: [String: RelationshipType]] = [:]
    
    private init() {} // Private initialization to enforce singleton
    
    func getProfile(withID id: String) async throws -> ProfileSettings {
        if let existingProfile = profiles[id] {
            return existingProfile
        } else {
            if id == "" {
                print("NULL id deteceted in getProfile async")
            }
            let profile = await getProfileAPI(with: id)
            guard let profile = profile else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No ProfileSettings has been returned when called getProfile"])
            }
            
            DispatchQueue.main.async {
                self.profiles[id] = profile
            }
            return profile
        }
    }
    
    func getProfile(withID id: String) -> ProfileSettings {
        if let existingProfile = profiles[id] {
            return existingProfile
        } else {
            if id == "" {
                print("NULL id deteceted in getProfile")
            }
            let newProfile = ProfileSettings(id: id)
            DispatchQueue.main.async {
                self.profiles[id] = newProfile
            }
            return newProfile
        }
    }
    
    func hasProfile(id: String) -> Bool {
        return profiles.values.contains(where: { $0.identityID == id})
    }
    
    func getProfileQueue(withID id: String) async throws {
        if !profiles.values.contains(where: { $0.identityID == id }) {
            if id == "" {
                print("NULL id deteceted in getProfileQueue async")
            }
            let profile = await getProfileAPI(with: id)
            guard let profile = profile else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No ProfileSettings has been returned when called getProfileQueue"])
            }
            
            let profileFollowerManager = ProfileFollowManager(userID: id, limit: 10)
            profile.followManager = profileFollowerManager
            ProfileManager.shared.updateProfile(profile)
            DispatchQueue.main.async {
                self.profiles[id] = profile
            }
        }
    }
    
    func getArrayProfiles(ids: [String]) -> [ProfileSettings] {
        return ids.compactMap { profiles[$0] }
    }
    
    func getProfileAPI(with userID: String) async -> ProfileSettings? {
        do {
            let arrUserProf = try await GraphQL.shared.fetchUserProfileQL(userIDs: [userID])
            
            guard let userProfile = arrUserProf.first else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No UserProfileQL has been returned when called UpdateProfile for \(userID)"])
            }
            
            return ProfileSettings(ql: userProfile)
            
        } catch {
            print("Error fetching user profile, attempting to fix...")
            // Attempt to fix the user profile if it exists
            if let userProfile = try? await GraphQL.shared.fetchUserProfileQL(userIDs: [userID]).first {
                do {
                    let newProfile = try await fixUserProfile(profile: userProfile)
                    return newProfile
                } catch {
                    print("Failed to fix UserProfileQL: \(error)")
                }
            }
        }
        return nil
    }
    
    func fixUserProfile(profile: UserProfileQL) async throws -> ProfileSettings {
        
        do {
            // Attempt to delete the problematic user profile
            try await GraphQL.shared.deleteModel(profile)
        } catch {
            print(error)
        }
        
        // Recreate the user profile based on current authenticated user attributes
        let amplifyAttributes = try await Amplify.Auth.fetchUserAttributes()
        let newProfileSettings = ProfileSettings(from: amplifyAttributes)
        
        // Save the newly created profile to the database
        let _ = try await GraphQL.shared.createModel(newProfileSettings.toUserProfileQL())
        
        return newProfileSettings
    }
    
    func updateProfile(_ profile: ProfileSettings) {
        DispatchQueue.main.async { [self] in
            profiles[profile.identityID] = profile
            objectWillChange.send()
        }
    }
    
    // Updates or fetches relationships if not present
    func fetchRelationshipStat(fromUserID: String, toUserID: String) async -> RelationshipType {
        if let fromUserRelationships = relationships[fromUserID],
           let relationship = fromUserRelationships[toUserID] {
            return relationship
        } else {
            
            do {
                let fetchedRelationship = try await GraphQL.shared.fetchUserFollowStat(followerId: fromUserID, followingId: toUserID)
                updateLocalRelationshipState(fromUserID: fromUserID, toUserID: toUserID, relationshipStatus: fetchedRelationship)
                return fetchedRelationship
            } catch {
                print(error)
            }
            
            return .disconnected
        }
    }
    
    // Updates the relationships in a centralized manner
    private func updateLocalRelationshipState(fromUserID: String, toUserID: String, relationshipStatus: RelationshipType) {
        var userRelationships = relationships[fromUserID] ?? [:]
        userRelationships[toUserID] = relationshipStatus
        relationships[fromUserID] = userRelationships
        
        var reverseRelationships = relationships[toUserID] ?? [:]
        reverseRelationships[fromUserID] = relationshipStatus.invert()
        relationships[toUserID] = reverseRelationships
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    // Retrieves the relationship status using cached or fetched data
    func getRelationshipStat(fromUserID: String, toUserID: String) async -> RelationshipType {
        if let fromUserRelationships = relationships[fromUserID],
           let relationship = fromUserRelationships[toUserID] {
            return relationship
        }
        return await fetchRelationshipStat(fromUserID: fromUserID, toUserID: toUserID)
    }
    
    // Manage following actions
    func updateFollowingStatus(fromUserID: String, toUserID: String, follow: Bool) {
        
        let currentStatus = relationships[fromUserID]?[toUserID] ?? .none
        
        // Determine the new relationship status based on the action
        let newStatus = follow ? determineNewFollowingStatus(currentStatus) : determineNewUnfollowingStatus(currentStatus)
        
        // Update the local and inverse relationship states
        updateLocalRelationshipState(fromUserID: fromUserID, toUserID: toUserID, relationshipStatus: newStatus)
        
        // Adjust follower/following counts
        //adjustCounts(for: fromUserID, toUserID: toUserID, newRelationship: newStatus, follow: follow)
        
        Task {
            do {
                // Communicate the change to the server
                _ = try await GraphQL.shared.followUser(currUserId: fromUserID, followUserId: toUserID, followUnfollow: follow)
                
            } catch {
                print("Failed to update following status: \(error)")
            }
        }
    }

    // Helper functions to determine new relationship statuses based on following or unfollowing actions
    private func determineNewFollowingStatus(_ currentStatus: RelationshipType) -> RelationshipType {
        switch currentStatus {
        case .follower:
            return .mutual
        case .none, .disconnected, .unknown:
            return .following
        default:
            return currentStatus // Returns current if already following or mutual
        }
    }

    private func determineNewUnfollowingStatus(_ currentStatus: RelationshipType) -> RelationshipType {
        switch currentStatus {
        case .mutual:
            return .follower  // They follow you, but you stop following them
        case .following:
            return .none  // No relationship after you stop following them
        default:
            return currentStatus // Returns current if already none or not following
        }
    }
    
    // Method to fetch and assign relationship data
    private func fetchAndAssignRelationshipData(for profile: ProfileSettings) async throws {
        // Assuming the user has a follow manager set up
        guard let followManager = profile.followManager else {
            profile.followManager = ProfileFollowManager(userID: profile.identityID)
            return
        }
        // Fetch relationship stats for the user
        await followManager.fetchFollows(relationship: .mutual, limit: 20)
    }
    
    
    func processFetchedFollowData(userID: String, response: FollowResponse, relationshipType: RelationshipType) {
        DispatchQueue.main.async {
            // Process followers
            if relationshipType == .follower || relationshipType == .mutual {
                response.followers?.forEach { follower in
                    let followerID = follower.followerID
                    self.updateLocalRelationshipState(fromUserID: followerID, toUserID: userID, relationshipStatus: .follower)
                }
            }

            // Process followings
            if relationshipType == .following || relationshipType == .mutual {
                response.followings?.forEach { following in
                    let followingID = following.followingID
                    self.updateLocalRelationshipState(fromUserID: userID, toUserID: followingID, relationshipStatus: .following)
                }
            }
        }
    }
    
    private func adjustCounts(for fromUserID: String, toUserID: String, newRelationship: RelationshipType, follow: Bool) {
        DispatchQueue.main.async { [self] in
            guard let fromProfile = profiles[fromUserID], let toProfile = profiles[toUserID] else {
                print("One of the profiles is not found, cannot update counts.")
                return
            }

            if follow {
                switch newRelationship {
                case .following, .mutual:
                    fromProfile.followingCount += 1
                    toProfile.followerCount += 1
                default:
                    break
                }
            } else {
                switch newRelationship {
                case .follower:
                    fromProfile.followingCount -= 1
                    toProfile.followerCount += 1 // Adjust because now it is one-way
                case .none:
                    fromProfile.followingCount -= 1
                    if toProfile.followingCount > 0 {
                        toProfile.followingCount -= 1 // They were a mutual follower, now none
                    }
                default:
                    break
                }
            }

            // Update profiles in the central store to ensure the UI and other components reflect these changes
            updateProfile(fromProfile)
            updateProfile(toProfile)
        }
    }
}

class ProfileSettings: Identifiable, ObservableObject {
    
    var id: UUID = UUID()
    
    var userprofileqlID: String
    var identityID: String
    var birthDate: Date
    var emailVerified: Bool
    var phoneNumberVerified: Bool
    var phoneNumber: String
    @Published var preferredUsername: String {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    @Published var givenName: String {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    var familyName: String
    var email: String
    var pictureURL: URL?
    @Published var lockState: Bool {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    @Published var bio: String {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    @Published var profileImage: profileImage? {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    @Published var backgroundImage: profileImage? {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    @Published var postContents: [String] {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    @Published var likeContents: [String] {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    
    @Published var followManager: ProfileFollowManager? {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    
    @Published var followingCount: Int = 0
    @Published var followerCount: Int = 0
    
    @Published var lastUpdateTimestamp: Int {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    
    var skinSetting: [Int] {
        didSet {
            ProfileManager.shared.updateProfile(self)
        }
    }
    
    var awsTimestamp: Double {
        return birthDate.timeIntervalSince1970
    }
    
    init(id: UUID = UUID(),
         userprofileqlID: String = "",
         identityID: String = "",
         birthDate: Date = Date(),
         emailVerified: Bool = false,
         phoneNumberVerified: Bool = false,
         phoneNumber: String = "",
         preferredUsername: String = "",
         givenName: String = "",
         familyName: String = "",
         email: String = "",
         pictureURL: URL? = nil,
         lockState: Bool = false,
         bio: String = "",
         profileImage: profileImage? = nil, // Empty Image
         backgroundImage: profileImage? = nil,
         postContents: [String] = [],
         likeContents: [String] = [],
         followingCount: Int = 0,
         followerCount: Int = 0,
         lastUpdateTimestamp: Int = Int(NSDate().timeIntervalSince1970),
         skinSetting: [Int] = [0, 0, 0]
    ) {
        if let userID = UUID(uuidString: userprofileqlID) {
            self.id = userID
        } else {
            self.id = id
        }
        self.userprofileqlID = userprofileqlID
        self.identityID = identityID
        self.birthDate = birthDate
        self.emailVerified = emailVerified
        self.phoneNumberVerified = phoneNumberVerified
        self.phoneNumber = phoneNumber
        self.preferredUsername = preferredUsername
        self.givenName = givenName
        self.familyName = familyName
        self.email = email
        self.pictureURL = pictureURL
        self.lockState = lockState
        self.bio = bio
        self.profileImage = profileImage
        self.backgroundImage = backgroundImage
        self.postContents = postContents
        self.likeContents = likeContents
        self.followingCount = followingCount
        self.followerCount = followerCount
        self.lastUpdateTimestamp = lastUpdateTimestamp
        self.skinSetting = skinSetting
    }
    
    init(from attributes: [AuthUserAttribute]) {
        self.id = UUID()
        self.userprofileqlID = ""
        self.identityID = ""
        self.birthDate = Date()
        self.emailVerified = false
        self.phoneNumberVerified = false
        self.phoneNumber = ""
        self.preferredUsername = ""
        self.givenName = ""
        self.familyName = ""
        self.email = ""
        self.pictureURL = nil
        self.lockState = false
        self.bio = ""
        self.profileImage = nil
        self.backgroundImage = nil
        self.postContents = []
        self.likeContents = []
        self.followingCount = 0
        self.followerCount = 0
        self.followManager = ProfileFollowManager(userID: self.identityID)
        self.lastUpdateTimestamp = Int(NSDate().timeIntervalSince1970)
        self.skinSetting = [0, 0, 0]
        
        for attribute in attributes {
            switch attribute.key {
            case .sub:
                userprofileqlID = attribute.value
            case .birthDate:
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                birthDate = dateFormatter.date(from: attribute.value)!
            case .emailVerified:
                emailVerified = Bool(attribute.value)!
            case .phoneNumberVerified:
                phoneNumberVerified = Bool(attribute.value)!
            case .phoneNumber:
                phoneNumber = attribute.value
            case .preferredUsername:
                preferredUsername = attribute.value
            case .givenName:
                givenName = attribute.value
            case .familyName:
                familyName = attribute.value
            case .email:
                email = attribute.value
            case .picture:
                pictureURL = URL(string: attribute.value)
                
            // custom attributes
            case .custom("bio"):
                bio = attribute.value
            case .custom("private"):
                if let intValue = Int(attribute.value) {
                    if intValue == 0 {
                        lockState = false
                    } else {
                        lockState = true
                    }
                } else {
                    // Handle the case where attribute.value is not a valid integer string
                    print("Error: attribute.value is not a valid integer string")
                }
            case .custom("SkinSensitivity"):
                skinSetting[0] = Int(attribute.value) ?? 0
            case .custom("SkinUVBathing"):
                skinSetting[1] = Int(attribute.value) ?? 0
            case .custom("SkinType"):
                skinSetting[2] = Int(attribute.value) ?? 0
                
            default:
                continue
            }
        }
        
        Task {
            do {
                try await self.fetchUserImages()
                try await self.fetchUserRelatedLumes()
                
                ProfileManager.shared.updateProfile(self)
            } catch {
                print(error)
            }
        }
        
    }
    
    // Copy initializer: Initializes a new instance using another instance's properties
    init(from profile: ProfileSettings) {
        self.id = profile.id
        self.userprofileqlID = profile.userprofileqlID
        self.identityID = profile.identityID
        self.birthDate = profile.birthDate
        self.emailVerified = profile.emailVerified
        self.phoneNumberVerified = profile.phoneNumberVerified
        self.phoneNumber = profile.phoneNumber
        self.preferredUsername = profile.preferredUsername
        self.givenName = profile.givenName
        self.familyName = profile.familyName
        self.email = profile.email
        self.pictureURL = profile.pictureURL
        self.lockState = profile.lockState
        self.bio = profile.bio
        self.profileImage = profile.profileImage
        self.backgroundImage = profile.backgroundImage
        self.postContents = profile.postContents
        self.likeContents = profile.likeContents
        self.followingCount = profile.followingCount
        self.followerCount = profile.followerCount
        self.followManager = profile.followManager
        self.lastUpdateTimestamp = profile.lastUpdateTimestamp
        self.skinSetting = profile.skinSetting
    }
        
    // Adjusted to use copy initializer if cached
    convenience init(id: String) {
        self.init(identityID: id)
        
        if id != "" {
            Task {
                
                let cachedOrNewProfile = await Self.getCachedOrNew(userprofileqlID: id)
                
                self.identityID = id
                
                guard let cachedOrNewProfile = cachedOrNewProfile else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Missing profile return when trying to init ProfileSettings in convenience init using ID"])
                }
                
                await updateSelf(profile: cachedOrNewProfile)
                
                ProfileManager.shared.updateProfile(self)
            }
        }
        
        print("ProfileSettings init: id@ \(self.identityID)")
    }
    
    convenience init(ql: UserProfileQL) {
        
        let id = UUID(uuidString: ql.id) ?? UUID()
        let birthDate = Date(timeIntervalSince1970: Double(ql.DOB ?? 0))
        let profileImage = ql.profileImage != nil ? Lumena.profileImage(url: ql.profileImage!) : nil
        let backgroundImage = ql.backgroundImage != nil ? Lumena.profileImage(url: ql.backgroundImage!) : nil
        
        let skinSetting = [Int(ql.Sensitivity ?? 0), Int(ql.SunBathing ?? 0), Int(ql.SkinType ?? 0)]
        
        self.init(
            id: id,
            userprofileqlID: ql.id,
            identityID: ql.id,
            birthDate: birthDate,
            emailVerified: false,
            phoneNumberVerified: false,
            phoneNumber: "",
            preferredUsername: ql.username,
            givenName: ql.firstName,
            familyName: "",
            email: "",
            pictureURL: nil,
            lockState: ql.lockState ?? false, bio: "",
            profileImage: profileImage,
            backgroundImage: backgroundImage,
            postContents: [],
            likeContents: [],
            followingCount: ql.followingCount ?? 0,
            followerCount: ql.followerCount ?? 0,
            lastUpdateTimestamp: 0,
            skinSetting: skinSetting
        )
        
        Task {
            do {
                if ql.backgroundImage == "" || ql.profileImage == "" {
                    try await self.fetchUserImages()
                }
                try await self.fetchUserRelatedLumes()
                ProfileManager.shared.updateProfile(self)
            } catch {
                print(error)
            }
        }
        
        print("ProfileSettings init: UserProfileQL@ \(self.identityID)")
    }
    
    func updateSelf(profile: ProfileSettings) async {
        DispatchQueue.main.async {
            self.birthDate = profile.birthDate
            self.emailVerified = profile.emailVerified
            self.phoneNumberVerified = profile.phoneNumberVerified
            self.phoneNumber = profile.phoneNumber
            self.preferredUsername = profile.preferredUsername
            self.givenName = profile.givenName
            self.familyName = profile.familyName
            self.email = profile.email
            self.pictureURL = profile.pictureURL
            self.lockState = profile.lockState
            self.bio = profile.bio
            self.profileImage = profile.profileImage
            self.backgroundImage = profile.backgroundImage
            self.postContents = profile.postContents
            self.likeContents = profile.likeContents
            self.followManager = profile.followManager
            self.followingCount = profile.followingCount
            self.followerCount = profile.followerCount
            self.lastUpdateTimestamp = profile.lastUpdateTimestamp
            self.skinSetting = profile.skinSetting
        }
    }
    
    func setProperties(with userProfile: UserProfileQL) {
         //Assuming main thread execution is required for UI-related updates
        DispatchQueue.main.async {
            self.userprofileqlID = userProfile.id
            self.identityID = userProfile.id
            self.birthDate = Date(timeIntervalSince1970: Double(userProfile.DOB ?? 0))
            self.preferredUsername = userProfile.username
            self.givenName = userProfile.firstName
            // Add more properties as needed
            if let userProfileLink = userProfile.profileImage {
                self.profileImage = Lumena.profileImage(url: userProfileLink)
            }
            if let userBackgroundLink = userProfile.backgroundImage {
                self.backgroundImage = Lumena.profileImage(url: userBackgroundLink)
            }
            self.lockState = userProfile.lockState ?? false
            self.bio = userProfile.bio ?? ""
            
            self.followManager = ProfileFollowManager(userID: userProfile.id)
            self.followingCount = userProfile.followingCount ?? 0
            self.followerCount = userProfile.followerCount ?? 0
            self.lastUpdateTimestamp = Int(NSDate().timeIntervalSince1970)
            self.skinSetting = [Int(userProfile.Sensitivity ?? 0), Int(userProfile.SunBathing ?? 0), Int(userProfile.SkinType ?? 0)]
        }
    }
    
    func toAuthUserAttributes() -> [AuthUserAttribute] {
        var attributes: [AuthUserAttribute] = []
        
        attributes.append(AuthUserAttribute(.sub, value: userprofileqlID))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        attributes.append(AuthUserAttribute(.birthDate, value: dateFormatter.string(from: birthDate)))
        attributes.append(AuthUserAttribute(.emailVerified, value: "\(emailVerified)"))
        attributes.append(AuthUserAttribute(.phoneNumberVerified, value: "\(phoneNumberVerified)"))
        attributes.append(AuthUserAttribute(.phoneNumber, value: phoneNumber))
        attributes.append(AuthUserAttribute(.preferredUsername, value: preferredUsername))
        attributes.append(AuthUserAttribute(.givenName, value: givenName))
        attributes.append(AuthUserAttribute(.familyName, value: familyName))
        attributes.append(AuthUserAttribute(.email, value: email))
        attributes.append(AuthUserAttribute(.custom("bio"), value: bio))
        attributes.append(AuthUserAttribute(.custom("SkinSensitivity"), value: String(describing: skinSetting[0])))
        attributes.append(AuthUserAttribute(.custom("SkinUVBathing"), value: String(describing: skinSetting[1])))
        attributes.append(AuthUserAttribute(.custom("SkinType"), value: String(describing: skinSetting[2])))
        if let pictureURLString = pictureURL?.absoluteString {
            attributes.append(AuthUserAttribute(.picture, value: pictureURLString))
        }
        
        return attributes
    }
    
    private func updatedProfile() {
        self.lastUpdateTimestamp = Int(NSDate().timeIntervalSince1970)
    }
}

extension ProfileSettings {
    
    static func getCachedOrNew(userprofileqlID: String) async -> ProfileSettings? {
        do {
            let result = try await ProfileManager.shared.getProfile(withID: userprofileqlID)
            return result
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func updateUserProfileQL() async throws {
        let message = try await GraphQL.shared.updateUserProfile(profile: self)
        print(message)
        ProfileManager.shared.updateProfile(self)
        self.updatedProfile()
    }
    
    func updateProfile(with userID: String) async throws {
        do {
            let arrUserProf = try await GraphQL.shared.fetchUserProfileQL(userIDs: [userID])
            
            guard let userProfile = arrUserProf.first else {
                try await self.updateUserProfileQL()
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No UserProfileQL has been returned when called UpdateProfile for \(self.identityID)"])
            }
            
            self.setProperties(with: userProfile)
            
            ProfileManager.shared.updateProfile(self)
        } catch {
            // Handle error
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unknown error occured while updating profile: \(error)"])
        }
        
        self.updatedProfile()
    }
}

extension ProfileSettings {
    
    func fetchUserRelatedLumes() async throws {
        do {
            try await fetchUserLikedPosts()
        } catch {
            print(error)
        }
        
        do {
            try await fetchUserLumes()
        } catch {
            print(error)
        }
    }
    
    func fetchUserLikedPosts() async throws {
        do {
            if self.likeContents.isEmpty {
                let lumes = try await GraphQL.shared.fetchUserLikedPosts(userID: self.identityID)
                self.likeContents = lumes.likes.map { $0.lumeQLID }
            }
        } catch {
            print(error)
        }
        
        self.updatedProfile()
    }
    
    func returnUserLikedLumes() -> [Lume] {
        return LumeManager.shared.getLumes(withID: self.likeContents)
    }
    
    func fetchUserLumes() async throws {
        do {
            if self.postContents.isEmpty {
                let lumes = try await GraphQL.shared.fetchUserLumas(userProfileID: self.identityID)
                self.postContents = lumes
                
                if self.identityID == GI.shared.identityID {
                    GI.shared.userPosts = lumes
                }
            }
        } catch {
            print(error)
        }
        
        self.updatedProfile()
    }
    
    func returnUserLumes() -> [Lume] {
        return LumeManager.shared.getUserLumes(withID: self.identityID)
    }
    
    func fetchUserImages() async throws {
        let dirstributionURL = "https://d1s4m1vkr1js6q.cloudfront.net/public/\(self.identityID)/userSetting"
        self.profileImage = Lumena.profileImage(url: "\(dirstributionURL)/profile_image.jpg")
        self.backgroundImage = Lumena.profileImage(url: "\(dirstributionURL)/background_image.jpg")
        self.updatedProfile()
    }

    func toUserProfileQL() -> UserProfileQL {
        return UserProfileQL(
            id: self.identityID,
            username: self.preferredUsername,
            DOB: Int(self.awsTimestamp),
            firstName: self.givenName,
            Sensitivity: Double(skinSetting[0]),
            SunBathing: Double(skinSetting[1]),
            SkinType: Double(skinSetting[2]),
            lockState: self.lockState,
            bio: bio
        )
    }
}

struct ImageURLs: Codable {
    let backgroundUrl: String
    let profileUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case backgroundUrl = "backgroundUrl"
        case profileUrl = "profileUrl"
    }
}

class profileImage: ObservableObject {
    @Published var image: UIImage?
    var url: String
    
    init(url: String = "", image: UIImage? = nil) {
        self.url = url
        self.image = image
        loadImageFromURL()
    }
    
    private func normalizeUrl(urlString: String) -> String {
        guard let url = URL(string: urlString) else { return urlString }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil  // Remove query to normalize
        return components?.url?.absoluteString ?? urlString
    }
    
    private func loadImageFromURL() {
        let normalizedUrl = normalizeUrl(urlString: self.url)
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            self.image = cachedImage
            return
        }
        
        self.downloadAndCacheImage(normalizedUrl: normalizedUrl)
    }
    
    private func downloadAndCacheImage(normalizedUrl: String) {
        guard let imageURL = URL(string: self.url) else { return }
        DispatchQueue.global(qos: .background).async {
            Task {
                let downloadedImage = await self.downloadImage(from: imageURL)
                DispatchQueue.main.async {
                    self.image = downloadedImage
                    if let downloadedImage = downloadedImage {
                        ImageCache.shared.store(image: downloadedImage, forId: normalizedUrl)
                    }
                }
            }
        }
    }
    
    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("HTTP Error: Status code is not 200 for URL: \(url)")
                return nil
            }
            return UIImage(data: data)
        } catch {
            print("Failed to download image from URL: \(url), Error: \(error.localizedDescription)")
            return nil
        }
    }

    func loadAgain(newUrl: String? = nil) {
        if let newUrl = newUrl {
            self.url = newUrl
        }
        loadImageFromURL()
    }
}



struct FollowResponse: Decodable {
    let followers: [Follower]?
    let followersNextToken: String?
    let followings: [Following]?
    let followingsNextToken: String?
}

struct Follower: Decodable {
    let followerID: String
    let followingID: String
    let status: String
    let timestamp: Int
}

struct Following: Decodable {
    let followerID: String
    let followingID: String
    let status: String
    let timestamp: Int
}


// for api decoding for UserFollowStat
struct RelationshipResponse: Codable {
    let RelationshipType: String
    
    func toRelationshipType() -> RelationshipType {
        return Lumena.RelationshipType(rawValue: self.RelationshipType.lowercased()) ?? .unknown
    }
}

struct FollowUserResponse: Codable {
    let message: String
}

enum RelationshipType: String, Decodable {
    case following = "following"
    case follower = "follower"
    case mutual = "mutual"
    case none = "none"            // No relationship found
    case unknown = "unknown"      // Relationship status has not been fetched
    case disconnected = "disconnected" // Checked but no relationship

    // Added lowercase values to match case insensitivity in JSON responses
    func stringValue() -> String {
        return self.rawValue
    }
}


extension RelationshipType {
    func invert() -> RelationshipType {
        switch self {
        case .following:
            return .follower
        case .follower:
            return .following
        case .mutual:
            return .mutual
        case .none, .unknown, .disconnected:
            return .none
        }
    }
}

struct UserRelationship {
    let userID: String
    var relationship: RelationshipType
}

extension ProfileSettings {
    func fetchFollowers(limit: Int = 20) async {
        // Assuming followManager has a function to fetch followers
        await followManager?.fetchFollows(relationship: .follower, limit: limit)
        // After fetching followers, update the profile in the central manager
        DispatchQueue.main.async {
            ProfileManager.shared.updateProfile(self)
        }
    }

    func fetchFollowing(limit: Int = 20) async {
        // Assuming followManager has a function to fetch followings
        await followManager?.fetchFollows(relationship: .following, limit: limit)
        // After fetching followings, update the profile in the central manager
        DispatchQueue.main.async {
            ProfileManager.shared.updateProfile(self)
        }
    }
}


class ProfileFollowManager: Identifiable, ObservableObject {
    var id = UUID()
    var userID: String
    
    //last token for graphql for following and follower search
    private var followingLastToken: String?
    private var followerLastToken: String?

    init(userID: String) {
        self.userID = userID
    }
    
    convenience init(userID: String, limit: Int = 10) {
        self.init(userID: userID)
        Task {
            await self.fetchFollows(relationship: .mutual, limit: limit)
        }
    }
    
    func returnUsers(relationship: RelationshipType = .follower) async throws -> [ProfileSettings] {
        var userProfiles: [ProfileSettings] = []
        let allRelationships = ProfileManager.shared.relationships

        // Iterate over each entry in the relationship dictionary
        for (_, relationships) in allRelationships {
            for (relatedUserID, relType) in relationships {
                // Check if the relationship matches the one we're interested in
                if relType == relationship {
                    // Fetch the profile asynchronously using the relatedUserID
                    if let profile = try? await ProfileManager.shared.getProfile(withID: relatedUserID) {
                        userProfiles.append(profile)
                    }
                }
            }
        }
        return userProfiles
    }
    
    // Fetch followers/following data and let ProfileManager handle actual relationship status updates
    func fetchFollows(relationship: RelationshipType = .follower, limit: Int = 20) async {
        do {
            var lastFollowingToken = ""
            var lastFollowerToken = ""
            if relationship == .following {
                lastFollowingToken = followingLastToken ?? ""
            } else if relationship == .follower {
                lastFollowerToken = followerLastToken ?? ""
            } else if relationship == .mutual {
                lastFollowingToken = followingLastToken ?? ""
                lastFollowerToken = followerLastToken ?? ""
            }
            
            let followResponse = try await GraphQL.shared.fetchUserFollow(userID: userID, relationshipType: relationship, limit: limit, lastFollowingToken: lastFollowingToken, lastFollowerToken: lastFollowerToken)
            
            if relationship == .following {
                followingLastToken = followResponse.followingsNextToken
            } else if relationship == .follower {
                followerLastToken = followResponse.followersNextToken
            } else if relationship == .mutual {
                followingLastToken = followResponse.followingsNextToken
                followerLastToken = followResponse.followersNextToken
            }
            
            ProfileManager.shared.processFetchedFollowData(userID: userID, response: followResponse, relationshipType: relationship)
        } catch {
            print("Error fetching followers and following: \(error)")
        }
    }
}

extension ProfileSettings {
    // Trigger follow/unfollow actions through ProfileManager directly
    func followUser(userID: String) {
        ProfileManager.shared.updateFollowingStatus(fromUserID: self.identityID, toUserID: userID, follow: true)
        self.followingCount += 1
    }
    
    func unfollowUser(userID: String) {
        ProfileManager.shared.updateFollowingStatus(fromUserID: self.identityID, toUserID: userID, follow: false)
        if self.followingCount > 0 {
            self.followingCount -= 1
        } else {
            self.followingCount = 0
        }
    }
}
