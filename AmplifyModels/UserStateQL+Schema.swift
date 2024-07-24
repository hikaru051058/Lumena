// swiftlint:disable all
import Amplify
import Foundation

extension UserStateQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case UserState
    case timestamp
    case reason
    case changedBy
    case userprofileqlID
    case userprofileql
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userStateQL = UserStateQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "UserStateQLS"
    
    model.fields(
      .id(),
      .field(userStateQL.UserState, is: .optional, ofType: .enum(type: AccountState.self)),
      .field(userStateQL.timestamp, is: .optional, ofType: .int),
      .field(userStateQL.reason, is: .optional, ofType: .string),
      .field(userStateQL.changedBy, is: .optional, ofType: .string),
      .field(userStateQL.userprofileqlID, is: .required, ofType: .string),
      .hasOne(userStateQL.userprofileql, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "userprofileqlID")
    )
    }
}