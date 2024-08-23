// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticSearchTagFrequency {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case word
    case clickCount
    case extractionCount
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticSearchTagFrequency = CosmeticSearchTagFrequency.keys
    
    model.pluralName = "CosmeticSearchTagFrequencies"
    
    model.fields(
      .field(cosmeticSearchTagFrequency.word, is: .optional, ofType: .string),
      .field(cosmeticSearchTagFrequency.clickCount, is: .optional, ofType: .int),
      .field(cosmeticSearchTagFrequency.extractionCount, is: .optional, ofType: .int)
    )
    }
}