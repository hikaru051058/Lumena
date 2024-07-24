// swiftlint:disable all
import Amplify
import Foundation

extension FollowQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case timestamp
    case followingID
    case following
    case followerID
    case follower
    case status
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let followQL = FollowQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "FollowQLS"
    
    model.fields(
      .id(),
      .field(followQL.timestamp, is: .optional, ofType: .int),
      .field(followQL.followingID, is: .required, ofType: .string),
      .hasOne(followQL.following, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "followingID"),
      .field(followQL.followerID, is: .required, ofType: .string),
      .hasOne(followQL.follower, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "followerID"),
      .field(followQL.status, is: .optional, ofType: .enum(type: FollowStatus.self))
    )
    }
}