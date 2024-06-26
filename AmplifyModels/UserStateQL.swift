// swiftlint:disable all
import Amplify
import Foundation

public struct UserStateQL: Model {
  public let id: String
  public var UserState: AccountState?
  public var timestamp: Int?
  public var reason: String?
  public var changedBy: String?
  public var userprofileqlID: String?
  public var UserProfileQL: UserProfileQL?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  public var userStateQLUserProfileQLId: String?
  
  public init(id: String = UUID().uuidString,
      UserState: AccountState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      userprofileqlID: String? = nil,
      UserProfileQL: UserProfileQL? = nil,
      userStateQLUserProfileQLId: String? = nil) {
    self.init(id: id,
      UserState: UserState,
      timestamp: timestamp,
      reason: reason,
      changedBy: changedBy,
      userprofileqlID: userprofileqlID,
      UserProfileQL: UserProfileQL,
      createdAt: nil,
      updatedAt: nil,
      userStateQLUserProfileQLId: userStateQLUserProfileQLId)
  }
  internal init(id: String = UUID().uuidString,
      UserState: AccountState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      userprofileqlID: String? = nil,
      UserProfileQL: UserProfileQL? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil,
      userStateQLUserProfileQLId: String? = nil) {
      self.id = id
      self.UserState = UserState
      self.timestamp = timestamp
      self.reason = reason
      self.changedBy = changedBy
      self.userprofileqlID = userprofileqlID
      self.UserProfileQL = UserProfileQL
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.userStateQLUserProfileQLId = userStateQLUserProfileQLId
  }
}