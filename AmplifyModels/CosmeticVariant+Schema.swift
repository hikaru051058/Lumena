// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticVariant {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case variantName
    case hexCode
    case description
    case additionalInfo
    case amount
    case price
    case productURL
    case barcode
    case ingredientIDs
    case imageURL
    case rating
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticVariant = CosmeticVariant.keys
    
    model.pluralName = "CosmeticVariants"
    
    model.fields(
      .field(cosmeticVariant.variantName, is: .optional, ofType: .string),
      .field(cosmeticVariant.hexCode, is: .optional, ofType: .string),
      .field(cosmeticVariant.description, is: .optional, ofType: .string),
      .field(cosmeticVariant.additionalInfo, is: .optional, ofType: .string),
      .field(cosmeticVariant.amount, is: .optional, ofType: .embedded(type: CosmeticAmount.self)),
      .field(cosmeticVariant.price, is: .optional, ofType: .embedded(type: CosmeticPrice.self)),
      .field(cosmeticVariant.productURL, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticVariant.barcode, is: .optional, ofType: .string),
      .field(cosmeticVariant.ingredientIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticVariant.imageURL, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticVariant.rating, is: .optional, ofType: .double)
    )
    }
}