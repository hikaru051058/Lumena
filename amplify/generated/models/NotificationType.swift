// swiftlint:disable all
import Amplify
import Foundation

public enum NotificationType: String, EnumPersistable {
  case apple = "APPLE"
  case google = "GOOGLE"
}