// swiftlint:disable all
import Amplify
import Foundation

public enum CosmeticSearchIndexStatus: String, EnumPersistable {
  case archived = "ARCHIVED"
  case pending = "PENDING"
  case restricted = "RESTRICTED"
}