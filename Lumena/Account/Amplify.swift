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
    case invalidResetPassword
    case unknown
    case success

    var localizedDescription: String {
        switch self {
        case .signedInRequiresSMSCode:
            return "Sign-in requires SMS code."
        case .customChallengeRequired:
            return "Custom challenge required."
        case .newPasswordRequired:
            return "New password required."
        case .passwordResetRequired:
            return "Password reset required."
        case .confirmationRequired:
            return "Confirmation required."
        case .invalidResetPassword:
            return "Invalid username field input. Please enter valid user credential."
        case .unknown:
            return "Please enter valid login credentail or password."
        case .success:
            return "Success."
        }
    }
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
    
    private var fetchedAuth: Bool = false
    
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
    
    func signIn(username: String, password: String, manualAuthStat: Bool = false) async throws -> AuthError {
        do {
            
            // sign out when it is in signed in state to avoid double signin
            if authStatus == .authenticated {
                do {
                    let signOutResult = await AuthenticationManager.shared.signOut(fromSignIn: true)
                    switch signOutResult {
                    case .success(let message):
                        print(message)
                    case .failure(let error):
                        print(error)
                        throw error
                    }
                } catch {
                    print(error)
                }
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
                if !manualAuthStat {
                    self.authStatus = .authenticated
                }
                let _ = try await fetchAuthDetails(manualAuth: manualAuthStat)
                return .success
            case .confirmSignInWithTOTPCode, .continueSignInWithTOTPSetup(_), .continueSignInWithMFASelection(_):
                throw AuthError.unknown
            }
            
        } catch let authError as AuthError {
            messageLabel = authError.localizedDescription
            self.authStatus = .unauthenticated
            print("Sign-in failed: \(messageLabel)")
            throw authError
        } catch {
            let friendlyMessage = error.localizedDescription
            print("Sign-in failed: \(friendlyMessage)")
            messageLabel = "Sign-in failed: \(friendlyMessage)"
            throw AuthError.unknown
        }
    }
    
    func signOut(fromSignIn: Bool = false) async -> Result<String, Error> {
        let _ = await Amplify.Auth.signOut(options: .init(globalSignOut: true))
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.set("", forKey: "userIdentityID")
        DispatchQueue.main.async { [self] in
            if !fromSignIn {
                authStatus = .unauthenticated
            }
            identityID = ""
        }
        GI.shared.profileSettings = nil
        GI.shared.identityID = ""
        messageLabel = "Signed Out successful"
        return .success("Signed Out successful")
    }
    
    func signUp(username: String, password: String, email: String = "test@test.co.jp", givenName: String = "null", familyName: String = "null", preferredUsername: String = "null", pictureURL: String = "http://null.com", birthdate: String = "0000000", phoneNumber: String = "+810000000000") async throws -> String {
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
        
        // Attempt to fetch existing UserProfileQL
        do {
            let _ = try await ProfileManager.shared.getProfile(withID: identityID)
            let blockedUserIDs = try await GraphQL.shared.fetchBlockedUsers(userProfileID: identityID)
            ProfileManager.shared.blockedUsers = blockedUserIDs
            blockedUserIDs.printDetails()
            return "Successfully fetched ProfileSettings for the current user"
            
        } catch {
            print("UserProfileQL does not exist, proceeding to create a new profile.")
            do {
                guard let newProfile = try await generateNewProfile(identityID: identityID) else { return "Error: Could not generate new profile" }
                ProfileManager.shared.updateProfile(newProfile)
                return "Successfully generated ProfileSettings for the current user"
            } catch {
                print("Error: Could not generate new profile in fetchCognioUserAttributes - \(error)")
            }
            throw error
        }
    }
    
    private func generateNewProfile(identityID: String) async throws -> ProfileSettings? {
        do {
            let amplifyAttributes = try await Amplify.Auth.fetchUserAttributes()
            let newProfileSettings = ProfileSettings(from: amplifyAttributes)
            newProfileSettings.identityID = identityID
            do {
                try await newProfileSettings.fetchUserLumes()
                try await newProfileSettings.fetchUserImages()
            } catch {
                print("Error: Could not fetch user lumes and profile images")
            }
            // Try creating a new user profile
            if let _ = try await GraphQL.shared.createModel(newProfileSettings.toUserProfileQL()) {
                GI.shared.profileSettings = newProfileSettings
                print("Successfully created new UserProfileQL due to it being missing for the current user")
                return newProfileSettings
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unsuccessful in creating UserProfileQL for the current user"])
            }
        } catch {
            print("Error: Could not create new UserProfileQL in fetchCognitoUserAttributes - \(error)")
        }
        return nil
    }
    
    func deleteUser() async throws -> String {
        try await Amplify.Auth.deleteUser()
        self.authStatus = .unauthenticated
        return "Delete user successful."
    }

    func resetPassword(username: String) async throws -> String {
        do {
            let resetResult = try await Amplify.Auth.resetPassword(for: username)
            switch resetResult.nextStep {
            case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                return "Confirm reset password with code sent to - \(deliveryDetails) \(String(describing: info))"
            case .done:
                return "Reset code successfully sent"
            }
        } catch {
            print("Failed to reset Password")
            throw AuthError.invalidResetPassword
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
    
    func fetchAuthDetails(manualAuth: Bool = false) async throws -> String {
        
        if fetchedAuth {
            if let _ = identityID {
                DispatchQueue.main.async {
                    self.authStatus = .authenticated
                }
            }
            return "Already fetched auth details"
        }
        
        let session = try await Amplify.Auth.fetchAuthSession()

        if let identityProvider = session as? AuthCognitoIdentityProvider {
            _ = try identityProvider.getUserSub().get()
            let identityId = try identityProvider.getIdentityId().get()
            
            // Fetch user profile using identityID and save it in the cache
            do  {
                let _ = try await ProfileManager.shared.getProfile(withID: identityId)
            } catch {
                do {
                    _ = try await generateNewProfile(identityID: identityId)
                } catch {
                    print("Error: Could not generate new profile for \(identityId) - \(error)")
                }
            }
            
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            UserDefaults.standard.set(identityId, forKey: "userIdentityID")
            
            DispatchQueue.main.async {
                if !manualAuth {
                    self.authStatus = .authenticated
                }
                self.identityID = identityId
            }
            
            GI.shared.identityID = identityId
            AuthenticationManager.shared.identityID = identityId
            
            print("identityId: \(identityId)")
            
            Task {
                do {
                    _ = try await fetchCognitoUserAttributes()
                    fetchedAuth = true
                } catch {
                    print(error)
                }
                
                let user = try await Amplify.Auth.getCurrentUser().userId
                try await Amplify.Notifications.Push.identifyUser(userId: user)
            }
        }

        if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
            _ = try awsCredentialsProvider.getAWSCredentials().get()
        }

        if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
            _ = try cognitoTokenProvider.getCognitoTokens().get()
        }

        return AuthenticationManager.shared.identityID ?? ""
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
//
//enum APIError: Error {
//    case invalidURL
//    case encodingError
//    case noData
//    case requestFailed
//    case badResponse(Int)
//    case custom(Error)
//    case decodingError(Error?)
//}

enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case requestFailed
    case badResponse(Int)  // Include status code
    case custom(Error)     // Wrap other errors
    case decodingError(Error?)  // Optional underlying error
    case noData
    case noCosmeticsFound(String)
    case decodingFailed(String)
    
    // Localized error description for each case
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The provided URL is invalid."
        case .encodingError:
            return "There was an error encoding the data."
        case .requestFailed:
            return "The request to the server failed."
        case .badResponse(let statusCode):
            return "Received a bad response from the server. Status code: \(statusCode)."
        case .custom(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode the response. \(error?.localizedDescription ?? "Unknown error.")"
        case .noData:
            return "No data was returned from the server."
        case .noCosmeticsFound(let message):
            return message
        case .decodingFailed(let message):
            return message
        }
    }
    
    // Optionally, you could add a `recoverySuggestion` or `failureReason`
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please check the URL and try again."
        case .encodingError, .decodingError, .decodingFailed:
            return "Please ensure the data is in the correct format."
        case .requestFailed, .badResponse:
            return "Please check your network connection and try again."
        default:
            return nil
        }
    }
}


