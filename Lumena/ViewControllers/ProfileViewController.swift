//
//  ProfileViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/24.
//

import Foundation
import UIKit
import SwiftUI

class ProfileViewController: UIViewController {
    private var hostingController: UIHostingController<Profile>?
    
    private var skinSettingVariables: [Int]
    private var mainOrSetting: Bool
    
    // Initializer to receive user data
    init(skinSettingVariables: [Int] = [0,0,0], mainOrSetting: Bool = true) {
        self.skinSettingVariables = skinSettingVariables
        self.mainOrSetting = mainOrSetting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for ProfileViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize your SwiftUI view
        var profileView = Profile()
        
        // Initialize your SwiftUI view
        profileView.onNavigate = navigateToLogin
        profileView.onNavigateSkinSetting = navigateSkinSetting

        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: profileView)
        
        // Add the hosting controller as a child view controller
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Setup constraints for layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }
    
    func navigateToLogin() {
        let profileVC = LoginViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func navigateSkinSetting(skinSetting: [Int] = [0,0,0], mainOrSetting: Bool = true) {
        let skinSettingVC = SkinSettingViewController(skinSettingVariables: skinSetting, mainOrSetting: mainOrSetting)
        navigationController?.pushViewController(skinSettingVC, animated: true)
    }
}

extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
