//
//  Amplify.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/08/15.
//

import Foundation
import UIKit
import Combine

import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import AVFoundation

enum AuthError: Error {
    case signedInRequiresSMSCode
    case customChallengeRequired
    case newPasswordRequired
    case passwordResetRequired
    case confirmationRequired
    case unknown
    case success
}

enum AuthStatus {
    case authenticated, unauthenticated, loading
}

class AuthenticationManager: ObservableObject {
    
    static let shared = AuthenticationManager()
    
    @Published var authStatus: AuthStatus = .loading {
        didSet {
            NotificationCenter.default.post(name: .authStatusChanged, object: nil)
        }
    }
    
    @Published var identityID: String?
    var profileSettings: ProfileSettings?
    var userProfileQL: UserProfileQL?
    
    var messageLabel: String = ""
    
    init() {
        checkLocalAuthState()
    }

    func checkLocalAuthState() {
        let isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        if isAuthenticated {
            self.authStatus = .authenticated
        } else {
            self.authStatus = .unauthenticated
        }
        
        let userIdentityID = UserDefaults.standard.object(forKey: "userIdentityID") as? String
        if (userIdentityID != nil) {
            self.identityID = userIdentityID
            GI.shared.identityID = userIdentityID
        }
        
        print("Local Auth Status: \(self.authStatus), \(self.identityID ?? "nil")")
        
        Task {
            do {
                let result = try await fetchAuthDetails()
                print(result)
                // Request user permission for notifications.
                let options: UNAuthorizationOptions = [.badge, .alert, .sound]
                let notificationsAllowed = try await UNUserNotificationCenter.current().requestAuthorization(
                    options: options
                )
                print(notificationsAllowed)
            } catch {
                print(error)
            }
        }
    }
    
    func signIn(username: String, password: String) async throws -> AuthError {
        do {
            
            do {
                if authStatus == .authenticated {
                    let signOutResult = await AuthenticationManager.shared.signOut()
                    switch signOutResult {
                    case .success(let message):
                        print(message)
                    case .failure(let error):
                        print(error)
                        throw error
                    }
                }
            } catch {
                print(error)
            }
                

            let signInResult = try await Amplify.Auth.signIn(username: username, password: password)
            
            switch signInResult.nextStep {
            case .confirmSignInWithSMSMFACode(_, _):
                throw AuthError.signedInRequiresSMSCode
            case .confirmSignInWithCustomChallenge(_):
                throw AuthError.customChallengeRequired
            case .confirmSignInWithNewPassword(_):
                throw AuthError.newPasswordRequired
            case .resetPassword(_):
                throw AuthError.passwordResetRequired
            case .confirmSignUp(_):
                print("Complete confirm sign up")
                throw AuthError.confirmationRequired
            case .done:
                print("Signin complete")
                messageLabel = "Signed In successful"
                
                let result = try await fetchAuthDetails()
                print(result)
                
                return .success
            case .confirmSignInWithTOTPCode, .continueSignInWithTOTPSetup(_), .continueSignInWithMFASelection(_):
                throw AuthError.unknown
            }
        } catch let error as AuthError {
            print("Sign in failed: \(error)")
            messageLabel = "Sign in failed: \(error)"
            throw error
        } catch {
            print("Unexpected error in signIn: \(error)")
            messageLabel = "Unexpected error in signIn: \(error)"
            throw error
        }
    }
    
    func signOut() async -> Result<String, Error> {
        let _ = await Amplify.Auth.signOut(options: .init(globalSignOut: true))
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set("", forKey: "userIdentityID")
        DispatchQueue.main.async { [self] in
            authStatus = .unauthenticated
            identityID = ""
        }
        GI.shared.profileSettings = nil
        GI.shared.identityID = ""
        messageLabel = "Signed Out successful"
        return .success("Signed Out successful")
    }
    
