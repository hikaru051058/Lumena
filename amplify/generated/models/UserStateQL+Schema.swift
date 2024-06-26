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
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userStateQL = UserStateQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "UserStateQLS"
    model.syncPluralName = "UserStateQLS"
    
    model.attributes(
      .primaryKey(fields: [userStateQL.id])
    )
    
    model.fields(
      .field(userStateQL.id, is: .required, ofType: .string),
      .field(userStateQL.UserState, is: .optional, ofType: .enum(type: AccountState.self)),
      .field(userStateQL.timestamp, is: .optional, ofType: .int),
      .field(userStateQL.reason, is: .optional, ofType: .string),
      .field(userStateQL.changedBy, is: .optional, ofType: .string),
      .field(userStateQL.userprofileqlID, is: .optional, ofType: .string),
      .field(userStateQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(userStateQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension UserStateQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}