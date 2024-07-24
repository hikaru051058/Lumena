// swiftlint:disable all
import Amplify
import Foundation

public struct NotificationQL: Model {
  public let id: String
  public var notificationType: NotificationType
  public var message: String
  public var userprofileqlID: String
  public var userProfile: UserProfileQL?
  public var validTill: Int?
  public var createdAt: Int?
  public var updatedAt: Int?
  
  public init(id: String = UUID().uuidString,
      notificationType: NotificationType,
      message: String,
      userprofileqlID: String,
      userProfile: UserProfileQL? = nil,
      validTill: Int? = nil,
      createdAt: Int? = nil,
      updatedAt: Int? = nil) {
      self.id = id
      self.notificationType = notificationType
      self.message = message
      self.userprofileqlID = userprofileqlID
      self.userProfile = userProfile
      self.validTill = validTill
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}