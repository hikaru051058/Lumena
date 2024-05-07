// swiftlint:disable all
import Amplify
import Foundation

extension LumeQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case postURL
    case timestamp
    case tagProducts
    case tagMusic
    case description
    case userprofile
    case likeCount
    case commentCount
    case hashTags
    case zipURL
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let lumeQL = LumeQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "LumeQLS"
    model.syncPluralName = "LumeQLS"
    
    model.attributes(
      .index(fields: ["userprofileqlID"], name: "byUserProfileQL"),
      .primaryKey(fields: [lumeQL.id])
    )
    
    model.fields(
      .field(lumeQL.id, is: .required, ofType: .string),
      .field(lumeQL.postURL, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(lumeQL.timestamp, is: .required, ofType: .int),
      .field(lumeQL.tagProducts, is: .optional, ofType: .embeddedCollection(of: TagCosmeticQL.self)),
      .field(lumeQL.tagMusic, is: .optional, ofType: .embedded(type: TagTrackQL.self)),
      .field(lumeQL.description, is: .optional, ofType: .string),
      .belongsTo(lumeQL.userprofile, is: .optional, ofType: UserProfileQL.self, targetNames: ["userprofileqlID"]),
      .field(lumeQL.likeCount, is: .optional, ofType: .int),
      .field(lumeQL.commentCount, is: .optional, ofType: .int),
      .field(lumeQL.hashTags, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(lumeQL.zipURL, is: .optional, ofType: .string),
      .field(lumeQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(lumeQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension LumeQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}