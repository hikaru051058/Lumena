// swiftlint:disable all
import Amplify
import Foundation

public enum AccountState: String, EnumPersistable {
  case active = "ACTIVE"
  case suspended = "SUSPENDED"
  case pendingVerification = "PENDING_VERIFICATION"
  case deleted = "DELETED"
  case banned = "BANNED"
}