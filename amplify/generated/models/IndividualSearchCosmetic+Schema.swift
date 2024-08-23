// swiftlint:disable all
import Amplify
import Foundation

extension IndividualSearchCosmetic {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case cosmeticID
    case clickedCount
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let individualSearchCosmetic = IndividualSearchCosmetic.keys
    
    model.pluralName = "IndividualSearchCosmetics"
    
    model.fields(
      .field(individualSearchCosmetic.cosmeticID, is: .optional, ofType: .string),
      .field(individualSearchCosmetic.clickedCount, is: .optional, ofType: .int)
    )
    }
}