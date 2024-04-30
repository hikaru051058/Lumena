//
//  LoadingViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/21.
//

import Foundation
import UIKit
import SwiftUI

class LoadingViewController: UIViewController {
    private var hostingController: UIHostingController<LoadingView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let loadingView = LoadingView()

        hostingController = UIHostingController(rootView: loadingView)
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
        
        AuthenticationManager.shared.checkLocalAuthState()
        
        if AuthenticationManager.shared.authStatus == .authenticated {
            navigateToMain()
        } else if AuthenticationManager.shared.authStatus == .unauthenticated {
            navigateToLogin()
        }
    }
    
    func navigateToMain() {
        let mainVC = MainViewController()
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
    func navigateToLogin() {
        let profileVC = LoginViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