class GraphQL {
    
    static let shared = GraphQL()
    
    // Generic function for creating a model
    func createModel<ModelType: Model>(_ model: ModelType) async throws -> String? {
        do {
            let result = try await Amplify.API.mutate(request: .create(model))
            switch result {
            case .success(let createdModel):
                return "Successfully created \(ModelType.self): \(createdModel.identifier)"
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
//                                if let json = String(data: data, encoding: .utf8) {
//                                    print("Raw JSON received: \(json)")
//                                }
                
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
    
    func checkUserProfileQLImage(userIDs: [String]) async throws -> [UserProfileQL] {
        let idsString = userIDs.joined(separator: ",")
        guard let encodedIdsString = idsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error encoding IDs"])
        }
        
        let urlString = "https://snguusa35a.execute-api.ap-northeast-1.amazonaws.com/userProfilePresigned?ids=\(encodedIdsString)"
        
        let apiResponse: APIResponse<[UserProfileQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        return body
    }
    
    func fetchUserProfileQL(userIDs: [String]) async throws -> [UserProfileQL] {
        var userProfiles: [UserProfileQL] = []
        for userqlID in userIDs {
            do {
                guard let userProfileQL = try await GraphQL.shared.queryAmplify(for: UserProfileQL.self, modelID: userqlID) else {
                    print("Error in fetchUserProfileQL: At Guard")
                    continue
                }
                userProfiles.append(userProfileQL)
            } catch {
                print("Error in fetchUserProfileQL: [\(userqlID)] -> \(error)")
            }
        }
        return userProfiles
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
            throw APIError.noData
        }
        
        return body
    }
    
    func fetchUserFollowStat(followerId: String, followingId: String) async throws -> RelationshipType {
        
        let encodedFollowerId = followerId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedFollowingId = followingId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let urlString = "https://if0neqxq6g.execute-api.ap-northeast-1.amazonaws.com/UserFollowStatAPI?followerId=\(encodedFollowerId)&followingId=\(encodedFollowingId)"
        
        let apiResponse: APIResponse<RelationshipResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        return body.toRelationshipType()
    }
    
    func fetchRandomLumes() async throws -> [Lume] {
        let urlString = "https://lk1umc2vwc.execute-api.ap-northeast-1.amazonaws.com/randomReelReturnAPI?number=20?userId=\(GI.shared.identityID ?? "")"
        let apiResponse: APIResponse<[LumeQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        var lumes = body.map{Lume.init(ql:$0)}
        
        if let userIdentityID = GI.shared.identityID {
            
            do {
                let blockedUsers = try await ProfileManager.shared.returnBlockedUsers(forUserID: userIdentityID)
                let blockedUserIDs = Set(blockedUsers.blocked)
                let blockingUserIDs = Set(blockedUsers.blocking)
                
                lumes = lumes.filter { lume in
                    return !blockedUserIDs.contains(lume.postUserIID) && !blockingUserIDs.contains(lume.postUserIID)
                }
            } catch {
                print(error)
            }
        }
        return lumes
    }
    
    func fetchUserFollowingLumes() async throws -> [Lume] {
        guard let userIdentityID = GI.shared.identityID else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No identityID found for current user"])
        }
        let urlString = "https://ox5mdm7jc1.execute-api.ap-northeast-1.amazonaws.com/FollowingUserPosts?userId=\(userIdentityID)"
        let apiResponse: APIResponse<UserFollowingLumesResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
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
        
        print("fetchRandomCosmetic: called API")
        
        guard let body = apiResponse.body else {
            print("fetchRandomCosmetic: no Data")
            throw APIError.noData
        }
        
        print("fetchRandomCosmetic: mapping Cosmetic")
        let cosmetics = body.map{Cosmetic.init(ql:$0)}
        
        print("fetchRandomCosmetic: before Return")
        return cosmetics
    }
    
    func fetchCosmetic(cosmeticIDs: [String]) async throws -> [Cosmetic] {
        var cosmetics: [Cosmetic] = []
        for cosmeticQLID in cosmeticIDs {
            do {
                guard let cosmeticQL = try await GraphQL.shared.queryAmplify(for: CosmeticQL.self, modelID: cosmeticQLID) else {
                    print("Error in fetchMultipleReelQL: At Guard")
                    continue
                }
                let cosmetic = Cosmetic(ql: cosmeticQL)
                cosmetics.append(cosmetic)
            } catch {
                print("Error in fetchCosmetic: [\(cosmeticQLID)] -> \(error)")
            }
        }
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
            throw APIError.noData
        }
        
        let comments = body.comments.map { Comment.init(ql:$0) }
        return (comments, body.nextToken)
    }
    
    /*func updateUserProfile(profile: ProfileSettings) async throws -> String {
        let baseURL = "https://46qr4mtg3d.execute-api.ap-northeast-1.amazonaws.com/v1/updateUserProfile"
        
        let eyeColorWO = (profile.skinSetting?.eyeColor ?? "")//.replacingOccurrences(of: "#", with: "")
        let skinColorWO = (profile.skinSetting?.skinColor ?? "")//.replacingOccurrences(of: "#", with: "")
        
        let id = "id=\(profile.identityID)"
        let username = "username=\(profile.preferredUsername)"
        let DOB = "DOB=\(profile.birthDate)"  // Ensure DOB is a String
        let firstName = "firstName=\(profile.givenName)"
        let lockState = "lockState=\(profile.lockState)"
        let bio = "bio=\(profile.bio)"
        let skinSensitivity = "skinSensitivity=\(profile.skinSetting?.sensitivity.toGraphQL().rawValue ?? "")"
        let skinUVBathing = "skinUVBathing=\(profile.skinSetting?.uv.toGraphQL().rawValue ?? "")"
        let skinType = "skinType=\(profile.skinSetting?.skinType.toGraphQL().rawValue ?? "")"
        let skinPersonalColor = "skinPersonalColor=\(profile.skinSetting?.personalColor.toGraphQL().rawValue ?? "")"
        let skinEyeColor = "skinEyeColor=\(eyeColorWO)"
        let skinColor = "skinColor=\(skinColorWO)"
        let skinConcerns = "skinConcerns=\(profile.skinSetting?.concerns.toGraphQL().rawValue ?? "")"
        
        let queryString = "\(id)&\(username)&\(DOB)&\(firstName)&\(lockState)&\(bio)&\(skinSensitivity)&\(skinUVBathing)&\(skinType)&\(skinPersonalColor)&\(skinEyeColor)&\(skinColor)&\(skinConcerns)"
        
        let urlString = "\(baseURL)?\(queryString)"
        
        let apiResponse: APIResponse<String> = try await baseAPICall(urlString: urlString, httpMethod: "POST")
         
        guard let body = apiResponse.body else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No body got returned"])
        }
        return body
    }*/
    
    func updateUserProfile(profile: ProfileSettings) async throws {
        if let userProfile = try? await GraphQL.shared.fetchUserProfileQL(userIDs: [profile.identityID]).first {
            var newUserProfileQL = userProfile
            newUserProfileQL.username = profile.preferredUsername
            newUserProfileQL.DOB = Int(profile.birthDate.timeIntervalSince1970)
            newUserProfileQL.firstName = profile.givenName
            newUserProfileQL.lockState = profile.lockState
            newUserProfileQL.bio = profile.bio
            newUserProfileQL.skinSettings = profile.skinSetting.toUserProfileQLDictionary()
            
            do {
                try await GraphQL.shared.updateModel(newUserProfileQL)
            } catch {
                print(error)
            }
        }
    }
    
    func lumePostProcess(postID: String) async throws -> String {
        
        let urlString = "https://0la3k7elej.execute-api.ap-northeast-1.amazonaws.com/LumePostProcessAPI?postID=\(postID)"
        
        let apiResponse: APIResponse<String> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        return body
    }
    
    func likeLume(LumeID: String, identityID: String, likeUnlike: Bool = true) async throws -> Int {
        let action = likeUnlike ? "like" : "unlike"
        let urlString = "https://d8s36zcm3l.execute-api.ap-northeast-1.amazonaws.com/LikeReeQL?postId=\(LumeID)&userId=\(identityID)&action=\(action)"
        
        let apiResponse: APIResponse<LikeResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
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
            throw APIError.noData
        }
        
        let _: [()] = body.likes.map{ LumeManager.shared.getLumeQueue(withID: $0.lumeQLID) }
        return body
    }
    
