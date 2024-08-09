// swiftlint:disable all
import Amplify
import Foundation

public struct UserProfileQL: Model {
  public let id: String
  public var followingUsers: [String]?
  public var followerUsers: [String]?
  public var username: String
  public var DOB: Int?
  public var firstName: String?
  public var lockState: Bool?
  public var profileImage: String?
  public var backgroundImage: String?
  public var followerCount: Int?
  public var followingCount: Int?
  public var bio: String?
  public var postCount: Int?
  public var profileImageLastModified: Int?
  public var backgroundImageLastModified: Int?
  public var skinSettings: SkinSettingsAttributesQL?
  public var skinStreaks: Int?
  
  public init(id: String = UUID().uuidString,
      followingUsers: [String]? = [],
      followerUsers: [String]? = [],
      username: String,
      DOB: Int? = nil,
      firstName: String? = nil,
      lockState: Bool? = nil,
      profileImage: String? = nil,
      backgroundImage: String? = nil,
      followerCount: Int? = nil,
      followingCount: Int? = nil,
      bio: String? = nil,
      postCount: Int? = nil,
      profileImageLastModified: Int? = nil,
      backgroundImageLastModified: Int? = nil,
      skinSettings: SkinSettingsAttributesQL? = nil,
      skinStreaks: Int? = nil) {
      self.id = id
      self.followingUsers = followingUsers
      self.followerUsers = followerUsers
      self.username = username
      self.DOB = DOB
      self.firstName = firstName
      self.lockState = lockState
      self.profileImage = profileImage
      self.backgroundImage = backgroundImage
      self.followerCount = followerCount
      self.followingCount = followingCount
      self.bio = bio
      self.postCount = postCount
      self.profileImageLastModified = profileImageLastModified
      self.backgroundImageLastModified = backgroundImageLastModified
      self.skinSettings = skinSettings
      self.skinStreaks = skinStreaks
  }
}