// swiftlint:disable all
import Amplify
import Foundation

extension LumeStateQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case state
    case timestamp
    case reason
    case changedBy
    case lumeqlID
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let lumeStateQL = LumeStateQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "LumeStateQLS"
    model.syncPluralName = "LumeStateQLS"
    
    model.attributes(
      .index(fields: ["lumeqlID"], name: "byLumeQL"),
      .primaryKey(fields: [lumeStateQL.id])
    )
    
    model.fields(
      .field(lumeStateQL.id, is: .required, ofType: .string),
      .field(lumeStateQL.state, is: .optional, ofType: .enum(type: LumeState.self)),
      .field(lumeStateQL.timestamp, is: .optional, ofType: .int),
      .field(lumeStateQL.reason, is: .optional, ofType: .string),
      .field(lumeStateQL.changedBy, is: .optional, ofType: .string),
      .field(lumeStateQL.lumeqlID, is: .required, ofType: .string),
      .field(lumeStateQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(lumeStateQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension LumeStateQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}