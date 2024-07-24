// swiftlint:disable all
import Amplify
import Foundation

extension BlockQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userprofileqlID
    case blockeduserprofileqlID
    case status
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let blockQL = BlockQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "BlockQLS"
    
    model.fields(
      .id(),
      .field(blockQL.userprofileqlID, is: .required, ofType: .string),
      .field(blockQL.blockeduserprofileqlID, is: .required, ofType: .string),
      .field(blockQL.status, is: .optional, ofType: .enum(type: BlockStatus.self))
    )
    }
}