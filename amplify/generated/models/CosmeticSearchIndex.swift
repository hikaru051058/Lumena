// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticSearchIndex: Model {
  public let id: String
  public var topCosmtics: [IndividualSearchCosmetic]?
  public var cosmeticCount: Int?
  public var lastUpdated: Int?
  public var tags: [CosmeticSearchTagFrequency]?
  public var integrityCheckSum: String?
  public var searchTermStatus: CosmeticSearchIndexStatus?
  public var jsonFileCount: Int?
  
  public init(id: String = UUID().uuidString,
      topCosmtics: [IndividualSearchCosmetic]? = [],
      cosmeticCount: Int? = nil,
      lastUpdated: Int? = nil,
      tags: [CosmeticSearchTagFrequency]? = [],
      integrityCheckSum: String? = nil,
      searchTermStatus: CosmeticSearchIndexStatus? = nil,
      jsonFileCount: Int? = nil) {
      self.id = id
      self.topCosmtics = topCosmtics
      self.cosmeticCount = cosmeticCount
      self.lastUpdated = lastUpdated
      self.tags = tags
      self.integrityCheckSum = integrityCheckSum
      self.searchTermStatus = searchTermStatus
      self.jsonFileCount = jsonFileCount
  }
}