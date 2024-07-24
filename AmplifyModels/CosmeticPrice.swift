// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticPrice: Embeddable {
  var price: Double?
  var priceSign: String?
  var currency: String?
}