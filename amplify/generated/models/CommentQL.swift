// swiftlint:disable all
import Amplify
import Foundation

public struct CommentQL: Model {
  public let id: String
  public var timestamp: Int
  public var comment: String
  public var lumeQLID: String
  public var lume: LumeQL?
  public var userprofileqlID: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      timestamp: Int,
      comment: String,
      lumeQLID: String,
      lume: LumeQL? = nil,
      userprofileqlID: String) {
    self.init(id: id,
      timestamp: timestamp,
      comment: comment,
      lumeQLID: lumeQLID,
      lume: lume,
      userprofileqlID: userprofileqlID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      timestamp: Int,
      comment: String,
      lumeQLID: String,
      lume: LumeQL? = nil,
      userprofileqlID: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.timestamp = timestamp
      self.comment = comment
      self.lumeQLID = lumeQLID
      self.lume = lume
      self.userprofileqlID = userprofileqlID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}