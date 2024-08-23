// swiftlint:disable all
import Amplify
import Foundation

public struct CosmeticSearchTagFrequency: Embeddable {
  var word: String?
  var clickCount: Int?
  var extractionCount: Int?
}