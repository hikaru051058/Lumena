// swiftlint:disable all
import Amplify
import Foundation

public struct LumeQL: Model {
  public let id: String
  public var postURL: [String?]?
  public var timestamp: Int
  public var tagProducts: [TagCosmeticQL?]?
  public var tagMusic: TagTrackQL?
  public var description: String?
  public var userprofileqlID: String
  public var likeCount: Int?
  public var commentCount: Int?
  public var hashTags: [String?]?
  public var zipURL: String?
  public var lumeState: List<LumeStateQL>?
  public var lumeAuth: Bool?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      postURL: [String?]? = nil,
      timestamp: Int,
      tagProducts: [TagCosmeticQL?]? = nil,
      tagMusic: TagTrackQL? = nil,
      description: String? = nil,
      userprofileqlID: String,
      likeCount: Int? = nil,
      commentCount: Int? = nil,
      hashTags: [String?]? = nil,
      zipURL: String? = nil,
      lumeState: List<LumeStateQL>? = [],
      lumeAuth: Bool? = nil) {
    self.init(id: id,
      postURL: postURL,
      timestamp: timestamp,
      tagProducts: tagProducts,
      tagMusic: tagMusic,
      description: description,
      userprofileqlID: userprofileqlID,
      likeCount: likeCount,
      commentCount: commentCount,
      hashTags: hashTags,
      zipURL: zipURL,
      lumeState: lumeState,
      lumeAuth: lumeAuth,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      postURL: [String?]? = nil,
      timestamp: Int,
      tagProducts: [TagCosmeticQL?]? = nil,
      tagMusic: TagTrackQL? = nil,
      description: String? = nil,
      userprofileqlID: String,
      likeCount: Int? = nil,
      commentCount: Int? = nil,
      hashTags: [String?]? = nil,
      zipURL: String? = nil,
      lumeState: List<LumeStateQL>? = [],
      lumeAuth: Bool? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.postURL = postURL
      self.timestamp = timestamp
      self.tagProducts = tagProducts
      self.tagMusic = tagMusic
      self.description = description
      self.userprofileqlID = userprofileqlID
      self.likeCount = likeCount
      self.commentCount = commentCount
      self.hashTags = hashTags
      self.zipURL = zipURL
      self.lumeState = lumeState
      self.lumeAuth = lumeAuth
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}