//
//  SkinSettingViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/07.
//

import Foundation
import UIKit
import SwiftUI

class SkinSettingViewController: UIViewController {
    private var hostingController: UIHostingController<SkinSetting>?
    
    private var skinSettingVariables: [Int] = [0, 0, 0]
    
    private var mainOrSetting: Bool
    
    // Initializer to receive user data
    init(skinSettingVariables: [Int], mainOrSetting: Bool = false) {
        self.skinSettingVariables = skinSettingVariables
        self.mainOrSetting = mainOrSetting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for SkinSettingViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize your SwiftUI view
        let skinSettingView = SkinSetting(skinSetting: skinSettingVariables, MainOrSetting: mainOrSetting, onNavigate: navigateToMain)

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
    }
    
    func navigateToMain() {
        let profileVC = LumeHorizontalTabViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
