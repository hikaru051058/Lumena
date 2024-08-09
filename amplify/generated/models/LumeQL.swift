// swiftlint:disable all
import Amplify
import Foundation

public struct LumeQL: Model {
  public let id: String
  public var postURL: [String]?
  public var timestamp: Int
  public var tagProducts: [TagCosmeticQL]?
  public var tagMusic: TagTrackQL?
  public var description: String?
  public var userprofileqlID: String
  public var userprofileql: UserProfileQL?
  public var likeCount: Int?
  public var commentCount: Int?
  public var hashTags: [String]?
  public var zipURL: String?
  public var lumeAuth: Bool?
  public var voiceOverURL: [String]?
  
  public init(id: String = UUID().uuidString,
      postURL: [String]? = [],
      timestamp: Int,
      tagProducts: [TagCosmeticQL]? = [],
      tagMusic: TagTrackQL? = nil,
      description: String? = nil,
      userprofileqlID: String,
      userprofileql: UserProfileQL? = nil,
      likeCount: Int? = nil,
      commentCount: Int? = nil,
      hashTags: [String]? = [],
      zipURL: String? = nil,
      lumeAuth: Bool? = nil,
      voiceOverURL: [String]? = []) {
      self.id = id
      self.postURL = postURL
      self.timestamp = timestamp
      self.tagProducts = tagProducts
      self.tagMusic = tagMusic
      self.description = description
      self.userprofileqlID = userprofileqlID
      self.userprofileql = userprofileql
      self.likeCount = likeCount
      self.commentCount = commentCount
      self.hashTags = hashTags
      self.zipURL = zipURL
      self.lumeAuth = lumeAuth
      self.voiceOverURL = voiceOverURL
  }
}