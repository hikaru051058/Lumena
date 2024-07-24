// swiftlint:disable all
import Amplify
import Foundation

public struct InvitationQL: Model {
  public let id: String
  public var invitationCode: String?
  public var timestamp: Int?
  public var userprofileqlID: String
  public var userprofileql: UserProfileQL?
  public var invitationorganizationqlID: String
  public var invitationorganizationql: InvitationOrganizationQL?
  
  public init(id: String = UUID().uuidString,
      invitationCode: String? = nil,
      timestamp: Int? = nil,
      userprofileqlID: String,
      userprofileql: UserProfileQL? = nil,
      invitationorganizationqlID: String,
      invitationorganizationql: InvitationOrganizationQL? = nil) {
      self.id = id
      self.invitationCode = invitationCode
      self.timestamp = timestamp
      self.userprofileqlID = userprofileqlID
      self.userprofileql = userprofileql
      self.invitationorganizationqlID = invitationorganizationqlID
      self.invitationorganizationql = invitationorganizationql
  }
}