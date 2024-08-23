// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticVariant: Embeddable {
  var variantName: String?
  var hexCode: String?
  var description: String?
  var additionalInfo: String?
  var amount: CosmeticAmount?
  var price: CosmeticPrice?
  var productURL: [String]?
  var barcode: String?
  var ingredientIDs: [String]?
  var imageURL: [String]?
  var rating: Double?
}