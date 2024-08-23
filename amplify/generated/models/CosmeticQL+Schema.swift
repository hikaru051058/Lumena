// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case productName
    case totPostTagCount
    case authenticated
    case cosmeticbrandqlID
    case cosmeticbrandql
    case description
    case rating
    case category
    case productType
    case imageURL
    case productURL
    case createdAt
    case updatedAt
    case variants
    case criteriaTags
    case ingredients
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
      .field(cosmeticQL.totPostTagCount, is: .optional, ofType: .int),
      .field(cosmeticQL.authenticated, is: .optional, ofType: .bool),
      .field(cosmeticQL.cosmeticbrandqlID, is: .required, ofType: .string),
      .hasOne(cosmeticQL.cosmeticbrandql, is: .optional, ofType: CosmeticBrandQL.self, associatedWith: CosmeticBrandQL.keys.id, targetName: "cosmeticbrandqlID"),
      .field(cosmeticQL.description, is: .optional, ofType: .string),
      .field(cosmeticQL.rating, is: .optional, ofType: .double),
      .field(cosmeticQL.category, is: .optional, ofType: .string),
      .field(cosmeticQL.productType, is: .optional, ofType: .string),
      .field(cosmeticQL.imageURL, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticQL.productURL, is: .optional, ofType: .string),
      .field(cosmeticQL.createdAt, is: .optional, ofType: .int),
      .field(cosmeticQL.updatedAt, is: .optional, ofType: .int),
      .field(cosmeticQL.variants, is: .optional, ofType: .embeddedCollection(of: CosmeticVariant.self)),
      .field(cosmeticQL.criteriaTags, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticQL.ingredients, is: .optional, ofType: .embeddedCollection(of: String.self))
    )
    }
}