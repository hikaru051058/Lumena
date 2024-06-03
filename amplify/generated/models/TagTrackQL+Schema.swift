// swiftlint:disable all
import Amplify
import Foundation

extension TagTrackQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case trackID
    case tagMusicRange
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let tagTrackQL = TagTrackQL.keys
    
    model.listPluralName = "TagTrackQLS"
    model.syncPluralName = "TagTrackQLS"
    
    model.fields(
      .field(tagTrackQL.trackID, is: .required, ofType: .string),
      .field(tagTrackQL.tagMusicRange, is: .optional, ofType: .embeddedCollection(of: Double.self))
    )
    }
}