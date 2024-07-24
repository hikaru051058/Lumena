// swiftlint:disable all
import Amplify
import Foundation

public enum SkinType: String, EnumPersistable {
  case oily = "OILY"
  case combination = "COMBINATION"
  case normal = "NORMAL"
  case sensitive = "SENSITIVE"
  case dry = "DRY"
}