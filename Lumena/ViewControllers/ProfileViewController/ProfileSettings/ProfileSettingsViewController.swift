//
//  ProfileSettingsViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/30.
//

import Foundation
import UIKit
import SwiftUI
import Amplify

protocol ProfileSettingsDelegate: AnyObject {
    func didUpdateUserName(_ newUserName: String)
    func didUpdateFirstName(_ newFirstName: String)
    func didUpdateDescription(_ newDescription: String)
    func didUpdateProfileImage(_ newProfileImage: UIImage)
    func didUpdateBackgroundImage(_ newBackgroundImage: UIImage)
    func didUpdateSkinSettings(_ newSkinSettings: SkinSettingsAttributes)
}

class ProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SkinSettingViewControllerDelegate {
    
    // UI Components
    private var backgroundImageView: UIImageView!
    private var profileImageView: UIImageView!
    private var backgroundImageHeight: CGFloat = 0.4
    
    private var fieldBackground: UIView!
    private var fieldBackgroundHeight: CGFloat = 120
    
    private var nameButton: UIButton!
    private var usernameButton: UIButton!
    private var bioButton: UIButton!
    
    private var buttonBackground: UIView!
    private var skinSettingButton: UIButton!
    private var logoutButton: UIButton!
    private var deleteAccountButton: UIButton!
    
    private var toolBarStackView: UIStackView!
    private var backButton: UIButton!
    private var doneButton: UIButton!
    private var unblockButton: UIButton!
    var color: UIColor = .background {
        didSet {
            updateButtonColors()
        }
    }
    private let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
    private let buttonTextConfig = UIFont.systemFont(ofSize: 18, weight: .bold)
    var addShadow: Bool = true
    
    // State variables
    @ObservedObject var profile: ProfileSettings
    var userPrivate: Bool = false
    var profSelectedImage: UIImage?
    var backSelectedImage: UIImage?
    
    weak var delegate: ProfileSettingsDelegate?
    
    init(profile: ProfileSettings) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProfileManager.shared.updateProfile(profile)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        setupImages()
        
        setupFieldButtons()
        
        setupButtons()
        
