// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticAmount {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case value
    case unit
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticAmount = CosmeticAmount.keys
    
    model.pluralName = "CosmeticAmounts"
    
    model.fields(
      .field(cosmeticAmount.value, is: .optional, ofType: .double),
      .field(cosmeticAmount.unit, is: .optional, ofType: .string)
    )
    }
}