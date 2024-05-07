//
//  AppDelegate.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/21.
//

import UIKit

import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
import AWSDataStorePlugin
import AWSPinpointPushNotificationsPlugin
import AVFAudio


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var authManager: AuthenticationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
        
        configureAmplify()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func configureAmplify() {
        do {
            // Set logging level
            Amplify.Logging.logLevel = .verbose
            
            // Add plugins
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: AmplifyModels()))
            try Amplify.add(plugin: AWSPinpointPushNotificationsPlugin(options: [.badge, .alert, .sound]))

            // Configure Amplify
            try Amplify.configure()
            
            print("Amplify configured successfully")

            // Initialize Authentication Manager
            authManager = AuthenticationManager.shared
            AuthenticationManager.shared.checkLocalAuthState()

            Task {
                let message = try await AuthenticationManager.shared.fetchAuthDetails()
                print("Success fetching fetchAuthDetails in configureAmplify: ", message)
                AuthenticationManager.shared.authStatus = .authenticated
            }
            
        } catch {
            print("Failed to initialize Amplify with \(error)")
            AuthenticationManager.shared.authStatus = .unauthenticated
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // Called when a user opens (taps or clicks) a notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        do {
            try await Amplify.Notifications.Push.recordNotificationOpened(response)
        } catch {
            print("Error recording notification opened: \(error)")
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        Task {
            do {
                try await Amplify.Notifications.Push.registerDevice(apnsToken: deviceToken)
                print("Registered with Pinpoint.")
            } catch {
                print("Error registering with Pinpoint: \(error)")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) async -> UIBackgroundFetchResult {
        
        do {
            try await Amplify.Notifications.Push.recordNotificationReceived(userInfo)
        } catch {
            print("Error recording receipt of notification: \(error)")
        }
        
        return .newData
    }
}


extension Notification.Name {
    static let authStatusChanged = Notification.Name("authStatusChanged")
}
