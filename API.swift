//  This file was automatically generated and should not be edited.

#if canImport(AWSAPIPlugin)
import Foundation

public protocol GraphQLInputValue {
}

public struct GraphQLVariable {
  let name: String
  
  public init(_ name: String) {
    self.name = name
  }
}

extension GraphQLVariable: GraphQLInputValue {
}

extension JSONEncodable {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> Any {
    return jsonValue
  }
}

public typealias GraphQLMap = [String: JSONEncodable?]

extension Dictionary where Key == String, Value == JSONEncodable? {
  public var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    var filtered = Dictionary<String, JSONEncodable>(minimumCapacity: count)
    for (key, value) in self {
      if value != nil {
        filtered[key] = value
      }
    }
    return filtered
  }
}

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: Any {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

public typealias GraphQLID = String

public protocol APISwiftGraphQLOperation: AnyObject {
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension APISwiftGraphQLOperation {
  static var requestString: String {
    return operationString
  }

  static var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: APISwiftGraphQLOperation {}

public protocol GraphQLMutation: APISwiftGraphQLOperation {}

public protocol GraphQLSubscription: APISwiftGraphQLOperation {}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}

public typealias Snapshot = [String: Any?]

public protocol GraphQLSelectionSet: Decodable {
  static var selections: [GraphQLSelection] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
    public init(from decoder: Decoder) throws {
        if let jsonObject = try? APISwiftJSONValue(from: decoder) {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(jsonObject)
            let decodedDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            let optionalDictionary = decodedDictionary.mapValues { $0 as Any? }

            self.init(snapshot: optionalDictionary)
        } else {
            self.init(snapshot: [:])
        }
    }
}

enum APISwiftJSONValue: Codable {
    case array([APISwiftJSONValue])
    case boolean(Bool)
    case number(Double)
    case object([String: APISwiftJSONValue])
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode([String: APISwiftJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([APISwiftJSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .array(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

public protocol GraphQLSelection {
}

public struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
}

public indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object([GraphQLSelection])
  case nonNull(GraphQLOutputType)
  case list(GraphQLOutputType)
  
  var namedType: GraphQLOutputType {
    switch self {
    case .nonNull(let innerType), .list(let innerType):
      return innerType.namedType
    case .scalar, .object:
      return self
    }
  }
}

public struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]
  
  public init(variableName: String, inverted: Bool, selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

public struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]
  
  public init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

public struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type
  
  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

public struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]
  
  public init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}

public typealias JSONObject = [String: Any]

public protocol JSONDecodable {
  init(jsonValue value: Any) throws
}

public protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: Any { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}

extension String: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  public var jsonValue: Any {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  public var jsonValue: Any {
    return self
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  public init(jsonValue value: Any) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public var jsonValue: Any {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  public init(jsonValue value: Any) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension Optional: JSONEncodable {
  public var jsonValue: Any {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as JSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension Dictionary: JSONEncodable {
  public var jsonValue: Any {
    return jsonObject
  }
  
  public var jsonObject: JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as JSONEncodable) = (key, value) {
        jsonObject[key] = value.jsonValue
      } else {
        fatalError("Dictionary is only JSONEncodable if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

extension Array: JSONEncodable {
  public var jsonValue: Any {
    return map() { element -> (Any) in
      if case let element as JSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

extension URL: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  public var jsonValue: Any {
    return self.absoluteString
  }
}

extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

#elseif canImport(AWSAppSync)
import AWSAppSync
#endif

public struct CreateFollowQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, timestamp: Int? = nil, followingId: GraphQLID, followerId: GraphQLID? = nil, status: FollowStatus? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: Int? {
    get {
      return graphQLMap["timestamp"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var followingId: GraphQLID {
    get {
      return graphQLMap["followingID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingID")
    }
  }

  public var followerId: GraphQLID? {
    get {
      return graphQLMap["followerID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerID")
    }
  }

  public var status: FollowStatus? {
    get {
      return graphQLMap["status"] as! FollowStatus?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }
}

public enum FollowStatus: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case pending
  case approved
  case rejected
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PENDING": self = .pending
      case "APPROVED": self = .approved
      case "REJECTED": self = .rejected
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pending: return "PENDING"
      case .approved: return "APPROVED"
      case .rejected: return "REJECTED"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: FollowStatus, rhs: FollowStatus) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending): return true
      case (.approved, .approved): return true
      case (.rejected, .rejected): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelFollowQLConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(timestamp: ModelIntInput? = nil, followingId: ModelIDInput? = nil, followerId: ModelIDInput? = nil, status: ModelFollowStatusInput? = nil, and: [ModelFollowQLConditionInput?]? = nil, or: [ModelFollowQLConditionInput?]? = nil, not: ModelFollowQLConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var followingId: ModelIDInput? {
    get {
      return graphQLMap["followingID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingID")
    }
  }

  public var followerId: ModelIDInput? {
    get {
      return graphQLMap["followerID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerID")
    }
  }

  public var status: ModelFollowStatusInput? {
    get {
      return graphQLMap["status"] as! ModelFollowStatusInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }

  public var and: [ModelFollowQLConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelFollowQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelFollowQLConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelFollowQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelFollowQLConditionInput? {
    get {
      return graphQLMap["not"] as! ModelFollowQLConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct ModelIntInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public enum ModelAttributeTypes: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case binary
  case binarySet
  case bool
  case list
  case map
  case number
  case numberSet
  case string
  case stringSet
  case null
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "binary": self = .binary
      case "binarySet": self = .binarySet
      case "bool": self = .bool
      case "list": self = .list
      case "map": self = .map
      case "number": self = .number
      case "numberSet": self = .numberSet
      case "string": self = .string
      case "stringSet": self = .stringSet
      case "_null": self = .null
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .binary: return "binary"
      case .binarySet: return "binarySet"
      case .bool: return "bool"
      case .list: return "list"
      case .map: return "map"
      case .number: return "number"
      case .numberSet: return "numberSet"
      case .string: return "string"
      case .stringSet: return "stringSet"
      case .null: return "_null"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelAttributeTypes, rhs: ModelAttributeTypes) -> Bool {
    switch (lhs, rhs) {
      case (.binary, .binary): return true
      case (.binarySet, .binarySet): return true
      case (.bool, .bool): return true
      case (.list, .list): return true
      case (.map, .map): return true
      case (.number, .number): return true
      case (.numberSet, .numberSet): return true
      case (.string, .string): return true
      case (.stringSet, .stringSet): return true
      case (.null, .null): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public struct ModelSizeInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }
}

public struct ModelFollowStatusInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(eq: FollowStatus? = nil, ne: FollowStatus? = nil) {
    graphQLMap = ["eq": eq, "ne": ne]
  }

  public var eq: FollowStatus? {
    get {
      return graphQLMap["eq"] as! FollowStatus?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var ne: FollowStatus? {
    get {
      return graphQLMap["ne"] as! FollowStatus?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }
}

public struct ModelStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil, size: ModelSizeInput? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "attributeExists": attributeExists, "attributeType": attributeType, "size": size]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }

  public var size: ModelSizeInput? {
    get {
      return graphQLMap["size"] as! ModelSizeInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

public struct UpdateFollowQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: Int? {
    get {
      return graphQLMap["timestamp"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var followingId: GraphQLID? {
    get {
      return graphQLMap["followingID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingID")
    }
  }

  public var followerId: GraphQLID? {
    get {
      return graphQLMap["followerID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerID")
    }
  }

  public var status: FollowStatus? {
    get {
      return graphQLMap["status"] as! FollowStatus?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }
}

public struct DeleteFollowQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateLikedLumeQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, timestamp: Int? = nil, lumeQlid: GraphQLID, userprofileqlId: GraphQLID) {
    graphQLMap = ["id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: Int? {
    get {
      return graphQLMap["timestamp"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var lumeQlid: GraphQLID {
    get {
      return graphQLMap["lumeQLID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: GraphQLID {
    get {
      return graphQLMap["userprofileqlID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }
}

public struct ModelLikedLumeQLConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(timestamp: ModelIntInput? = nil, lumeQlid: ModelIDInput? = nil, userprofileqlId: ModelIDInput? = nil, and: [ModelLikedLumeQLConditionInput?]? = nil, or: [ModelLikedLumeQLConditionInput?]? = nil, not: ModelLikedLumeQLConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var lumeQlid: ModelIDInput? {
    get {
      return graphQLMap["lumeQLID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: ModelIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var and: [ModelLikedLumeQLConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelLikedLumeQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelLikedLumeQLConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelLikedLumeQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelLikedLumeQLConditionInput? {
    get {
      return graphQLMap["not"] as! ModelLikedLumeQLConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateLikedLumeQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID? = nil, userprofileqlId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: Int? {
    get {
      return graphQLMap["timestamp"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var lumeQlid: GraphQLID? {
    get {
      return graphQLMap["lumeQLID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: GraphQLID? {
    get {
      return graphQLMap["userprofileqlID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }
}

public struct DeleteLikedLumeQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateCommentQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, timestamp: Int, comment: String, lumeQlid: GraphQLID, userprofileqlId: GraphQLID) {
    graphQLMap = ["id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: Int {
    get {
      return graphQLMap["timestamp"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var comment: String {
    get {
      return graphQLMap["comment"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  public var lumeQlid: GraphQLID {
    get {
      return graphQLMap["lumeQLID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: GraphQLID {
    get {
      return graphQLMap["userprofileqlID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }
}

public struct ModelCommentQLConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(timestamp: ModelIntInput? = nil, comment: ModelStringInput? = nil, lumeQlid: ModelIDInput? = nil, userprofileqlId: ModelIDInput? = nil, and: [ModelCommentQLConditionInput?]? = nil, or: [ModelCommentQLConditionInput?]? = nil, not: ModelCommentQLConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var comment: ModelStringInput? {
    get {
      return graphQLMap["comment"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  public var lumeQlid: ModelIDInput? {
    get {
      return graphQLMap["lumeQLID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: ModelIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var and: [ModelCommentQLConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelCommentQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelCommentQLConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelCommentQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelCommentQLConditionInput? {
    get {
      return graphQLMap["not"] as! ModelCommentQLConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateCommentQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, timestamp: Int? = nil, comment: String? = nil, lumeQlid: GraphQLID? = nil, userprofileqlId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: Int? {
    get {
      return graphQLMap["timestamp"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var comment: String? {
    get {
      return graphQLMap["comment"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  public var lumeQlid: GraphQLID? {
    get {
      return graphQLMap["lumeQLID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: GraphQLID? {
    get {
      return graphQLMap["userprofileqlID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }
}

public struct DeleteCommentQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateCosmeticQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil) {
    graphQLMap = ["id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var productName: String {
    get {
      return graphQLMap["productName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "productName")
    }
  }

  public var companyId: String {
    get {
      return graphQLMap["companyID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "companyID")
    }
  }

  public var price: String? {
    get {
      return graphQLMap["price"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var amount: String? {
    get {
      return graphQLMap["amount"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var totTagCount: Int? {
    get {
      return graphQLMap["totTagCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "totTagCount")
    }
  }

  public var authenticated: Bool {
    get {
      return graphQLMap["authenticated"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authenticated")
    }
  }

  public var link: [String?]? {
    get {
      return graphQLMap["link"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var tagCnt: Int? {
    get {
      return graphQLMap["tagCnt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagCnt")
    }
  }

  public var type: String? {
    get {
      return graphQLMap["type"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  public var zipUrl: String? {
    get {
      return graphQLMap["zipURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }
}

public struct ModelCosmeticQLConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(productName: ModelStringInput? = nil, companyId: ModelStringInput? = nil, price: ModelStringInput? = nil, amount: ModelStringInput? = nil, totTagCount: ModelIntInput? = nil, authenticated: ModelBooleanInput? = nil, link: ModelStringInput? = nil, tagCnt: ModelIntInput? = nil, type: ModelStringInput? = nil, zipUrl: ModelStringInput? = nil, and: [ModelCosmeticQLConditionInput?]? = nil, or: [ModelCosmeticQLConditionInput?]? = nil, not: ModelCosmeticQLConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var productName: ModelStringInput? {
    get {
      return graphQLMap["productName"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "productName")
    }
  }

  public var companyId: ModelStringInput? {
    get {
      return graphQLMap["companyID"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "companyID")
    }
  }

  public var price: ModelStringInput? {
    get {
      return graphQLMap["price"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var amount: ModelStringInput? {
    get {
      return graphQLMap["amount"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var totTagCount: ModelIntInput? {
    get {
      return graphQLMap["totTagCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "totTagCount")
    }
  }

  public var authenticated: ModelBooleanInput? {
    get {
      return graphQLMap["authenticated"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authenticated")
    }
  }

  public var link: ModelStringInput? {
    get {
      return graphQLMap["link"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var tagCnt: ModelIntInput? {
    get {
      return graphQLMap["tagCnt"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagCnt")
    }
  }

  public var type: ModelStringInput? {
    get {
      return graphQLMap["type"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  public var zipUrl: ModelStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var and: [ModelCosmeticQLConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelCosmeticQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelCosmeticQLConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelCosmeticQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelCosmeticQLConditionInput? {
    get {
      return graphQLMap["not"] as! ModelCosmeticQLConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct ModelBooleanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct UpdateCosmeticQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, productName: String? = nil, companyId: String? = nil, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool? = nil, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil) {
    graphQLMap = ["id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var productName: String? {
    get {
      return graphQLMap["productName"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "productName")
    }
  }

  public var companyId: String? {
    get {
      return graphQLMap["companyID"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "companyID")
    }
  }

  public var price: String? {
    get {
      return graphQLMap["price"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var amount: String? {
    get {
      return graphQLMap["amount"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var totTagCount: Int? {
    get {
      return graphQLMap["totTagCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "totTagCount")
    }
  }

  public var authenticated: Bool? {
    get {
      return graphQLMap["authenticated"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authenticated")
    }
  }

  public var link: [String?]? {
    get {
      return graphQLMap["link"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var tagCnt: Int? {
    get {
      return graphQLMap["tagCnt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagCnt")
    }
  }

  public var type: String? {
    get {
      return graphQLMap["type"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  public var zipUrl: String? {
    get {
      return graphQLMap["zipURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }
}

public struct DeleteCosmeticQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateLumeQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagCosmeticQLInput?]? = nil, tagMusic: TagTrackQLInput? = nil, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil) {
    graphQLMap = ["id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts, "tagMusic": tagMusic, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var postUrl: [String?]? {
    get {
      return graphQLMap["postURL"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postURL")
    }
  }

  public var timestamp: Int {
    get {
      return graphQLMap["timestamp"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var tagProducts: [TagCosmeticQLInput?]? {
    get {
      return graphQLMap["tagProducts"] as! [TagCosmeticQLInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagProducts")
    }
  }

  public var tagMusic: TagTrackQLInput? {
    get {
      return graphQLMap["tagMusic"] as! TagTrackQLInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagMusic")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var userprofileqlId: GraphQLID {
    get {
      return graphQLMap["userprofileqlID"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var likeCount: Int? {
    get {
      return graphQLMap["likeCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "likeCount")
    }
  }

  public var commentCount: Int? {
    get {
      return graphQLMap["commentCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentCount")
    }
  }

  public var hashTags: [String?]? {
    get {
      return graphQLMap["hashTags"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hashTags")
    }
  }

  public var zipUrl: String? {
    get {
      return graphQLMap["zipURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }
}

public struct TagCosmeticQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
    graphQLMap = ["cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl]
  }

  public var cosmeticId: String {
    get {
      return graphQLMap["cosmeticID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "cosmeticID")
    }
  }

  public var authProduct: Bool {
    get {
      return graphQLMap["authProduct"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authProduct")
    }
  }

  public var recommend: Double? {
    get {
      return graphQLMap["recommend"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "recommend")
    }
  }

  public var effect: Double? {
    get {
      return graphQLMap["effect"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "effect")
    }
  }

  public var fading: Double? {
    get {
      return graphQLMap["fading"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "fading")
    }
  }

  public var feeling: Double? {
    get {
      return graphQLMap["feeling"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "feeling")
    }
  }

  public var attachedUrl: String? {
    get {
      return graphQLMap["attachedURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attachedURL")
    }
  }
}

public struct TagTrackQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(trackId: String, tagMusicRange: [Double]? = nil) {
    graphQLMap = ["trackID": trackId, "tagMusicRange": tagMusicRange]
  }

  public var trackId: String {
    get {
      return graphQLMap["trackID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "trackID")
    }
  }

  public var tagMusicRange: [Double]? {
    get {
      return graphQLMap["tagMusicRange"] as! [Double]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagMusicRange")
    }
  }
}

public struct ModelLumeQLConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(postUrl: ModelStringInput? = nil, timestamp: ModelIntInput? = nil, description: ModelStringInput? = nil, userprofileqlId: ModelIDInput? = nil, likeCount: ModelIntInput? = nil, commentCount: ModelIntInput? = nil, hashTags: ModelStringInput? = nil, zipUrl: ModelStringInput? = nil, and: [ModelLumeQLConditionInput?]? = nil, or: [ModelLumeQLConditionInput?]? = nil, not: ModelLumeQLConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var postUrl: ModelStringInput? {
    get {
      return graphQLMap["postURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postURL")
    }
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var userprofileqlId: ModelIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var likeCount: ModelIntInput? {
    get {
      return graphQLMap["likeCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "likeCount")
    }
  }

  public var commentCount: ModelIntInput? {
    get {
      return graphQLMap["commentCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentCount")
    }
  }

  public var hashTags: ModelStringInput? {
    get {
      return graphQLMap["hashTags"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hashTags")
    }
  }

  public var zipUrl: ModelStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var and: [ModelLumeQLConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelLumeQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelLumeQLConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelLumeQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelLumeQLConditionInput? {
    get {
      return graphQLMap["not"] as! ModelLumeQLConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct UpdateLumeQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int? = nil, tagProducts: [TagCosmeticQLInput?]? = nil, tagMusic: TagTrackQLInput? = nil, description: String? = nil, userprofileqlId: GraphQLID? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil) {
    graphQLMap = ["id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts, "tagMusic": tagMusic, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var postUrl: [String?]? {
    get {
      return graphQLMap["postURL"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postURL")
    }
  }

  public var timestamp: Int? {
    get {
      return graphQLMap["timestamp"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var tagProducts: [TagCosmeticQLInput?]? {
    get {
      return graphQLMap["tagProducts"] as! [TagCosmeticQLInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagProducts")
    }
  }

  public var tagMusic: TagTrackQLInput? {
    get {
      return graphQLMap["tagMusic"] as! TagTrackQLInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagMusic")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var userprofileqlId: GraphQLID? {
    get {
      return graphQLMap["userprofileqlID"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var likeCount: Int? {
    get {
      return graphQLMap["likeCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "likeCount")
    }
  }

  public var commentCount: Int? {
    get {
      return graphQLMap["commentCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentCount")
    }
  }

  public var hashTags: [String?]? {
    get {
      return graphQLMap["hashTags"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hashTags")
    }
  }

  public var zipUrl: String? {
    get {
      return graphQLMap["zipURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }
}

public struct DeleteLumeQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreateUserProfileQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil) {
    graphQLMap = ["id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var followingUsers: [String?]? {
    get {
      return graphQLMap["followingUsers"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingUsers")
    }
  }

  public var followerUsers: [String?]? {
    get {
      return graphQLMap["followerUsers"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerUsers")
    }
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var dob: Int? {
    get {
      return graphQLMap["DOB"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "DOB")
    }
  }

  public var firstName: String {
    get {
      return graphQLMap["firstName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var sensitivity: Double? {
    get {
      return graphQLMap["Sensitivity"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "Sensitivity")
    }
  }

  public var sunBathing: Double? {
    get {
      return graphQLMap["SunBathing"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SunBathing")
    }
  }

  public var skinType: Double? {
    get {
      return graphQLMap["SkinType"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SkinType")
    }
  }

  public var lockState: Bool? {
    get {
      return graphQLMap["lockState"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lockState")
    }
  }

  public var profileImage: String? {
    get {
      return graphQLMap["profileImage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileImage")
    }
  }

  public var backgroundImage: String? {
    get {
      return graphQLMap["backgroundImage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "backgroundImage")
    }
  }

  public var followerCount: Int? {
    get {
      return graphQLMap["followerCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerCount")
    }
  }

  public var followingCount: Int? {
    get {
      return graphQLMap["followingCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingCount")
    }
  }

  public var bio: String? {
    get {
      return graphQLMap["bio"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bio")
    }
  }

  public var zipUrl: String? {
    get {
      return graphQLMap["zipURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var postCount: Int? {
    get {
      return graphQLMap["postCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postCount")
    }
  }
}

public struct ModelUserProfileQLConditionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(followingUsers: ModelStringInput? = nil, followerUsers: ModelStringInput? = nil, username: ModelStringInput? = nil, dob: ModelIntInput? = nil, firstName: ModelStringInput? = nil, sensitivity: ModelFloatInput? = nil, sunBathing: ModelFloatInput? = nil, skinType: ModelFloatInput? = nil, lockState: ModelBooleanInput? = nil, profileImage: ModelStringInput? = nil, backgroundImage: ModelStringInput? = nil, followerCount: ModelIntInput? = nil, followingCount: ModelIntInput? = nil, bio: ModelStringInput? = nil, zipUrl: ModelStringInput? = nil, postCount: ModelIntInput? = nil, and: [ModelUserProfileQLConditionInput?]? = nil, or: [ModelUserProfileQLConditionInput?]? = nil, not: ModelUserProfileQLConditionInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil) {
    graphQLMap = ["followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "and": and, "or": or, "not": not, "createdAt": createdAt, "updatedAt": updatedAt]
  }

  public var followingUsers: ModelStringInput? {
    get {
      return graphQLMap["followingUsers"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingUsers")
    }
  }

  public var followerUsers: ModelStringInput? {
    get {
      return graphQLMap["followerUsers"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerUsers")
    }
  }

  public var username: ModelStringInput? {
    get {
      return graphQLMap["username"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var dob: ModelIntInput? {
    get {
      return graphQLMap["DOB"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "DOB")
    }
  }

  public var firstName: ModelStringInput? {
    get {
      return graphQLMap["firstName"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var sensitivity: ModelFloatInput? {
    get {
      return graphQLMap["Sensitivity"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "Sensitivity")
    }
  }

  public var sunBathing: ModelFloatInput? {
    get {
      return graphQLMap["SunBathing"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SunBathing")
    }
  }

  public var skinType: ModelFloatInput? {
    get {
      return graphQLMap["SkinType"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SkinType")
    }
  }

  public var lockState: ModelBooleanInput? {
    get {
      return graphQLMap["lockState"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lockState")
    }
  }

  public var profileImage: ModelStringInput? {
    get {
      return graphQLMap["profileImage"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileImage")
    }
  }

  public var backgroundImage: ModelStringInput? {
    get {
      return graphQLMap["backgroundImage"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "backgroundImage")
    }
  }

  public var followerCount: ModelIntInput? {
    get {
      return graphQLMap["followerCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerCount")
    }
  }

  public var followingCount: ModelIntInput? {
    get {
      return graphQLMap["followingCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingCount")
    }
  }

  public var bio: ModelStringInput? {
    get {
      return graphQLMap["bio"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bio")
    }
  }

  public var zipUrl: ModelStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var postCount: ModelIntInput? {
    get {
      return graphQLMap["postCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postCount")
    }
  }

  public var and: [ModelUserProfileQLConditionInput?]? {
    get {
      return graphQLMap["and"] as! [ModelUserProfileQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelUserProfileQLConditionInput?]? {
    get {
      return graphQLMap["or"] as! [ModelUserProfileQLConditionInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelUserProfileQLConditionInput? {
    get {
      return graphQLMap["not"] as! ModelUserProfileQLConditionInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }
}

public struct ModelFloatInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, between: [Double?]? = nil, attributeExists: Bool? = nil, attributeType: ModelAttributeTypes? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "attributeExists": attributeExists, "attributeType": attributeType]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var attributeExists: Bool? {
    get {
      return graphQLMap["attributeExists"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeExists")
    }
  }

  public var attributeType: ModelAttributeTypes? {
    get {
      return graphQLMap["attributeType"] as! ModelAttributeTypes?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributeType")
    }
  }
}

public struct UpdateUserProfileQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String? = nil, dob: Int? = nil, firstName: String? = nil, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil) {
    graphQLMap = ["id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var followingUsers: [String?]? {
    get {
      return graphQLMap["followingUsers"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingUsers")
    }
  }

  public var followerUsers: [String?]? {
    get {
      return graphQLMap["followerUsers"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerUsers")
    }
  }

  public var username: String? {
    get {
      return graphQLMap["username"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var dob: Int? {
    get {
      return graphQLMap["DOB"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "DOB")
    }
  }

  public var firstName: String? {
    get {
      return graphQLMap["firstName"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var sensitivity: Double? {
    get {
      return graphQLMap["Sensitivity"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "Sensitivity")
    }
  }

  public var sunBathing: Double? {
    get {
      return graphQLMap["SunBathing"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SunBathing")
    }
  }

  public var skinType: Double? {
    get {
      return graphQLMap["SkinType"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SkinType")
    }
  }

  public var lockState: Bool? {
    get {
      return graphQLMap["lockState"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lockState")
    }
  }

  public var profileImage: String? {
    get {
      return graphQLMap["profileImage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileImage")
    }
  }

  public var backgroundImage: String? {
    get {
      return graphQLMap["backgroundImage"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "backgroundImage")
    }
  }

  public var followerCount: Int? {
    get {
      return graphQLMap["followerCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerCount")
    }
  }

  public var followingCount: Int? {
    get {
      return graphQLMap["followingCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingCount")
    }
  }

  public var bio: String? {
    get {
      return graphQLMap["bio"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bio")
    }
  }

  public var zipUrl: String? {
    get {
      return graphQLMap["zipURL"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var postCount: Int? {
    get {
      return graphQLMap["postCount"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postCount")
    }
  }
}

public struct DeleteUserProfileQLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct ModelFollowQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, timestamp: ModelIntInput? = nil, followingId: ModelIDInput? = nil, followerId: ModelIDInput? = nil, status: ModelFollowStatusInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelFollowQLFilterInput?]? = nil, or: [ModelFollowQLFilterInput?]? = nil, not: ModelFollowQLFilterInput? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var followingId: ModelIDInput? {
    get {
      return graphQLMap["followingID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingID")
    }
  }

  public var followerId: ModelIDInput? {
    get {
      return graphQLMap["followerID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerID")
    }
  }

  public var status: ModelFollowStatusInput? {
    get {
      return graphQLMap["status"] as! ModelFollowStatusInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelFollowQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelFollowQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelFollowQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelFollowQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelFollowQLFilterInput? {
    get {
      return graphQLMap["not"] as! ModelFollowQLFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelLikedLumeQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, timestamp: ModelIntInput? = nil, lumeQlid: ModelIDInput? = nil, userprofileqlId: ModelIDInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelLikedLumeQLFilterInput?]? = nil, or: [ModelLikedLumeQLFilterInput?]? = nil, not: ModelLikedLumeQLFilterInput? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var lumeQlid: ModelIDInput? {
    get {
      return graphQLMap["lumeQLID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: ModelIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelLikedLumeQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelLikedLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelLikedLumeQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelLikedLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelLikedLumeQLFilterInput? {
    get {
      return graphQLMap["not"] as! ModelLikedLumeQLFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelCommentQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, timestamp: ModelIntInput? = nil, comment: ModelStringInput? = nil, lumeQlid: ModelIDInput? = nil, userprofileqlId: ModelIDInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelCommentQLFilterInput?]? = nil, or: [ModelCommentQLFilterInput?]? = nil, not: ModelCommentQLFilterInput? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var comment: ModelStringInput? {
    get {
      return graphQLMap["comment"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  public var lumeQlid: ModelIDInput? {
    get {
      return graphQLMap["lumeQLID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: ModelIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelCommentQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelCommentQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelCommentQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelCommentQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelCommentQLFilterInput? {
    get {
      return graphQLMap["not"] as! ModelCommentQLFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelCosmeticQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, productName: ModelStringInput? = nil, companyId: ModelStringInput? = nil, price: ModelStringInput? = nil, amount: ModelStringInput? = nil, totTagCount: ModelIntInput? = nil, authenticated: ModelBooleanInput? = nil, link: ModelStringInput? = nil, tagCnt: ModelIntInput? = nil, type: ModelStringInput? = nil, zipUrl: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelCosmeticQLFilterInput?]? = nil, or: [ModelCosmeticQLFilterInput?]? = nil, not: ModelCosmeticQLFilterInput? = nil) {
    graphQLMap = ["id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var productName: ModelStringInput? {
    get {
      return graphQLMap["productName"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "productName")
    }
  }

  public var companyId: ModelStringInput? {
    get {
      return graphQLMap["companyID"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "companyID")
    }
  }

  public var price: ModelStringInput? {
    get {
      return graphQLMap["price"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var amount: ModelStringInput? {
    get {
      return graphQLMap["amount"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var totTagCount: ModelIntInput? {
    get {
      return graphQLMap["totTagCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "totTagCount")
    }
  }

  public var authenticated: ModelBooleanInput? {
    get {
      return graphQLMap["authenticated"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authenticated")
    }
  }

  public var link: ModelStringInput? {
    get {
      return graphQLMap["link"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var tagCnt: ModelIntInput? {
    get {
      return graphQLMap["tagCnt"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagCnt")
    }
  }

  public var type: ModelStringInput? {
    get {
      return graphQLMap["type"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  public var zipUrl: ModelStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelCosmeticQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelCosmeticQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelCosmeticQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelCosmeticQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelCosmeticQLFilterInput? {
    get {
      return graphQLMap["not"] as! ModelCosmeticQLFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelLumeQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, postUrl: ModelStringInput? = nil, timestamp: ModelIntInput? = nil, description: ModelStringInput? = nil, userprofileqlId: ModelIDInput? = nil, likeCount: ModelIntInput? = nil, commentCount: ModelIntInput? = nil, hashTags: ModelStringInput? = nil, zipUrl: ModelStringInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelLumeQLFilterInput?]? = nil, or: [ModelLumeQLFilterInput?]? = nil, not: ModelLumeQLFilterInput? = nil) {
    graphQLMap = ["id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var postUrl: ModelStringInput? {
    get {
      return graphQLMap["postURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postURL")
    }
  }

  public var timestamp: ModelIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var description: ModelStringInput? {
    get {
      return graphQLMap["description"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var userprofileqlId: ModelIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var likeCount: ModelIntInput? {
    get {
      return graphQLMap["likeCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "likeCount")
    }
  }

  public var commentCount: ModelIntInput? {
    get {
      return graphQLMap["commentCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentCount")
    }
  }

  public var hashTags: ModelStringInput? {
    get {
      return graphQLMap["hashTags"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hashTags")
    }
  }

  public var zipUrl: ModelStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelLumeQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelLumeQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelLumeQLFilterInput? {
    get {
      return graphQLMap["not"] as! ModelLumeQLFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelUserProfileQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDInput? = nil, followingUsers: ModelStringInput? = nil, followerUsers: ModelStringInput? = nil, username: ModelStringInput? = nil, dob: ModelIntInput? = nil, firstName: ModelStringInput? = nil, sensitivity: ModelFloatInput? = nil, sunBathing: ModelFloatInput? = nil, skinType: ModelFloatInput? = nil, lockState: ModelBooleanInput? = nil, profileImage: ModelStringInput? = nil, backgroundImage: ModelStringInput? = nil, followerCount: ModelIntInput? = nil, followingCount: ModelIntInput? = nil, bio: ModelStringInput? = nil, zipUrl: ModelStringInput? = nil, postCount: ModelIntInput? = nil, createdAt: ModelStringInput? = nil, updatedAt: ModelStringInput? = nil, and: [ModelUserProfileQLFilterInput?]? = nil, or: [ModelUserProfileQLFilterInput?]? = nil, not: ModelUserProfileQLFilterInput? = nil) {
    graphQLMap = ["id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDInput? {
    get {
      return graphQLMap["id"] as! ModelIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var followingUsers: ModelStringInput? {
    get {
      return graphQLMap["followingUsers"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingUsers")
    }
  }

  public var followerUsers: ModelStringInput? {
    get {
      return graphQLMap["followerUsers"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerUsers")
    }
  }

  public var username: ModelStringInput? {
    get {
      return graphQLMap["username"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var dob: ModelIntInput? {
    get {
      return graphQLMap["DOB"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "DOB")
    }
  }

  public var firstName: ModelStringInput? {
    get {
      return graphQLMap["firstName"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var sensitivity: ModelFloatInput? {
    get {
      return graphQLMap["Sensitivity"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "Sensitivity")
    }
  }

  public var sunBathing: ModelFloatInput? {
    get {
      return graphQLMap["SunBathing"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SunBathing")
    }
  }

  public var skinType: ModelFloatInput? {
    get {
      return graphQLMap["SkinType"] as! ModelFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SkinType")
    }
  }

  public var lockState: ModelBooleanInput? {
    get {
      return graphQLMap["lockState"] as! ModelBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lockState")
    }
  }

  public var profileImage: ModelStringInput? {
    get {
      return graphQLMap["profileImage"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileImage")
    }
  }

  public var backgroundImage: ModelStringInput? {
    get {
      return graphQLMap["backgroundImage"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "backgroundImage")
    }
  }

  public var followerCount: ModelIntInput? {
    get {
      return graphQLMap["followerCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerCount")
    }
  }

  public var followingCount: ModelIntInput? {
    get {
      return graphQLMap["followingCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingCount")
    }
  }

  public var bio: ModelStringInput? {
    get {
      return graphQLMap["bio"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bio")
    }
  }

  public var zipUrl: ModelStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var postCount: ModelIntInput? {
    get {
      return graphQLMap["postCount"] as! ModelIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postCount")
    }
  }

  public var createdAt: ModelStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelUserProfileQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelUserProfileQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelUserProfileQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelUserProfileQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelUserProfileQLFilterInput? {
    get {
      return graphQLMap["not"] as! ModelUserProfileQLFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public enum ModelSortDirection: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case asc
  case desc
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ASC": self = .asc
      case "DESC": self = .desc
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .asc: return "ASC"
      case .desc: return "DESC"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ModelSortDirection, rhs: ModelSortDirection) -> Bool {
    switch (lhs, rhs) {
      case (.asc, .asc): return true
      case (.desc, .desc): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ModelSubscriptionFollowQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, timestamp: ModelSubscriptionIntInput? = nil, followingId: ModelSubscriptionIDInput? = nil, followerId: ModelSubscriptionIDInput? = nil, status: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionFollowQLFilterInput?]? = nil, or: [ModelSubscriptionFollowQLFilterInput?]? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var followingId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["followingID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingID")
    }
  }

  public var followerId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["followerID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerID")
    }
  }

  public var status: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["status"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionFollowQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionFollowQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionFollowQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionFollowQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public struct ModelSubscriptionIDInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil, `in`: [GraphQLID?]? = nil, notIn: [GraphQLID?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [GraphQLID?]? {
    get {
      return graphQLMap["in"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [GraphQLID?]? {
    get {
      return graphQLMap["notIn"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionIntInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Int? = nil, eq: Int? = nil, le: Int? = nil, lt: Int? = nil, ge: Int? = nil, gt: Int? = nil, between: [Int?]? = nil, `in`: [Int?]? = nil, notIn: [Int?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "in": `in`, "notIn": notIn]
  }

  public var ne: Int? {
    get {
      return graphQLMap["ne"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Int? {
    get {
      return graphQLMap["eq"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Int? {
    get {
      return graphQLMap["le"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Int? {
    get {
      return graphQLMap["lt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Int? {
    get {
      return graphQLMap["ge"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Int? {
    get {
      return graphQLMap["gt"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Int?]? {
    get {
      return graphQLMap["between"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var `in`: [Int?]? {
    get {
      return graphQLMap["in"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [Int?]? {
    get {
      return graphQLMap["notIn"] as! [Int?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionStringInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil, `in`: [String?]? = nil, notIn: [String?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith, "in": `in`, "notIn": notIn]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }

  public var `in`: [String?]? {
    get {
      return graphQLMap["in"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [String?]? {
    get {
      return graphQLMap["notIn"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public struct ModelSubscriptionLikedLumeQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, timestamp: ModelSubscriptionIntInput? = nil, lumeQlid: ModelSubscriptionIDInput? = nil, userprofileqlId: ModelSubscriptionIDInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionLikedLumeQLFilterInput?]? = nil, or: [ModelSubscriptionLikedLumeQLFilterInput?]? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var lumeQlid: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["lumeQLID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionLikedLumeQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionLikedLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionLikedLumeQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionLikedLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public struct ModelSubscriptionCommentQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, timestamp: ModelSubscriptionIntInput? = nil, comment: ModelSubscriptionStringInput? = nil, lumeQlid: ModelSubscriptionIDInput? = nil, userprofileqlId: ModelSubscriptionIDInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionCommentQLFilterInput?]? = nil, or: [ModelSubscriptionCommentQLFilterInput?]? = nil) {
    graphQLMap = ["id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var timestamp: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var comment: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["comment"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  public var lumeQlid: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["lumeQLID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lumeQLID")
    }
  }

  public var userprofileqlId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionCommentQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionCommentQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionCommentQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionCommentQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public struct ModelSubscriptionCosmeticQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, productName: ModelSubscriptionStringInput? = nil, companyId: ModelSubscriptionStringInput? = nil, price: ModelSubscriptionStringInput? = nil, amount: ModelSubscriptionStringInput? = nil, totTagCount: ModelSubscriptionIntInput? = nil, authenticated: ModelSubscriptionBooleanInput? = nil, link: ModelSubscriptionStringInput? = nil, tagCnt: ModelSubscriptionIntInput? = nil, type: ModelSubscriptionStringInput? = nil, zipUrl: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionCosmeticQLFilterInput?]? = nil, or: [ModelSubscriptionCosmeticQLFilterInput?]? = nil) {
    graphQLMap = ["id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var productName: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["productName"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "productName")
    }
  }

  public var companyId: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["companyID"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "companyID")
    }
  }

  public var price: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["price"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "price")
    }
  }

  public var amount: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["amount"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var totTagCount: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["totTagCount"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "totTagCount")
    }
  }

  public var authenticated: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["authenticated"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authenticated")
    }
  }

  public var link: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["link"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "link")
    }
  }

  public var tagCnt: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["tagCnt"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagCnt")
    }
  }

  public var type: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["type"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  public var zipUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionCosmeticQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionCosmeticQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionCosmeticQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionCosmeticQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public struct ModelSubscriptionBooleanInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Bool? = nil, eq: Bool? = nil) {
    graphQLMap = ["ne": ne, "eq": eq]
  }

  public var ne: Bool? {
    get {
      return graphQLMap["ne"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Bool? {
    get {
      return graphQLMap["eq"] as! Bool?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }
}

public struct ModelSubscriptionLumeQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, postUrl: ModelSubscriptionStringInput? = nil, timestamp: ModelSubscriptionIntInput? = nil, description: ModelSubscriptionStringInput? = nil, userprofileqlId: ModelSubscriptionIDInput? = nil, likeCount: ModelSubscriptionIntInput? = nil, commentCount: ModelSubscriptionIntInput? = nil, hashTags: ModelSubscriptionStringInput? = nil, zipUrl: ModelSubscriptionStringInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionLumeQLFilterInput?]? = nil, or: [ModelSubscriptionLumeQLFilterInput?]? = nil) {
    graphQLMap = ["id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var postUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["postURL"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postURL")
    }
  }

  public var timestamp: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["timestamp"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var description: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["description"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var userprofileqlId: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["userprofileqlID"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userprofileqlID")
    }
  }

  public var likeCount: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["likeCount"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "likeCount")
    }
  }

  public var commentCount: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["commentCount"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentCount")
    }
  }

  public var hashTags: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["hashTags"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "hashTags")
    }
  }

  public var zipUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionLumeQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionLumeQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionLumeQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public struct ModelSubscriptionUserProfileQLFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelSubscriptionIDInput? = nil, followingUsers: ModelSubscriptionStringInput? = nil, followerUsers: ModelSubscriptionStringInput? = nil, username: ModelSubscriptionStringInput? = nil, dob: ModelSubscriptionIntInput? = nil, firstName: ModelSubscriptionStringInput? = nil, sensitivity: ModelSubscriptionFloatInput? = nil, sunBathing: ModelSubscriptionFloatInput? = nil, skinType: ModelSubscriptionFloatInput? = nil, lockState: ModelSubscriptionBooleanInput? = nil, profileImage: ModelSubscriptionStringInput? = nil, backgroundImage: ModelSubscriptionStringInput? = nil, followerCount: ModelSubscriptionIntInput? = nil, followingCount: ModelSubscriptionIntInput? = nil, bio: ModelSubscriptionStringInput? = nil, zipUrl: ModelSubscriptionStringInput? = nil, postCount: ModelSubscriptionIntInput? = nil, createdAt: ModelSubscriptionStringInput? = nil, updatedAt: ModelSubscriptionStringInput? = nil, and: [ModelSubscriptionUserProfileQLFilterInput?]? = nil, or: [ModelSubscriptionUserProfileQLFilterInput?]? = nil) {
    graphQLMap = ["id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt, "and": and, "or": or]
  }

  public var id: ModelSubscriptionIDInput? {
    get {
      return graphQLMap["id"] as! ModelSubscriptionIDInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var followingUsers: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["followingUsers"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingUsers")
    }
  }

  public var followerUsers: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["followerUsers"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerUsers")
    }
  }

  public var username: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["username"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var dob: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["DOB"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "DOB")
    }
  }

  public var firstName: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["firstName"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var sensitivity: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["Sensitivity"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "Sensitivity")
    }
  }

  public var sunBathing: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["SunBathing"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SunBathing")
    }
  }

  public var skinType: ModelSubscriptionFloatInput? {
    get {
      return graphQLMap["SkinType"] as! ModelSubscriptionFloatInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "SkinType")
    }
  }

  public var lockState: ModelSubscriptionBooleanInput? {
    get {
      return graphQLMap["lockState"] as! ModelSubscriptionBooleanInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lockState")
    }
  }

  public var profileImage: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["profileImage"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileImage")
    }
  }

  public var backgroundImage: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["backgroundImage"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "backgroundImage")
    }
  }

  public var followerCount: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["followerCount"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followerCount")
    }
  }

  public var followingCount: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["followingCount"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "followingCount")
    }
  }

  public var bio: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["bio"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bio")
    }
  }

  public var zipUrl: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["zipURL"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "zipURL")
    }
  }

  public var postCount: ModelSubscriptionIntInput? {
    get {
      return graphQLMap["postCount"] as! ModelSubscriptionIntInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postCount")
    }
  }

  public var createdAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["createdAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  public var updatedAt: ModelSubscriptionStringInput? {
    get {
      return graphQLMap["updatedAt"] as! ModelSubscriptionStringInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedAt")
    }
  }

  public var and: [ModelSubscriptionUserProfileQLFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelSubscriptionUserProfileQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelSubscriptionUserProfileQLFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelSubscriptionUserProfileQLFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }
}

public struct ModelSubscriptionFloatInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: Double? = nil, eq: Double? = nil, le: Double? = nil, lt: Double? = nil, ge: Double? = nil, gt: Double? = nil, between: [Double?]? = nil, `in`: [Double?]? = nil, notIn: [Double?]? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "between": between, "in": `in`, "notIn": notIn]
  }

  public var ne: Double? {
    get {
      return graphQLMap["ne"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: Double? {
    get {
      return graphQLMap["eq"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: Double? {
    get {
      return graphQLMap["le"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: Double? {
    get {
      return graphQLMap["lt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: Double? {
    get {
      return graphQLMap["ge"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: Double? {
    get {
      return graphQLMap["gt"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var between: [Double?]? {
    get {
      return graphQLMap["between"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var `in`: [Double?]? {
    get {
      return graphQLMap["in"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "in")
    }
  }

  public var notIn: [Double?]? {
    get {
      return graphQLMap["notIn"] as! [Double?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notIn")
    }
  }
}

public final class CreateFollowQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateFollowQL($input: CreateFollowQLInput!, $condition: ModelFollowQLConditionInput) {\n  createFollowQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateFollowQLInput
  public var condition: ModelFollowQLConditionInput?

  public init(input: CreateFollowQLInput, condition: ModelFollowQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createFollowQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createFollowQl: CreateFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createFollowQL": createFollowQl.flatMap { $0.snapshot }])
    }

    public var createFollowQl: CreateFollowQl? {
      get {
        return (snapshot["createFollowQL"] as? Snapshot).flatMap { CreateFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createFollowQL")
      }
    }

    public struct CreateFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class UpdateFollowQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateFollowQL($input: UpdateFollowQLInput!, $condition: ModelFollowQLConditionInput) {\n  updateFollowQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateFollowQLInput
  public var condition: ModelFollowQLConditionInput?

  public init(input: UpdateFollowQLInput, condition: ModelFollowQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateFollowQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateFollowQl: UpdateFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateFollowQL": updateFollowQl.flatMap { $0.snapshot }])
    }

    public var updateFollowQl: UpdateFollowQl? {
      get {
        return (snapshot["updateFollowQL"] as? Snapshot).flatMap { UpdateFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateFollowQL")
      }
    }

    public struct UpdateFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class DeleteFollowQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteFollowQL($input: DeleteFollowQLInput!, $condition: ModelFollowQLConditionInput) {\n  deleteFollowQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteFollowQLInput
  public var condition: ModelFollowQLConditionInput?

  public init(input: DeleteFollowQLInput, condition: ModelFollowQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteFollowQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteFollowQl: DeleteFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteFollowQL": deleteFollowQl.flatMap { $0.snapshot }])
    }

    public var deleteFollowQl: DeleteFollowQl? {
      get {
        return (snapshot["deleteFollowQL"] as? Snapshot).flatMap { DeleteFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteFollowQL")
      }
    }

    public struct DeleteFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class CreateLikedLumeQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateLikedLumeQL($input: CreateLikedLumeQLInput!, $condition: ModelLikedLumeQLConditionInput) {\n  createLikedLumeQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateLikedLumeQLInput
  public var condition: ModelLikedLumeQLConditionInput?

  public init(input: CreateLikedLumeQLInput, condition: ModelLikedLumeQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createLikedLumeQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createLikedLumeQl: CreateLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createLikedLumeQL": createLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var createLikedLumeQl: CreateLikedLumeQl? {
      get {
        return (snapshot["createLikedLumeQL"] as? Snapshot).flatMap { CreateLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createLikedLumeQL")
      }
    }

    public struct CreateLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class UpdateLikedLumeQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateLikedLumeQL($input: UpdateLikedLumeQLInput!, $condition: ModelLikedLumeQLConditionInput) {\n  updateLikedLumeQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateLikedLumeQLInput
  public var condition: ModelLikedLumeQLConditionInput?

  public init(input: UpdateLikedLumeQLInput, condition: ModelLikedLumeQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateLikedLumeQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateLikedLumeQl: UpdateLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateLikedLumeQL": updateLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var updateLikedLumeQl: UpdateLikedLumeQl? {
      get {
        return (snapshot["updateLikedLumeQL"] as? Snapshot).flatMap { UpdateLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateLikedLumeQL")
      }
    }

    public struct UpdateLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class DeleteLikedLumeQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteLikedLumeQL($input: DeleteLikedLumeQLInput!, $condition: ModelLikedLumeQLConditionInput) {\n  deleteLikedLumeQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteLikedLumeQLInput
  public var condition: ModelLikedLumeQLConditionInput?

  public init(input: DeleteLikedLumeQLInput, condition: ModelLikedLumeQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteLikedLumeQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteLikedLumeQl: DeleteLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteLikedLumeQL": deleteLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var deleteLikedLumeQl: DeleteLikedLumeQl? {
      get {
        return (snapshot["deleteLikedLumeQL"] as? Snapshot).flatMap { DeleteLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteLikedLumeQL")
      }
    }

    public struct DeleteLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class CreateCommentQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateCommentQL($input: CreateCommentQLInput!, $condition: ModelCommentQLConditionInput) {\n  createCommentQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateCommentQLInput
  public var condition: ModelCommentQLConditionInput?

  public init(input: CreateCommentQLInput, condition: ModelCommentQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createCommentQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createCommentQl: CreateCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createCommentQL": createCommentQl.flatMap { $0.snapshot }])
    }

    public var createCommentQl: CreateCommentQl? {
      get {
        return (snapshot["createCommentQL"] as? Snapshot).flatMap { CreateCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createCommentQL")
      }
    }

    public struct CreateCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class UpdateCommentQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateCommentQL($input: UpdateCommentQLInput!, $condition: ModelCommentQLConditionInput) {\n  updateCommentQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateCommentQLInput
  public var condition: ModelCommentQLConditionInput?

  public init(input: UpdateCommentQLInput, condition: ModelCommentQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateCommentQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateCommentQl: UpdateCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateCommentQL": updateCommentQl.flatMap { $0.snapshot }])
    }

    public var updateCommentQl: UpdateCommentQl? {
      get {
        return (snapshot["updateCommentQL"] as? Snapshot).flatMap { UpdateCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateCommentQL")
      }
    }

    public struct UpdateCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class DeleteCommentQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteCommentQL($input: DeleteCommentQLInput!, $condition: ModelCommentQLConditionInput) {\n  deleteCommentQL(input: $input, condition: $condition) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteCommentQLInput
  public var condition: ModelCommentQLConditionInput?

  public init(input: DeleteCommentQLInput, condition: ModelCommentQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteCommentQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteCommentQl: DeleteCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteCommentQL": deleteCommentQl.flatMap { $0.snapshot }])
    }

    public var deleteCommentQl: DeleteCommentQl? {
      get {
        return (snapshot["deleteCommentQL"] as? Snapshot).flatMap { DeleteCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteCommentQL")
      }
    }

    public struct DeleteCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class CreateCosmeticQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateCosmeticQL($input: CreateCosmeticQLInput!, $condition: ModelCosmeticQLConditionInput) {\n  createCosmeticQL(input: $input, condition: $condition) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateCosmeticQLInput
  public var condition: ModelCosmeticQLConditionInput?

  public init(input: CreateCosmeticQLInput, condition: ModelCosmeticQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createCosmeticQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createCosmeticQl: CreateCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createCosmeticQL": createCosmeticQl.flatMap { $0.snapshot }])
    }

    public var createCosmeticQl: CreateCosmeticQl? {
      get {
        return (snapshot["createCosmeticQL"] as? Snapshot).flatMap { CreateCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createCosmeticQL")
      }
    }

    public struct CreateCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class UpdateCosmeticQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateCosmeticQL($input: UpdateCosmeticQLInput!, $condition: ModelCosmeticQLConditionInput) {\n  updateCosmeticQL(input: $input, condition: $condition) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateCosmeticQLInput
  public var condition: ModelCosmeticQLConditionInput?

  public init(input: UpdateCosmeticQLInput, condition: ModelCosmeticQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateCosmeticQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateCosmeticQl: UpdateCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateCosmeticQL": updateCosmeticQl.flatMap { $0.snapshot }])
    }

    public var updateCosmeticQl: UpdateCosmeticQl? {
      get {
        return (snapshot["updateCosmeticQL"] as? Snapshot).flatMap { UpdateCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateCosmeticQL")
      }
    }

    public struct UpdateCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class DeleteCosmeticQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteCosmeticQL($input: DeleteCosmeticQLInput!, $condition: ModelCosmeticQLConditionInput) {\n  deleteCosmeticQL(input: $input, condition: $condition) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteCosmeticQLInput
  public var condition: ModelCosmeticQLConditionInput?

  public init(input: DeleteCosmeticQLInput, condition: ModelCosmeticQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteCosmeticQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteCosmeticQl: DeleteCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteCosmeticQL": deleteCosmeticQl.flatMap { $0.snapshot }])
    }

    public var deleteCosmeticQl: DeleteCosmeticQl? {
      get {
        return (snapshot["deleteCosmeticQL"] as? Snapshot).flatMap { DeleteCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteCosmeticQL")
      }
    }

    public struct DeleteCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class CreateLumeQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateLumeQL($input: CreateLumeQLInput!, $condition: ModelLumeQLConditionInput) {\n  createLumeQL(input: $input, condition: $condition) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateLumeQLInput
  public var condition: ModelLumeQLConditionInput?

  public init(input: CreateLumeQLInput, condition: ModelLumeQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createLumeQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createLumeQl: CreateLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createLumeQL": createLumeQl.flatMap { $0.snapshot }])
    }

    public var createLumeQl: CreateLumeQl? {
      get {
        return (snapshot["createLumeQL"] as? Snapshot).flatMap { CreateLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createLumeQL")
      }
    }

    public struct CreateLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class UpdateLumeQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateLumeQL($input: UpdateLumeQLInput!, $condition: ModelLumeQLConditionInput) {\n  updateLumeQL(input: $input, condition: $condition) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateLumeQLInput
  public var condition: ModelLumeQLConditionInput?

  public init(input: UpdateLumeQLInput, condition: ModelLumeQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateLumeQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateLumeQl: UpdateLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateLumeQL": updateLumeQl.flatMap { $0.snapshot }])
    }

    public var updateLumeQl: UpdateLumeQl? {
      get {
        return (snapshot["updateLumeQL"] as? Snapshot).flatMap { UpdateLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateLumeQL")
      }
    }

    public struct UpdateLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class DeleteLumeQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteLumeQL($input: DeleteLumeQLInput!, $condition: ModelLumeQLConditionInput) {\n  deleteLumeQL(input: $input, condition: $condition) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteLumeQLInput
  public var condition: ModelLumeQLConditionInput?

  public init(input: DeleteLumeQLInput, condition: ModelLumeQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteLumeQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteLumeQl: DeleteLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteLumeQL": deleteLumeQl.flatMap { $0.snapshot }])
    }

    public var deleteLumeQl: DeleteLumeQl? {
      get {
        return (snapshot["deleteLumeQL"] as? Snapshot).flatMap { DeleteLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteLumeQL")
      }
    }

    public struct DeleteLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class CreateUserProfileQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateUserProfileQL($input: CreateUserProfileQLInput!, $condition: ModelUserProfileQLConditionInput) {\n  createUserProfileQL(input: $input, condition: $condition) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var input: CreateUserProfileQLInput
  public var condition: ModelUserProfileQLConditionInput?

  public init(input: CreateUserProfileQLInput, condition: ModelUserProfileQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createUserProfileQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(CreateUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createUserProfileQl: CreateUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createUserProfileQL": createUserProfileQl.flatMap { $0.snapshot }])
    }

    public var createUserProfileQl: CreateUserProfileQl? {
      get {
        return (snapshot["createUserProfileQL"] as? Snapshot).flatMap { CreateUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createUserProfileQL")
      }
    }

    public struct CreateUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class UpdateUserProfileQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateUserProfileQL($input: UpdateUserProfileQLInput!, $condition: ModelUserProfileQLConditionInput) {\n  updateUserProfileQL(input: $input, condition: $condition) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var input: UpdateUserProfileQLInput
  public var condition: ModelUserProfileQLConditionInput?

  public init(input: UpdateUserProfileQLInput, condition: ModelUserProfileQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateUserProfileQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(UpdateUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateUserProfileQl: UpdateUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateUserProfileQL": updateUserProfileQl.flatMap { $0.snapshot }])
    }

    public var updateUserProfileQl: UpdateUserProfileQl? {
      get {
        return (snapshot["updateUserProfileQL"] as? Snapshot).flatMap { UpdateUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateUserProfileQL")
      }
    }

    public struct UpdateUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class DeleteUserProfileQlMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteUserProfileQL($input: DeleteUserProfileQLInput!, $condition: ModelUserProfileQLConditionInput) {\n  deleteUserProfileQL(input: $input, condition: $condition) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var input: DeleteUserProfileQLInput
  public var condition: ModelUserProfileQLConditionInput?

  public init(input: DeleteUserProfileQLInput, condition: ModelUserProfileQLConditionInput? = nil) {
    self.input = input
    self.condition = condition
  }

  public var variables: GraphQLMap? {
    return ["input": input, "condition": condition]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteUserProfileQL", arguments: ["input": GraphQLVariable("input"), "condition": GraphQLVariable("condition")], type: .object(DeleteUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteUserProfileQl: DeleteUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteUserProfileQL": deleteUserProfileQl.flatMap { $0.snapshot }])
    }

    public var deleteUserProfileQl: DeleteUserProfileQl? {
      get {
        return (snapshot["deleteUserProfileQL"] as? Snapshot).flatMap { DeleteUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteUserProfileQL")
      }
    }

    public struct DeleteUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class GetFollowQlQuery: GraphQLQuery {
  public static let operationString =
    "query GetFollowQL($id: ID!) {\n  getFollowQL(id: $id) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getFollowQL", arguments: ["id": GraphQLVariable("id")], type: .object(GetFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getFollowQl: GetFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "getFollowQL": getFollowQl.flatMap { $0.snapshot }])
    }

    public var getFollowQl: GetFollowQl? {
      get {
        return (snapshot["getFollowQL"] as? Snapshot).flatMap { GetFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getFollowQL")
      }
    }

    public struct GetFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class ListFollowQlsQuery: GraphQLQuery {
  public static let operationString =
    "query ListFollowQLS($filter: ModelFollowQLFilterInput, $limit: Int, $nextToken: String) {\n  listFollowQLS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      timestamp\n      followingID\n      followerID\n      status\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelFollowQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelFollowQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listFollowQLS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listFollowQls: ListFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "listFollowQLS": listFollowQls.flatMap { $0.snapshot }])
    }

    public var listFollowQls: ListFollowQl? {
      get {
        return (snapshot["listFollowQLS"] as? Snapshot).flatMap { ListFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listFollowQLS")
      }
    }

    public struct ListFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelFollowQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelFollowQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["FollowQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("timestamp", type: .scalar(Int.self)),
          GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followerID", type: .scalar(GraphQLID.self)),
          GraphQLField("status", type: .scalar(FollowStatus.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var timestamp: Int? {
          get {
            return snapshot["timestamp"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var followingId: GraphQLID {
          get {
            return snapshot["followingID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingID")
          }
        }

        public var followerId: GraphQLID? {
          get {
            return snapshot["followerID"] as? GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerID")
          }
        }

        public var status: FollowStatus? {
          get {
            return snapshot["status"] as? FollowStatus
          }
          set {
            snapshot.updateValue(newValue, forKey: "status")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetLikedLumeQlQuery: GraphQLQuery {
  public static let operationString =
    "query GetLikedLumeQL($id: ID!) {\n  getLikedLumeQL(id: $id) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getLikedLumeQL", arguments: ["id": GraphQLVariable("id")], type: .object(GetLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getLikedLumeQl: GetLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "getLikedLumeQL": getLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var getLikedLumeQl: GetLikedLumeQl? {
      get {
        return (snapshot["getLikedLumeQL"] as? Snapshot).flatMap { GetLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getLikedLumeQL")
      }
    }

    public struct GetLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class ListLikedLumeQlsQuery: GraphQLQuery {
  public static let operationString =
    "query ListLikedLumeQLS($filter: ModelLikedLumeQLFilterInput, $limit: Int, $nextToken: String) {\n  listLikedLumeQLS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      timestamp\n      lumeQLID\n      userprofileqlID\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelLikedLumeQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelLikedLumeQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listLikedLumeQLS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listLikedLumeQls: ListLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "listLikedLumeQLS": listLikedLumeQls.flatMap { $0.snapshot }])
    }

    public var listLikedLumeQls: ListLikedLumeQl? {
      get {
        return (snapshot["listLikedLumeQLS"] as? Snapshot).flatMap { ListLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listLikedLumeQLS")
      }
    }

    public struct ListLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelLikedLumeQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["LikedLumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("timestamp", type: .scalar(Int.self)),
          GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var timestamp: Int? {
          get {
            return snapshot["timestamp"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var lumeQlid: GraphQLID {
          get {
            return snapshot["lumeQLID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "lumeQLID")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetCommentQlQuery: GraphQLQuery {
  public static let operationString =
    "query GetCommentQL($id: ID!) {\n  getCommentQL(id: $id) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getCommentQL", arguments: ["id": GraphQLVariable("id")], type: .object(GetCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getCommentQl: GetCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "getCommentQL": getCommentQl.flatMap { $0.snapshot }])
    }

    public var getCommentQl: GetCommentQl? {
      get {
        return (snapshot["getCommentQL"] as? Snapshot).flatMap { GetCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getCommentQL")
      }
    }

    public struct GetCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class ListCommentQlsQuery: GraphQLQuery {
  public static let operationString =
    "query ListCommentQLS($filter: ModelCommentQLFilterInput, $limit: Int, $nextToken: String) {\n  listCommentQLS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      timestamp\n      comment\n      lumeQLID\n      userprofileqlID\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelCommentQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelCommentQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listCommentQLS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listCommentQls: ListCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "listCommentQLS": listCommentQls.flatMap { $0.snapshot }])
    }

    public var listCommentQls: ListCommentQl? {
      get {
        return (snapshot["listCommentQLS"] as? Snapshot).flatMap { ListCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listCommentQLS")
      }
    }

    public struct ListCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelCommentQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelCommentQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["CommentQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("comment", type: .nonNull(.scalar(String.self))),
          GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var comment: String {
          get {
            return snapshot["comment"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "comment")
          }
        }

        public var lumeQlid: GraphQLID {
          get {
            return snapshot["lumeQLID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "lumeQLID")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetCosmeticQlQuery: GraphQLQuery {
  public static let operationString =
    "query GetCosmeticQL($id: ID!) {\n  getCosmeticQL(id: $id) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getCosmeticQL", arguments: ["id": GraphQLVariable("id")], type: .object(GetCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getCosmeticQl: GetCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "getCosmeticQL": getCosmeticQl.flatMap { $0.snapshot }])
    }

    public var getCosmeticQl: GetCosmeticQl? {
      get {
        return (snapshot["getCosmeticQL"] as? Snapshot).flatMap { GetCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getCosmeticQL")
      }
    }

    public struct GetCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class ListCosmeticQlsQuery: GraphQLQuery {
  public static let operationString =
    "query ListCosmeticQLS($filter: ModelCosmeticQLFilterInput, $limit: Int, $nextToken: String) {\n  listCosmeticQLS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      productName\n      companyID\n      price\n      amount\n      totTagCount\n      authenticated\n      link\n      tagCnt\n      type\n      zipURL\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelCosmeticQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelCosmeticQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listCosmeticQLS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listCosmeticQls: ListCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "listCosmeticQLS": listCosmeticQls.flatMap { $0.snapshot }])
    }

    public var listCosmeticQls: ListCosmeticQl? {
      get {
        return (snapshot["listCosmeticQLS"] as? Snapshot).flatMap { ListCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listCosmeticQLS")
      }
    }

    public struct ListCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelCosmeticQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelCosmeticQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["CosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("productName", type: .nonNull(.scalar(String.self))),
          GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
          GraphQLField("price", type: .scalar(String.self)),
          GraphQLField("amount", type: .scalar(String.self)),
          GraphQLField("totTagCount", type: .scalar(Int.self)),
          GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("link", type: .list(.scalar(String.self))),
          GraphQLField("tagCnt", type: .scalar(Int.self)),
          GraphQLField("type", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var productName: String {
          get {
            return snapshot["productName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "productName")
          }
        }

        public var companyId: String {
          get {
            return snapshot["companyID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "companyID")
          }
        }

        public var price: String? {
          get {
            return snapshot["price"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "price")
          }
        }

        public var amount: String? {
          get {
            return snapshot["amount"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }

        public var totTagCount: Int? {
          get {
            return snapshot["totTagCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "totTagCount")
          }
        }

        public var authenticated: Bool {
          get {
            return snapshot["authenticated"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authenticated")
          }
        }

        public var link: [String?]? {
          get {
            return snapshot["link"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "link")
          }
        }

        public var tagCnt: Int? {
          get {
            return snapshot["tagCnt"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagCnt")
          }
        }

        public var type: String? {
          get {
            return snapshot["type"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "type")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetLumeQlQuery: GraphQLQuery {
  public static let operationString =
    "query GetLumeQL($id: ID!) {\n  getLumeQL(id: $id) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getLumeQL", arguments: ["id": GraphQLVariable("id")], type: .object(GetLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getLumeQl: GetLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "getLumeQL": getLumeQl.flatMap { $0.snapshot }])
    }

    public var getLumeQl: GetLumeQl? {
      get {
        return (snapshot["getLumeQL"] as? Snapshot).flatMap { GetLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getLumeQL")
      }
    }

    public struct GetLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class ListLumeQlsQuery: GraphQLQuery {
  public static let operationString =
    "query ListLumeQLS($filter: ModelLumeQLFilterInput, $limit: Int, $nextToken: String) {\n  listLumeQLS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelLumeQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelLumeQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listLumeQLS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listLumeQls: ListLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "listLumeQLS": listLumeQls.flatMap { $0.snapshot }])
    }

    public var listLumeQls: ListLumeQl? {
      get {
        return (snapshot["listLumeQLS"] as? Snapshot).flatMap { ListLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listLumeQLS")
      }
    }

    public struct ListLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelLumeQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelLumeQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class GetUserProfileQlQuery: GraphQLQuery {
  public static let operationString =
    "query GetUserProfileQL($id: ID!) {\n  getUserProfileQL(id: $id) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getUserProfileQL", arguments: ["id": GraphQLVariable("id")], type: .object(GetUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getUserProfileQl: GetUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "getUserProfileQL": getUserProfileQl.flatMap { $0.snapshot }])
    }

    public var getUserProfileQl: GetUserProfileQl? {
      get {
        return (snapshot["getUserProfileQL"] as? Snapshot).flatMap { GetUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getUserProfileQL")
      }
    }

    public struct GetUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class ListUserProfileQlsQuery: GraphQLQuery {
  public static let operationString =
    "query ListUserProfileQLS($filter: ModelUserProfileQLFilterInput, $limit: Int, $nextToken: String) {\n  listUserProfileQLS(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var filter: ModelUserProfileQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelUserProfileQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listUserProfileQLS", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listUserProfileQls: ListUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Query", "listUserProfileQLS": listUserProfileQls.flatMap { $0.snapshot }])
    }

    public var listUserProfileQls: ListUserProfileQl? {
      get {
        return (snapshot["listUserProfileQLS"] as? Snapshot).flatMap { ListUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listUserProfileQLS")
      }
    }

    public struct ListUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelUserProfileQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelUserProfileQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class FollowQlsByFollowingIdQuery: GraphQLQuery {
  public static let operationString =
    "query FollowQLSByFollowingID($followingID: ID!, $sortDirection: ModelSortDirection, $filter: ModelFollowQLFilterInput, $limit: Int, $nextToken: String) {\n  followQLSByFollowingID(\n    followingID: $followingID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      timestamp\n      followingID\n      followerID\n      status\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var followingID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelFollowQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(followingID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelFollowQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.followingID = followingID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["followingID": followingID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("followQLSByFollowingID", arguments: ["followingID": GraphQLVariable("followingID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(FollowQlsByFollowingId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(followQlsByFollowingId: FollowQlsByFollowingId? = nil) {
      self.init(snapshot: ["__typename": "Query", "followQLSByFollowingID": followQlsByFollowingId.flatMap { $0.snapshot }])
    }

    public var followQlsByFollowingId: FollowQlsByFollowingId? {
      get {
        return (snapshot["followQLSByFollowingID"] as? Snapshot).flatMap { FollowQlsByFollowingId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "followQLSByFollowingID")
      }
    }

    public struct FollowQlsByFollowingId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelFollowQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelFollowQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["FollowQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("timestamp", type: .scalar(Int.self)),
          GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followerID", type: .scalar(GraphQLID.self)),
          GraphQLField("status", type: .scalar(FollowStatus.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var timestamp: Int? {
          get {
            return snapshot["timestamp"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var followingId: GraphQLID {
          get {
            return snapshot["followingID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingID")
          }
        }

        public var followerId: GraphQLID? {
          get {
            return snapshot["followerID"] as? GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerID")
          }
        }

        public var status: FollowStatus? {
          get {
            return snapshot["status"] as? FollowStatus
          }
          set {
            snapshot.updateValue(newValue, forKey: "status")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class LikedLumeQlsByUserprofileqlIdQuery: GraphQLQuery {
  public static let operationString =
    "query LikedLumeQLSByUserprofileqlID($userprofileqlID: ID!, $sortDirection: ModelSortDirection, $filter: ModelLikedLumeQLFilterInput, $limit: Int, $nextToken: String) {\n  likedLumeQLSByUserprofileqlID(\n    userprofileqlID: $userprofileqlID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      timestamp\n      lumeQLID\n      userprofileqlID\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var userprofileqlID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelLikedLumeQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(userprofileqlID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelLikedLumeQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.userprofileqlID = userprofileqlID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["userprofileqlID": userprofileqlID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("likedLumeQLSByUserprofileqlID", arguments: ["userprofileqlID": GraphQLVariable("userprofileqlID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(LikedLumeQlsByUserprofileqlId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(likedLumeQlsByUserprofileqlId: LikedLumeQlsByUserprofileqlId? = nil) {
      self.init(snapshot: ["__typename": "Query", "likedLumeQLSByUserprofileqlID": likedLumeQlsByUserprofileqlId.flatMap { $0.snapshot }])
    }

    public var likedLumeQlsByUserprofileqlId: LikedLumeQlsByUserprofileqlId? {
      get {
        return (snapshot["likedLumeQLSByUserprofileqlID"] as? Snapshot).flatMap { LikedLumeQlsByUserprofileqlId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "likedLumeQLSByUserprofileqlID")
      }
    }

    public struct LikedLumeQlsByUserprofileqlId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelLikedLumeQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["LikedLumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("timestamp", type: .scalar(Int.self)),
          GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var timestamp: Int? {
          get {
            return snapshot["timestamp"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var lumeQlid: GraphQLID {
          get {
            return snapshot["lumeQLID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "lumeQLID")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class CommentQlsByUserprofileqlIdQuery: GraphQLQuery {
  public static let operationString =
    "query CommentQLSByUserprofileqlID($userprofileqlID: ID!, $sortDirection: ModelSortDirection, $filter: ModelCommentQLFilterInput, $limit: Int, $nextToken: String) {\n  commentQLSByUserprofileqlID(\n    userprofileqlID: $userprofileqlID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      timestamp\n      comment\n      lumeQLID\n      userprofileqlID\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var userprofileqlID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelCommentQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(userprofileqlID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelCommentQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.userprofileqlID = userprofileqlID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["userprofileqlID": userprofileqlID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("commentQLSByUserprofileqlID", arguments: ["userprofileqlID": GraphQLVariable("userprofileqlID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(CommentQlsByUserprofileqlId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(commentQlsByUserprofileqlId: CommentQlsByUserprofileqlId? = nil) {
      self.init(snapshot: ["__typename": "Query", "commentQLSByUserprofileqlID": commentQlsByUserprofileqlId.flatMap { $0.snapshot }])
    }

    public var commentQlsByUserprofileqlId: CommentQlsByUserprofileqlId? {
      get {
        return (snapshot["commentQLSByUserprofileqlID"] as? Snapshot).flatMap { CommentQlsByUserprofileqlId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "commentQLSByUserprofileqlID")
      }
    }

    public struct CommentQlsByUserprofileqlId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelCommentQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelCommentQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["CommentQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("comment", type: .nonNull(.scalar(String.self))),
          GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var comment: String {
          get {
            return snapshot["comment"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "comment")
          }
        }

        public var lumeQlid: GraphQLID {
          get {
            return snapshot["lumeQLID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "lumeQLID")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class LumeQlsByUserprofileqlIdQuery: GraphQLQuery {
  public static let operationString =
    "query LumeQLSByUserprofileqlID($userprofileqlID: ID!, $sortDirection: ModelSortDirection, $filter: ModelLumeQLFilterInput, $limit: Int, $nextToken: String) {\n  lumeQLSByUserprofileqlID(\n    userprofileqlID: $userprofileqlID\n    sortDirection: $sortDirection\n    filter: $filter\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    nextToken\n  }\n}"

  public var userprofileqlID: GraphQLID
  public var sortDirection: ModelSortDirection?
  public var filter: ModelLumeQLFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(userprofileqlID: GraphQLID, sortDirection: ModelSortDirection? = nil, filter: ModelLumeQLFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.userprofileqlID = userprofileqlID
    self.sortDirection = sortDirection
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["userprofileqlID": userprofileqlID, "sortDirection": sortDirection, "filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("lumeQLSByUserprofileqlID", arguments: ["userprofileqlID": GraphQLVariable("userprofileqlID"), "sortDirection": GraphQLVariable("sortDirection"), "filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(LumeQlsByUserprofileqlId.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(lumeQlsByUserprofileqlId: LumeQlsByUserprofileqlId? = nil) {
      self.init(snapshot: ["__typename": "Query", "lumeQLSByUserprofileqlID": lumeQlsByUserprofileqlId.flatMap { $0.snapshot }])
    }

    public var lumeQlsByUserprofileqlId: LumeQlsByUserprofileqlId? {
      get {
        return (snapshot["lumeQLSByUserprofileqlID"] as? Snapshot).flatMap { LumeQlsByUserprofileqlId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "lumeQLSByUserprofileqlID")
      }
    }

    public struct LumeQlsByUserprofileqlId: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelLumeQLConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelLumeQLConnection", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnCreateFollowQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateFollowQL($filter: ModelSubscriptionFollowQLFilterInput) {\n  onCreateFollowQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFollowQLFilterInput?

  public init(filter: ModelSubscriptionFollowQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateFollowQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateFollowQl: OnCreateFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateFollowQL": onCreateFollowQl.flatMap { $0.snapshot }])
    }

    public var onCreateFollowQl: OnCreateFollowQl? {
      get {
        return (snapshot["onCreateFollowQL"] as? Snapshot).flatMap { OnCreateFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateFollowQL")
      }
    }

    public struct OnCreateFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnUpdateFollowQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateFollowQL($filter: ModelSubscriptionFollowQLFilterInput) {\n  onUpdateFollowQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFollowQLFilterInput?

  public init(filter: ModelSubscriptionFollowQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateFollowQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateFollowQl: OnUpdateFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateFollowQL": onUpdateFollowQl.flatMap { $0.snapshot }])
    }

    public var onUpdateFollowQl: OnUpdateFollowQl? {
      get {
        return (snapshot["onUpdateFollowQL"] as? Snapshot).flatMap { OnUpdateFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateFollowQL")
      }
    }

    public struct OnUpdateFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnDeleteFollowQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteFollowQL($filter: ModelSubscriptionFollowQLFilterInput) {\n  onDeleteFollowQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    followingID\n    following {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    followerID\n    status\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionFollowQLFilterInput?

  public init(filter: ModelSubscriptionFollowQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteFollowQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteFollowQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteFollowQl: OnDeleteFollowQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteFollowQL": onDeleteFollowQl.flatMap { $0.snapshot }])
    }

    public var onDeleteFollowQl: OnDeleteFollowQl? {
      get {
        return (snapshot["onDeleteFollowQL"] as? Snapshot).flatMap { OnDeleteFollowQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteFollowQL")
      }
    }

    public struct OnDeleteFollowQl: GraphQLSelectionSet {
      public static let possibleTypes = ["FollowQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("followingID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("followerID", type: .scalar(GraphQLID.self)),
        GraphQLField("status", type: .scalar(FollowStatus.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, followingId: GraphQLID, following: Following? = nil, followerId: GraphQLID? = nil, status: FollowStatus? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "FollowQL", "id": id, "timestamp": timestamp, "followingID": followingId, "following": following.flatMap { $0.snapshot }, "followerID": followerId, "status": status, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var followingId: GraphQLID {
        get {
          return snapshot["followingID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingID")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var followerId: GraphQLID? {
        get {
          return snapshot["followerID"] as? GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerID")
        }
      }

      public var status: FollowStatus? {
        get {
          return snapshot["status"] as? FollowStatus
        }
        set {
          snapshot.updateValue(newValue, forKey: "status")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnCreateLikedLumeQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateLikedLumeQL($filter: ModelSubscriptionLikedLumeQLFilterInput) {\n  onCreateLikedLumeQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionLikedLumeQLFilterInput?

  public init(filter: ModelSubscriptionLikedLumeQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateLikedLumeQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateLikedLumeQl: OnCreateLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateLikedLumeQL": onCreateLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var onCreateLikedLumeQl: OnCreateLikedLumeQl? {
      get {
        return (snapshot["onCreateLikedLumeQL"] as? Snapshot).flatMap { OnCreateLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateLikedLumeQL")
      }
    }

    public struct OnCreateLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnUpdateLikedLumeQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateLikedLumeQL($filter: ModelSubscriptionLikedLumeQLFilterInput) {\n  onUpdateLikedLumeQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionLikedLumeQLFilterInput?

  public init(filter: ModelSubscriptionLikedLumeQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateLikedLumeQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateLikedLumeQl: OnUpdateLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateLikedLumeQL": onUpdateLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var onUpdateLikedLumeQl: OnUpdateLikedLumeQl? {
      get {
        return (snapshot["onUpdateLikedLumeQL"] as? Snapshot).flatMap { OnUpdateLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateLikedLumeQL")
      }
    }

    public struct OnUpdateLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnDeleteLikedLumeQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteLikedLumeQL($filter: ModelSubscriptionLikedLumeQLFilterInput) {\n  onDeleteLikedLumeQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionLikedLumeQLFilterInput?

  public init(filter: ModelSubscriptionLikedLumeQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteLikedLumeQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteLikedLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteLikedLumeQl: OnDeleteLikedLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteLikedLumeQL": onDeleteLikedLumeQl.flatMap { $0.snapshot }])
    }

    public var onDeleteLikedLumeQl: OnDeleteLikedLumeQl? {
      get {
        return (snapshot["onDeleteLikedLumeQL"] as? Snapshot).flatMap { OnDeleteLikedLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteLikedLumeQL")
      }
    }

    public struct OnDeleteLikedLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LikedLumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .scalar(Int.self)),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int? = nil, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LikedLumeQL", "id": id, "timestamp": timestamp, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int? {
        get {
          return snapshot["timestamp"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnCreateCommentQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateCommentQL($filter: ModelSubscriptionCommentQLFilterInput) {\n  onCreateCommentQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionCommentQLFilterInput?

  public init(filter: ModelSubscriptionCommentQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateCommentQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateCommentQl: OnCreateCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateCommentQL": onCreateCommentQl.flatMap { $0.snapshot }])
    }

    public var onCreateCommentQl: OnCreateCommentQl? {
      get {
        return (snapshot["onCreateCommentQL"] as? Snapshot).flatMap { OnCreateCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateCommentQL")
      }
    }

    public struct OnCreateCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnUpdateCommentQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateCommentQL($filter: ModelSubscriptionCommentQLFilterInput) {\n  onUpdateCommentQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionCommentQLFilterInput?

  public init(filter: ModelSubscriptionCommentQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateCommentQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateCommentQl: OnUpdateCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateCommentQL": onUpdateCommentQl.flatMap { $0.snapshot }])
    }

    public var onUpdateCommentQl: OnUpdateCommentQl? {
      get {
        return (snapshot["onUpdateCommentQL"] as? Snapshot).flatMap { OnUpdateCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateCommentQL")
      }
    }

    public struct OnUpdateCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnDeleteCommentQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteCommentQL($filter: ModelSubscriptionCommentQLFilterInput) {\n  onDeleteCommentQL(filter: $filter) {\n    __typename\n    id\n    timestamp\n    comment\n    lumeQLID\n    lume {\n      __typename\n      id\n      postURL\n      timestamp\n      description\n      userprofileqlID\n      likeCount\n      commentCount\n      hashTags\n      zipURL\n      createdAt\n      updatedAt\n    }\n    userprofileqlID\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionCommentQLFilterInput?

  public init(filter: ModelSubscriptionCommentQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteCommentQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteCommentQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteCommentQl: OnDeleteCommentQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteCommentQL": onDeleteCommentQl.flatMap { $0.snapshot }])
    }

    public var onDeleteCommentQl: OnDeleteCommentQl? {
      get {
        return (snapshot["onDeleteCommentQL"] as? Snapshot).flatMap { OnDeleteCommentQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteCommentQL")
      }
    }

    public struct OnDeleteCommentQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CommentQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("comment", type: .nonNull(.scalar(String.self))),
        GraphQLField("lumeQLID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("lume", type: .object(Lume.selections)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, timestamp: Int, comment: String, lumeQlid: GraphQLID, lume: Lume? = nil, userprofileqlId: GraphQLID, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CommentQL", "id": id, "timestamp": timestamp, "comment": comment, "lumeQLID": lumeQlid, "lume": lume.flatMap { $0.snapshot }, "userprofileqlID": userprofileqlId, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var comment: String {
        get {
          return snapshot["comment"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "comment")
        }
      }

      public var lumeQlid: GraphQLID {
        get {
          return snapshot["lumeQLID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "lumeQLID")
        }
      }

      public var lume: Lume? {
        get {
          return (snapshot["lume"] as? Snapshot).flatMap { Lume(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "lume")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct Lume: GraphQLSelectionSet {
        public static let possibleTypes = ["LumeQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("postURL", type: .list(.scalar(String.self))),
          GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("likeCount", type: .scalar(Int.self)),
          GraphQLField("commentCount", type: .scalar(Int.self)),
          GraphQLField("hashTags", type: .list(.scalar(String.self))),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, description: String? = nil, userprofileqlId: GraphQLID, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "description": description, "userprofileqlID": userprofileqlId, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var postUrl: [String?]? {
          get {
            return snapshot["postURL"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "postURL")
          }
        }

        public var timestamp: Int {
          get {
            return snapshot["timestamp"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var userprofileqlId: GraphQLID {
          get {
            return snapshot["userprofileqlID"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "userprofileqlID")
          }
        }

        public var likeCount: Int? {
          get {
            return snapshot["likeCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "likeCount")
          }
        }

        public var commentCount: Int? {
          get {
            return snapshot["commentCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "commentCount")
          }
        }

        public var hashTags: [String?]? {
          get {
            return snapshot["hashTags"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "hashTags")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnCreateCosmeticQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateCosmeticQL($filter: ModelSubscriptionCosmeticQLFilterInput) {\n  onCreateCosmeticQL(filter: $filter) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionCosmeticQLFilterInput?

  public init(filter: ModelSubscriptionCosmeticQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateCosmeticQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateCosmeticQl: OnCreateCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateCosmeticQL": onCreateCosmeticQl.flatMap { $0.snapshot }])
    }

    public var onCreateCosmeticQl: OnCreateCosmeticQl? {
      get {
        return (snapshot["onCreateCosmeticQL"] as? Snapshot).flatMap { OnCreateCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateCosmeticQL")
      }
    }

    public struct OnCreateCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnUpdateCosmeticQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateCosmeticQL($filter: ModelSubscriptionCosmeticQLFilterInput) {\n  onUpdateCosmeticQL(filter: $filter) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionCosmeticQLFilterInput?

  public init(filter: ModelSubscriptionCosmeticQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateCosmeticQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateCosmeticQl: OnUpdateCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateCosmeticQL": onUpdateCosmeticQl.flatMap { $0.snapshot }])
    }

    public var onUpdateCosmeticQl: OnUpdateCosmeticQl? {
      get {
        return (snapshot["onUpdateCosmeticQL"] as? Snapshot).flatMap { OnUpdateCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateCosmeticQL")
      }
    }

    public struct OnUpdateCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnDeleteCosmeticQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteCosmeticQL($filter: ModelSubscriptionCosmeticQLFilterInput) {\n  onDeleteCosmeticQL(filter: $filter) {\n    __typename\n    id\n    productName\n    companyID\n    price\n    amount\n    totTagCount\n    authenticated\n    link\n    tagCnt\n    type\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionCosmeticQLFilterInput?

  public init(filter: ModelSubscriptionCosmeticQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteCosmeticQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteCosmeticQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteCosmeticQl: OnDeleteCosmeticQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteCosmeticQL": onDeleteCosmeticQl.flatMap { $0.snapshot }])
    }

    public var onDeleteCosmeticQl: OnDeleteCosmeticQl? {
      get {
        return (snapshot["onDeleteCosmeticQL"] as? Snapshot).flatMap { OnDeleteCosmeticQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteCosmeticQL")
      }
    }

    public struct OnDeleteCosmeticQl: GraphQLSelectionSet {
      public static let possibleTypes = ["CosmeticQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("productName", type: .nonNull(.scalar(String.self))),
        GraphQLField("companyID", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .scalar(String.self)),
        GraphQLField("amount", type: .scalar(String.self)),
        GraphQLField("totTagCount", type: .scalar(Int.self)),
        GraphQLField("authenticated", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("link", type: .list(.scalar(String.self))),
        GraphQLField("tagCnt", type: .scalar(Int.self)),
        GraphQLField("type", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, productName: String, companyId: String, price: String? = nil, amount: String? = nil, totTagCount: Int? = nil, authenticated: Bool, link: [String?]? = nil, tagCnt: Int? = nil, type: String? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "CosmeticQL", "id": id, "productName": productName, "companyID": companyId, "price": price, "amount": amount, "totTagCount": totTagCount, "authenticated": authenticated, "link": link, "tagCnt": tagCnt, "type": type, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var productName: String {
        get {
          return snapshot["productName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "productName")
        }
      }

      public var companyId: String {
        get {
          return snapshot["companyID"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "companyID")
        }
      }

      public var price: String? {
        get {
          return snapshot["price"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "price")
        }
      }

      public var amount: String? {
        get {
          return snapshot["amount"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }

      public var totTagCount: Int? {
        get {
          return snapshot["totTagCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "totTagCount")
        }
      }

      public var authenticated: Bool {
        get {
          return snapshot["authenticated"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "authenticated")
        }
      }

      public var link: [String?]? {
        get {
          return snapshot["link"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "link")
        }
      }

      public var tagCnt: Int? {
        get {
          return snapshot["tagCnt"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "tagCnt")
        }
      }

      public var type: String? {
        get {
          return snapshot["type"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }
    }
  }
}

public final class OnCreateLumeQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateLumeQL($filter: ModelSubscriptionLumeQLFilterInput) {\n  onCreateLumeQL(filter: $filter) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionLumeQLFilterInput?

  public init(filter: ModelSubscriptionLumeQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateLumeQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateLumeQl: OnCreateLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateLumeQL": onCreateLumeQl.flatMap { $0.snapshot }])
    }

    public var onCreateLumeQl: OnCreateLumeQl? {
      get {
        return (snapshot["onCreateLumeQL"] as? Snapshot).flatMap { OnCreateLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateLumeQL")
      }
    }

    public struct OnCreateLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnUpdateLumeQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateLumeQL($filter: ModelSubscriptionLumeQLFilterInput) {\n  onUpdateLumeQL(filter: $filter) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionLumeQLFilterInput?

  public init(filter: ModelSubscriptionLumeQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateLumeQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateLumeQl: OnUpdateLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateLumeQL": onUpdateLumeQl.flatMap { $0.snapshot }])
    }

    public var onUpdateLumeQl: OnUpdateLumeQl? {
      get {
        return (snapshot["onUpdateLumeQL"] as? Snapshot).flatMap { OnUpdateLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateLumeQL")
      }
    }

    public struct OnUpdateLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnDeleteLumeQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteLumeQL($filter: ModelSubscriptionLumeQLFilterInput) {\n  onDeleteLumeQL(filter: $filter) {\n    __typename\n    id\n    postURL\n    timestamp\n    tagProducts {\n      __typename\n      cosmeticID\n      authProduct\n      recommend\n      effect\n      fading\n      feeling\n      attachedURL\n    }\n    tagMusic {\n      __typename\n      trackID\n      tagMusicRange\n    }\n    description\n    userprofileqlID\n    userprofile {\n      __typename\n      id\n      followingUsers\n      followerUsers\n      username\n      DOB\n      firstName\n      Sensitivity\n      SunBathing\n      SkinType\n      lockState\n      profileImage\n      backgroundImage\n      followerCount\n      followingCount\n      bio\n      zipURL\n      postCount\n      createdAt\n      updatedAt\n    }\n    likeCount\n    commentCount\n    hashTags\n    zipURL\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionLumeQLFilterInput?

  public init(filter: ModelSubscriptionLumeQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteLumeQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteLumeQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteLumeQl: OnDeleteLumeQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteLumeQL": onDeleteLumeQl.flatMap { $0.snapshot }])
    }

    public var onDeleteLumeQl: OnDeleteLumeQl? {
      get {
        return (snapshot["onDeleteLumeQL"] as? Snapshot).flatMap { OnDeleteLumeQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteLumeQL")
      }
    }

    public struct OnDeleteLumeQl: GraphQLSelectionSet {
      public static let possibleTypes = ["LumeQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("postURL", type: .list(.scalar(String.self))),
        GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
        GraphQLField("tagProducts", type: .list(.object(TagProduct.selections))),
        GraphQLField("tagMusic", type: .object(TagMusic.selections)),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("userprofileqlID", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("userprofile", type: .object(Userprofile.selections)),
        GraphQLField("likeCount", type: .scalar(Int.self)),
        GraphQLField("commentCount", type: .scalar(Int.self)),
        GraphQLField("hashTags", type: .list(.scalar(String.self))),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, postUrl: [String?]? = nil, timestamp: Int, tagProducts: [TagProduct?]? = nil, tagMusic: TagMusic? = nil, description: String? = nil, userprofileqlId: GraphQLID, userprofile: Userprofile? = nil, likeCount: Int? = nil, commentCount: Int? = nil, hashTags: [String?]? = nil, zipUrl: String? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "LumeQL", "id": id, "postURL": postUrl, "timestamp": timestamp, "tagProducts": tagProducts.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "tagMusic": tagMusic.flatMap { $0.snapshot }, "description": description, "userprofileqlID": userprofileqlId, "userprofile": userprofile.flatMap { $0.snapshot }, "likeCount": likeCount, "commentCount": commentCount, "hashTags": hashTags, "zipURL": zipUrl, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var postUrl: [String?]? {
        get {
          return snapshot["postURL"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "postURL")
        }
      }

      public var timestamp: Int {
        get {
          return snapshot["timestamp"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "timestamp")
        }
      }

      public var tagProducts: [TagProduct?]? {
        get {
          return (snapshot["tagProducts"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { TagProduct(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "tagProducts")
        }
      }

      public var tagMusic: TagMusic? {
        get {
          return (snapshot["tagMusic"] as? Snapshot).flatMap { TagMusic(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "tagMusic")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var userprofileqlId: GraphQLID {
        get {
          return snapshot["userprofileqlID"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "userprofileqlID")
        }
      }

      public var userprofile: Userprofile? {
        get {
          return (snapshot["userprofile"] as? Snapshot).flatMap { Userprofile(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "userprofile")
        }
      }

      public var likeCount: Int? {
        get {
          return snapshot["likeCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "likeCount")
        }
      }

      public var commentCount: Int? {
        get {
          return snapshot["commentCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "commentCount")
        }
      }

      public var hashTags: [String?]? {
        get {
          return snapshot["hashTags"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "hashTags")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct TagProduct: GraphQLSelectionSet {
        public static let possibleTypes = ["TagCosmeticQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cosmeticID", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProduct", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("recommend", type: .scalar(Double.self)),
          GraphQLField("effect", type: .scalar(Double.self)),
          GraphQLField("fading", type: .scalar(Double.self)),
          GraphQLField("feeling", type: .scalar(Double.self)),
          GraphQLField("attachedURL", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cosmeticId: String, authProduct: Bool, recommend: Double? = nil, effect: Double? = nil, fading: Double? = nil, feeling: Double? = nil, attachedUrl: String? = nil) {
          self.init(snapshot: ["__typename": "TagCosmeticQL", "cosmeticID": cosmeticId, "authProduct": authProduct, "recommend": recommend, "effect": effect, "fading": fading, "feeling": feeling, "attachedURL": attachedUrl])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cosmeticId: String {
          get {
            return snapshot["cosmeticID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cosmeticID")
          }
        }

        public var authProduct: Bool {
          get {
            return snapshot["authProduct"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "authProduct")
          }
        }

        public var recommend: Double? {
          get {
            return snapshot["recommend"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "recommend")
          }
        }

        public var effect: Double? {
          get {
            return snapshot["effect"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "effect")
          }
        }

        public var fading: Double? {
          get {
            return snapshot["fading"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "fading")
          }
        }

        public var feeling: Double? {
          get {
            return snapshot["feeling"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "feeling")
          }
        }

        public var attachedUrl: String? {
          get {
            return snapshot["attachedURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "attachedURL")
          }
        }
      }

      public struct TagMusic: GraphQLSelectionSet {
        public static let possibleTypes = ["TagTrackQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("trackID", type: .nonNull(.scalar(String.self))),
          GraphQLField("tagMusicRange", type: .list(.nonNull(.scalar(Double.self)))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(trackId: String, tagMusicRange: [Double]? = nil) {
          self.init(snapshot: ["__typename": "TagTrackQL", "trackID": trackId, "tagMusicRange": tagMusicRange])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var trackId: String {
          get {
            return snapshot["trackID"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "trackID")
          }
        }

        public var tagMusicRange: [Double]? {
          get {
            return snapshot["tagMusicRange"] as? [Double]
          }
          set {
            snapshot.updateValue(newValue, forKey: "tagMusicRange")
          }
        }
      }

      public struct Userprofile: GraphQLSelectionSet {
        public static let possibleTypes = ["UserProfileQL"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("followingUsers", type: .list(.scalar(String.self))),
          GraphQLField("followerUsers", type: .list(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("DOB", type: .scalar(Int.self)),
          GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
          GraphQLField("Sensitivity", type: .scalar(Double.self)),
          GraphQLField("SunBathing", type: .scalar(Double.self)),
          GraphQLField("SkinType", type: .scalar(Double.self)),
          GraphQLField("lockState", type: .scalar(Bool.self)),
          GraphQLField("profileImage", type: .scalar(String.self)),
          GraphQLField("backgroundImage", type: .scalar(String.self)),
          GraphQLField("followerCount", type: .scalar(Int.self)),
          GraphQLField("followingCount", type: .scalar(Int.self)),
          GraphQLField("bio", type: .scalar(String.self)),
          GraphQLField("zipURL", type: .scalar(String.self)),
          GraphQLField("postCount", type: .scalar(Int.self)),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var followingUsers: [String?]? {
          get {
            return snapshot["followingUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingUsers")
          }
        }

        public var followerUsers: [String?]? {
          get {
            return snapshot["followerUsers"] as? [String?]
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerUsers")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var dob: Int? {
          get {
            return snapshot["DOB"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "DOB")
          }
        }

        public var firstName: String {
          get {
            return snapshot["firstName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstName")
          }
        }

        public var sensitivity: Double? {
          get {
            return snapshot["Sensitivity"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "Sensitivity")
          }
        }

        public var sunBathing: Double? {
          get {
            return snapshot["SunBathing"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SunBathing")
          }
        }

        public var skinType: Double? {
          get {
            return snapshot["SkinType"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "SkinType")
          }
        }

        public var lockState: Bool? {
          get {
            return snapshot["lockState"] as? Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "lockState")
          }
        }

        public var profileImage: String? {
          get {
            return snapshot["profileImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "profileImage")
          }
        }

        public var backgroundImage: String? {
          get {
            return snapshot["backgroundImage"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "backgroundImage")
          }
        }

        public var followerCount: Int? {
          get {
            return snapshot["followerCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followerCount")
          }
        }

        public var followingCount: Int? {
          get {
            return snapshot["followingCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "followingCount")
          }
        }

        public var bio: String? {
          get {
            return snapshot["bio"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bio")
          }
        }

        public var zipUrl: String? {
          get {
            return snapshot["zipURL"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "zipURL")
          }
        }

        public var postCount: Int? {
          get {
            return snapshot["postCount"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "postCount")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class OnCreateUserProfileQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateUserProfileQL($filter: ModelSubscriptionUserProfileQLFilterInput) {\n  onCreateUserProfileQL(filter: $filter) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionUserProfileQLFilterInput?

  public init(filter: ModelSubscriptionUserProfileQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateUserProfileQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnCreateUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateUserProfileQl: OnCreateUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateUserProfileQL": onCreateUserProfileQl.flatMap { $0.snapshot }])
    }

    public var onCreateUserProfileQl: OnCreateUserProfileQl? {
      get {
        return (snapshot["onCreateUserProfileQL"] as? Snapshot).flatMap { OnCreateUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateUserProfileQL")
      }
    }

    public struct OnCreateUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnUpdateUserProfileQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateUserProfileQL($filter: ModelSubscriptionUserProfileQLFilterInput) {\n  onUpdateUserProfileQL(filter: $filter) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionUserProfileQLFilterInput?

  public init(filter: ModelSubscriptionUserProfileQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateUserProfileQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnUpdateUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateUserProfileQl: OnUpdateUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateUserProfileQL": onUpdateUserProfileQl.flatMap { $0.snapshot }])
    }

    public var onUpdateUserProfileQl: OnUpdateUserProfileQl? {
      get {
        return (snapshot["onUpdateUserProfileQL"] as? Snapshot).flatMap { OnUpdateUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateUserProfileQL")
      }
    }

    public struct OnUpdateUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class OnDeleteUserProfileQlSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteUserProfileQL($filter: ModelSubscriptionUserProfileQLFilterInput) {\n  onDeleteUserProfileQL(filter: $filter) {\n    __typename\n    id\n    followingUsers\n    followerUsers\n    username\n    DOB\n    firstName\n    Sensitivity\n    SunBathing\n    SkinType\n    postContents {\n      __typename\n      nextToken\n    }\n    likedContents {\n      __typename\n      nextToken\n    }\n    comments {\n      __typename\n      nextToken\n    }\n    lockState\n    profileImage\n    backgroundImage\n    followerCount\n    followingCount\n    bio\n    zipURL\n    following {\n      __typename\n      nextToken\n    }\n    postCount\n    createdAt\n    updatedAt\n  }\n}"

  public var filter: ModelSubscriptionUserProfileQLFilterInput?

  public init(filter: ModelSubscriptionUserProfileQLFilterInput? = nil) {
    self.filter = filter
  }

  public var variables: GraphQLMap? {
    return ["filter": filter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteUserProfileQL", arguments: ["filter": GraphQLVariable("filter")], type: .object(OnDeleteUserProfileQl.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteUserProfileQl: OnDeleteUserProfileQl? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteUserProfileQL": onDeleteUserProfileQl.flatMap { $0.snapshot }])
    }

    public var onDeleteUserProfileQl: OnDeleteUserProfileQl? {
      get {
        return (snapshot["onDeleteUserProfileQL"] as? Snapshot).flatMap { OnDeleteUserProfileQl(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteUserProfileQL")
      }
    }

    public struct OnDeleteUserProfileQl: GraphQLSelectionSet {
      public static let possibleTypes = ["UserProfileQL"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("followingUsers", type: .list(.scalar(String.self))),
        GraphQLField("followerUsers", type: .list(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("DOB", type: .scalar(Int.self)),
        GraphQLField("firstName", type: .nonNull(.scalar(String.self))),
        GraphQLField("Sensitivity", type: .scalar(Double.self)),
        GraphQLField("SunBathing", type: .scalar(Double.self)),
        GraphQLField("SkinType", type: .scalar(Double.self)),
        GraphQLField("postContents", type: .object(PostContent.selections)),
        GraphQLField("likedContents", type: .object(LikedContent.selections)),
        GraphQLField("comments", type: .object(Comment.selections)),
        GraphQLField("lockState", type: .scalar(Bool.self)),
        GraphQLField("profileImage", type: .scalar(String.self)),
        GraphQLField("backgroundImage", type: .scalar(String.self)),
        GraphQLField("followerCount", type: .scalar(Int.self)),
        GraphQLField("followingCount", type: .scalar(Int.self)),
        GraphQLField("bio", type: .scalar(String.self)),
        GraphQLField("zipURL", type: .scalar(String.self)),
        GraphQLField("following", type: .object(Following.selections)),
        GraphQLField("postCount", type: .scalar(Int.self)),
        GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
        GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, followingUsers: [String?]? = nil, followerUsers: [String?]? = nil, username: String, dob: Int? = nil, firstName: String, sensitivity: Double? = nil, sunBathing: Double? = nil, skinType: Double? = nil, postContents: PostContent? = nil, likedContents: LikedContent? = nil, comments: Comment? = nil, lockState: Bool? = nil, profileImage: String? = nil, backgroundImage: String? = nil, followerCount: Int? = nil, followingCount: Int? = nil, bio: String? = nil, zipUrl: String? = nil, following: Following? = nil, postCount: Int? = nil, createdAt: String, updatedAt: String) {
        self.init(snapshot: ["__typename": "UserProfileQL", "id": id, "followingUsers": followingUsers, "followerUsers": followerUsers, "username": username, "DOB": dob, "firstName": firstName, "Sensitivity": sensitivity, "SunBathing": sunBathing, "SkinType": skinType, "postContents": postContents.flatMap { $0.snapshot }, "likedContents": likedContents.flatMap { $0.snapshot }, "comments": comments.flatMap { $0.snapshot }, "lockState": lockState, "profileImage": profileImage, "backgroundImage": backgroundImage, "followerCount": followerCount, "followingCount": followingCount, "bio": bio, "zipURL": zipUrl, "following": following.flatMap { $0.snapshot }, "postCount": postCount, "createdAt": createdAt, "updatedAt": updatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var followingUsers: [String?]? {
        get {
          return snapshot["followingUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingUsers")
        }
      }

      public var followerUsers: [String?]? {
        get {
          return snapshot["followerUsers"] as? [String?]
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerUsers")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var dob: Int? {
        get {
          return snapshot["DOB"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "DOB")
        }
      }

      public var firstName: String {
        get {
          return snapshot["firstName"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var sensitivity: Double? {
        get {
          return snapshot["Sensitivity"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "Sensitivity")
        }
      }

      public var sunBathing: Double? {
        get {
          return snapshot["SunBathing"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SunBathing")
        }
      }

      public var skinType: Double? {
        get {
          return snapshot["SkinType"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "SkinType")
        }
      }

      public var postContents: PostContent? {
        get {
          return (snapshot["postContents"] as? Snapshot).flatMap { PostContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "postContents")
        }
      }

      public var likedContents: LikedContent? {
        get {
          return (snapshot["likedContents"] as? Snapshot).flatMap { LikedContent(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "likedContents")
        }
      }

      public var comments: Comment? {
        get {
          return (snapshot["comments"] as? Snapshot).flatMap { Comment(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "comments")
        }
      }

      public var lockState: Bool? {
        get {
          return snapshot["lockState"] as? Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "lockState")
        }
      }

      public var profileImage: String? {
        get {
          return snapshot["profileImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profileImage")
        }
      }

      public var backgroundImage: String? {
        get {
          return snapshot["backgroundImage"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "backgroundImage")
        }
      }

      public var followerCount: Int? {
        get {
          return snapshot["followerCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followerCount")
        }
      }

      public var followingCount: Int? {
        get {
          return snapshot["followingCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "followingCount")
        }
      }

      public var bio: String? {
        get {
          return snapshot["bio"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bio")
        }
      }

      public var zipUrl: String? {
        get {
          return snapshot["zipURL"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "zipURL")
        }
      }

      public var following: Following? {
        get {
          return (snapshot["following"] as? Snapshot).flatMap { Following(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "following")
        }
      }

      public var postCount: Int? {
        get {
          return snapshot["postCount"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "postCount")
        }
      }

      public var createdAt: String {
        get {
          return snapshot["createdAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAt")
        }
      }

      public var updatedAt: String {
        get {
          return snapshot["updatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAt")
        }
      }

      public struct PostContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct LikedContent: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelLikedLumeQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelLikedLumeQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Comment: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelCommentQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelCommentQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }

      public struct Following: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelFollowQLConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelFollowQLConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}