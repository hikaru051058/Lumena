// swiftlint:disable all
import Amplify
import Foundation

extension InvitationOrganizationQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case organizationName
    case validTill
    case userprofileqlID
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let invitationOrganizationQL = InvitationOrganizationQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "InvitationOrganizationQLS"
    
    model.fields(
      .id(),
      .field(invitationOrganizationQL.organizationName, is: .optional, ofType: .string),
      .field(invitationOrganizationQL.validTill, is: .optional, ofType: .int),
      .field(invitationOrganizationQL.userprofileqlID, is: .required, ofType: .string)
    )
    }
}