//
//  LoginViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/21.
//

import Foundation
import UIKit
import SwiftUI

class LoginViewController: UIViewController {
    private var hostingController: UIHostingController<LoginView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        var loginView = LoginView()
        loginView.onNavigateMain = navigateToMain
        loginView.onNavigateCreateAccount = navigateToCreateAccount

        hostingController = UIHostingController(rootView: loginView)
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func navigateToMain() {
        DispatchQueue.main.async {
            let mainVC = LumeHorizontalTabViewController()
            self.navigationController?.pushViewController(mainVC, animated: true)
        }
    }
    
    func navigateToCreateAccount() {
        DispatchQueue.main.async {
            let createAccountVC = CreateAccountViewController()
            self.navigationController?.pushViewController(createAccountVC, animated: true)
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
