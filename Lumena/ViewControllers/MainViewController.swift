//
//  MainViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/21.
//

import Foundation
import UIKit
import SwiftUI

class MainViewController: UIViewController {
    private var hostingController: UIHostingController<Main>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        // Initialize your SwiftUI view
        var mainView = Main()
        mainView.onNavigate = navigateToProfile // Passing the navigation action to SwiftUI

        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: mainView)
        
        // Setup the hosting controller
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }

    func navigateToProfile() {
        //let profileVC = ProfileViewController()
        let profileVC = TwitterParallaxViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}


extension UIView {
    func pinToEdges(of parentView: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
}
