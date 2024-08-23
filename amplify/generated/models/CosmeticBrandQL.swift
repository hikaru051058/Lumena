// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticBrandQL: Model {
  public let id: String
  public var name: String?
  public var websiteURL: String?
  public var description: String?
  
  public init(id: String = UUID().uuidString,
      name: String? = nil,
      websiteURL: String? = nil,
      description: String? = nil) {
      self.id = id
      self.name = name
      self.websiteURL = websiteURL
      self.description = description
  }
}