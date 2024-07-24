// swiftlint:disable all
import Amplify
import Foundation

extension CommentQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case timestamp
    case comment
    case lumeQLID
    case lume
    case userprofileqlID
    case userprofileql
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let commentQL = CommentQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "CommentQLS"
    
    model.fields(
      .id(),
      .field(commentQL.timestamp, is: .required, ofType: .int),
      .field(commentQL.comment, is: .required, ofType: .string),
      .field(commentQL.lumeQLID, is: .required, ofType: .string),
      .hasOne(commentQL.lume, is: .optional, ofType: LumeQL.self, associatedWith: LumeQL.keys.id, targetName: "lumeQLID"),
      .field(commentQL.userprofileqlID, is: .required, ofType: .string),
      .hasOne(commentQL.userprofileql, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "userprofileqlID")
    )
    }
}