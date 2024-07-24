// swiftlint:disable all
import Amplify
import Foundation

public enum SkinSensitivity: String, EnumPersistable {
  case extremelySensitive = "EXTREMELY_SENSITIVE"
  case verySensitive = "VERY_SENSITIVE"
  case sensitive = "SENSITIVE"
  case slightlySensitive = "SLIGHTLY_SENSITIVE"
  case notSensitive = "NOT_SENSITIVE"
}