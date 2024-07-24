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
    case userprofileqlID
    case userprofileql
    case likeCount
    case commentCount
    case hashTags
    case zipURL
    case lumeAuth
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let lumeQL = LumeQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "LumeQLS"
    
    model.fields(
      .id(),
      .field(lumeQL.postURL, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(lumeQL.timestamp, is: .required, ofType: .int),
      .field(lumeQL.tagProducts, is: .optional, ofType: .embeddedCollection(of: TagCosmeticQL.self)),
      .field(lumeQL.tagMusic, is: .optional, ofType: .embedded(type: TagTrackQL.self)),
      .field(lumeQL.description, is: .optional, ofType: .string),
      .field(lumeQL.userprofileqlID, is: .required, ofType: .string),
      .hasOne(lumeQL.userprofileql, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "userprofileqlID"),
      .field(lumeQL.likeCount, is: .optional, ofType: .int),
      .field(lumeQL.commentCount, is: .optional, ofType: .int),
      .field(lumeQL.hashTags, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(lumeQL.zipURL, is: .optional, ofType: .string),
      .field(lumeQL.lumeAuth, is: .optional, ofType: .bool)
    )
    }
}