    func signUp(username: String, password: String, email: String = "test@test.co.jp", givenName: String = "null", familyName: String = "null", preferredUsername: String = "null", pictureURL: String = "http://null.com", birthdate: String = "01/01/1001", phoneNumber: String = "+810000000000") async throws -> String {
        let userAttributes: [AuthUserAttribute] = [
            .init(.email, value: email),
            .init(.givenName, value: givenName),
            .init(.familyName, value: familyName),
            .init(.preferredUsername, value: preferredUsername),
            .init(.picture, value: pictureURL),
            .init(.birthDate, value: birthdate),
            .init(.phoneNumber, value: phoneNumber)
        ]
        
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        let signUpResult = try await Amplify.Auth.signUp(username: username, password: password, options: options)
        
        switch signUpResult.nextStep {
        case .confirmUser(let deliveryDetails, _, let userId):
            messageLabel = "Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))"
            GI.shared.profileSettings?.preferredUsername = username
            return "Confirmation code sent"
        default:
            return "SignUp Complete"
        }
    }
    
    func resendCode(username: String, password: String) async throws -> String {
        let deliveryDetails = try await Amplify.Auth.sendVerificationCode(forUserAttributeKey: .email)
        return "Resend code sent to - \(deliveryDetails)"
    }

    
    func confirmSignUp(username: String, confirmationCode: String) async throws {
        do {
            let _ = try await Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode)
            return
        } catch {
            throw error
        }
    }
    
    func fetchCognitoUserAttributes() async throws -> String {
        guard let identityID = identityID else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Missing identityID in fetchCognitoUserAttributes"])
        }

        print("identityID: \(identityID)")
        // Attempt to fetch existing UserProfileQL
        do {
            let userProfileQL = try await GraphQL.shared.queryAmplify(for: UserProfileQL.self, modelID: identityID)
            // If the user profile exists, initialize ProfileSettings with the fetched data
            if let userProfileQL = userProfileQL {
                let profileSettings = ProfileSettings(ql: userProfileQL)
                profileSettings.identityID = identityID
                GI.shared.profileSettings = profileSettings
                print("Successfully fetched UserProfileQL of the current user in DynamoDB")
                return "Successfully fetched ProfileSettings for the current user"
            }
            
            return "Error: Unknown error occured in fetchCognitoUserAttributes"
            
        } catch {
            print("UserProfileQL does not exist, proceeding to create a new profile.")
            // Fetch user attributes from Amplify/Auth
            let amplifyAttributes = try await Amplify.Auth.fetchUserAttributes()
            let newProfileSettings = ProfileSettings(from: amplifyAttributes)
            newProfileSettings.identityID = identityID
            try await newProfileSettings.fetchUserLumes()
            try await newProfileSettings.fetchUserImages()

            // Try creating a new user profile
            if let _ = try await GraphQL.shared.createModel(newProfileSettings.toUserProfileQL()) {
                GI.shared.profileSettings = newProfileSettings
                print("Successfully created new UserProfileQL due to it being missing for the current user")
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unsuccessful in creating UserProfileQL for the current user"])
            }
            
            throw error
        }
    }
    
    func deleteUser() async throws -> String {
        try await Amplify.Auth.deleteUser()
        return "Delete user successful."
    }

    func resetPassword(username: String) async throws -> String {
        let resetResult = try await Amplify.Auth.resetPassword(for: username)
        switch resetResult.nextStep {
        case .confirmResetPasswordWithCode(let deliveryDetails, let info):
            return "Confirm reset password with code sent to - \(deliveryDetails) \(String(describing: info))"
        case .done:
            return "Reset code successfully sent"
        }
    }

    func confirmResetPassword(username: String, newPassword: String, confirmationCode: String) async throws -> String {
        try await Amplify.Auth.confirmResetPassword(for: username, with: newPassword, confirmationCode: confirmationCode)
        return "Reset completed"
    }

    
    func updateUserAttributes(attributeName: AuthUserAttributeKey, value: String) async throws -> String {
        if let userProfileQLToUpdate = GI.shared.profileSettings?.toUserProfileQL() {
            try await GI.shared.profileSettings?.updateUserProfileQL()
            let result = try await GraphQL.shared.createModel(userProfileQLToUpdate)
            print(result ?? "")
        }

        let updateResult = try await Amplify.Auth.update(userAttribute: AuthUserAttribute(attributeName, value: value))
        switch updateResult.nextStep {
        case .confirmAttributeWithCode(let deliveryDetails, let info):
            return "Confirm the attribute with details sent to - \(deliveryDetails) \(info!)"
        case .done:
            return "Successfully updated amplify attributes: \(attributeName)"
        }
    }
    
    func fetchAuthDetails() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()

        if let identityProvider = session as? AuthCognitoIdentityProvider {
            _ = try identityProvider.getUserSub().get()
            let identityId = try identityProvider.getIdentityId().get()
            
            // Fetch user profile using identityID and save it in the cache
            Task {
                do  {
                    let _ = try await ProfileManager.shared.getProfile(withID: identityId)
                } catch {
                    let amplifyAttributes = try await Amplify.Auth.fetchUserAttributes()
                    let newProfileSettings = ProfileSettings(from: amplifyAttributes)
                    newProfileSettings.identityID = identityId
                    
                    let newUserStateQL = UserStateQL(UserState: .active, timestamp: Int(Date.timeIntervalSinceReferenceDate), reason: "fetchAuth acc", userprofileqlID: identityId)
                    do {
                        let message = try await GraphQL.shared.createModel(newUserStateQL)
                        print(message as Any)
                    } catch {
                        print("Error in creating UserStateQL: \(error)")
                    }
                    
                    // Save the newly created profile to the database
                    let _ = try await GraphQL.shared.createModel(newProfileSettings.toUserProfileQL())
                }
            }
            
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            UserDefaults.standard.set(identityId, forKey: "userIdentityID")
            
            DispatchQueue.main.async {
                self.authStatus = .unauthenticated
                self.identityID = identityId
            }
            
            GI.shared.identityID = identityId
            
            do {
                let result = try await fetchCognitoUserAttributes()
                print(result)
            } catch {
                print(error)
            }
        
            let user = try await Amplify.Auth.getCurrentUser().userId
            try await Amplify.Notifications.Push.identifyUser(userId: user)
        }

        if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
            _ = try awsCredentialsProvider.getAWSCredentials().get()
        }

        if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
            _ = try cognitoTokenProvider.getCognitoTokens().get()
        }

        return "Auth details fetched successfully."
    }
}

