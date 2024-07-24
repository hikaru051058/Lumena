// swiftlint:disable all
import Amplify
import Foundation

public enum BlockStatus: String, EnumPersistable {
  case blocked = "BLOCKED"
  case blocking = "BLOCKING"
  case mutual = "MUTUAL"
}