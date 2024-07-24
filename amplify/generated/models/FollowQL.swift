// swiftlint:disable all
import Amplify
import Foundation

public struct FollowQL: Model {
  public let id: String
  public var timestamp: Int?
  public var followingID: String
  public var following: UserProfileQL?
  public var followerID: String
  public var follower: UserProfileQL?
  public var status: FollowStatus?
  
  public init(id: String = UUID().uuidString,
      timestamp: Int? = nil,
      followingID: String,
      following: UserProfileQL? = nil,
      followerID: String,
      follower: UserProfileQL? = nil,
      status: FollowStatus? = nil) {
      self.id = id
      self.timestamp = timestamp
      self.followingID = followingID
      self.following = following
      self.followerID = followerID
      self.follower = follower
      self.status = status
  }
}