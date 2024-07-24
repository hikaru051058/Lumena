// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticQL: Model {
  public let id: String
  public var productName: String
  public var price: CosmeticPrice?
  public var amount: String?
  public var totPostTagCount: Int?
  public var authenticated: Bool
  public var cosmeticbrandqlID: String
  public var cosmeticbrandql: CosmeticBrandQL?
  public var description: String?
  public var rating: Double?
  public var category: String?
  public var productType: String?
  public var imageLink: [String]?
  public var productLink: String?
  public var createdAt: Int?
  public var updatedAt: Int?
  public var productColors: [ProductColor]?
  public var barcode: String?
  public var criteriaTags: [String]?
  
  public init(id: String = UUID().uuidString,
      productName: String,
      price: CosmeticPrice? = nil,
      amount: String? = nil,
      totPostTagCount: Int? = nil,
      authenticated: Bool,
      cosmeticbrandqlID: String,
      cosmeticbrandql: CosmeticBrandQL? = nil,
      description: String? = nil,
      rating: Double? = nil,
      category: String? = nil,
      productType: String? = nil,
      imageLink: [String]? = [],
      productLink: String? = nil,
      createdAt: Int? = nil,
      updatedAt: Int? = nil,
      productColors: [ProductColor]? = [],
      barcode: String? = nil,
      criteriaTags: [String]? = []) {
      self.id = id
      self.productName = productName
      self.price = price
      self.amount = amount
      self.totPostTagCount = totPostTagCount
      self.authenticated = authenticated
      self.cosmeticbrandqlID = cosmeticbrandqlID
      self.cosmeticbrandql = cosmeticbrandql
      self.description = description
      self.rating = rating
      self.category = category
      self.productType = productType
      self.imageLink = imageLink
      self.productLink = productLink
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.productColors = productColors
      self.barcode = barcode
      self.criteriaTags = criteriaTags
  }
}