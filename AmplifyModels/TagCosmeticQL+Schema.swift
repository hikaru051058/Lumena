// swiftlint:disable all
import Amplify
import Foundation

extension TagCosmeticQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case cosmeticID
    case authProduct
    case recommend
    case effect
    case fading
    case feeling
    case attachedURL
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let tagCosmeticQL = TagCosmeticQL.keys
    
    model.listPluralName = "TagCosmeticQLS"
    model.syncPluralName = "TagCosmeticQLS"
    
    model.fields(
      .field(tagCosmeticQL.cosmeticID, is: .required, ofType: .string),
      .field(tagCosmeticQL.authProduct, is: .required, ofType: .bool),
      .field(tagCosmeticQL.recommend, is: .optional, ofType: .double),
      .field(tagCosmeticQL.effect, is: .optional, ofType: .double),
      .field(tagCosmeticQL.fading, is: .optional, ofType: .double),
      .field(tagCosmeticQL.feeling, is: .optional, ofType: .double),
      .field(tagCosmeticQL.attachedURL, is: .optional, ofType: .string)
    )
    }
}