        addToolBar()
    }
    
    private func setupImages() {
        
        // Background Image View
        backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.backgroundColor = .systemGray5
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        // Profile Image View
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 55
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.background.cgColor
        profileImageView.layer.borderWidth = 4
        profileImageView.isUserInteractionEnabled = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: backgroundImageHeight),
            
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 110),
            profileImageView.heightAnchor.constraint(equalToConstant: 110),
        ])
        
        // Setup default appearance for images if not set
        setupDefaultImageAppearance(imageView: backgroundImageView, text: "Tap to set background image", icon: "photo.on.rectangle")
        setupDefaultImageAppearance(imageView: profileImageView, text: "", icon: "person.fill")
        
        // Add gesture recognizers for image taps
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(profileImageTapGesture)
        let backgroundImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundImageTap))
        backgroundImageView.addGestureRecognizer(backgroundImageTapGesture)
    }

    private func setupDefaultImageAppearance(imageView: UIImageView, text: String?, icon: String) {
        imageView.subviews.forEach { $0.removeFromSuperview() } // Always clear previous subviews first
        
        if imageView.image == nil {
            imageView.backgroundColor = .systemGray5
            
            // Configure the label if text is provided
            if let text = text, !text.isEmpty {
                let iconImage = UIImage(systemName: icon)?.withTintColor(.primary, renderingMode: .alwaysOriginal)  // Apply primary color
                let iconImageView = UIImageView(image: iconImage)
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                
                let label = UILabel()
                label.text = text
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 16)
                label.translatesAutoresizingMaskIntoConstraints = false
                
                let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.spacing = 8
                stackView.translatesAutoresizingMaskIntoConstraints = false
                
                imageView.addSubview(stackView)
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                ])
            } else {
                // Create the icon view with the primary color when no text is provided
                let iconImage = UIImage(systemName: icon)?.withTintColor(.primary, renderingMode: .alwaysOriginal)
                let iconImageView = UIImageView(image: iconImage)
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                
                imageView.addSubview(iconImageView)
                
                // Adjust the icon to fill the imageView
                NSLayoutConstraint.activate([
                    iconImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    iconImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                    iconImageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.7),
                    iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
                ])
            }
        } else {
            imageView.backgroundColor = .clear // Optionally clear the background color if not needed
        }
        
        imageView.layoutIfNeeded()
    }

    private func setupFieldButtons() {
        
        // Field Background
        fieldBackground = UIView()
        fieldBackground.backgroundColor = .background
        fieldBackground.layer.masksToBounds = true
        fieldBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fieldBackground)
        
        // Name Button
        nameButton = createFieldButton(title: profile.givenName, placeholder: "名")
        nameButton.contentHorizontalAlignment = .leading
        fieldBackground.addSubview(nameButton)
        
        // Username Button
        usernameButton = createFieldButton(title: profile.preferredUsername, placeholder: "ユーザーネーム")
        usernameButton.contentHorizontalAlignment = .leading
        fieldBackground.addSubview(usernameButton)
        
        // Bio Button
        bioButton = createFieldButton(title: profile.bio, placeholder: "概要欄")
        bioButton.contentHorizontalAlignment = .leading
        bioButton.contentVerticalAlignment = .top
        bioButton.titleLabel?.numberOfLines = 2
        bioButton.layer.masksToBounds = true
        bioButton.translatesAutoresizingMaskIntoConstraints = false
        fieldBackground.addSubview(bioButton)
        
        NSLayoutConstraint.activate([
            fieldBackground.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            fieldBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            fieldBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            nameButton.topAnchor.constraint(equalTo: fieldBackground.topAnchor, constant: 15),
            nameButton.leadingAnchor.constraint(equalTo: fieldBackground.leadingAnchor, constant: 15),
            nameButton.trailingAnchor.constraint(equalTo: fieldBackground.trailingAnchor, constant: -15),
            nameButton.heightAnchor.constraint(equalToConstant: 50),
            
            usernameButton.topAnchor.constraint(equalTo: nameButton.bottomAnchor, constant: 15),
            usernameButton.leadingAnchor.constraint(equalTo: fieldBackground.leadingAnchor, constant: 15),
            usernameButton.trailingAnchor.constraint(equalTo: fieldBackground.trailingAnchor, constant: -15),
            usernameButton.heightAnchor.constraint(equalToConstant: 50),
            
            bioButton.topAnchor.constraint(equalTo: usernameButton.bottomAnchor, constant: 15),
            bioButton.leadingAnchor.constraint(equalTo: fieldBackground.leadingAnchor, constant: 15),
            bioButton.trailingAnchor.constraint(equalTo: fieldBackground.trailingAnchor, constant: -15),
            bioButton.heightAnchor.constraint(equalToConstant: 130),
            bioButton.bottomAnchor.constraint(equalTo: fieldBackground.bottomAnchor),
        ])
        
        nameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(editUsername), for: .touchUpInside)
        bioButton.addTarget(self, action: #selector(editBio), for: .touchUpInside)
    }
    
    private func setupButtons() {
        // Button Background
        buttonBackground = UIView()
        buttonBackground.backgroundColor = .background
        buttonBackground.layer.masksToBounds = true
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonBackground)
        
        // Skin Setting Button
        skinSettingButton = createActionButton(title: NSLocalizedString("肌設定を編集", comment: ""), color: .aginGreenColorScheme)
        skinSettingButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Logout Button
        logoutButton = UIButton(type: .system)
        logoutButton.setTitle(NSLocalizedString("ログアウト", comment: ""), for: .normal)
        logoutButton.setTitleColor(.gray, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Delete Account Button
        deleteAccountButton = UIButton(type: .system)
        deleteAccountButton.setTitle(NSLocalizedString("アカウントを削除", comment: ""), for: .normal)
        deleteAccountButton.setTitleColor(.red, for: .normal)
        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack View for Buttons
        let stackView = UIStackView(arrangedSubviews: [skinSettingButton, logoutButton, deleteAccountButton])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            buttonBackground.heightAnchor.constraint(equalToConstant: 130),
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBackground.topAnchor.constraint(equalTo: fieldBackground.bottomAnchor),
            buttonBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: buttonBackground.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: buttonBackground.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: buttonBackground.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: buttonBackground.bottomAnchor, constant: -10),
            
            skinSettingButton.widthAnchor.constraint(equalToConstant: 150),
            logoutButton.widthAnchor.constraint(equalToConstant: 150),
            deleteAccountButton.widthAnchor.constraint(equalToConstant: 150),
            
            skinSettingButton.heightAnchor.constraint(equalTo: buttonBackground.heightAnchor, multiplier: 2/7),
            logoutButton.heightAnchor.constraint(equalTo: buttonBackground.heightAnchor, multiplier: 2/7),
            deleteAccountButton.heightAnchor.constraint(equalTo: buttonBackground.heightAnchor, multiplier: 2/7)
        ])
        
        skinSettingButton.addTarget(self, action: #selector(handleSkinSettingTap), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
    }

    private func loadData() {
        userPrivate = profile.lockState
        backSelectedImage = profile.backgroundImage?.image
        profSelectedImage = profile.profileImage?.image
        
        backgroundImageView.image = backSelectedImage
        profileImageView.image = profSelectedImage
        
        // Ensure the default appearance is correctly setup based on current image states
        setupDefaultImageAppearance(imageView: backgroundImageView, text: "Tap to set background image", icon: "photo.on.rectangle")
        setupDefaultImageAppearance(imageView: profileImageView, text: "", icon: "person.fill")
    }

    @objc private func handleProfileImageTap() {
        let alert = UIAlertController(title: NSLocalizedString("プロファイル写真の変更", comment: ""), message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("リセット", comment: ""), style: .destructive, handler: { _ in
            // make logic in lambda and dynamodb to remove the profile image existance: Maybe bool?
            self.profileImageView.image = nil  // Set profile image view to nil
            self.profileImageView.subviews.forEach { $0.removeFromSuperview() } // Clear any added subviews
            self.setupDefaultImageAppearance(imageView: self.profileImageView, text: "", icon: "person.fill")
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ライブラリから選択", comment: ""), style: .default, handler: { _ in
            self.showImagePicker(sourceType: .photoLibrary, forProfile: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handleBackgroundImageTap() {
        let alert = UIAlertController(title: NSLocalizedString("バックグラウンド写真の変更", comment: ""), message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("リセット", comment: ""), style: .destructive, handler: { _ in
            // make logic in lambda and dynamodb to remove the background image existance: Maybe bool?
            self.backgroundImageView.image = nil  // Set profile image view to nil
            self.backgroundImageView.subviews.forEach { $0.removeFromSuperview() } // Clear any added subviews
            self.setupDefaultImageAppearance(imageView: self.backgroundImageView, text: "Tap to set background image", icon: "photo.on.rectangle")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ライブラリから選択", comment: ""), style: .default, handler: { _ in
            self.showImagePicker(sourceType: .photoLibrary, forProfile: false)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handleSkinSettingTap() {
        let skinSettingVC = SkinSettingViewController(profile: profile, mainOrSetting: true)
        skinSettingVC.delegate = self
        navigationController?.pushViewController(skinSettingVC, animated: true)
    }
    
    func skinSettingViewControllerDidDismiss(_ skinSettings: SkinSettingsAttributes) {
        delegate?.didUpdateSkinSettings(skinSettings)
    }

    @objc private func handleLogout() {
        let alert = UIAlertController(title: NSLocalizedString("ログアウト", comment: ""), message: NSLocalizedString("本当にログアウトしますか？", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ログアウト", comment: ""), style: .destructive, handler: { _ in
            // Perform logout action
            Task {
                let result = await AuthenticationManager.shared.signOut()
                print(result)
                self.logoutAndNavigateToLumeHorizontalTabViewController()
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handleDeleteAccount() {
        let alert = UIAlertController(title: NSLocalizedString("アカウントを削除", comment: ""), message: NSLocalizedString("アカウントに紐ずくデータは全て削除されますがよろしいでしょうか？ アカウントを一度削除されますと、復旧はできません。以下の「削除」ボタンを押すことにより、データが削除されることに同意し、回復できないことに同意したと見做します。", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("削除", comment: ""), style: .destructive, handler: { _ in
            // Perform delete account action
            Task {
                do {
                    let result = try await AuthenticationManager.shared.deleteUser()
                    print(result)
                    self.logoutAndNavigateToLumeHorizontalTabViewController()
                } catch {
                    print(error)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func logoutAndNavigateToLumeHorizontalTabViewController() {
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is LumeHorizontalTabViewController {
                    navigationController?.popToViewController(viewController, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let lumeVC = viewController as? LumeHorizontalTabViewController {
                            lumeVC.showLoginSheet()
                        }
                    }
                    return
                }
            }
        }
        
        // Fallback: if the target view controller is not found, pop to the root view controller
        navigationController?.popToRootViewController(animated: true)
        
        // After navigation is complete, present the login sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let rootVC = self.navigationController?.viewControllers.first as? LumeHorizontalTabViewController {
                rootVC.showLoginSheet()
            }
        }
    }
    
    private func createFieldButton(title: String, placeholder: String) -> UIButton {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title.isEmpty ? NSLocalizedString(placeholder, comment: "") : title
        configuration.baseForegroundColor = title.isEmpty ? .systemGray2 : .primary
        configuration.titleAlignment = .leading
        button.configuration = configuration
        button.configuration?.background.backgroundColor = .systemGray5
        button.configuration?.background.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createActionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        button.setTitleColor(.primary, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = color
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc private func editName() {
        let config = EditProfileTextInputConfig(
            title: "名",
            placeholder: "名",
            initialText: profile.givenName,
            onSave: { [weak self] newName in
                self?.nameButton.setTitle(newName, for: .normal)
                self?.profile.givenName = newName
                self?.nameButton.configuration?.baseForegroundColor = newName.isEmpty ? .secondary : .primary
                self?.delegate?.didUpdateFirstName(newName)
                ProfileManager.shared.updateProfile(self!.profile)
                // Update in Amplify
                Task {
                    do {
                        let result = try await Amplify.Auth.update(userAttribute: AuthUserAttribute(.givenName, value: newName))
                        print(result)
                    } catch {
                        print(error)
                    }
                }
            },
            userInstructionText: "友人などから親しみのある名前を使用すると、友人達から見つかりやすくなるかもしれません。",
            characterLimit: 50
        )
        let editVC = EditProfileTextInputViewController(config: config)
        navigationController?.pushViewController(editVC, animated: true)
    }

    @objc private func editUsername() {
        let config = EditProfileTextInputConfig(
            title: "ユーザーネーム",
            placeholder: "ユーザーネーム",
            initialText: profile.preferredUsername,
            onSave: { [weak self] newUsername in
                self?.usernameButton.setTitle(newUsername, for: .normal)
                self?.profile.preferredUsername = newUsername
                self?.delegate?.didUpdateUserName(newUsername)
                self?.usernameButton.configuration?.baseForegroundColor = newUsername.isEmpty ? .secondary : .primary
                ProfileManager.shared.updateProfile(self!.profile)
                // Update in Amplify
                Task {
                    do {
                        let result = try await Amplify.Auth.update(userAttribute: AuthUserAttribute(.preferredUsername, value: newUsername))
                        print(result)
                    } catch {
                        print(error)
                    }
                }
            },
            userInstructionText: "ユーザーネームはアカウントを検索する際に使用されます。そのため、検索しやすいユーザーネームにすると、友人達から見つかりやすくなるかもしれません。",
            characterLimit: 20
        )
        let editVC = EditProfileTextInputViewController(config: config)
        navigationController?.pushViewController(editVC, animated: true)
    }

    @objc private func editBio() {
        let config = EditProfileTextInputConfig(
            title: "概要欄",
            placeholder: "概要欄",
            initialText: profile.bio,
            onSave: { [weak self] newBio in
                self?.bioButton.setTitle(newBio, for: .normal)
                self?.profile.bio = newBio
                self?.delegate?.didUpdateDescription(newBio)
                self?.bioButton.configuration?.baseForegroundColor = newBio.isEmpty ? .secondary : .primary
                ProfileManager.shared.updateProfile(self!.profile)
                // Update in Amplify
                Task {
                    do {
                        let message = try await AuthenticationManager.shared.updateUserAttributes(attributeName: AuthUserAttributeKey.custom("bio"), value: newBio)
                        print(message)
                    } catch {
                        print("Error: \(error)")
                    }
                }
            },
            userInstructionText: "概要欄は他のユーザーに自分のことを文面で紹介できる機能です。概要欄を使って自己紹介や気分、何でも思うがままに自分を表現しましょう！概要欄の文字数は150文字制限があります。",
            characterLimit: 150
        )
        let editVC = EditProfileTextInputViewController(config: config)
        navigationController?.pushViewController(editVC, animated: true)
    }

    // UIImagePickerControllerDelegate Methods
    private func showImagePicker(sourceType: UIImagePickerController.SourceType, forProfile: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = forProfile
        imagePicker.view.tag = forProfile ? 1 : 2
        present(imagePicker, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            print("No image was selected")
            dismiss(animated: true, completion: nil)
            return
        }
        
        let isProfileImage = (picker.view.tag == 1)
        updateImage(forProfile: isProfileImage, with: selectedImage)
        
        dismiss(animated: true, completion: nil)
    }

    private func updateImage(forProfile: Bool, with image: UIImage) {
        if forProfile {
            profSelectedImage = image
            profileImageView.image = profSelectedImage
            profileImageView.subviews.forEach { $0.removeFromSuperview() } // Clear any added subviews
            profileImageView.layoutIfNeeded()
            self.delegate?.didUpdateProfileImage(image)
            Task {
                await profile.uploadProfileImage(image: image)
            }
        } else {
            backSelectedImage = image
            backgroundImageView.subviews.forEach { $0.removeFromSuperview() } // Clear any added subviews
            backgroundImageView.image = backSelectedImage
            backgroundImageView.layoutIfNeeded()
            self.delegate?.didUpdateBackgroundImage(image)
            Task {
                await profile.uploadBackgroundImage(image: image)
            }
        }
        ProfileManager.shared.updateProfile(profile)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateProfile(profile: ProfileSettings) {
        self.profile = profile
        self.loadData()
    }
}

extension ProfileSettingsViewController {
    
    private func addToolBar() {
        
        view.backgroundColor = .background
        
        setupBackButton()
        setupDoneButton()
        setupUnblockButton()
        
        toolBarStackView = UIStackView(arrangedSubviews: [backButton, createFlexibleSpace(), unblockButton])
        toolBarStackView.axis = .horizontal
        toolBarStackView.distribution = .equalSpacing
        toolBarStackView.alignment = .center
        toolBarStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toolBarStackView)
        
        NSLayoutConstraint.activate([
            toolBarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toolBarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toolBarStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolBarStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        updateButtonColors()
    }
    
    private func setupBackButton() {
        backButton = createButton(action: #selector(backButtonTapped), imageName: "chevron.backward", buttonLabel: "", tintColor: self.color, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    private func setupDoneButton() {
        doneButton = createButton(action: #selector(saveButtonTapped), imageName: "", buttonLabel: "", tintColor: self.color, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    private func setupUnblockButton() {
        unblockButton = createButton(action: #selector(unblockButtonTapped), imageName: "person.crop.circle.fill.badge.xmark", buttonLabel: "", tintColor: self.color, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    @objc private func backButtonTapped() {
        Task {
            do {
                try await profile.updateUserProfileQL()
            } catch {
                print(error)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {}
    
    @objc private func unblockButtonTapped() {
        let unblockViewController = UnblockViewController(userIdentityID: profile.identityID)
        self.navigationController?.pushViewController(unblockViewController, animated: true)
    }
    
    private func updateButtonColors() {
        if backButton != nil {
            backButton.tintColor = color
        }
        if doneButton != nil {
            doneButton.tintColor = color
        }
    }
}

extension ProfileSettingsViewController {
    
    private func createButton(action: Selector, imageName: String, buttonLabel: String, tintColor: UIColor, shadow: Bool, buttonTextConfig: UIFont, buttonImageConfig: UIImage.SymbolConfiguration) -> UIButton {
        let button = UIButton()
        if imageName == "" {
            button.setTitle(buttonLabel, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.titleLabel?.font = buttonTextConfig
        } else {
            if let image = UIImage(systemName: imageName, withConfiguration: buttonImageConfig) {
                button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        if shadow {
            addShadow(to: button)
        }
        
        return button
    }
    
    private func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIKit.UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
    }
    
    private func createFlexibleSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        return space
    }
    
    private func createFixedSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            space.widthAnchor.constraint(equalToConstant: 16)
        ])
        return space
    }
}

struct EditProfileTextInputConfig {
    var title: String
    var placeholder: String
    var initialText: String
    var onSave: (String) -> Void
    var userInstructionText: String
    var characterLimit: Int = Int.max
}

class EditProfileTextInputViewController: UIViewController {
    
    var config: EditProfileTextInputConfig
    private var userInput: UserInput
    
    private var stackView: UIStackView!
    private var backButton: UIButton!
    private var doneButton: UIButton!
    
    private var textfield: UIHostingController<VerticalTextField>!
    private var characterCountLabel: UILabel!
    
    private var bottomInfoText: UILabel!
    
    var colorScheme: UIUserInterfaceStyle = .dark {
        didSet {
            updateButtonColors()
        }
    }
    
    private let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
    private let buttonTextConfig = UIFont.systemFont(ofSize: 18, weight: .bold)
    var addShadow: Bool = false
    
    
    init(config: EditProfileTextInputConfig) {
        self.config = config
        self.userInput = UserInput(text: config.initialText)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        addToolBar()
        addTextBody()
    }
}

// MARK: - toolbar setup
extension EditProfileTextInputViewController {
    
    private func addToolBar() {
        
        view.backgroundColor = .background
        
        setupBackButton()
        setupDoneButton()
        
        stackView = UIStackView(arrangedSubviews: [backButton, createFlexibleSpace(), doneButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupTitleLabel()
        
//        updateButtonColors()
    }
    
    private func setupBackButton() {
        backButton = createButton(action: #selector(backButtonTapped), imageName: "chevron.backward", buttonLabel: "", tintColor: .arinDarkGreen, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    private func setupTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString(config.title, comment: "")
        titleLabel.font = buttonTextConfig
        titleLabel.textColor = .arinDarkGreen
        
        stackView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton = createButton(action: #selector(saveButtonTapped), imageName: "", buttonLabel: NSLocalizedString("保存", comment: ""), tintColor: .arinDarkGreen, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        if userInput.text.count <= config.characterLimit {
            config.onSave(userInput.text)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateButtonColors() {
        if backButton != nil {
            backButton.tintColor = buttonTintColor()
        }
        if doneButton != nil {
            doneButton.tintColor = buttonTintColor()
        }
    }
}

extension EditProfileTextInputViewController {
    
    private func createButton(action: Selector, imageName: String, buttonLabel: String, tintColor: UIColor, shadow: Bool, buttonTextConfig: UIFont, buttonImageConfig: UIImage.SymbolConfiguration) -> UIButton {
        let button = UIButton()
        if imageName == "" {
            button.setTitle(buttonLabel, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.titleLabel?.font = buttonTextConfig
        } else {
            if let image = UIImage(systemName: imageName, withConfiguration: buttonImageConfig) {
                button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        if shadow {
            addShadow(to: button)
        }
        
        return button
    }
    
    private func buttonTintColor() -> UIColor {
        return colorScheme == .dark ? .white : .black
    }
    
    private func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIKit.UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
    }
    
    private func createFlexibleSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        return space
    }
    
    private func createFixedSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            space.widthAnchor.constraint(equalToConstant: 16)
        ])
        return space
    }
}


// MARK: - textfield setup

extension EditProfileTextInputViewController {
    
    private func addTextBody() {
        addTextField()
        //addBottomInfoText()
    }
    
    private func addTextField() {
        let swiftUIView = VerticalTextField(placeholder: config.placeholder, bottomInfoText: config.userInstructionText, userInput: userInput, characterLimit: config.characterLimit)
        textfield = UIHostingController(rootView: swiftUIView)
        
        addChild(textfield)
        view.addSubview(textfield.view)
        textfield.didMove(toParent: self)
        
        textfield.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textfield.view.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            textfield.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textfield.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textfield.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


class UserInput: ObservableObject {
    @Published var text: String
    
    init(text: String) {
        self.text = text
    }
}

struct VerticalTextField: View {
    
    @State var placeholder: String
    @State var bottomInfoText: String
    @ObservedObject var userInput: UserInput
    var characterLimit: Int
    
    var body: some View {
        VStack {
            Divider()
            
            TextField(NSLocalizedString(placeholder, comment: ""), text: $userInput.text, axis: .vertical)
                .autocapitalization(.none)
                .onReceive(userInput.text.publisher) { newValue in
                    if userInput.text.count > characterLimit {
                        userInput.text = String(userInput.text.prefix(characterLimit))
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
            
            Divider()
            
            HStack {
                Spacer()
                Text("\(userInput.text.count) / \(characterLimit)")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            .padding(.horizontal, 20)
            
            Text(NSLocalizedString(bottomInfoText, comment: ""))
                .font(.caption)
                .foregroundColor(Color.secondary)
                .padding(.top, 5)
                .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}
