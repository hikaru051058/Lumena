// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticBrandQL: Model {
  public let id: String
  public var name: String?
  public var websiteLink: String?
  public var description: String?
  
  public init(id: String = UUID().uuidString,
      name: String? = nil,
      websiteLink: String? = nil,
      description: String? = nil) {
      self.id = id
      self.name = name
      self.websiteLink = websiteLink
      self.description = description
  }
}