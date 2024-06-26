// swiftlint:disable all
import Amplify
import Foundation

extension UserProfileQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case followingUsers
    case followerUsers
    case username
    case DOB
    case firstName
    case Sensitivity
    case SunBathing
    case SkinType
    case postContents
    case likedContents
    case comments
    case lockState
    case profileImage
    case backgroundImage
    case followerCount
    case followingCount
    case bio
    case following
    case postCount
    case profileImageLastModified
    case backgroundImageLastModified
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userProfileQL = UserProfileQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "UserProfileQLS"
    model.syncPluralName = "UserProfileQLS"
    
    model.attributes(
      .primaryKey(fields: [userProfileQL.id])
    )
    
    model.fields(
      .field(userProfileQL.id, is: .required, ofType: .string),
      .field(userProfileQL.followingUsers, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(userProfileQL.followerUsers, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(userProfileQL.username, is: .required, ofType: .string),
      .field(userProfileQL.DOB, is: .optional, ofType: .int),
      .field(userProfileQL.firstName, is: .required, ofType: .string),
      .field(userProfileQL.Sensitivity, is: .optional, ofType: .double),
      .field(userProfileQL.SunBathing, is: .optional, ofType: .double),
      .field(userProfileQL.SkinType, is: .optional, ofType: .double),
      .hasMany(userProfileQL.postContents, is: .optional, ofType: LumeQL.self, associatedWith: LumeQL.keys.userprofileqlID),
      .hasMany(userProfileQL.likedContents, is: .optional, ofType: LikedLumeQL.self, associatedWith: LikedLumeQL.keys.userprofileqlID),
      .hasMany(userProfileQL.comments, is: .optional, ofType: CommentQL.self, associatedWith: CommentQL.keys.userprofileqlID),
      .field(userProfileQL.lockState, is: .optional, ofType: .bool),
      .field(userProfileQL.profileImage, is: .optional, ofType: .string),
      .field(userProfileQL.backgroundImage, is: .optional, ofType: .string),
      .field(userProfileQL.followerCount, is: .optional, ofType: .int),
      .field(userProfileQL.followingCount, is: .optional, ofType: .int),
      .field(userProfileQL.bio, is: .optional, ofType: .string),
      .hasMany(userProfileQL.following, is: .optional, ofType: FollowQL.self, associatedWith: FollowQL.keys.following),
      .field(userProfileQL.postCount, is: .optional, ofType: .int),
      .field(userProfileQL.profileImageLastModified, is: .optional, ofType: .int),
      .field(userProfileQL.backgroundImageLastModified, is: .optional, ofType: .int),
      .field(userProfileQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(userProfileQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension UserProfileQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}