// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case productName
    case price
    case amount
    case totPostTagCount
    case authenticated
    case cosmeticbrandqlID
    case cosmeticbrandql
    case description
    case rating
    case category
    case productType
    case imageLink
    case productLink
    case createdAt
    case updatedAt
    case productColors
    case barcode
    case criteriaTags
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticQL = CosmeticQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "CosmeticQLS"
    
    model.fields(
      .id(),
      .field(cosmeticQL.productName, is: .required, ofType: .string),
      .field(cosmeticQL.price, is: .optional, ofType: .embedded(type: CosmeticPrice.self)),
      .field(cosmeticQL.amount, is: .optional, ofType: .string),
      .field(cosmeticQL.totPostTagCount, is: .optional, ofType: .int),
      .field(cosmeticQL.authenticated, is: .required, ofType: .bool),
      .field(cosmeticQL.cosmeticbrandqlID, is: .required, ofType: .string),
      .hasOne(cosmeticQL.cosmeticbrandql, is: .optional, ofType: CosmeticBrandQL.self, associatedWith: CosmeticBrandQL.keys.id, targetName: "cosmeticbrandqlID"),
      .field(cosmeticQL.description, is: .optional, ofType: .string),
      .field(cosmeticQL.rating, is: .optional, ofType: .double),
      .field(cosmeticQL.category, is: .optional, ofType: .string),
      .field(cosmeticQL.productType, is: .optional, ofType: .string),
      .field(cosmeticQL.imageLink, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticQL.productLink, is: .optional, ofType: .string),
      .field(cosmeticQL.createdAt, is: .optional, ofType: .int),
      .field(cosmeticQL.updatedAt, is: .optional, ofType: .int),
      .field(cosmeticQL.productColors, is: .optional, ofType: .embeddedCollection(of: ProductColor.self)),
      .field(cosmeticQL.barcode, is: .optional, ofType: .string),
      .field(cosmeticQL.criteriaTags, is: .optional, ofType: .embeddedCollection(of: String.self))
    )
    }
}