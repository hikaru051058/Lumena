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
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let commentQL = CommentQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "CommentQLS"
    model.syncPluralName = "CommentQLS"
    
    model.attributes(
      .index(fields: ["userprofileqlID"], name: "byUserProfileQL"),
      .primaryKey(fields: [commentQL.id])
    )
    
    model.fields(
      .field(commentQL.id, is: .required, ofType: .string),
      .field(commentQL.timestamp, is: .required, ofType: .int),
      .field(commentQL.comment, is: .required, ofType: .string),
      .field(commentQL.lumeQLID, is: .required, ofType: .string),
      .hasOne(commentQL.lume, is: .optional, ofType: LumeQL.self, associatedWith: LumeQL.keys.id, targetNames: ["lumeQLID"]),
      .field(commentQL.userprofileqlID, is: .required, ofType: .string),
      .field(commentQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(commentQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension CommentQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}