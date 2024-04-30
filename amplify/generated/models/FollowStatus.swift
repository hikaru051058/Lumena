// swiftlint:disable all
import Amplify
import Foundation

public enum FollowStatus: String, EnumPersistable {
  case pending = "PENDING"
  case approved = "APPROVED"
  case rejected = "REJECTED"
}