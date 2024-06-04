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

class ProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

    // State variables
    var profile: ProfileSettings!
    var userPrivate: Bool = false
    var profSelectedImage: UIImage?
    var backSelectedImage: UIImage?

    var onNavigate: (() -> Void)?
    var onNavigateSkinSetting: (([Int], Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Background Image View
        backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        // Profile Image View
        profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 55
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 4
        profileImageView.isUserInteractionEnabled = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        // Field Background
        fieldBackground = UIView()
        fieldBackground.backgroundColor = .white
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
        bioButton.titleLabel?.numberOfLines = 2
        fieldBackground.addSubview(bioButton)
        
        // Button Background
        buttonBackground = UIView()
        buttonBackground.backgroundColor = .white
        buttonBackground.layer.masksToBounds = true
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonBackground)
        
        // Skin Setting Button
        skinSettingButton = createActionButton(title: "肌設定を編集", color: UIColor(red: 0.863, green: 0.948, blue: 0.92, alpha: 1))
        buttonBackground.addSubview(skinSettingButton)
        
        // Logout Button
        logoutButton = UIButton(type: .system)
        logoutButton.setTitle("ログアウト", for: .normal)
        logoutButton.setTitleColor(.gray, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.addSubview(logoutButton)
        
        // Delete Account Button
        deleteAccountButton = UIButton(type: .system)
        deleteAccountButton.setTitle("アカウントを削除", for: .normal)
        deleteAccountButton.setTitleColor(.red, for: .normal)
        deleteAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        deleteAccountButton.translatesAutoresizingMaskIntoConstraints = false
        buttonBackground.addSubview(deleteAccountButton)
        
        setupConstraints()
        
        // Add gesture recognizer for profile image tap
        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageView.addGestureRecognizer(profileImageTapGesture)
        
        // Add gesture recognizer for background image tap
        let backgroundImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundImageTap))
        backgroundImageView.addGestureRecognizer(backgroundImageTapGesture)
        
        // Add button actions
        nameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(editUsername), for: .touchUpInside)
        bioButton.addTarget(self, action: #selector(editBio), for: .touchUpInside)
        skinSettingButton.addTarget(self, action: #selector(handleSkinSettingTap), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: backgroundImageHeight),
            
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 110),
            profileImageView.heightAnchor.constraint(equalToConstant: 110),
            
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
            
            buttonBackground.heightAnchor.constraint(equalToConstant: 150),
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            skinSettingButton.topAnchor.constraint(equalTo: buttonBackground.topAnchor, constant: 20),
            skinSettingButton.centerXAnchor.constraint(equalTo: buttonBackground.centerXAnchor),
            skinSettingButton.widthAnchor.constraint(equalToConstant: 150),
            skinSettingButton.heightAnchor.constraint(equalToConstant: 40),
            
            logoutButton.topAnchor.constraint(equalTo: skinSettingButton.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: buttonBackground.centerXAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
            
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            deleteAccountButton.centerXAnchor.constraint(equalTo: buttonBackground.centerXAnchor),
            deleteAccountButton.bottomAnchor.constraint(equalTo: buttonBackground.bottomAnchor, constant: -20),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func loadData() {
        userPrivate = profile.lockState
        backSelectedImage = profile.backgroundImage?.image
        profSelectedImage = profile.profileImage?.image
        
        backgroundImageView.image = backSelectedImage
        profileImageView.image = profSelectedImage
    }

    @objc private func handleProfileImageTap() {
        showImagePicker(sourceType: .photoLibrary, forProfile: true)
    }

    @objc private func handleBackgroundImageTap() {
        showImagePicker(sourceType: .photoLibrary, forProfile: false)
    }

    @objc private func handleSkinSettingTap() {
        onNavigateSkinSetting?(profile.skinSetting, true)
    }

    @objc private func handleLogout() {
        let alert = UIAlertController(title: "ログアウト", message: "本当にログアウトしますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive, handler: { _ in
            // Perform logout action
            self.onNavigate?()
        }))
        present(alert, animated: true, completion: nil)
    }

    @objc private func handleDeleteAccount() {
        let alert = UIAlertController(title: "アカウントを削除", message: "アカウントに紐ずくデータは全て削除されますがよろしいでしょうか？ アカウントを一度削除されますと、復旧はできません。以下の「削除」ボタンを押すことにより、データが削除されることに同意し、回復できないことに同意したと見做します。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: { _ in
            // Perform delete account action
        }))
        present(alert, animated: true, completion: nil)
    }

    private func showImagePicker(sourceType: UIImagePickerController.SourceType, forProfile: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tag = forProfile ? 1 : 2
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func createFieldButton(title: String, placeholder: String) -> UIButton {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title.isEmpty ? placeholder : title
        configuration.baseForegroundColor = title.isEmpty ? .secondary : .primary
        configuration.titleAlignment = .leading
        button.configuration = configuration
        button.configuration?.background.backgroundColor = .customGray
        button.configuration?.background.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func createActionButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
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
                self?.bioButton.configuration?.baseForegroundColor = newBio.isEmpty ? .secondary : .primary
                // Update in Amplify
//                Task {
//                    do {
//                        let result = try await Amplify.Auth.update(userAttribute: AuthUserAttribute.custom("bio", value: newBio))
//                        print(result)
//                    } catch {
//                        print(error)
//                    }
//                }
            },
            userInstructionText: "概要欄は他のユーザーに自分のことを文面で紹介できる機能です。概要欄を使って自己紹介や気分、何でも思うがままに自分を表現しましょう！概要欄の文字数は200文字制限があります。",
            characterLimit: 150
        )
        let editVC = EditProfileTextInputViewController(config: config)
        navigationController?.pushViewController(editVC, animated: true)
    }

    // UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as? UIImage
        if picker.view.tag == 1 {
            profSelectedImage = selectedImage
            profileImageView.image = profSelectedImage
        } else {
            backSelectedImage = selectedImage
            backgroundImageView.image = backSelectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


struct UserSetting: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @State var profile: ProfileSettings
    
    @State var logout: Bool = false
    
    @State private var userPrivate: Bool = false //profile.lockState ?? false
    
    //@State private var profSelectedItems = [PhotosPickerItem]()
    @State private var profSelectedImage: UIImage? = nil //profile?.profileImage?.image ?? nil
    @State private var isCroppingProfImage: Bool = false
    
    //@State private var backSelectedItems = [PhotosPickerItem]()
    @State private var backSelectedImage: UIImage? = nil //profile?.backgroundImage?.image ?? nil
    @State private var isCroppingBackImage: Bool = false
    
    
    @State private var logoutAccountButton: Bool = false
    @State private var deleteAccountButton: Bool = false
    
    @State var numCnt: Int = 0
    
    var onNavigate: () -> Void = {}
    var onNavigateSkinSetting: ([Int], Bool) -> Void = { _, _ in}
    
    var body: some View {
        
        NavigationView {
            
            ZStack{
                
                Button(action:{
                    isCroppingBackImage = true
                }){
                    ZStack {
                        if let uiImage = backSelectedImage {
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width)
                            
                        } else {
                            
                            Rectangle()
                                .foregroundColor(.gray)
                            
                            VStack{
                                
                                Text("背景を変更")
                                    .font(.title3)
                                    .padding(.top, 200)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .cropImagePicker(
                    option: Crop.rectangle,
                    show: $isCroppingBackImage,
                    croppedImage: $backSelectedImage
                )
                .onAppear{
                    
                    userPrivate = profile.lockState
                    
                    backSelectedImage = profile.backgroundImage?.image ?? nil
                    profSelectedImage = profile.profileImage?.image ?? nil
                }
                .onChange(of: backSelectedImage) { change in
                    
                    if change != profile.backgroundImage?.image {
                        if let image = change, let imageData = image.jpegData(compressionQuality: 1.0) {
                            S3.shared.storeData(name: "\(profile.identityID )/userSetting/background_image.jpg", data: imageData, accessLevel: .guest,
                                progressHandler: { progress in
                                    print("Upload Progress: \(progress * 100)%")
                            }){ result in
                                switch result {
                                case .success(_):
                                    print("Successfully uploaded backgroundImage")
                                case .failure(let error):
                                    print(error)
                                }
                            }
                            profile.backgroundImage?.image = change
                            profile.backgroundImage?.url = ""
                        }
                    }
                }
                .ignoresSafeArea()
                
                
                VStack{
                    
                    Spacer()
                        .padding(.top)
                    
                    ZStack{
                        
                        VStack{
                            
                            Rectangle()
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                                .ignoresSafeArea()
                        }
                        .padding(.top, 75)
                        
                        VStack{
                            
                            HStack{
                                
                                Button(action:{
                                    
                                    isCroppingProfImage = true
                                }){
                                    
                                    ZStack {
                                        if let uiImage = profSelectedImage {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 110, height: 110)
                                                .clipShape(Circle()) // This crops the image to a circle.
                                                .overlay(
                                                    Circle()
                                                        .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 4)
                                                )
                                            
                                        } else {
                                            Circle()
                                                .foregroundColor(.gray)
                                                .overlay(
                                                    Circle()
                                                        .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 4)
                                                )
                                            
                                            Image(systemName: "plus")
                                                .font(.title)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .frame(width: 150, height: 150)
                                }
                                .cropImagePicker(
                                    option: Crop.circle,
                                    show: $isCroppingProfImage,
                                    croppedImage: $profSelectedImage
                                )
                                .onChange(of: profSelectedImage) { change in
                                    
                                    if change != profile.profileImage?.image {
                                        if let image = change, let imageData = image.jpegData(compressionQuality: 1.0) {
                                            S3.shared.storeData(name: "\(profile.identityID )/userSetting/profile_image.jpg", data: imageData, accessLevel: .guest,
                                                progressHandler: { progress in
                                                    print("Upload Progress: \(progress * 100)%")
                                            }){ result in
                                                switch result {
                                                case .success(_):
                                                    print("Successfully uploaded profileImage")
                                                case .failure(let error):
                                                    print(error)
                                                }
                                            }
                                            profile.profileImage?.image = change
                                            profile.profileImage?.url = ""
                                        }
                                    }
                                }

                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            NavigationLink(destination: editName(profile: $profile, userOriginalInput: profile.givenName )){
                                
                                Text(profile.givenName )
                                    .placeholder(when: profile.givenName.isEmpty ) {
                                        HStack {
                                            Text("名").foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                    .padding(.all, 15)
                                    .background(Color.primary.opacity(0.1))
                                    .foregroundColor(Color.primary)
                                    .cornerRadius(15)
                                    .padding(.bottom, 15)
                                    .padding(.leading, 60)
                            }
                            .padding(.horizontal, 25)
                            .onChange(of: profile.givenName) { change in
                                
                                Task {
                                    do {
                                        let result = try await AuthenticationManager.shared.updateUserAttributes(attributeName: AuthUserAttributeKey.givenName, value: change)
                                        
                                        print(result)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            
                            NavigationLink(destination: editUsername(profile: $profile, userOriginalInput: profile.preferredUsername )){
                                
                                Text(profile.preferredUsername )
                                    .placeholder(when: profile.preferredUsername.isEmpty ) {
                                        
                                        HStack {
                                            Text("ユーザーネーム").foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                    .padding(.all, 15)
                                    .background(Color.primary.opacity(0.1))
                                    .foregroundColor(Color.primary)
                                    .cornerRadius(15)
                                    .padding(.bottom, 15)
                                    .padding(.leading, 60)
                            }
                            .padding(.horizontal, 25)
                            .onChange(of: profile.preferredUsername) { change in
                                
                                Task {
                                    do {
                                        let result = try await AuthenticationManager.shared.updateUserAttributes(attributeName: AuthUserAttributeKey.preferredUsername, value: change)
                                        print(result)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                            
                            NavigationLink(destination: editBio(profile: $profile, userOriginalInput: profile.bio )){
                                
                                Text(profile.bio )
                                    .placeholder(when: profile.bio.isEmpty ) {
                                        HStack {
                                            Text("概要欄").foregroundColor(.secondary)
                                            Spacer()
                                        }
                                    }
                                    .frame(maxHeight: 200)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.all, 15)
                                    .background(Color.primary.opacity(0.1))
                                    .foregroundColor(Color.primary)
                                    .cornerRadius(15)
                                    .padding(.bottom, 15)
                                    .padding(.leading, 60)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 15)
                            .onChange(of: profile.bio) { change in
                                
                                Task {
                                    do {
                                        let message = try await AuthenticationManager.shared.updateUserAttributes(attributeName: AuthUserAttributeKey.custom("bio"), value: change)
                                        print(message)
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            Spacer()
                                .padding(.bottom, 5)
                            
                            Group {
                                
                                Button(action: {onNavigateSkinSetting(profile.skinSetting, true)}) {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundColor(Color(red: 0.863, green: 0.948, blue: 0.92))
                                            .frame(width: 150, height: 40)
                                        
                                        Text("肌設定を編集")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.black)
                                    }
                                    .padding(.bottom, 5)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    logoutAccountButton = true
                                    
                                }){
                                    Text("ログアウト")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .frame(height: 40)
                                }
                                .confirmationDialog("ログアウト", isPresented: $logoutAccountButton){
                                    
                                    Button(
                                        role: .destructive,
                                        action: {
                                        
                                        Task {
                                            let result = await AuthenticationManager.shared.signOut()
                                            print(result)
                                            
                                            onNavigate()
                                        }
                                            
                                    }){
                                        Text("ログアウト")
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    deleteAccountButton = true
                                
                                }){
                                Text("アカウントを削除")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.bottom, 5)
                                    .frame(height: 40)
                                }
                                .alert(isPresented: $deleteAccountButton) {
                                    Alert(title: Text("アカウントを削除"),
                                          message: Text("アカウントに紐ずくデータは全て削除されますがよろしいでしょうか？なお、アカウントを一度削除されますと、復旧はできません。以下の「削除」ボタンを押すことにより、データが削除されることに同意し、回復できないことに同意したと見做します。"),
                                          primaryButton: .cancel(Text("キャンセル")),
                                          secondaryButton: .destructive(Text("削除"),
                                                    action: {
                                            Task {
                                                do {
                                                    let result = try await AuthenticationManager.shared.deleteUser()
                                                        
                                                    print("\(result)")
                                                    logout = true
                                                } catch {
                                                    print(error)
                                                }
                                            }
                                    }))
                                }
                            }
                            .frame(height: 20)
                        }
                    }
                }
                
                VStack{
                    
                    HStack{
                        
                        Button(action: {
                            
                            Task {
                                do {
                                    try await profile.updateUserProfileQL()
                                } catch {
                                    print(error)
                                }
                            }
                            
                            //presentationMode.wrappedValue.dismiss()
                            onNavigate()
                        }, label: {
                            
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                                .foregroundColor(Color.white)
                                .padding(.leading)
                                .shadow(radius: 5)
                            
                        })
                        .frame(width: 70, height: 70)
                        .contentShape(Rectangle())
                        
                        Spacer()
                        
                        
                        /*
                        Button(action: {
                            
                            withAnimation{
                                userPrivate.toggle()
                            }
                            
                            profile.lockState = userPrivate
                            
                        }, label: {
                            
                            Image(systemName: userPrivate ? "lock.fill" : "lock.open.fill")
                                .font(Font.system(size: 25).weight(.bold))
                                .foregroundColor(Color.white)
                                .padding(.leading)
                                .shadow(radius: 5)
                            
                        })
                        .frame(width: 70, height: 70)
                        .contentShape(Rectangle())
                        .onChange(of: userPrivate) { change in
                            
                            Task {
                                
                                let valueToSet = change ? "1" : "0"
                                await AuthenticationManager.shared.updateUserAttributes(attributeName: AuthUserAttributeKey.custom("privateState"), value: valueToSet) { result in
                                    switch result {
                                    case .success(let message):
                                        print(message)
                                    case .failure(let error):
                                        print("Error: \(error)")
                                    }
                                }
                            }
                        }
                         
                         */
                    }
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
                
                
            }
        }
        .navigationBarHidden(true)
    }
    
    
    struct editName: View {
        
        @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
        
        @Binding var profile: ProfileSettings
        
        @State var userInput: String = ""
        
        @State var userOriginalInput: String
        
        var body: some View {
            
            ZStack{
                
                VStack{
                    
                    HStack{
                        Button(action: {
                            
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                            
                            Text("名前")
                                .font(.title3)
                                .fontWeight(.heavy)
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            userOriginalInput = userInput
                            profile.givenName = userInput

                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("完了")
                                .fontWeight(.heavy)
                        }
                    }
                    .foregroundColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    
                    Divider()
                    
                    TextField("名前", text: $userInput, axis: .vertical)
                        .autocapitalization(.none)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                    
                    Divider()
                    
                    Text("友人などから親しみのある名前を使用すると、友人達から見つかりやすくなるかもしれません。")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .padding(.vertical)
                        .padding(.horizontal, 25)
                    
                    Spacer()
                }
            }
            .onAppear{
                userInput = userOriginalInput
            }
            .navigationBarHidden(true)
        }
    }
    
    struct editUsername: View {
        
        @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
        
        @Binding var profile: ProfileSettings
        
        @State var userInput: String = ""
        
        @State var userOriginalInput: String
        
        var body: some View {
            
            ZStack{
                
                VStack{
                    
                    HStack{
                        Button(action: {
                            
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                            
                            Text("ユーザーネーム")
                                .font(.title3)
                                .fontWeight(.heavy)
                        })
                        
                        Spacer()
                        
                        Button(action:{
                            
                            userOriginalInput = userInput
                            profile.preferredUsername = userInput
                            presentationMode.wrappedValue.dismiss()
                        }){
                            Text("完了")
                                .fontWeight(.heavy)
                        }
                        
                    }
                    .foregroundColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    
                    Divider()
                    
                    TextField("ユーザーネーム", text: $userInput, axis: .vertical)
                        .autocapitalization(.none)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                    
                    Divider()
                    
                    Text("ユーザーネームはアカウントを検索する際に使用されます。そのため、検索しやすいユーザーネームにすると、友人達から見つかりやすくなるかもしれません。")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .padding(.vertical)
                        .padding(.horizontal, 25)
                    
                    Spacer()
                }
            }
            .onAppear{
                userInput = userOriginalInput
            }
            .navigationBarHidden(true)
        }
    }
    
    struct editBio: View {
        
        @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
        
        @Binding var profile: ProfileSettings
        
        @State var userInput: String = ""
        
        @State var userOriginalInput: String
        
        var body: some View {
            
            ZStack{
                
                VStack{
                    
                    HStack{
                        Button(action: {
                            
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                            
                            Text("概要欄")
                                .font(.title3)
                                .fontWeight(.heavy)
                        })
                        
                        Spacer()
                        
                        Button(action:{
                            
                            userOriginalInput = userInput
                            profile.bio = userInput
                            presentationMode.wrappedValue.dismiss()
                        }){
                            Text("完了")
                                .fontWeight(.heavy)
                        }
                        
                    }
                    .foregroundColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    
                    Divider()
                    
                    TextField("概要欄", text: $userInput, axis: .vertical)
                        .autocapitalization(.none)
                        .onReceive(userInput.publisher.collect()) {
                            userInput = String($0.prefix(200))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                    
                    Divider()
                    
                    HStack {
                        
                        Spacer()
                        
                        Text("\(userInput.count) / 200")
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    }
                    .padding(.horizontal, 25)
                    
                    Text("概要欄は他のユーザーに自分のことを文面で紹介できる機能です。概要欄を使って自己紹介や気分、何でも思うがままに自分を表現しましょう！概要欄の文字数は200文字制限があります。")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .padding(.vertical)
                        .padding(.horizontal, 25)
                    
                    Spacer()
                }
            }
            .onAppear {
                userInput = userOriginalInput
                if userOriginalInput.count > 200 {
                    userOriginalInput = String(userOriginalInput.prefix(200))
                }
            }
            .navigationBarHidden(true)
        }
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
        titleLabel.text = config.title
        titleLabel.font = buttonTextConfig
        titleLabel.textColor = .arinDarkGreen
        
        stackView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton = createButton(action: #selector(saveButtonTapped), imageName: "", buttonLabel: "Done", tintColor: .arinDarkGreen, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
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
            
            TextField(placeholder, text: $userInput.text, axis: .vertical)
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
            
            Text(bottomInfoText)
                .font(.caption)
                .foregroundColor(Color.secondary)
                .padding(.top, 5)
                .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}
