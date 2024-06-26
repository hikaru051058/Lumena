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
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      UserState: AccountState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      userprofileqlID: String? = nil) {
    self.init(id: id,
      UserState: UserState,
      timestamp: timestamp,
      reason: reason,
      changedBy: changedBy,
      userprofileqlID: userprofileqlID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      UserState: AccountState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      userprofileqlID: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.UserState = UserState
      self.timestamp = timestamp
      self.reason = reason
      self.changedBy = changedBy
      self.userprofileqlID = userprofileqlID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}