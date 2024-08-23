// swiftlint:disable all
import Amplify
import Foundation

public struct IngredientQL: Model {
  public let id: String
  public var name: String
  public var description: String?
  public var effectOnSkin: [Double]?
  public var cosmeticqlID: String
  public var synonyms: [String]?
  public var casNumbers: [String]?
  
  public init(id: String = UUID().uuidString,
      name: String,
      description: String? = nil,
      effectOnSkin: [Double]? = [],
      cosmeticqlID: String,
      synonyms: [String]? = [],
      casNumbers: [String]? = []) {
      self.id = id
      self.name = name
      self.description = description
      self.effectOnSkin = effectOnSkin
      self.cosmeticqlID = cosmeticqlID
      self.synonyms = synonyms
      self.casNumbers = casNumbers
  }
}