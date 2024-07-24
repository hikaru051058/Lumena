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
    case lume
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let lumeStateQL = LumeStateQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "LumeStateQLS"
    
    model.fields(
      .id(),
      .field(lumeStateQL.state, is: .optional, ofType: .enum(type: LumeState.self)),
      .field(lumeStateQL.timestamp, is: .optional, ofType: .int),
      .field(lumeStateQL.reason, is: .optional, ofType: .string),
      .field(lumeStateQL.changedBy, is: .optional, ofType: .string),
      .field(lumeStateQL.lumeqlID, is: .required, ofType: .string),
      .hasOne(lumeStateQL.lume, is: .optional, ofType: LumeQL.self, associatedWith: LumeQL.keys.id, targetName: "lumeqlID")
    )
    }
}