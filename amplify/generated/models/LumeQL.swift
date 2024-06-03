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
  public var userprofile: UserProfileQL?
  public var likeCount: Int?
  public var commentCount: Int?
  public var hashTags: [String?]?
  public var zipURL: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      postURL: [String?]? = nil,
      timestamp: Int,
      tagProducts: [TagCosmeticQL?]? = nil,
      tagMusic: TagTrackQL? = nil,
      description: String? = nil,
      userprofile: UserProfileQL? = nil,
      likeCount: Int? = nil,
      commentCount: Int? = nil,
      hashTags: [String?]? = nil,
      zipURL: String? = nil) {
    self.init(id: id,
      postURL: postURL,
      timestamp: timestamp,
      tagProducts: tagProducts,
      tagMusic: tagMusic,
      description: description,
      userprofile: userprofile,
      likeCount: likeCount,
      commentCount: commentCount,
      hashTags: hashTags,
      zipURL: zipURL,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      postURL: [String?]? = nil,
      timestamp: Int,
      tagProducts: [TagCosmeticQL?]? = nil,
      tagMusic: TagTrackQL? = nil,
      description: String? = nil,
      userprofile: UserProfileQL? = nil,
      likeCount: Int? = nil,
      commentCount: Int? = nil,
      hashTags: [String?]? = nil,
      zipURL: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.postURL = postURL
      self.timestamp = timestamp
      self.tagProducts = tagProducts
      self.tagMusic = tagMusic
      self.description = description
      self.userprofile = userprofile
      self.likeCount = likeCount
      self.commentCount = commentCount
      self.hashTags = hashTags
      self.zipURL = zipURL
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}