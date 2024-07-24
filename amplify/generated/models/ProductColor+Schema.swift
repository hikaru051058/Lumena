// swiftlint:disable all
import Amplify
import Foundation

extension ProductColor {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case hexValue
    case colorName
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let productColor = ProductColor.keys
    
    model.pluralName = "ProductColors"
    
    model.fields(
      .field(productColor.hexValue, is: .optional, ofType: .string),
      .field(productColor.colorName, is: .optional, ofType: .string)
    )
    }
}