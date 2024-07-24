// swiftlint:disable all
import Amplify
import Foundation

public struct BlockQL: Model {
  public let id: String
  public var userprofileqlID: String
  public var blockeduserprofileqlID: String
  public var status: BlockStatus?
  
  public init(id: String = UUID().uuidString,
      userprofileqlID: String,
      blockeduserprofileqlID: String,
      status: BlockStatus? = nil) {
      self.id = id
      self.userprofileqlID = userprofileqlID
      self.blockeduserprofileqlID = blockeduserprofileqlID
      self.status = status
  }
}