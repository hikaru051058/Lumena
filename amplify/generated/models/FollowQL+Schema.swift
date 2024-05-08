// swiftlint:disable all
import Amplify
import Foundation

extension FollowQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case timestamp
    case following
    case followerID
    case status
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let followQL = FollowQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "FollowQLS"
    model.syncPluralName = "FollowQLS"
    
    model.attributes(
      .index(fields: ["followingID"], name: "byUserProfileQL"),
      .primaryKey(fields: [followQL.id])
    )
    
    model.fields(
      .field(followQL.id, is: .required, ofType: .string),
      .field(followQL.timestamp, is: .optional, ofType: .int),
      .belongsTo(followQL.following, is: .optional, ofType: UserProfileQL.self, targetNames: ["followingID"]),
      .field(followQL.followerID, is: .optional, ofType: .string),
      .field(followQL.status, is: .optional, ofType: .enum(type: FollowStatus.self)),
      .field(followQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(followQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension FollowQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}