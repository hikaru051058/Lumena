// swiftlint:disable all
import Amplify
import Foundation

public enum LumeState: String, EnumPersistable {
  case visible = "VISIBLE"
  case hidden = "HIDDEN"
  case deleted = "DELETED"
  case reported = "REPORTED"
}