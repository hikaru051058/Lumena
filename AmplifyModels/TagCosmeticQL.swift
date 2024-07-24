// swiftlint:disable all
import Amplify
import Foundation

public struct TagCosmeticQL: Embeddable {
  var cosmeticID: String
  var authProduct: Bool
  var recommend: Double?
  var effect: Double?
  var fading: Double?
  var feeling: Double?
  var attachedURL: String?
}