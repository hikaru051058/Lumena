// swiftlint:disable all
import Amplify
import Foundation

public struct UserProfileQL: Model {
  public let id: String
  public var followingUsers: [String?]?
  public var followerUsers: [String?]?
  public var username: String
  public var DOB: Int?
  public var firstName: String
  public var Sensitivity: Double?
  public var SunBathing: Double?
  public var SkinType: Double?
  public var postContents: List<LumeQL>?
  public var likedContents: List<LikedLumeQL>?
  public var comments: List<CommentQL>?
  public var lockState: Bool?
  public var profileImage: String?
  public var backgroundImage: String?
  public var followerCount: Int?
  public var followingCount: Int?
  public var bio: String?
  public var following: List<FollowQL>?
  public var postCount: Int?
  public var profileImageLastModified: Int?
  public var backgroundImageLastModified: Int?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      followingUsers: [String?]? = nil,
      followerUsers: [String?]? = nil,
      username: String,
      DOB: Int? = nil,
      firstName: String,
      Sensitivity: Double? = nil,
      SunBathing: Double? = nil,
      SkinType: Double? = nil,
      postContents: List<LumeQL>? = [],
      likedContents: List<LikedLumeQL>? = [],
      comments: List<CommentQL>? = [],
      lockState: Bool? = nil,
      profileImage: String? = nil,
      backgroundImage: String? = nil,
      followerCount: Int? = nil,
      followingCount: Int? = nil,
      bio: String? = nil,
      following: List<FollowQL>? = [],
      postCount: Int? = nil,
      profileImageLastModified: Int? = nil,
      backgroundImageLastModified: Int? = nil) {
    self.init(id: id,
      followingUsers: followingUsers,
      followerUsers: followerUsers,
      username: username,
      DOB: DOB,
      firstName: firstName,
      Sensitivity: Sensitivity,
      SunBathing: SunBathing,
      SkinType: SkinType,
      postContents: postContents,
      likedContents: likedContents,
      comments: comments,
      lockState: lockState,
      profileImage: profileImage,
      backgroundImage: backgroundImage,
      followerCount: followerCount,
      followingCount: followingCount,
      bio: bio,
      following: following,
      postCount: postCount,
      profileImageLastModified: profileImageLastModified,
      backgroundImageLastModified: backgroundImageLastModified,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      followingUsers: [String?]? = nil,
      followerUsers: [String?]? = nil,
      username: String,
      DOB: Int? = nil,
      firstName: String,
      Sensitivity: Double? = nil,
      SunBathing: Double? = nil,
      SkinType: Double? = nil,
      postContents: List<LumeQL>? = [],
      likedContents: List<LikedLumeQL>? = [],
      comments: List<CommentQL>? = [],
      lockState: Bool? = nil,
      profileImage: String? = nil,
      backgroundImage: String? = nil,
      followerCount: Int? = nil,
      followingCount: Int? = nil,
      bio: String? = nil,
      following: List<FollowQL>? = [],
      postCount: Int? = nil,
      profileImageLastModified: Int? = nil,
      backgroundImageLastModified: Int? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.followingUsers = followingUsers
      self.followerUsers = followerUsers
      self.username = username
      self.DOB = DOB
      self.firstName = firstName
      self.Sensitivity = Sensitivity
      self.SunBathing = SunBathing
      self.SkinType = SkinType
      self.postContents = postContents
      self.likedContents = likedContents
      self.comments = comments
      self.lockState = lockState
      self.profileImage = profileImage
      self.backgroundImage = backgroundImage
      self.followerCount = followerCount
      self.followingCount = followingCount
      self.bio = bio
      self.following = following
      self.postCount = postCount
      self.profileImageLastModified = profileImageLastModified
      self.backgroundImageLastModified = backgroundImageLastModified
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}