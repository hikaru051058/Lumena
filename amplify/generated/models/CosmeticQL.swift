// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticQL: Model {
  public let id: String
  public var productName: String
  public var totPostTagCount: Int?
  public var authenticated: Bool?
  public var cosmeticbrandqlID: String
  public var cosmeticbrandql: CosmeticBrandQL?
  public var description: String?
  public var rating: Double?
  public var category: String?
  public var productType: String?
  public var imageURL: [String]?
  public var productURL: String?
  public var createdAt: Int?
  public var updatedAt: Int?
  public var variants: [CosmeticVariant]?
  public var criteriaTags: [String]?
  public var ingredients: [String]?
  
  public init(id: String = UUID().uuidString,
      productName: String,
      totPostTagCount: Int? = nil,
      authenticated: Bool? = nil,
      cosmeticbrandqlID: String,
      cosmeticbrandql: CosmeticBrandQL? = nil,
      description: String? = nil,
      rating: Double? = nil,
      category: String? = nil,
      productType: String? = nil,
      imageURL: [String]? = [],
      productURL: String? = nil,
      createdAt: Int? = nil,
      updatedAt: Int? = nil,
      variants: [CosmeticVariant]? = [],
      criteriaTags: [String]? = [],
      ingredients: [String]? = []) {
      self.id = id
      self.productName = productName
      self.totPostTagCount = totPostTagCount
      self.authenticated = authenticated
      self.cosmeticbrandqlID = cosmeticbrandqlID
      self.cosmeticbrandql = cosmeticbrandql
      self.description = description
      self.rating = rating
      self.category = category
      self.productType = productType
      self.imageURL = imageURL
      self.productURL = productURL
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.variants = variants
      self.criteriaTags = criteriaTags
      self.ingredients = ingredients
  }
}