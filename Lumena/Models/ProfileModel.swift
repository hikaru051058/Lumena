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
    @Published var blockedUsers: BlockResultData?
    
    private var fetchedBlockUsers: Bool = false
    private var fetchingProfiles: Set<String> = []
    
    private var loggedIds: Set<String> = []
    private let profileQueue = DispatchQueue(label: "com.lumena.profileQueue")
    
    private init() {} // Private initialization to enforce singleton
    
    func getProfile(withID id: String) async throws -> ProfileSettings {
        print("Entering getProfile with ID: \(id)")
        if let existingProfile = profiles[id] {
            print("Profile found in cache for ID: \(id)")
            return existingProfile
        } else {
            if id == "" {
                print("NULL id detected in getProfile async")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: ID cannot be null"])
            }
            var isFetching = false
            profileQueue.sync {
                isFetching = fetchingProfiles.contains(id)
            }
            if isFetching {
                print("Already fetching profile for ID: \(id), waiting...")
                while true {
                    var stillFetching = false
                    profileQueue.sync {
                        stillFetching = fetchingProfiles.contains(id)
                    }
                    if !stillFetching {
                        break
                    }
                    try await Task.sleep(nanoseconds: 100_000_000) // Sleep for 0.1 seconds
                }
                guard let fetchedProfile = profiles[id] else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Failed to fetch profile"])
                }
                return fetchedProfile
            } else {
                profileQueue.async(flags: .barrier) {
                    self.fetchingProfiles.insert(id)
                }
                defer {
                    profileQueue.async(flags: .barrier) {
                        self.fetchingProfiles.remove(id)
                    }
                }
                let profile = await getProfileAPI(with: id)
                guard let profile = profile else {
                    print("No ProfileSettings returned from getProfileAPI for ID: \(id)")
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No ProfileSettings has been returned when called getProfile"])
                }
                
                if let userIdentityID = GI.shared.identityID {
                    let _ = await fetchRelationshipStat(fromUserID: userIdentityID, toUserID: id)
                }
                
                DispatchQueue.main.async {
                    self.profiles[id] = profile
                }
                print("Returning profile from API for ID: \(id)")
                return profile
            }
        }
    }
    
    func getProfile(withID id: String) -> ProfileSettings {
        print("Entering synchronous getProfile with ID: \(id)")
        if let existingProfile = profiles[id] {
            print("Profile found in cache for ID: \(id)")
            return existingProfile
        } else {
            if id == "" {
                print("NULL id detected in synchronous getProfile")
            }
            let newProfile = ProfileSettings(id: id)
            DispatchQueue.main.async {
                self.profiles[id] = newProfile
            }
            print("Returning new profile for ID: \(id)")
            return newProfile
        }
    }
    
    func hasProfile(id: String) -> Bool {
        print("Checking if profile exists for ID: \(id)")
        return profiles.values.contains(where: { $0.identityID == id})
    }
    
    func getProfileQueue(withID id: String) async throws {
        try await profileQueue.sync {
            if !loggedIds.contains(id) {
                loggedIds.insert(id)
                print("Entering getProfileQueue with ID: \(id)")
            }
        }
        
        if !profiles.values.contains(where: { $0.identityID == id }) {
            if id == "" {
                print("NULL id detected in getProfileQueue async")
                return
            }
            var isFetching = false
            profileQueue.sync {
                isFetching = fetchingProfiles.contains(id)
            }
            if isFetching {
                print("Already fetching profile for queue ID: \(id), waiting...")
                while true {
                    var stillFetching = false
                    profileQueue.sync {
                        stillFetching = fetchingProfiles.contains(id)
                    }
                    if !stillFetching {
                        break
                    }
                    try await Task.sleep(nanoseconds: 100_000_000) // Sleep for 0.1 seconds
                }
                return
            } else {
                profileQueue.async(flags: .barrier) {
                    self.fetchingProfiles.insert(id)
                }
                defer {
                    profileQueue.async(flags: .barrier) {
                        self.fetchingProfiles.remove(id)
                    }
                }
                let profile = await getProfileAPI(with: id)
                guard let profile = profile else {
                    print("No ProfileSettings returned from getProfileAPI for getProfileQueue ID: \(id)")
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No ProfileSettings has been returned when called getProfileQueue"])
                }
                
                let profileFollowerManager = ProfileFollowManager(userID: id, limit: 10)
                profile.followManager = profileFollowerManager
                ProfileManager.shared.updateProfile(profile)
                DispatchQueue.main.async {
                    self.profiles[id] = profile
                }
                print("Returning profile from API for getProfileQueue ID: \(id)")
            }
        }
    }
    
    func getArrayProfiles(ids: [String]) -> [ProfileSettings] {
        print("Entering getArrayProfiles with IDs: \(ids)")
        return ids.compactMap { profiles[$0] }
    }
    
    func getProfileAPI(with userID: String) async -> ProfileSettings? {
        do {
            let response = try await GraphQL.shared.fetchUserProfileQL(userIDs: [userID])
            print("Fetched user profiles from GraphQL for userID: \(userID): \(response)")
            
            guard let userProfile = response.first else {
                print("No UserProfileQL returned from fetchUserProfileQL for userID: \(userID)")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No UserProfileQL has been returned when called UpdateProfile for \(userID)"])
            }
            
            print("Returning ProfileSettings from getProfileAPI for userID: \(userID)")
            return ProfileSettings(ql: userProfile)
            
        } catch {
            print("Error fetching user profile for userID: \(userID): \(error.localizedDescription), attempting to fix...")
            // Attempt to fix the user profile if it exists
            if let userProfile = try? await GraphQL.shared.fetchUserProfileQL(userIDs: [userID]).first {
                do {
                    let newProfile = try await fixUserProfile(profile: userProfile)
                    print("Returning fixed ProfileSettings for userID: \(userID)")
                    return newProfile
                } catch {
                    print("Failed to fix UserProfileQL for userID: \(userID): \(error)")
                }
            }
        }
        print("Returning nil from getProfileAPI for userID: \(userID)")
        return nil
    }
    
    func fixUserProfile(profile: UserProfileQL) async throws -> ProfileSettings {
        print("Entering fixUserProfile")
        do {
            // Attempt to delete the problematic user profile
            try await GraphQL.shared.deleteModel(profile)
            print("Deleted problematic user profile")
        } catch {
            print("Error deleting problematic user profile: \(error)")
        }
        
        // Recreate the user profile based on current authenticated user attributes
        let amplifyAttributes = try await Amplify.Auth.fetchUserAttributes()
        let newProfileSettings = ProfileSettings(from: amplifyAttributes)
        
        // Save the newly created profile to the database
        let _ = try await GraphQL.shared.createModel(newProfileSettings.toUserProfileQL())
        print("Created new user profile")
        
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
    
    func isFollowing(_ fromUserID: String, to toUserID: String) -> Bool {
        if let relationship = relationships[fromUserID]?[toUserID] {
            return relationship == .following || relationship == .mutual
        }
        return false
    }
    
    // Manage following actions
    func updateFollowingStatus(fromUserID: String, toUserID: String, follow: Bool) {
        let currentStatus = relationships[fromUserID]?[toUserID] ?? .none
        let newStatus = follow ? determineNewFollowingStatus(currentStatus) : determineNewUnfollowingStatus(currentStatus)
        updateLocalRelationshipState(fromUserID: fromUserID, toUserID: toUserID, relationshipStatus: newStatus)
        adjustCounts(for: fromUserID, toUserID: toUserID, newRelationship: newStatus, follow: follow)
        Task {
            do {
                _ = try await GraphQL.shared.followUser(currUserId: fromUserID, followUserId: toUserID, followUnfollow: follow)
                NotificationCenter.default.post(name: .didChangeFollowStatus, object: nil, userInfo: ["fromUserID": fromUserID, "toUserID": toUserID])
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

extension ProfileManager {
    // Method to block a user
    func blockUser(fromUserID: String, toUserID: String) async throws {
        try await GraphQL.shared.blockUser(blockuserprofileqlID: toUserID, blockAction: .block)
        updateLocalRelationshipState(fromUserID: fromUserID, toUserID: toUserID, relationshipStatus: .blocked)
    }
    
    // Method to unblock a user
    func unblockUser(fromUserID: String, toUserID: String) async throws {
        try await GraphQL.shared.blockUser(blockuserprofileqlID: toUserID, blockAction: .unblock)
        updateLocalRelationshipState(fromUserID: fromUserID, toUserID: toUserID, relationshipStatus: .none)
    }
    
    // Method to fetch blocked and blocking users
    func fetchBlockedUsers(forUserID userID: String) async throws {
        let blockResultData = try await GraphQL.shared.fetchBlockedUsers(userProfileID: userID)
        
        DispatchQueue.main.async {
            self.blockedUsers = blockResultData
            blockResultData.blocking.forEach { blockedID in
                self.updateLocalRelationshipState(fromUserID: userID, toUserID: blockedID, relationshipStatus: .blocked)
            }
            blockResultData.blocked.forEach { blockingID in
                self.updateLocalRelationshipState(fromUserID: blockingID, toUserID: userID, relationshipStatus: .blocked)
            }
        }
    }
    
    // Method to return blocked and blocking users, fetching from GraphQL if needed
    func returnBlockedUsers(forUserID userID: String, forceFetch: Bool = false) async throws -> (blocked: [String], blocking: [String]) {
        if !fetchedBlockUsers || forceFetch {
            try await fetchBlockedUsers(forUserID: userID)
            fetchedBlockUsers = true
        }
        
        let blocked = blockedUsers?.blocked ?? []
        let blocking = blockedUsers?.blocking ?? []
        return (blocked, blocking)
    }
}


class ProfileSettings: Identifiable, ObservableObject, Equatable, Reflectable {
    
    static func == (lhs: ProfileSettings, rhs: ProfileSettings) -> Bool {
        return lhs.identityID == rhs.identityID
    }
    
    var id: UUID = UUID()
    
    var userprofileqlID: String
    var identityID: String
    var birthDate: Date
    var emailVerified: Bool
    var phoneNumberVerified: Bool
    var phoneNumber: String
    @Published var preferredUsername: String {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    @Published var givenName: String {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    var familyName: String
    var email: String
    var pictureURL: URL?
    @Published var lockState: Bool {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    @Published var bio: String {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    @Published var profileImage: profileImage? {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    @Published var backgroundImage: profileImage? {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    
    
    @Published var postContentsID: [String] {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    @Published var likeContentsID: [String] {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    
    @Published var postContents: [Lume] = [] {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    @Published var likeContents: [Lume] = [] {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    
    
    @Published var followManager: ProfileFollowManager? {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
        }
    }
    
    @Published var followingCount: Int = 0
    @Published var followerCount: Int = 0
    
    @Published var blockedUsers: [String] = []
    @Published var blockingUsers: [String] = []
    
    @Published var lastUpdateTimestamp: Int?
    
    @Published var skinSetting: SkinSettingsAttributes? {
        didSet {
            DispatchQueue.main.async {
                ProfileManager.shared.updateProfile(self)
            }
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
         skinSetting: SkinSettingsAttributes = SkinSettingsAttributes()
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
        self.postContentsID = postContents
        self.likeContentsID = likeContents
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
        self.postContentsID = []
        self.likeContentsID = []
        self.followingCount = 0
        self.followerCount = 0
        self.followManager = ProfileFollowManager(userID: self.identityID)
        self.lastUpdateTimestamp = Int(NSDate().timeIntervalSince1970)
        self.skinSetting = SkinSettingsAttributes()
        
        for attribute in attributes {
            switch attribute.key {
            case .sub:
                userprofileqlID = attribute.value
            case .birthDate:
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                birthDate = dateFormatter.date(from: attribute.value) ??  Date()
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
                skinSetting?.sensitivity = SensitivityOptions(rawValue: attribute.value)!
            case .custom("SkinUVBathing"):
                skinSetting?.uv = UVOptions(rawValue: attribute.value)!
            case .custom("SkinType"):
                skinSetting?.skinType = SkinTypeOptions(rawValue: attribute.value)!
            case .custom("SkinPersonalColor"):
                skinSetting?.personalColor = PersonalColorOptions(rawValue: attribute.value)!
            case .custom("SkinEyeColor"):
                skinSetting?.eyeColor = attribute.value
            case .custom("SkinColor"):
                skinSetting?.skinColor = attribute.value
            case .custom("SkinConcerns"):
                skinSetting?.concerns = ConcernsOptions(rawValue: attribute.value)!
                
            default:
                continue
            }
        }
        
        Task {
            do {
                try await self.fetchUserRelatedLumes()
                ProfileManager.shared.updateProfile(self)
                let _ = await ProfileManager.shared.getProfileAPI(with: self.identityID)
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
        self.postContentsID = profile.postContentsID
        self.likeContentsID = profile.likeContentsID
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
        let skinSetting = SkinSettingsAttributes(from: ql.skinSettings ?? SkinSettingsAttributesQL())
        
        self.init(
            id: id,
            userprofileqlID: ql.id,
            identityID: ql.id,
            birthDate: birthDate,
            emailVerified: false,
            phoneNumberVerified: false,
            phoneNumber: "",
            preferredUsername: ql.username,
            givenName: ql.firstName ?? "",
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
            self.postContentsID = profile.postContentsID
            self.likeContentsID = profile.likeContentsID
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
            self.givenName = userProfile.firstName ?? ""
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
            self.skinSetting = SkinSettingsAttributes(from: userProfile.skinSettings ?? SkinSettingsAttributesQL())
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
        attributes.append(AuthUserAttribute(.custom("SkinSensitivity"), value: skinSetting?.sensitivity.rawValue ?? ""))
        attributes.append(AuthUserAttribute(.custom("SkinUVBathing"), value: skinSetting?.uv.rawValue ?? ""))
        attributes.append(AuthUserAttribute(.custom("SkinType"), value: skinSetting?.skinType.rawValue ?? ""))
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
        try await GraphQL.shared.updateUserProfile(profile: self)
        ProfileManager.shared.updateProfile(self)
        self.updatedProfile()
    }
    
    func updateProfile() async throws {
        do {
            let userProfile = try await ProfileManager.shared.getProfile(withID: identityID)
            
            try await self.updateUserProfileQL()
            
            self.setProperties(with: userProfile.toUserProfileQL())
            
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
            print("fetched user liked posts for \(self.identityID)")
        } catch {
            print(error)
        }
        
        do {
            try await fetchUserLumes()
            print("fetched user posts for \(self.identityID)")
        } catch {
            print(error)
        }
    }
    
    func fetchUserLikedPosts() async throws {
        do {
            if self.likeContentsID.isEmpty {
                let lumes = try await GraphQL.shared.fetchUserLikedPosts(userID: self.identityID)
                self.likeContentsID = lumes.likes.map { $0.lumeQLID }
                
                self.likeContents = try await GraphQL.shared.fetchMultipleReelQL(reelQLIds: lumes.likes.map({ $0.lumeQLID }))
            }
        } catch {
            print(error)
        }
        
        self.updatedProfile()
    }
    
    func returnUserLikedLumes() -> [Lume] {
        if self.likeContents.isEmpty {
            self.likeContents = LumeManager.shared.getLumes(withID: self.likeContentsID)
        }
        return self.likeContents
    }
    
    func fetchUserLumes() async throws {
        do {
            if self.postContentsID.isEmpty {
                let lumes = try await GraphQL.shared.fetchUserLumas(userProfileID: self.identityID)
                self.postContentsID = lumes
                
                if self.identityID == GI.shared.identityID {
                    GI.shared.userPosts = lumes
                }
                for PostLume in lumes {
                    LumeManager.shared.getLumeQueue(withID: PostLume)
                }
            }
        } catch {
            print(error)
        }
        
        self.updatedProfile()
    }
    
    func returnUserLumes() -> [Lume] {
        if self.postContents.isEmpty {
            self.postContents = LumeManager.shared.getUserPostLumes(withID: self.identityID)
        }
        return self.postContents
    }
    
    func fetchUserImages() async throws {
        self.updatedProfile()
    }
    
    func toUserProfileQL() -> UserProfileQL {
        
        let skinToUserProfileQL = skinSetting?.toUserProfileQLDictionary()
        
        return UserProfileQL(
            id: self.identityID,
            username: self.preferredUsername,
            DOB: Int(self.awsTimestamp),
            firstName: self.givenName,
            lockState: self.lockState,
            bio: bio,
            skinSettings: skinToUserProfileQL
        )
    }
}

extension ProfileSettings {
    
    func uploadProfileImage(image: UIImage) async {
        
        self.profileImage?.image = image
        do {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let _ = try await S3.shared.storeDataAsync(name: "\(self.identityID)/userSetting/profile_image.jpg", data: imageData, progressHandler: { progress in
                    print("Upload Progress for Profile Image: \(progress * 100)%")
                })
                await refreshProfileImage()
            }
        } catch {
            print(error)
        }
    }
    
    func uploadBackgroundImage(image: UIImage) async {
        
        self.backgroundImage?.image = image
        do {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let _ = try await S3.shared.storeDataAsync(name: "\(self.identityID)/userSetting/background_image.jpg", data: imageData, progressHandler: { progress in
                    print("Upload Progress for Background Image: \(progress * 100)%")
                })
                await refreshBackgroundImage()
            }
        } catch {
            print(error)
        }
    }
    
    func refreshProfileImage() async {
        do {
            let arrProfile = try await GraphQL.shared.checkUserProfileQLImage(userIDs: [self.userprofileqlID])
            
            if let newProfile = arrProfile.first {
                
                self.profileImage?.url = ""
                
                self.profileImage?.loadAgain(newUrl: newProfile.profileImage)
                
                try await updateProfile()
            }
        } catch {
            print(error)
        }
    }
    
    func refreshBackgroundImage() async {
        do {
            let arrProfile = try await GraphQL.shared.checkUserProfileQLImage(userIDs: [self.userprofileqlID])
            
            if let newProfile = arrProfile.first {
                
                self.backgroundImage?.url = ""
                
                self.backgroundImage?.loadAgain(newUrl: newProfile.backgroundImage)
                
                try await updateProfile()
            }
        } catch {
            print(error)
        }
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
                print("HTTP Error: Status code is not 200 for URL in downloadImage Profile: \(url)")
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
        guard !self.url.isEmpty else { return }
        loadImageFromURL()
    }
    
    // New async throwing function
    func loadImageFromNewURL(newUrl: String) async throws -> UIImage? {
        self.url = newUrl
        let normalizedUrl = normalizeUrl(urlString: newUrl)
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(forId: normalizedUrl) {
            self.image = cachedImage
            return cachedImage
        }
        
        // Download new image
        guard let imageURL = URL(string: newUrl) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: imageURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let downloadedImage = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        DispatchQueue.main.async {
            self.image = downloadedImage
            ImageCache.shared.store(image: downloadedImage, forId: normalizedUrl)
        }
        
        return downloadedImage
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


enum BlockAction: String {
    case block = "block"
    case unblock = "unblock"
}

enum BlockFetch: String, Decodable {
    case blocked = "blocked"
    case blocking = "blocking"
    case both = "both"
    case none = "none"
}

struct BlockResultData: Decodable {
    let blocking: [String]
    let blocked: [String]

    enum CodingKeys: String, CodingKey {
        case blocking, blocked
    }
    
    func printDetails() {
        print("Blocking:")
        if blocking.isEmpty {
            print("None")
        } else {
            blocking.forEach { print($0) }
        }
        
        print("\nBlocked:")
        if blocked.isEmpty {
            print("None")
        } else {
            blocked.forEach { print($0) }
        }
    }
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
    case blocked = "blocked"

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
        case .blocked:
            return .blocked
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
