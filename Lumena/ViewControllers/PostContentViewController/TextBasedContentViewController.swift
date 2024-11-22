//
//  TextBasedContentViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/30.
//

import Foundation
import UIKit
import SwiftUI


protocol TextBasedContentViewControllerDelegate : AnyObject {
    func didUpdateText(_ newText: String)
}

class TextBasedContentViewController: UIViewController {
    
    weak var delegate: TextBasedContentViewControllerDelegate?
    
    private var userInput: UserInput
    private var characterLimit: Int = 1000
    
    private var profileHeaderStack: UIStackView!
    private var textfield: UIHostingController<TextBasedVerticalTextField>!
    private var characterCountLabel: UILabel!
    
    private var textFieldBottomConstraint: NSLayoutConstraint!
    
    private var profileImage: UIImageView!
    private var usernameLabel: UILabel!
    
    private var bottomBarView: UIView!
    
    private var keyboardIsVisible: Bool = false
    private var keyboardHeight: CGFloat = 0.0
    private var lastHeight: CGFloat = 40.0
    
    var bottomInsetHeight: CGFloat = 0.0
    
    init(text: String = "") {
        self.userInput = UserInput(text: text)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
    }
    
    private func setupUI() {
        
        setupHeaderUserUI()
        setupBottomHorizontalBar()
        addTextBody()
        
        registerForKeyboardNotifications()
        
        view.sendSubviewToBack(textfield.view)
        view.bringSubviewToFront(bottomBarView)
    }
}

// MARK: - UserInfo Header

extension TextBasedContentViewController {
    
    private func setupHeaderUserUI() {
        
        profileHeaderStack = UIStackView()
        profileHeaderStack.axis = .horizontal
        profileHeaderStack.alignment = .center
        profileHeaderStack.spacing = 8
        profileHeaderStack.distribution = .fillProportionally
        profileHeaderStack.backgroundColor = .background
        
        view.addSubview(profileHeaderStack)
        
        profileImage = UIImageView()
        profileImage.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
        profileImage.contentMode = .scaleAspectFit
        
        usernameLabel = UILabel()
        usernameLabel.text = "username"
        usernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        usernameLabel.textColor = .primary
        
        profileHeaderStack.addArrangedSubview(profileImage)
        profileHeaderStack.addArrangedSubview(usernameLabel)
        
        profileHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileHeaderStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileHeaderStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            profileHeaderStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            profileHeaderStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            
            profileImage.topAnchor.constraint(equalTo: profileHeaderStack.topAnchor, constant: 5),
            profileImage.bottomAnchor.constraint(equalTo: profileHeaderStack.bottomAnchor, constant: -5),
            profileImage.leadingAnchor.constraint(equalTo: profileHeaderStack.leadingAnchor),
            profileImage.trailingAnchor.constraint(equalTo: profileHeaderStack.leadingAnchor, constant: 40),
        ])
        
        updateProfileInfo()
    }
    
    private func updateProfileInfo() {
        guard let userIdentityID = AuthenticationManager.shared.identityID else { return }
        
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    let userProfile = try await ProfileManager.shared.getProfile(withID: userIdentityID)
                    usernameLabel.text = userProfile.preferredUsername
                    let profileUIImage = userProfile.profileImage?.image
                    if profileUIImage != nil {
                        profileImage.image = userProfile.profileImage?.image
                    }
                    view.layoutIfNeeded()
                } catch {
                    print(error)
                }
                
            }
        }
    }
}


// MARK: - TextField View

extension TextBasedContentViewController {
    
    private func addTextBody() {
        addTextField()
    }
    
    private func addTextField() {
        let swiftUIView = TextBasedVerticalTextField(
            placeholder: "What's New?",
            userInput: userInput,
            characterLimit: characterLimit,
            onTextChanged: { [weak self] newText in
                self?.delegate?.didUpdateText(newText)
            }
        )
        textfield = UIHostingController(rootView: swiftUIView)
        
        addChild(textfield)
        view.addSubview(textfield.view)
        textfield.didMove(toParent: self)
        
        textfield.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textfield.view.topAnchor.constraint(equalTo: profileHeaderStack.bottomAnchor),
            textfield.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            textfield.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            textfield.view.bottomAnchor.constraint(equalTo: bottomBarView.bottomAnchor, constant: -5)
        ])
    }
}


