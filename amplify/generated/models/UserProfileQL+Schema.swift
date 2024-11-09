// swiftlint:disable all
import Amplify
import Foundation

extension UserProfileQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case username
    case DOB
    case firstName
    case lockState
    case profileImage
    case backgroundImage
    case followerCount
    case followingCount
    case bio
    case postCount
    case profileImageLastModified
    case backgroundImageLastModified
    case skinSettings
    case skinStreaks
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userProfileQL = UserProfileQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "UserProfileQLS"
    
    model.fields(
      .id(),
      .field(userProfileQL.username, is: .required, ofType: .string),
      .field(userProfileQL.DOB, is: .optional, ofType: .int),
      .field(userProfileQL.firstName, is: .optional, ofType: .string),
      .field(userProfileQL.lockState, is: .optional, ofType: .bool),
      .field(userProfileQL.profileImage, is: .optional, ofType: .string),
      .field(userProfileQL.backgroundImage, is: .optional, ofType: .string),
      .field(userProfileQL.followerCount, is: .optional, ofType: .int),
      .field(userProfileQL.followingCount, is: .optional, ofType: .int),
      .field(userProfileQL.bio, is: .optional, ofType: .string),
      .field(userProfileQL.postCount, is: .optional, ofType: .int),
      .field(userProfileQL.profileImageLastModified, is: .optional, ofType: .int),
      .field(userProfileQL.backgroundImageLastModified, is: .optional, ofType: .int),
      .field(userProfileQL.skinSettings, is: .optional, ofType: .embedded(type: SkinSettingsAttributesQL.self)),
      .field(userProfileQL.skinStreaks, is: .optional, ofType: .int)
    )
    }
}