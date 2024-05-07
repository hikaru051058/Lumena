// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticQL: Model {
  public let id: String
  public var productName: String
  public var companyID: String
  public var price: String?
  public var amount: String?
  public var totTagCount: Int?
  public var authenticated: Bool
  public var link: [String?]?
  public var tagCnt: Int?
  public var type: String?
  public var zipURL: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      productName: String,
      companyID: String,
      price: String? = nil,
      amount: String? = nil,
      totTagCount: Int? = nil,
      authenticated: Bool,
      link: [String?]? = nil,
      tagCnt: Int? = nil,
      type: String? = nil,
      zipURL: String? = nil) {
    self.init(id: id,
      productName: productName,
      companyID: companyID,
      price: price,
      amount: amount,
      totTagCount: totTagCount,
      authenticated: authenticated,
      link: link,
      tagCnt: tagCnt,
      type: type,
      zipURL: zipURL,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      productName: String,
      companyID: String,
      price: String? = nil,
      amount: String? = nil,
      totTagCount: Int? = nil,
      authenticated: Bool,
      link: [String?]? = nil,
      tagCnt: Int? = nil,
      type: String? = nil,
      zipURL: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.productName = productName
      self.companyID = companyID
      self.price = price
      self.amount = amount
      self.totTagCount = totTagCount
      self.authenticated = authenticated
      self.link = link
      self.tagCnt = tagCnt
      self.type = type
      self.zipURL = zipURL
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}