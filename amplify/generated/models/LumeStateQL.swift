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
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      state: LumeState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      lumeqlID: String) {
    self.init(id: id,
      state: state,
      timestamp: timestamp,
      reason: reason,
      changedBy: changedBy,
      lumeqlID: lumeqlID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      state: LumeState? = nil,
      timestamp: Int? = nil,
      reason: String? = nil,
      changedBy: String? = nil,
      lumeqlID: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.state = state
      self.timestamp = timestamp
      self.reason = reason
      self.changedBy = changedBy
      self.lumeqlID = lumeqlID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}