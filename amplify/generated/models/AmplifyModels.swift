// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "1665957827e68d2be7fc0108ff560888"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: FollowQL.self)
    ModelRegistry.register(modelType: LikedLumeQL.self)
    ModelRegistry.register(modelType: CommentQL.self)
    ModelRegistry.register(modelType: CosmeticQL.self)
    ModelRegistry.register(modelType: LumeQL.self)
    ModelRegistry.register(modelType: UserProfileQL.self)
  }
}