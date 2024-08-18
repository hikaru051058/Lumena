//
//  SkinSettingViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/07.
//

import Foundation
import UIKit
import SwiftUI

protocol SkinSettingViewControllerDelegate: AnyObject {
    func skinSettingViewControllerDidDismiss(_ skinSettings: SkinSettingsAttributes)
}

// ObservableObject class for skin settings
class SkinSettingsModel: ObservableObject {
    @Published var skinSettings: SkinSettingsAttributes

    init(skinSettings: SkinSettingsAttributes) {
        self.skinSettings = skinSettings
    }
}

class SkinSettingViewController: UIViewController {
    private var hostingController: UIHostingController<SkinSetting>?
    // false = jump to main view , true = setting
    var profile: ProfileSettings
    private var skinSettingsModel: SkinSettingsModel
    var mainOrSetting: Bool
    
    weak var delegate: SkinSettingViewControllerDelegate?

    init(profile: ProfileSettings, mainOrSetting: Bool = false) {
        self.profile = profile
        self.mainOrSetting = mainOrSetting
        self.skinSettingsModel = SkinSettingsModel(skinSettings: profile.skinSetting ?? SkinSettingsAttributes())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for SkinSettingViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize your SwiftUI view
        let skinSettingView = SkinSetting(skinSettingsModel: skinSettingsModel, MainOrSetting: mainOrSetting, onNavigate: navigateToMain)

        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: skinSettingView)
        
        // Add the hosting controller as a child view controller
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Setup constraints for layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
        
        if !mainOrSetting {
            // Disable the interactive pop gesture to prevent swiping back
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Notify delegate when view controller is dismissed
        if isMovingFromParent || isBeingDismissed {
            print("ProfileSettingsDelegate: @SkinSettingViewController -> \(self.skinSettingsModel.skinSettings)")
            delegate?.skinSettingViewControllerDidDismiss(self.skinSettingsModel.skinSettings)
        }
    }
    
    func navigateToMain() {
        Task {
            do {
                let _ = try await AuthenticationManager.shared.fetchAuthDetails()
            } catch {
                print(error)
            }
        }
    }
}
