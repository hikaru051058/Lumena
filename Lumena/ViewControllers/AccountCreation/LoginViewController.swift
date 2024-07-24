//
//  LoginViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/21.
//

import Foundation
import UIKit
import Amplify
import AWSCognitoAuthPlugin
import SwiftUI

class LoginViewController: UIViewController {
    
    var onLoginSuccess: (() -> Void)?
    
    private var lumenaLogoImageView: UIImageView!
    private var arinLogoImageView: UIImageView!
    private var bottomFunctions: LoginViewBottomFunctions!
    private var backgroundGradient: GradientEffectViewController!
    private var bottomFunctionsHostingController: UIHostingController<LoginViewBottomFunctions>!
    
    private var showForgotPassword: Bool = false {
        didSet {
            bottomFunctions.showForgotPassword = showForgotPassword
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        showInitialImageAndThenSetupBottomFunctions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isModalInPresentation = false
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.systemBackground
        setupGradientBackground(colors: defaultColors(for: traitCollection.userInterfaceStyle).map { Color(uiColor: $0) })
    }
    
    private func setupLayout() {
        setupLumenaLogoImage()
        setupArinLogoImage()
        setupBottomFunctions()
        setupBottomFunctionsLayout()
    }
    
    private func setupBottomFunctions() {
        bottomFunctions = LoginViewBottomFunctions()
        bottomFunctions.onNavigateMain = navigateToMain
        bottomFunctions.onNavigateCreateAccount = navigateToCreateAccount
        bottomFunctions.onShowConfirmationSheet = showConfirmationSheet
        bottomFunctions.onShowResetPasswordSheet = showResetPasswordSheet
        bottomFunctionsHostingController = UIHostingController(rootView: bottomFunctions)
        bottomFunctionsHostingController.view.backgroundColor = .clear
        addChild(bottomFunctionsHostingController)
        view.addSubview(bottomFunctionsHostingController.view)
        bottomFunctionsHostingController.didMove(toParent: self)
        
        bottomFunctionsHostingController.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLumenaLogoImage() {
        
        lumenaLogoImageView = UIImageView(image: UIImage(named: "Lumena-White"))
        lumenaLogoImageView.contentMode = .scaleAspectFit
        lumenaLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lumenaLogoImageView)
        
        NSLayoutConstraint.activate([
            lumenaLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lumenaLogoImageView.widthAnchor.constraint(equalToConstant: 300),
            lumenaLogoImageView.heightAnchor.constraint(equalToConstant: 100),
            lumenaLogoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
        ])
    }
    
    private func setupArinLogoImage() {
        arinLogoImageView = UIImageView(image: UIImage(named: "arin-white"))
        arinLogoImageView.contentMode = .scaleAspectFit
        arinLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arinLogoImageView)
        
        NSLayoutConstraint.activate([
            arinLogoImageView.topAnchor.constraint(equalTo: lumenaLogoImageView.bottomAnchor, constant: 20),
            arinLogoImageView.widthAnchor.constraint(equalToConstant: 100),
            arinLogoImageView.heightAnchor.constraint(equalToConstant: 100),
            arinLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arinLogoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupBottomFunctionsLayout() {
        NSLayoutConstraint.activate([
            bottomFunctionsHostingController.view.topAnchor.constraint(equalTo: lumenaLogoImageView.bottomAnchor, constant: 20),
            bottomFunctionsHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFunctionsHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFunctionsHostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupGradientBackground(colors: [Color]) {
        backgroundGradient = GradientEffectViewController(colors: colors)
        
        addChild(backgroundGradient)
        view.addSubview(backgroundGradient.view)
        backgroundGradient.didMove(toParent: self)
        
        backgroundGradient.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundGradient.view.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundGradient.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundGradient.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundGradient.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func defaultColors(for colorScheme: UIUserInterfaceStyle) -> [UIColor] {
        return [
            UIColor.arinBlue,
            UIColor.arinPink,
            UIColor.arinGreen,
        ]
    }
    
    private func showInitialImageAndThenSetupBottomFunctions() {
        // Initially set the alpha of bottom functions to 0 (invisible)
        bottomFunctionsHostingController.view.alpha = 0
        
        // Show initial image for 1 second, then animate the transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.5, animations: {
                // Fade out the initial logo image view
                self.arinLogoImageView.alpha = 0
                self.bottomFunctionsHostingController.view.alpha = 1
            })
        }
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
            self.isModalInPresentation = true
            self.navigationController?.pushViewController(createAccountVC, animated: true)
        }
    }
    
    private func showConfirmationSheet(username: String, password: String) {
        DispatchQueue.main.async {
            let confirmationVC = UIHostingController(rootView: UserReConfirmationCodeView(username: username, password: password))
            confirmationVC.modalPresentationStyle = .automatic
            confirmationVC.modalTransitionStyle = .crossDissolve
            confirmationVC.isModalInPresentation = true // Lock the modal view
            self.present(confirmationVC, animated: true, completion: nil)
        }
    }
    
    private func showResetPasswordSheet(username: String) {
        DispatchQueue.main.async {
            let resetPasswordVC = UIHostingController(rootView: ResetPasswordLoginView(username: username))
            resetPasswordVC.modalPresentationStyle = .automatic
            resetPasswordVC.modalTransitionStyle = .crossDissolve
            resetPasswordVC.isModalInPresentation = true // Lock the modal view
            self.present(resetPasswordVC, animated: true)
        }
    }
}


struct LoginViewBottomFunctions: View {
    @State  var userInput: String = ""
    @State var password: String = ""
    @State var loginLoading: Bool = false
    @State private var showAlert = false
    @State private var messageLabel = ""
    @FocusState private var focusState: FocusField?
    
    @Environment(\.colorScheme) var colorScheme
    
    enum FocusField: Hashable {
        case userInput
        case password
    }
    
    var onNavigateMain: () -> Void = {}
    var onNavigateCreateAccount: () -> Void = {}
    var onShowConfirmationSheet: ((String, String) -> Void)?
    var onShowResetPasswordSheet: ((String) -> Void)?
    
    @State var showForgotPassword: Bool = false
    
    var body: some View {
        VStack {
            ScrollView {
                Text(messageLabel)
                    .font(.caption2)
                    .foregroundStyle(Color(uiColor: colorScheme == .light ? UIColor.white : UIColor.arinPink))
            }
            .padding(.all, 15)
            .foregroundColor(.black)
            .background(Color.red.opacity(0.3))
            .cornerRadius(15)
            .padding(.bottom, 15)
            .frame(height: 90)
            .opacity(messageLabel.isEmpty ? 0 : 1)
            
            TextField("", text: $userInput)
                .focused($focusState, equals: .userInput)
                .placeholder(when: userInput.isEmpty) {
                    Text("ユーザー名・電話番号・Email").foregroundColor(.gray)
                }
                .frame(height: 23)
                .padding(.all, 15)
                .background(Color.white.opacity(0.4))
                .cornerRadius(15)
                .padding(.bottom, 15)
                .foregroundColor(.black)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .submitLabel(.next)
                .onSubmit {
                    focusState = .password
                }
                .disabled(loginLoading)
            
            SecureField("", text: $password)
                .focused($focusState, equals: .password)
                .placeholder(when: password.isEmpty) {
                    Text("パスワード").foregroundColor(.gray)
                }
                .frame(height: 23)
                .padding(.all, 15)
                .foregroundColor(.black)
                .background(Color.white.opacity(0.4))
                .cornerRadius(15)
                .textContentType(.password)
                .submitLabel(.done)
                .onSubmit {
                    if !userInput.isEmpty || !password.isEmpty {
                        loginProcess()
                    }
                }
                .disabled(loginLoading)
            
            HStack {
                Spacer()
                Button(action: {
                    showForgotPassword = true
                    Task {
                        do {
                            let message = try await AuthenticationManager.shared.resetPassword(username: userInput)
                            print(message)
                            messageLabel = NSLocalizedString("パスワード変更用の６桁の数字をご登録されているメールに送信いたしました。", comment: "")
                            onShowResetPasswordSheet?(userInput)
                            
                            showForgotPassword = false
                            
                        } catch let authError as AuthError {
                            messageLabel = "Failed to reset password: \(authError.localizedDescription)"
                        } catch {
                            messageLabel = NSLocalizedString("パスワード変更先が見つかりませんでした。正しい Email またはユーザーネームを上記に入力してください。", comment: "")
                        }
                    }
                }) {
                    if showForgotPassword {
                        ProgressView()
                    } else {
                        Text("パスワードを忘れた場合")
                    }
                }
                .font(.caption)
                .foregroundColor(Color.secondary)
                .disabled(userInput.isEmpty)
                .opacity(userInput.isEmpty ? 0 : 1)
            }
            .padding(.top, 10)
            .opacity(loginLoading ? 0 : 1)
            
            if !loginLoading {
                Button(action: {
                    if userInput.isEmpty || password.isEmpty {
                        showAlert = true
                    } else {
                        loginProcess()
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 140, height: 35)
                            .cornerRadius(50)
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        
                        Text("ログイン")
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("入力エラー"), message: Text("ユーザーIDとパスワードを入力してください"), dismissButton: .default(Text("OK")))
                }
                .padding(.vertical, 15)
                
                Button(action: { onNavigateCreateAccount() }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 140, height: 35)
                            .cornerRadius(50)
                            .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        
                        Text("新規登録")
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom)
                
            } else {
                ProgressView()
                    .foregroundColor(Color.gray)
                    .font(.title)
            }
        }
        .padding(.horizontal, 50)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut) {
                    loginLoading = false
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func loginProcess() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        if loginLoading {
            return
        }
        withAnimation {
            loginLoading = true
        }
        
        Task {
            do {
                let message = try await AuthenticationManager.shared.signIn(username: userInput, password: password, manualAuthStat: true)
                print(message)
                loginLoading = false
                
                AuthenticationManager.shared.authStatus = .authenticated
                let _ = try await AuthenticationManager.shared.fetchAuthDetails()
                
            } catch let authError as AuthError {
                messageLabel = "Sign in failed: \(authError.localizedDescription)"
                if authError == .confirmationRequired {
                    onShowConfirmationSheet?(userInput, password)
                }
                loginLoading = false
                print("Failed with Error: \(messageLabel)")
            } catch {
                messageLabel = "Sign in failed: \(error.localizedDescription)"
                loginLoading = false
                print("Failed with Error: \(messageLabel)")
            }
        }
    }
}
