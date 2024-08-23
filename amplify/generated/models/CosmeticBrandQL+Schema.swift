// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticBrandQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case websiteURL
    case description
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticBrandQL = CosmeticBrandQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "CosmeticBrandQLS"
    
    model.fields(
      .id(),
      .field(cosmeticBrandQL.name, is: .optional, ofType: .string),
      .field(cosmeticBrandQL.websiteURL, is: .optional, ofType: .string),
      .field(cosmeticBrandQL.description, is: .optional, ofType: .string)
    )
    }
}