class S3 {
    
    static let shared = S3()
    
    /// Upload an image to S3 and provide the URL back via a completion handler.
    /// - Parameters:
    ///   - imageData: The image data to upload.
    ///   - completion: A callback with the resulting URL or an error.
    
    //MARK: - private
    func storeData(name: String, data: Data, accessLevel: String = "private", progressHandler: @escaping (Double) -> Void, completionHandler: @escaping (Result<String, StorageError>) -> Void) {
        let path = name
        let options = StorageUploadDataRequest.Options()
        let uploadTask = Amplify.Storage.uploadData(
            key: path,
            data: data,
            options: options
        )

        Task {
            var lastReportedProgress: Double = 0
            for await progress in await uploadTask.progress {
                // Throttle progress updates to reduce the frequency of updates
                if progress.fractionCompleted - lastReportedProgress > 0.05 || progress.fractionCompleted == 1.0 {
                    lastReportedProgress = progress.fractionCompleted
                    progressHandler(progress.fractionCompleted)
                }
            }
            do {
                let data = try await uploadTask.value
                print("Upload completed: \(data)")
                completionHandler(.success(name))
            } catch {
                if let storageError = error as? StorageError {
                    print("Upload failed: \(storageError.localizedDescription).")
                    completionHandler(.failure(storageError))
                } else {
                    print("Upload failed: \(error).")
                    // Convert the error to your StorageError or a custom error type if needed
                    completionHandler(.failure(StorageError.unknown("Unknown error occurred during upload.")))
                }
            }
        }
    }
    
