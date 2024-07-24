// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticPrice {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case price
    case priceSign
    case currency
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticPrice = CosmeticPrice.keys
    
    model.pluralName = "CosmeticPrices"
    
    model.fields(
      .field(cosmeticPrice.price, is: .optional, ofType: .double),
      .field(cosmeticPrice.priceSign, is: .optional, ofType: .string),
      .field(cosmeticPrice.currency, is: .optional, ofType: .string)
    )
    }
}