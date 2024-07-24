// swiftlint:disable all
import Amplify
import Foundation

public struct InvitationOrganizationQL: Model {
  public let id: String
  public var organizationName: String?
  public var validTill: Int?
  public var userprofileqlID: String
  
  public init(id: String = UUID().uuidString,
      organizationName: String? = nil,
      validTill: Int? = nil,
      userprofileqlID: String) {
      self.id = id
      self.organizationName = organizationName
      self.validTill = validTill
      self.userprofileqlID = userprofileqlID
  }
}