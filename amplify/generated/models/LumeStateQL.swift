// swiftlint:disable all
import Amplify
import Foundation

public struct LumeStateQL: Model {
  public let id: String
  public var state: LumeState?
  public var timestamp: Int?
  public var reason: String?
  public var changedBy: String?
  public var lumeqlID: String
  public var lume: LumeQL?
  
  public init(id: String = UUID().uuidString,
      state: LumeState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      lumeqlID: String,
      lume: LumeQL? = nil) {
      self.id = id
      self.state = state
      self.timestamp = timestamp
      self.reason = reason
      self.changedBy = changedBy
      self.lumeqlID = lumeqlID
      self.lume = lume
  }
}