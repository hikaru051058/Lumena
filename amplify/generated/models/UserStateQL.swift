// swiftlint:disable all
import Amplify
import Foundation

public struct UserStateQL: Model {
  public let id: String
  public var UserState: AccountState?
  public var timestamp: Int?
  public var reason: String?
  public var changedBy: String?
  public var userprofileqlID: String
  public var userprofileql: UserProfileQL?
  
  public init(id: String = UUID().uuidString,
      UserState: AccountState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      userprofileqlID: String,
      userprofileql: UserProfileQL? = nil) {
      self.id = id
      self.UserState = UserState
      self.timestamp = timestamp
      self.reason = reason
      self.changedBy = changedBy
      self.userprofileqlID = userprofileqlID
      self.userprofileql = userprofileql
  }
}