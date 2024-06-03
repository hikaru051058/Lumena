// swiftlint:disable all
import Amplify
import Foundation

extension LikedLumeQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case timestamp
    case lumeQLID
    case lume
    case userprofileqlID
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let likedLumeQL = LikedLumeQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "LikedLumeQLS"
    model.syncPluralName = "LikedLumeQLS"
    
    model.attributes(
      .index(fields: ["userprofileqlID"], name: "byUserProfileQL"),
      .primaryKey(fields: [likedLumeQL.id])
    )
    
    model.fields(
      .field(likedLumeQL.id, is: .required, ofType: .string),
      .field(likedLumeQL.timestamp, is: .optional, ofType: .int),
      .field(likedLumeQL.lumeQLID, is: .required, ofType: .string),
      .hasOne(likedLumeQL.lume, is: .optional, ofType: LumeQL.self, associatedWith: LumeQL.keys.id, targetNames: ["lumeQLID"]),
      .field(likedLumeQL.userprofileqlID, is: .required, ofType: .string),
      .field(likedLumeQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(likedLumeQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension LikedLumeQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}