    func searchUserLikedPost(userID: String, postId: String) async throws -> Bool {
        let encodedUserID = userID.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedPostId = postId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let urlString = "https://zuyt1hmvoa.execute-api.ap-northeast-1.amazonaws.com/SearchUserLikedPostAPI/?userId=\(encodedUserID)&postId=\(encodedPostId)"
        
        let apiResponse: APIResponse<SearchUserLikedResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        return body.likeExists
    }
    
    func followUser(currUserId: String, followUserId: String, followUnfollow: Bool = true) async throws -> String {
        let action = followUnfollow ? "follow" : "unfollow"
        let urlString = "https://q14qwpond6.execute-api.ap-northeast-1.amazonaws.com/FollowUserAPI?currUserId=\(currUserId)&followUserId=\(followUserId)&action=\(action)"
        let apiResponse: APIResponse<FollowUserResponse> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        return body.message
    }
    
    
    // MARK: -- API Doccument not updated from below
    
    func searchCosmeticQL(searchKeyword: String) async throws -> [Cosmetic] {
        let baseURL = "https://s853vsbclh.execute-api.ap-northeast-1.amazonaws.com/v1/searchCosmeticOpensearch"
        
        // Construct URL with query parameters
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: searchKeyword),
            URLQueryItem(name: "limit", value: "30"),
        ]
        
        // Ensure the URL is valid
        guard let urlString = components.string else {
            throw APIError.invalidURL
        }
        
        do {
            // Perform API call and decode response into APIResponse<[CosmeticQL]>
            let apiResponse: APIResponse<[CosmeticQL]> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
            
            // Check if the body of the response is present
            guard let body = apiResponse.body else {
                throw APIError.noData
            }
            
            // Return the converted cosmetics
            return body.map { Cosmetic(ql: $0) }
            
        } catch let decodingError as DecodingError {
            // Handle decoding error
            print("Decoding error: \(decodingError)")
            throw APIError.decodingError(decodingError)
            
        } catch let apiError as APIError {
            // Re-throw specific API errors for further handling
            throw apiError
            
        } catch let urlError as URLError {
            // Handle URL errors
            print("Request failed with error: \(urlError)")
            throw APIError.requestFailed
            
        } catch {
            // Handle other unexpected errors
            print("Unexpected error: \(error)")
            throw APIError.custom(error)
        }
    }
    
    func blockUser(blockuserprofileqlID: String, blockAction: BlockAction) async throws {
        // Base URL
        let baseURL = "https://t02im31sfe.execute-api.ap-northeast-1.amazonaws.com/v1/injectBlockUser"
        var components = URLComponents(string: baseURL)!

        
        guard let userProfileID = GI.shared.identityID else {
            print("Error: Could not get user identity ID in blockUser")
            throw APIError.invalidURL
        }
        // Adding query parameters
        components.queryItems = [
            URLQueryItem(name: "userprofileqlID", value: userProfileID),
            URLQueryItem(name: "blockeduserprofileqlID", value: blockuserprofileqlID),
            URLQueryItem(name: "action", value: blockAction.rawValue)
        ]

        // Ensure the URL is valid
        guard let urlString = components.string else {
            throw APIError.invalidURL
        }

        // Make the API call
        let apiResponse: APIResponse<APImessageStruct> = try await baseAPICall(urlString: urlString, httpMethod: "GET")

        // Handle no data scenario
        guard let _ = apiResponse.body else {
            throw APIError.noData
        }

        return
    }
    
    func fetchBlockedUsers(blockStatus: BlockFetch = .both, userProfileID: String) async throws -> BlockResultData {
        // Base URL
        let baseURL = "https://wm4n6altui.execute-api.ap-northeast-1.amazonaws.com/v1/fetchBlockUsers"
        var components = URLComponents(string: baseURL)!
        
        // Adding query parameters
        components.queryItems = [
            URLQueryItem(name: "userId", value: userProfileID),
            URLQueryItem(name: "fetchType", value: blockStatus.rawValue)
        ]
        
        // Ensure the URL is valid
        guard let urlString = components.string else {
            throw APIError.invalidURL
        }

        // Make the API call
        let apiResponse: APIResponse<BlockResultData> = try await baseAPICall(urlString: urlString, httpMethod: "GET")
        
        // Handle no data scenario
        guard let body = apiResponse.body else {
            throw APIError.noData
        }
        
        return body
    }
    
    func postCosmeticQLUploadProcess(cosmeticID: String) {
        Task {
            let baseURL = " https://vttvbc03bc.execute-api.ap-northeast-1.amazonaws.com/v1/processCosmeticQL"
            var components = URLComponents(string: baseURL)!
            
            // Adding query parameters
            components.queryItems = [
                URLQueryItem(name: "cosmeticqlID", value: cosmeticID)
            ]
            
            // Ensure the URL is valid
            guard let urlString = components.string else {
                throw APIError.invalidURL
            }
            
            // Make the API call
            let _ : APIResponse<String> = try await baseAPICall(urlString: urlString, httpMethod: "POST")
            
            
        }
    }
}
