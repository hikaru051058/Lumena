// swiftlint:disable all
import Amplify
import Foundation

public enum ProductType: String, EnumPersistable {
  case mascara = "MASCARA"
  case eyeShadow = "EYE_SHADOW"
  case foundation = "FOUNDATION"
}