// swiftlint:disable all
import Amplify
import Foundation

extension CosmeticQL {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case productName
    case companyID
    case price
    case amount
    case totTagCount
    case authenticated
    case link
    case tagCnt
    case type
    case zipURL
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let cosmeticQL = CosmeticQL.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "CosmeticQLS"
    model.syncPluralName = "CosmeticQLS"
    
    model.attributes(
      .primaryKey(fields: [cosmeticQL.id])
    )
    
    model.fields(
      .field(cosmeticQL.id, is: .required, ofType: .string),
      .field(cosmeticQL.productName, is: .required, ofType: .string),
      .field(cosmeticQL.companyID, is: .required, ofType: .string),
      .field(cosmeticQL.price, is: .optional, ofType: .string),
      .field(cosmeticQL.amount, is: .optional, ofType: .string),
      .field(cosmeticQL.totTagCount, is: .optional, ofType: .int),
      .field(cosmeticQL.authenticated, is: .required, ofType: .bool),
      .field(cosmeticQL.link, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(cosmeticQL.tagCnt, is: .optional, ofType: .int),
      .field(cosmeticQL.type, is: .optional, ofType: .string),
      .field(cosmeticQL.zipURL, is: .optional, ofType: .string),
      .field(cosmeticQL.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(cosmeticQL.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension CosmeticQL: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}