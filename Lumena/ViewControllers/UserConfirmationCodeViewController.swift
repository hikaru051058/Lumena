//
//  UserConfirmationCodeViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/25.
//

import Foundation
import UIKit
import SwiftUI

import UIKit
import SwiftUI

class UserConfirmationCodeViewController: UIViewController {
    private var hostingController: UIHostingController<UserConfirmationCodeView>?

    // Properties to store user data
    private var username: String
    private var password: String
    private var email: String

    // Initializer to receive user data
    init(username: String, password: String, email: String) {
        self.username = username
        self.password = password
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for UserConfirmationCodeViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the SwiftUI view with the user data
        let userConfirmationView = UserConfirmationCodeView(username: username, password: password, email: email)
        
        hostingController = UIHostingController(rootView: userConfirmationView)

        // Ensure the hosting controller is available
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Set up constraints for the SwiftUI view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }
}