    func storeDataAsync(name: String, data: Data, accessLevel: String = "private", progressHandler: @escaping (Double) -> Void) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            // Call the original storeData function inside the continuation.
            self.storeData(name: name, data: data, accessLevel: accessLevel, progressHandler: progressHandler) { result in
                switch result {
                case .success(let name):
                    continuation.resume(returning: name)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func retrieveData<T: Decodable>(name: String, accessLevel: String = "private", dataType: T.Type) async throws -> T? {
        let path = name
        let options = StorageDownloadDataRequest.Options()
        do {
            let data = try await Amplify.Storage.downloadData(key: path, options: options).value
            print("\(String(describing: dataType)) \(name) loaded")
            if dataType == UIImage.self, let image = UIImage(data: data) {
                return image as? T
            } else {
                print("Data could not be converted to \(dataType)")
                return nil
            }
        } catch {
            print("Cannot download \(String(describing: dataType)): \(error).")
            throw error
        }
    }

    func deleteData(name: String) async throws -> String {
        let options = StorageRemoveRequest.Options(accessLevel: .private)
        do {
            let key = try await Amplify.Storage.remove(key: name, options: options)
            print("Image \(key) deleted")
            return key
        } catch {
            print("Cannot delete image: \(error).")
            throw error
        }
    }
}


enum MediaType: String {
    case image = "Image"
    case video = "Video"
}


struct APIResponse<T: Decodable>: Decodable {
    let statusCode: Int
    let body: T?

    enum CodingKeys: String, CodingKey {
        case statusCode, body
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
        
        // If T is a type that can decode directly from a String, handle it accordingly
        if T.self == String.self {
            body = try container.decode(T.self, forKey: .body)
        } else {
            let bodyString = try container.decode(String.self, forKey: .body)
            guard let bodyData = bodyString.data(using: .utf8) else {
                throw DecodingError.dataCorruptedError(forKey: .body, in: container, debugDescription: "Cannot decode body string to data")
            }
            body = try JSONDecoder().decode(T.self, from: bodyData)
        }
    }
}

struct APImessageStruct: Decodable {
    let message: String

    enum CodingKeys: String, CodingKey {
        case message
    }
}



enum APIError: Error {
    case invalidURL
    case encodingError
    case noData
    case badResponse(Int)
    case custom(Error)
    case decodingError(Error?)
}


class GraphQL {
    
    static let shared = GraphQL()
    
    // Generic function for creating a model
    func createModel<ModelType: Model>(_ model: ModelType) async throws -> String? {
        do {
            let result = try await Amplify.API.mutate(request: .create(model))
            switch result {
            case .success(let createdModel):
                return "Successfully created \(ModelType.self): \(createdModel)"
            case .failure(let graphQLError):
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Failed to create graphql \(graphQLError)"])
            }
        } catch let error as APIError {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Failed to create \(ModelType.self) - \(error)"])
        } catch {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unexpected error in createModel: \(error)"])
        }
    }
    
    // Generic function for updating a model
    func updateModel<ModelType: Model>(_ model: ModelType) async throws {
        do {
            let result = try await Amplify.API.mutate(request: .update(model))
            switch result {
                
            case .success(_):
                print("Successfully updated \(ModelType.self)")
                return
            case .failure(let error):
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Got failed result with \(error.errorDescription)"])
            }
        } catch let error as APIError {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error: Failed to update \(ModelType.self) - \(error)"])
        } catch {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error: Unexpected error in updateModel: \(error)"])
        }
    }
    
    // Generic function for deleting a model
    func deleteModel<ModelType: Model>(_ model: ModelType) async throws {
        do {
            let result = try await Amplify.API.mutate(request: .delete(model))
            switch result {
            case .success(let deletedModel):
                print("Successfully deleted \(ModelType.self): \(deletedModel)")
                return
            case .failure(let error):
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Got failed result with \(error.errorDescription)"])
            }
        } catch let error as APIError {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to delete \(ModelType.self) - \(error)"])
        } catch {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error in deleteModel: \(error)"])
        }
    }
    
    func queryAmplify<ModelType: Model>(for modelType: ModelType.Type, modelID: String) async throws -> ModelType? {
        do {
            let result = try await Amplify.API.query(
                request: .get(modelType.self, byId: modelID)
            )
            switch result {
            case .success(let model):
                guard let model = model else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find model of type \(ModelType.self)"])
                }
                print("Successfully retrieved model using return: \(model.identifier)")
                return model
            case .failure(let error):
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Got failed result with \(error)"])
            }
        } catch let error as APIError {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to query \(ModelType.self) - \(error)"])
        } catch {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected error in queryAmplify returnModelType: \(modelID) \(error)"])
        }
    }
    
    func baseAPICall<T: Decodable>(urlString: String, httpMethod: String = "GET") async throws -> APIResponse<T> {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: APIError.custom(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    continuation.resume(throwing: APIError.noData)
                    return
                }
                
                // Debug: Print raw JSON string
//                if let json = String(data: data, encoding: .utf8) {
//                    print("Raw JSON received: \(json)")
//                }
                
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let apiResponse = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                        continuation.resume(returning: apiResponse)
                    } catch let decodingError as DecodingError {
                        self.printDecodingError(decodingError, for: T.self)
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            print("Decodable JSON: \(json)")
                        } catch {
                            print(error)
                        }
                        continuation.resume(throwing: APIError.decodingError(decodingError))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case 204:
                    continuation.resume(throwing: APIError.noData)
                default:
                    continuation.resume(throwing: APIError.badResponse(httpResponse.statusCode))
                }
            }
            task.resume()
        }
    }
    
    func printDecodingError<T>(_ error: DecodingError, for type: T.Type) {
        let errorDescription: String
        switch error {
        case .typeMismatch(let type, let context):
            errorDescription = "Type mismatch for type \(type) with context \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            errorDescription = "Value not found for type \(type) with context \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            errorDescription = "Key '\(key.stringValue)' not found with context \(context.debugDescription)"
        case .dataCorrupted(let context):
            errorDescription = "Data corrupted with context \(context.debugDescription)"
        @unknown default:
            errorDescription = "Unknown decoding error"
        }
        print("Decoding error for model \(T.self): \(errorDescription)")
    }


    func fetchDistributionURL(s3Keys: [String] = []) async throws -> [String] {
        let idsString = s3Keys.joined(separator: ",")
        guard let encodedIdsString = idsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: "/", with: "%2F") else {
            throw APIError.encodingError
        }
        
        let urlString = "https://dwzwfnb5i8.execute-api.ap-northeast-1.amazonaws.com/DistributionURLKeyStage?ids=\(encodedIdsString)"
        
        let apiResponse: APIResponse<[String]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        return body
    }
    
    func fetchUserLumas(userProfileID: String) async throws -> [String] {
        let urlString = "https://f95ph0rite.execute-api.ap-northeast-1.amazonaws.com/UserLumas?id=\(userProfileID)"
        
        let apiResponse: APIResponse<[LumeQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        _ = body.map{Lume.init(ql:$0)}
        let lumeIDs = body.map{ $0.id }
        return lumeIDs
    }
    
    func fetchSingleReelQL(reelQLId: String) async throws -> Lume {
        do {
            guard let lumeQL = try await GraphQL.shared.queryAmplify(for: LumeQL.self, modelID: reelQLId) else {
                throw NSError(domain: "fetchSingleReelQL", code: 404, userInfo: [NSLocalizedDescriptionKey: "LumeQL not found for ID: \(reelQLId)"])
            }
            let lume = Lume(ql: lumeQL)
            LumeManager.shared.setNewLume(lume)
            
            return lume
            
        } catch {
            print("Error in fetchSingleReelQL: [\(reelQLId)] -> \(error)")
            throw error
        }
    }
    
    func fetchMultipleReelQL(reelQLIds: [String]) async throws -> [Lume] {
        var lumes: [Lume] = []
        for reelQLID in reelQLIds {
            do {
                guard let lumeQL = try await GraphQL.shared.queryAmplify(for: LumeQL.self, modelID: reelQLID) else {
                    print("Error in fetchMultipleReelQL: At Guard")
                    continue
                }
                let lume = Lume(ql: lumeQL)
                lumes.append(lume)
                LumeManager.shared.setNewLume(lume)
            } catch {
                print("Error in fetchMultipleReelQL: [\(reelQLID)] -> \(error)")
            }
        }
        return lumes
    }
    
    func fetchUserProfileQL(userIDs: [String]) async throws -> [UserProfileQL] {
        let idsString = userIDs.joined(separator: ",")
        guard let encodedIdsString = idsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error encoding IDs"])
        }
        
        let urlString = "https://snguusa35a.execute-api.ap-northeast-1.amazonaws.com/userProfilePresigned?ids=\(encodedIdsString)"
        let apiResponse: APIResponse<[UserProfileQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        return body
    }
    
    func fetchUserFollow(userID: String, relationshipType: RelationshipType, limit: Int, lastFollowingToken: String = "", lastFollowerToken: String = "") async throws -> FollowResponse {
        let encodedUserID = userID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let relationshipTypeString = relationshipType.stringValue()
        let encodedRelationshipType = relationshipTypeString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "both"
        let encodedLastFollowingToken = lastFollowingToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedLastFollowerToken = lastFollowerToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        var urlString = "https://k7oxva88df.execute-api.ap-northeast-1.amazonaws.com/UserFollowReturnAPI?userId=\(encodedUserID)&fetchType=\(encodedRelationshipType)&limit=\(limit)"
        
        if !lastFollowingToken.isEmpty {
            urlString += "&lastFollowingToken=\(encodedLastFollowingToken)"
        }
        if !lastFollowerToken.isEmpty {
            urlString += "&lastFollowerToken=\(encodedLastFollowerToken)"
        }
        
        let apiResponse: APIResponse<FollowResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body
    }
    
    func fetchUserFollowStat(followerId: String, followingId: String) async throws -> RelationshipType {
        
        let encodedFollowerId = followerId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedFollowingId = followingId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""

        let urlString = "https://if0neqxq6g.execute-api.ap-northeast-1.amazonaws.com/UserFollowStatAPI?followerId=\(encodedFollowerId)&followingId=\(encodedFollowingId)"
        
        let apiResponse: APIResponse<RelationshipResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body.toRelationshipType()
    }
    
    func fetchRandomLumes() async throws -> [Lume] {
        let urlString = "https://lk1umc2vwc.execute-api.ap-northeast-1.amazonaws.com/randomReelReturnAPI?number=20"
        let apiResponse: APIResponse<[LumeQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let lumes = body.map{Lume.init(ql:$0)}
        return lumes
    }
    
    func fetchUserFollowingLumes() async throws -> [Lume] {
        guard let userIdentityID = GI.shared.identityID else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No identityID found for current user"])
        }
        let urlString = "https://ox5mdm7jc1.execute-api.ap-northeast-1.amazonaws.com/FollowingUserPosts?userId=\(userIdentityID)"
        let apiResponse: APIResponse<UserFollowingLumesResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let lumesID = body.lumes.flatMap { $0.items }.map { $0.id }
        var lumes: [Lume] = []
        do {
            lumes = try await LumeManager.shared.getLumes(withID: lumesID)
        } catch {
            print(error)
            lumes = body.lumes.flatMap { $0.items }.map { Lume(id: $0.id) }
        }
        return lumes
    }
    
    func fetchRandomCosmetic() async throws -> [Cosmetic] {
        let urlString = "https://tyipo1o3a5.execute-api.ap-northeast-1.amazonaws.com/RandomCosmeticReturnStage?number=20"
        let apiResponse: APIResponse<[CosmeticQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let cosmetics = body.map{Cosmetic.init(ql:$0)}
        return cosmetics
    }
    
    func fetchCosmetic(cosmeticID: [String]) async throws -> [Cosmetic] {
        let idsString = cosmeticID.joined(separator: ",")
        guard let encodedIdsString = idsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error encoding IDs"])
        }
        let urlString = "https://i4raksfhi2.execute-api.ap-northeast-1.amazonaws.com/CosmeticQLReturn?id=\(encodedIdsString)"
        let apiResponse: APIResponse<[CosmeticQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let cosmetics = body.map{Cosmetic.init(ql:$0)}
        return cosmetics
    }

    func fetchLumeComments(LumeID: String, commentLimit: Int, lastToken: String = "") async throws -> ([Comment], String?) {
        let encodedLumeID = LumeID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedLastToken = lastToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        var urlString = "https://rm4kk4o6t0.execute-api.ap-northeast-1.amazonaws.com/ReelQLCommentQLfetchStage?id=\(encodedLumeID)&limit=\(commentLimit)"
        
        if !lastToken.isEmpty {
            urlString += "&lastToken=\(encodedLastToken)"
        }
        
        let apiResponse: APIResponse<CommentResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let comments = body.comments.map { Comment.init(ql:$0) }
        return (comments, body.nextToken)
    }

    
    func updateUserProfile(profile: ProfileSettings) async throws -> String {
        let baseURL = "https://is1w47fcab.execute-api.ap-northeast-1.amazonaws.com/UpdateUserProfileQLAPI"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "id", value: profile.identityID),
            URLQueryItem(name: "username", value: profile.preferredUsername),
            URLQueryItem(name: "firstName", value: profile.givenName),
            URLQueryItem(name: "Sensitivity", value: "\(profile.skinSetting[0])"),
            URLQueryItem(name: "SunBathing", value: "\(profile.skinSetting[1])"),
            URLQueryItem(name: "SkinType", value: "\(profile.skinSetting[2])"),
            URLQueryItem(name: "lockState", value: "\(profile.lockState)"),
            URLQueryItem(name: "Bio", value: profile.bio)
        ]
        
        guard let urlString = components.string else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
        }
        
        let apiResponse: APIResponse<String> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body
    }
    
    func lumePostProcess(postID: String) async throws -> String {
        
        let urlString = "https://0la3k7elej.execute-api.ap-northeast-1.amazonaws.com/LumePostProcessAPI?postID=\(postID)"
        
        let apiResponse: APIResponse<String> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body
    }
    
    func likeLume(LumeID: String, identityID: String, likeUnlike: Bool = true) async throws -> Int {
        let action = likeUnlike ? "like" : "unlike"
        let urlString = "https://d8s36zcm3l.execute-api.ap-northeast-1.amazonaws.com/LikeReeQL?postId=\(LumeID)&userId=\(identityID)&action=\(action)"
        
        let apiResponse: APIResponse<LikeResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body.data.likeCount
    }
    
    func fetchUserLikedPosts(userID: String, limit: Int = 10, lastToken: String = "") async throws -> UserLikedPostsResponse {
        let encodedUserID = userID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedLastToken = lastToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        var urlString = "https://0znz3e18ba.execute-api.ap-northeast-1.amazonaws.com/FetchUserLikedPostsStage?userId=\(encodedUserID)&limit=\(limit)"
        
        if !lastToken.isEmpty {
            urlString += "&lastToken=\(encodedLastToken)"
        }
        
        // Make the API call and decode the response as LikesResponse
        let apiResponse: APIResponse<UserLikedPostsResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let _: [()] = body.likes.map{ LumeManager.shared.getLumeQueue(withID: $0.lumeQLID) }
        return body
    }
    
    func SearchUserLikedPost(userID: String, postId: String) async throws -> Bool {
        let encodedUserID = userID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedPostId = postId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let urlString = "https://zuyt1hmvoa.execute-api.ap-northeast-1.amazonaws.com/SearchUserLikedPostAPI/?userId=\(encodedUserID)&postId=\(encodedPostId)"
        
        let apiResponse: APIResponse<SearchUserLikedResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body.likeExists
    }

    func followUser(currUserId: String, followUserId: String, followUnfollow: Bool = true) async throws -> String {
        let action = followUnfollow ? "follow" : "unfollow"
        let urlString = "https://q14qwpond6.execute-api.ap-northeast-1.amazonaws.com/FollowUserAPI?currUserId=\(currUserId)&followUserId=\(followUserId)&action=\(action)"
        let apiResponse: APIResponse<FollowUserResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        return body.message
    }
    
    func searchCosmeticQL(searchKeyword: String) async throws -> [Cosmetic] {
        
        let baseURL = "https://os9xlcvkn2.execute-api.ap-northeast-1.amazonaws.com/prod/search"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: searchKeyword),
        ]
        
        guard let urlString = components.string else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: nil)
        }
        
        let apiResponse: APIResponse<[CosmeticQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        
        let cosmeticArr = body.map{ Cosmetic(ql: $0) }
        return cosmeticArr
    }
}
