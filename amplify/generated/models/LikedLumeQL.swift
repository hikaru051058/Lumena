// swiftlint:disable all
import Amplify
import Foundation

public struct LikedLumeQL: Model {
  public let id: String
  public var timestamp: Int?
  public var lumeQLID: String
  public var lume: LumeQL?
  public var userprofileqlID: String
  public var userprofileql: UserProfileQL?
  
  public init(id: String = UUID().uuidString,
      timestamp: Int? = nil,
      lumeQLID: String,
      lume: LumeQL? = nil,
      userprofileqlID: String,
      userprofileql: UserProfileQL? = nil) {
      self.id = id
      self.timestamp = timestamp
      self.lumeQLID = lumeQLID
      self.lume = lume
      self.userprofileqlID = userprofileqlID
      self.userprofileql = userprofileql
  }
}