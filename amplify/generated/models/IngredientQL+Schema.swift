// swiftlint:disable all
import Amplify
import Foundation

extension IngredientQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case name
    case description
    case effectOnSkin
    case synonyms
    case casNumbers
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let ingredientQL = IngredientQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "IngredientQLS"
    
    model.fields(
      .id(),
      .field(ingredientQL.name, is: .required, ofType: .string),
      .field(ingredientQL.description, is: .optional, ofType: .string),
      .field(ingredientQL.effectOnSkin, is: .optional, ofType: .embeddedCollection(of: Double.self)),
      .field(ingredientQL.synonyms, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(ingredientQL.casNumbers, is: .optional, ofType: .embeddedCollection(of: String.self))
    )
    }
}