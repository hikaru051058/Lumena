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
    let skinSettingsAttributesQL = SkinSettingsAttributesQL.keys
    
    model.pluralName = "SkinSettingsAttributesQLS"
    
    model.fields(
      .field(skinSettingsAttributesQL.skinSensitivity, is: .optional, ofType: .enum(type: SkinSensitivity.self)),
      .field(skinSettingsAttributesQL.skinUVBathing, is: .optional, ofType: .string),
      .field(skinSettingsAttributesQL.skinType, is: .optional, ofType: .enum(type: SkinType.self)),
      .field(skinSettingsAttributesQL.skinPersonalColor, is: .optional, ofType: .enum(type: SkinPersonalColor.self)),
      .field(skinSettingsAttributesQL.skinEyeColor, is: .optional, ofType: .string),
      .field(skinSettingsAttributesQL.skinColor, is: .optional, ofType: .string),
      .field(skinSettingsAttributesQL.skinConcerns, is: .optional, ofType: .enum(type: SkinConcerns.self))
    )
    }
}