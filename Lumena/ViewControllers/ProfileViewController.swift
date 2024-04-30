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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize your SwiftUI view
        var profileView = Profile()
        
        // Initialize your SwiftUI view
        profileView.onNavigate = navigateToLogin // Passing the navigation action to SwiftUI

        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: profileView)
        
        // Add the hosting controller as a child view controller
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Setup constraints for layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }
    
    func navigateToLogin() {
        let profileVC = LoginViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
