// swiftlint:disable all
import Amplify
import Foundation

extension SkinSettingsAttributesQL {
  // MARK: - CodingKeys
   public enum CodingKeys: String, ModelKey {
    case skinSensitivity
    case skinUVBathing
    case skinType
    case skinPersonalColor
    case skinEyeColor
    case skinColor
    case skinConcerns
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let skinSettingsAttributes = SkinSettingsAttributesQL.keys
    
    model.pluralName = "SkinSettingsAttributesQL"
    
    model.fields(
      .field(skinSettingsAttributes.skinSensitivity, is: .optional, ofType: .enum(type: SkinSensitivity.self)),
      .field(skinSettingsAttributes.skinUVBathing, is: .optional, ofType: .string),
      .field(skinSettingsAttributes.skinType, is: .optional, ofType: .enum(type: SkinType.self)),
      .field(skinSettingsAttributes.skinPersonalColor, is: .optional, ofType: .enum(type: SkinPersonalColor.self)),
      .field(skinSettingsAttributes.skinEyeColor, is: .optional, ofType: .string),
      .field(skinSettingsAttributes.skinColor, is: .optional, ofType: .string),
      .field(skinSettingsAttributes.skinConcerns, is: .optional, ofType: .enum(type: SkinConcerns.self))
    )
    }
}