struct TextBasedVerticalTextField: View {
    
    @State var placeholder: String
    @ObservedObject var userInput: UserInput
    var characterLimit: Int
    var onTextChanged: (String) -> Void
    
    var body: some View {
        VStack {
            TextField(NSLocalizedString(placeholder, comment: ""), text: $userInput.text, axis: .vertical)
                .autocapitalization(.none)
                .submitLabel(.done) // Set the keyboard to "Done"
                .onSubmit {
                    UIApplication.shared.dismissKeyboard()
                }
                .onChange(of: userInput.text) { newValue in
                    if userInput.text.count > characterLimit {
                        userInput.text = String(userInput.text.prefix(characterLimit))
                    }
                    onTextChanged(userInput.text)
                }
                .padding(.bottom, 5)
            
            HStack {
                Spacer()
                Text("\(userInput.text.count) / \(characterLimit)")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

extension UIApplication {
    /// Dismisses the keyboard by resigning the first responder.
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}



// MARK: - Submit Button View

extension TextBasedContentViewController {
    
    private func setupBottomHorizontalBar() {
        
        bottomBarView = UIView()
        bottomBarView.backgroundColor = .clear
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        
        let saveButton = setupSaveButton()
        let xButton = setupXButton()
        
        bottomBarView.addSubview(xButton)
        bottomBarView.addSubview(saveButton)
        
        view.addSubview(bottomBarView)
        
        bottomBarView.alpha = 0.0
        textFieldBottomConstraint = bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            bottomBarView.heightAnchor.constraint(equalToConstant: 40),
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textFieldBottomConstraint,
            
            saveButton.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -20),
            saveButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 40),
            
            xButton.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: 20),
            xButton.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor),
            xButton.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func setupButton(withImageName imageName: String, pointSize: CGFloat, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)  // Set the button type to custom
        
        // Setup the icon
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: config)?.withTintColor(.arinMatGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        // Prevent the image from distorting
        button.imageView?.contentMode = .scaleAspectFit
        
        // Setup the button background
        button.backgroundColor = .black.withAlphaComponent(0.1)
        button.layer.cornerRadius = 20/2.0  // Height / 2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Ensure the button is tappable
        button.isUserInteractionEnabled = true
        
        // Bring the button to the front
        button.layer.zPosition = 1
        
        // Set button action
        button.addTarget(target, action: action, for: .touchUpInside)
        
        // Add constraints for width and height
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return button
    }
    private func setupXButton() -> UIButton {
        return setupButton(withImageName: "x.circle.fill", pointSize: 20, target: self, action: #selector(xButtonTapped))
    }

    private func setupSaveButton() -> UIButton {
        return setupButton(withImageName: "checkmark.circle.fill", pointSize: 20, target: self, action: #selector(saveButtonTapped))
    }
    
    @objc private func saveButtonTapped() {
        // Dismiss the keyboard by resigning first responder status
        textfield.view.endEditing(true)
        
        // Notify delegate with the updated text
        delegate?.didUpdateText(userInput.text)
    }

    @objc private func xButtonTapped() {
        // Clear the user input
        userInput.text = ""
        
        // Update the SwiftUI TextField to reflect the cleared text immediately
        textfield.rootView = TextBasedVerticalTextField(
            placeholder: textfield.rootView.placeholder,
            userInput: userInput,
            characterLimit: characterLimit,
            onTextChanged: textfield.rootView.onTextChanged
        )
    }
}


extension TextBasedContentViewController {
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
            adjustForKeyboard(height: keyboardFrame.height)
            keyboardIsVisible = true
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        keyboardHeight = 0.0
        adjustForKeyboard(height: 0)
        keyboardIsVisible = false
    }
    
    private func adjustForKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            if height != 0 {
                self.bottomBarView.alpha = 1.0
                self.textFieldBottomConstraint.constant = -height + self.bottomInsetHeight
            } else {
                self.bottomBarView.alpha = 0.0
                self.textFieldBottomConstraint.constant = -height
            }
            self.view.layoutIfNeeded()
        }
    }
}
