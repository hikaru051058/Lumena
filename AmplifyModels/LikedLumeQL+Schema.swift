// swiftlint:disable all
import Amplify
import Foundation

extension LikedLumeQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case timestamp
    case lumeQLID
    case lume
    case userprofileqlID
    case userprofileql
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let likedLumeQL = LikedLumeQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "LikedLumeQLS"
    
    model.fields(
      .id(),
      .field(likedLumeQL.timestamp, is: .optional, ofType: .int),
      .field(likedLumeQL.lumeQLID, is: .required, ofType: .string),
      .hasOne(likedLumeQL.lume, is: .optional, ofType: LumeQL.self, associatedWith: LumeQL.keys.id, targetName: "lumeQLID"),
      .field(likedLumeQL.userprofileqlID, is: .required, ofType: .string),
      .hasOne(likedLumeQL.userprofileql, is: .optional, ofType: UserProfileQL.self, associatedWith: UserProfileQL.keys.id, targetName: "userprofileqlID")
    )
    }
}