// swiftlint:disable all
import Amplify
import Foundation

extension NotificationQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case notificationType
    case message
    case userprofileqlID
    case userProfile
    case validTill
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let notificationQL = NotificationQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "NotificationQLS"
    
    model.fields(
      .id(),
      .field(notificationQL.notificationType, is: .required, ofType: .enum(type: NotificationType.self)),
      .field(notificationQL.message, is: .required, ofType: .string),
      .field(notificationQL.userprofileqlID, is: .required, ofType: .string),
      .hasOne(notificationQL.userProfile, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "userprofileqlID"),
      .field(notificationQL.validTill, is: .optional, ofType: .int),
      .field(notificationQL.createdAt, is: .optional, ofType: .int),
      .field(notificationQL.updatedAt, is: .optional, ofType: .int)
    )
    }
}