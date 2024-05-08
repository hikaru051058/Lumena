// swiftlint:disable all
import Amplify
import Foundation

public struct FollowQL: Model {
  public let id: String
  public var timestamp: Int?
  public var following: UserProfileQL?
  public var followerID: String?
  public var status: FollowStatus?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      timestamp: Int? = nil,
      following: UserProfileQL? = nil,
      followerID: String? = nil,
      status: FollowStatus? = nil) {
    self.init(id: id,
      timestamp: timestamp,
      following: following,
      followerID: followerID,
      status: status,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      timestamp: Int? = nil,
      following: UserProfileQL? = nil,
      followerID: String? = nil,
      status: FollowStatus? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.timestamp = timestamp
      self.following = following
      self.followerID = followerID
      self.status = status
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}