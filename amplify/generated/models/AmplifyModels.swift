// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "a4a915a3828b6675957c0115044e2f2e"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: CosmeticSearchIndex.self)
    ModelRegistry.register(modelType: IngredientQL.self)
    ModelRegistry.register(modelType: CosmeticBrandQL.self)
    ModelRegistry.register(modelType: NotificationQL.self)
    ModelRegistry.register(modelType: InvitationOrganizationQL.self)
    ModelRegistry.register(modelType: InvitationQL.self)
    ModelRegistry.register(modelType: BlockQL.self)
    ModelRegistry.register(modelType: LumeStateQL.self)
    ModelRegistry.register(modelType: UserStateQL.self)
    ModelRegistry.register(modelType: FollowQL.self)
    ModelRegistry.register(modelType: LikedLumeQL.self)
    ModelRegistry.register(modelType: CommentQL.self)
    ModelRegistry.register(modelType: CosmeticQL.self)
    ModelRegistry.register(modelType: LumeQL.self)
    ModelRegistry.register(modelType: UserProfileQL.self)
  }
}