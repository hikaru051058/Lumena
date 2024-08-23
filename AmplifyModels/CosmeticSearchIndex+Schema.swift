// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticSearchIndex {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case topCosmtics
    case cosmeticCount
    case lastUpdated
    case tags
    case integrityCheckSum
    case searchTermStatus
    case jsonFileCount
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticSearchIndex = CosmeticSearchIndex.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "CosmeticSearchIndices"
    
    model.fields(
      .id(),
      .field(cosmeticSearchIndex.topCosmtics, is: .optional, ofType: .embeddedCollection(of: IndividualSearchCosmetic.self)),
      .field(cosmeticSearchIndex.cosmeticCount, is: .optional, ofType: .int),
      .field(cosmeticSearchIndex.lastUpdated, is: .optional, ofType: .int),
      .field(cosmeticSearchIndex.tags, is: .optional, ofType: .embeddedCollection(of: CosmeticSearchTagFrequency.self)),
      .field(cosmeticSearchIndex.integrityCheckSum, is: .optional, ofType: .string),
      .field(cosmeticSearchIndex.searchTermStatus, is: .optional, ofType: .enum(type: CosmeticSearchIndexStatus.self)),
      .field(cosmeticSearchIndex.jsonFileCount, is: .optional, ofType: .int)
    )
    }
}