// swiftlint:disable all
import Amplify
import Foundation

extension InvitationQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case invitationCode
    case timestamp
    case userprofileqlID
    case userprofileql
    case invitationorganizationqlID
    case invitationorganizationql
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let invitationQL = InvitationQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "InvitationQLS"
    
    model.fields(
      .id(),
      .field(invitationQL.invitationCode, is: .optional, ofType: .string),
      .field(invitationQL.timestamp, is: .optional, ofType: .int),
      .field(invitationQL.userprofileqlID, is: .required, ofType: .string),
      .hasOne(invitationQL.userprofileql, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "userprofileqlID"),
      .field(invitationQL.invitationorganizationqlID, is: .required, ofType: .string),
      .hasOne(invitationQL.invitationorganizationql, is: .optional, ofType: InvitationOrganizationQL.self, associatedWith: InvitationOrganizationQL.keys.id, targetName: "invitationorganizationqlID")
    )
    }
}