// swiftlint:disable all
import Amplify
import Foundation

public struct SkinSettingsAttributesQL: Embeddable {
  var skinSensitivity: SkinSensitivity?
  var skinUVBathing: String?
  var skinType: SkinType?
  var skinPersonalColor: SkinPersonalColor?
  var skinEyeColor: String?
  var skinColor: String?
  var skinConcerns: SkinConcerns?
}
