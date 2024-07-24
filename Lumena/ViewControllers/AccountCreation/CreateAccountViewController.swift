//
//  CreateAccount.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/25.
//

import Foundation
import UIKit
import SwiftUI

class CreateAccountViewController: UIViewController {
    private var hostingController: UIHostingController<CreateAccount>?

    override func viewDidLoad() {
        super.viewDidLoad()
        var createAccountView = CreateAccount()
        
        createAccountView.navigateToUserConfirmationCodeView = navigateToUserConfirmationCodeView

        hostingController = UIHostingController(rootView: createAccountView)
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }
    
    func navigateToLogin() {
        let profileVC = LoginViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func navigateToUserConfirmationCodeView(username: String, password: String, email: String) {
        DispatchQueue.main.async {
            let confirmationVC = UserConfirmationCodeViewController(username: username, password: password, email: email)
            self.isModalInPresentation = true
            self.navigationController?.pushViewController(confirmationVC, animated: true)
        }
    }
}
