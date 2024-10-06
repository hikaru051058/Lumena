//
//  CreateAccount.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/13.
//

import UIKit
import Combine
import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

struct CreateAccount: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var lastName: String = ""
    @State var firstName: String = ""
    @State var tempPhoneNum: String = "+81"
    @State var selectedAge: Int = 0
    @State var sex: String = ""
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authPage: Bool = false
    
    @State var isAbove13: Bool = false
    
    @State private var showPassword: Bool = false
    @State private var showPasswordInfo: Bool = false
    @State private var passwordRequirement: Bool = false
    
    @State private var loadingSignUp: Bool = false
    
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var isValidInput = true
    
    @State private var isKeyboardVisible: Bool = false
    @State private var scrollViewProxy: ScrollViewProxy?
    
    enum FocusTextFields {
        case lastName
        case firstName
        case tempPhoneNum
        case dob
        case email
        case username
        case password
    }
    
    @FocusState var focusState: FocusTextFields?
    
    var navigateToUserConfirmationCodeView: (String, String, String) -> Void = { _, _, _ in }
    
    var body: some View {
        
        ZStack{
            Color(red: 0.86, green: 0.92, blue: 0.87)
                .ignoresSafeArea()
            
            VStack{
                
                HStack{
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                    })
                    
                    Text("新規登録")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                    
                    Spacer()
                }
                .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
                
                HStack{
                    Text ("Lumenaアカウントの作成")
                        .foregroundColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                        .fontWeight(.bold)
                        .font(.footnote)
                    
                    Spacer()
                }
                .padding(.leading, 45)
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            
            
            VStack{
                
                ScrollViewReader { proxy in
                    
                    ScrollView {
                        
                        VStack{
                            
                            VStack{
                                
                                HStack{
                                    
                                    TextField("", text: $lastName)
                                        .placeholder(when: lastName.isEmpty) {
                                            Text("姓").foregroundColor(.gray)
                                        }
                                        .onReceive(lastName.publisher.collect()) {
                                            lastName = String($0.prefix(23))
                                        }
                                        .submitLabel(.next)
                                        .focused($focusState, equals: .lastName)
                                        .onSubmit {
                                            focusState = .firstName
                                        }
                                        .padding(.horizontal, 5)
                                    
                                    Spacer()
                                    
                                    Text("\(lastName.count) / 23")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(Color.secondary)
                                
                                Spacer()
                                    .padding(.bottom, 15)
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 15)
                            .id("top")
                            
                            VStack{
                                HStack{
                                    
                                    TextField("", text: $firstName)
                                        .placeholder(when: firstName.isEmpty) {
                                            Text("名").foregroundColor(.gray)
                                        }
                                        .onReceive(firstName.publisher.collect()) {
                                            firstName = String($0.prefix(23))
                                        }
                                        .submitLabel(.next)
                                        .focused($focusState, equals: .firstName)
                                        .onSubmit {
                                            focusState = .tempPhoneNum
                                        }
                                        .padding(.horizontal, 5)
                                    
                                    Spacer()
                                    
                                    Text("\(firstName.count) / 23")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(Color.secondary)
                                
                                Spacer()
                                    .padding(.bottom, 15)
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 15)
                            
                            VStack {
                                
                                HStack {
                                    Text("年齢")
                                        .padding(.horizontal, 5)
                                        .foregroundColor(isValidInput ? .gray : .red)
                                    
                                    Text("13歳以上です")
                                        .foregroundColor(isValidInput ? .gray : .red)
                                    
                                    Spacer()
                                    
                                    CheckboxViewRepresentable(isAbove13: $isAbove13)
                                        .onChange(of: isAbove13) { newValue in
                                            isValidInput = newValue
                                            if !isValidInput {
                                                showAlert = true
                                            }
                                        }
                                        .alert(isPresented: $showAlert) {
                                            Alert(title: Text(NSLocalizedString("エラー", comment: "")), message: Text(NSLocalizedString("このアプリを利用するには、13歳以上である必要があります。", comment: "")), dismissButton: .default(Text("OK")))
                                        }
                                        .frame(width: 50)
                                }
                                
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(isValidInput ? Color.secondary : Color.red)
                                
                                Spacer()
                                    .padding(.bottom, 15)
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 15)

                            
                            VStack{
                                HStack{
                                    
                                    TextField("", text: $email)
                                        .placeholder(when: email.isEmpty) {
                                            Text("Email").foregroundColor(.gray)
                                        }
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .submitLabel(.next)
                                        .focused($focusState, equals: .email)
                                        .onSubmit {
                                            focusState = .username
                                        }
                                    
                                        .padding(.horizontal, 5)
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(Color.secondary)
                                
                                Spacer()
                                    .padding(.bottom, 15)
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 15)
                            
                            VStack{
                                HStack{
                                    
                                    TextField("", text: $username)
                                        .placeholder(when: username.isEmpty) {
                                            Text("ユーザーネーム").foregroundColor(.gray)
                                        }
                                        .onReceive(username.publisher.collect()) {
                                            username = String($0.prefix(23))
                                        }
                                        .autocapitalization(.none)
                                        .submitLabel(.next)
                                        .focused($focusState, equals: .username)
                                        .onSubmit {
                                            focusState = .password
                                        }
                                        .padding(.horizontal, 5)
                                    
                                    Spacer()
                                    
                                    Text("\(username.count) / 23")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(Color.secondary)
                                
                                Spacer()
                                    .padding(.bottom, 15)
                                
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 15)
                            
                            VStack{
                                
                                HStack{
                                    
                                    Group{
                                        if(showPassword){
                                            TextField("", text: $password)
                                                .placeholder(when: password.isEmpty) {
                                                    Text("パスワード").foregroundColor(passwordRequirement ? .gray : .red)
                                                }
                                                .padding(.bottom, 2)
                                        } else {
                                            
                                            SecureField("", text: $password)
                                                .placeholder(when: password.isEmpty) {
                                                    Text("パスワード").foregroundColor(passwordRequirement ? .gray : .red)
                                                }
                                                .padding(.bottom, 3)
                                        }
                                    }
                                    .foregroundColor(passwordRequirement ? .black : .red)
                                    .submitLabel(.done)
                                    .focused($focusState, equals: .password)
                                    .padding([.horizontal, .bottom], 5)
                                    .onReceive(password.publisher.collect()) { _ in
                                        // Check password validity whenever it changes
                                        if !password.isEmpty {
                                            passwordRequirement = passwordIsValid()
                                        } else {
                                            passwordRequirement = true
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    
                                    Group {
                                        if(showPassword){
                                            Image(systemName: "eye.fill")
                                                .foregroundColor(.gray)
                                        } else {
                                            
                                            Image(systemName: "eye.slash.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }.onTapGesture {
                                        showPassword.toggle()
                                    }
                                    
                                    Button(action: {
                                        withAnimation{
                                            showPasswordInfo.toggle()
                                        }
                                    }){
                                        
                                        Image(systemName: "info.circle")
                                            .foregroundColor(Color.gray)
                                    }
                                    .alert(isPresented: $showPasswordInfo, content: {
                                        Alert(title: Text("Password Structure"), message: Text(NSLocalizedString("8文字以上\n数字を1つ以上含む\n大文字のアルファベットを1つ以上\n小文字のアルファベットを1つ以上含む", comment: "")), dismissButton: .default(Text("OK")))
                                    })
                                }
                                
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(passwordRequirement ? Color.secondary : Color.red)
                                
                            }
                            .padding(.horizontal, 40)
                            .frame(minHeight: 15)
                            
                            ScrollView {
                                Text(errorMessage)
                                    .font(.caption2)
                                    .foregroundColor(Color.red)
                            }
                            .frame(height: UIScreen.main.bounds.height*0.1)
                            .opacity((errorMessage.isEmpty) ? 0 : 1)
                            .scrollDisabled(false)
                            
                            Spacer()
                                .frame(height: 50)
                        }
                    }
                    .scrollDisabled(!isKeyboardVisible)
                    .foregroundColor(Color.black)
                    .onAppear {
                        self.scrollViewProxy = proxy
                    }
                }
                
                VStack {
                    if(lastName.isEmpty || firstName.isEmpty ||
                       /*(selectedAge < 13)*/!isAbove13 || !isValidInput ||
                       email.isEmpty || username.isEmpty ||
                       password.isEmpty || !passwordRequirement)
                    {
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 140, height: 35)
                                .cornerRadius(50)
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text("新規登録")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom)
                        
                    } else {
                        
                        Button(action: {
                            createAccountProcess()
                            
                        }) {
                            
                            ZStack {
                                
                                if loadingSignUp{
                                    
                                    ProgressView()
                                        .foregroundColor(Color.gray)
                                        .padding()
                                } else {
                                    Rectangle()
                                        .frame(width: 140, height: 35)
                                        .cornerRadius(50)
                                        .foregroundColor(.white.opacity(1))
                                    
                                    Text("新規登録")
                                        .fontWeight(.bold)
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                    
                    HyperLinkTextView(text: parsedContent.text, hyperlinks: parsedContent.hyperlinks)
                        .padding(.horizontal)
                        .frame(height: UIScreen.main.bounds.height*0.1)
                    
                }
            }
            .ignoresSafeArea(.keyboard)
            .padding(.top, 120)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
                scrollViewProxy?.scrollTo("top", anchor: .top)
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    class NumbersOnly: ObservableObject {
        @Published var value = "" {
            didSet {
                let filtered = value.filter { $0.isNumber }
                
                if value != filtered {
                    value = filtered
                }
            }
        }
    }
    
    private func createAccountProcess() {
        loadingSignUp = true
        
        if authPage {
            navigateToUserConfirmationCodeView(username, password, email)
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        
        let birthDateString = convertAgeToTimestamp(selectedAge: 13)//selectedAge)
        
        Task {
            do {
                _ = try await AuthenticationManager.shared.signUp(
                    username: username,
                    password: password,
                    email: email,
                    givenName: firstName,
                    familyName: lastName,
                    preferredUsername: username,
                    birthdate: String(birthDateString)
                )
                
                authPage = true
                navigateToUserConfirmationCodeView(username, password, email)
                
            } catch {
                print("Failure: \(error)")
                errorMessage = "Error: \(error)"
            }
            loadingSignUp = false
        }
    }
    
    func passwordIsValid() -> Bool {
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasMinimumLength = password.count >= 8
        
        return hasUppercase && hasLowercase && hasNumber && hasMinimumLength
    }
    
    private var parsedContent: (text: String, hyperlinks: [String: String]) {
        return CreateAccount.parseContent(CreateAccount.privacyPolicyContent)
    }
    
    private func convertAgeToTimestamp(selectedAge: Int) -> Int {
        // Calculate the birthdate from the age
        let calendar = Calendar.current
        let currentDate = Date()
        let birthdate = calendar.date(byAdding: .year, value: -selectedAge, to: currentDate)!

        // Get the timestamp
        let timestamp = Int(birthdate.timeIntervalSince1970)
        return timestamp
    }
    
    static let privacyPolicyContent: [hyperLinkContent] = [
        .text(NSLocalizedString("サインアップすることにより、", comment: "CreateAccountAgreementText")),
        .link(text: NSLocalizedString("利用規約", comment: "CreateAccountAgreementText"), url: "https://www.arin-tech.com/terms-of-use-eng"),
        .text(NSLocalizedString("、", comment: "CreateAccountAgreementText")),
        .link(text: NSLocalizedString("プライバシーポリシー", comment: "CreateAccountAgreementText"), url: "https://www.arin-tech.com/terms-of-use-eng-1"),
        .text(NSLocalizedString("、", comment: "CreateAccountAgreementText")),
        .link(text: NSLocalizedString("コミュニティーガイドライン", comment: "CreateAccountAgreementText"), url: "https://www.arin-tech.com/terms-of-use-eng-1-1"),
        .text(NSLocalizedString("、", comment: "CreateAccountAgreementText")),
        .link(text: NSLocalizedString("プラットフォームポリシー", comment: "CreateAccountAgreementText"), url: "https://www.arin-tech.com/terms-of-use-eng-1-1-1"),
        .text(NSLocalizedString("に同意したことになります。", comment: "CreateAccountAgreementText"))
    ]
    
    static func parseContent(_ content: [hyperLinkContent]) -> (String, [String: String]) {
        var text = ""
        var hyperlinks: [String: String] = [:]
        
        for item in content {
            switch item {
            case .text(let value):
                text += value
            case .link(let linkText, let url):
                text += linkText
                hyperlinks[linkText] = url
            }
        }
        
        return (text, hyperlinks)
    }
}

struct UserConfirmationCodeView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var username: String
    
    @State var password: String
    
    @State var email: String
    
    @State var profile: ProfileSettings? = nil
    
    @State private var confirmationCode: String = ""
    @State private var promptMessage: String = "メールの確認のため、６桁の番号を送信させていただきました。見つからない場合は、再送信のボタンを押してください"
    
    @State private var confirmState: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var loading: Bool = false
    
    @State private var confirmedSignUpCheck: Bool = false
    
    @State private var canResendCode: Bool = true
    @State private var lastResendTime: Date = Date(timeIntervalSince1970: 0)
    
    @State private var keyboardHeight: CGFloat = 0
    
    var onNavigateIntroView: (ProfileSettings) -> Void = { _ in }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack{
            
            VStack{
                
                HStack{
                    
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                    })
                    
                    Text("アカウント認証")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "checkmark.shield.fill")
                        .font(.title)
                    
                    Spacer()
                }
                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            
            VStack {
                
                Spacer()
                
                Image(systemName: "envelope.badge.fill")
                    .font(Font.system(size: 50))
                    .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                    .padding(.top, 50)
                
                Text(NSLocalizedString(promptMessage, comment: "AccountValidationCode"))
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                    .padding(.vertical)
                
                
                TextField("", text: $confirmationCode)
                    .placeholder(when: confirmationCode.isEmpty) {
                        Text("認証コード").foregroundColor(.gray)
                    }
                    .frame(height: 23)
                    .padding(.all, 15)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(15)
                    .padding(.bottom, 15)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.numberPad)
                    .textContentType(.username)
                    .submitLabel(.next)
                    .onSubmit {
                        confirmationAction()
                    }
                    .onChange(of: confirmationCode) { newValue in
                        if newValue.count > 6 {
                            self.confirmationCode = String(newValue.prefix(6))
                        }
                    }
                    .disabled(loading)
                
                ScrollView {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                        .foregroundStyle(Color(uiColor: colorScheme == .light ? UIColor.white : UIColor.arinPink))
                }
                .padding(.all, 15)
                .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width-32, height: 90)
                .background(Color.red.opacity(0.3))
                .cornerRadius(15)
                .padding(.bottom, 15)
                .opacity(errorMessage.isEmpty ? 0 : 1)
                .padding(.bottom, 150)
                
                Spacer()
            }
            .padding(.all)
            
            VStack {
                
                Spacer()
                
                VStack {
                    Button(action: {
                        confirmationAction()
                    }) {
                        if loading {
                            ProgressView()
                        } else {
                            ZStack {
                                Rectangle()
                                    .frame(width: 140, height: 35)
                                    .cornerRadius(50)
                                    .foregroundColor(.primary.opacity(confirmationCode.count != 6 ? 0.2 : 1))
                                
                                
                                Text("認証")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.background))
                            }
                            .padding(.bottom)
                        }
                    }
                    .disabled(loading || confirmationCode.count != 6)
                    
                    Button(action: {
                        Task{
                            do {
                                let message = try await AuthenticationManager.shared.resendCode(username: username, password: password)
                                
                                lastResendTime = Date()
                                canResendCode = false
                                print(message)
                                
                            } catch {
                                
                                print(error)
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                            canResendCode = true
                        }
                        
                    }) {
                        if !loading {
                            ZStack {
                                Rectangle()
                                    .frame(width: 140, height: 35)
                                    .cornerRadius(50)
                                    .foregroundColor(.primary.opacity(!canResendCode ? 0.2 : 1))
                                
                                Text("再送信")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.background))
                            }
                            .padding(.bottom)
                        }
                    }
                    .disabled(loading || !canResendCode)
                }
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .padding(.bottom)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func confirmationAction() {
        loading = true
        Task {
            
            do {
                try await AuthenticationManager.shared.confirmSignUp(username: username, confirmationCode: confirmationCode)
                confirmedSignUpCheck = true
                
                do {
                    _ = try await AuthenticationManager.shared.signIn(username: username, password: password, manualAuthStat: true)
                    confirmState = true
                    if let newIdentityID = AuthenticationManager.shared.identityID {
                        do {
                            profile = try await ProfileManager.shared.getProfile(withID: newIdentityID)
                            onNavigateIntroView(profile!)
                        } catch {
                            print("Error: Could not fetch the user profile for \(newIdentityID) - \(error)")
                        }
                    } else {
                        print("Error: No identity ID was returned from AuthenticationManager in UserConfirmationView")
                    }
                } catch {
                    print("Sign-in after confirmation failed with error: \(error)")
                    errorMessage = "\((error))"
                    loading = false
                }
                
            } catch {
                print("error in confirmSignUp: \(error)")
                errorMessage = "\(error)"
                loading = false
            }
        }
    }
}

#Preview("UserConfirmationCodePreview") {
    
    UserConfirmationCodeView(username: "", password: "", email: "")
}

class CheckboxViewCoordinator: NSObject {
    var parent: CheckboxViewRepresentable

    init(parent: CheckboxViewRepresentable) {
        self.parent = parent
    }

    @objc func toggleCheckbox() {
        parent.isAbove13.toggle()
    }
}

struct CheckboxViewRepresentable: UIViewRepresentable {
    @Binding var isAbove13: Bool

    func makeUIView(context: Context) -> UIButton {
        let checkboxButton = CheckboxButton(frame: .zero)
        checkboxButton.addTarget(context.coordinator, action: #selector(CheckboxViewCoordinator.toggleCheckbox), for: .touchUpInside)
        return checkboxButton
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        (uiView as! CheckboxButton).isChecked = isAbove13
    }

    func makeCoordinator() -> CheckboxViewCoordinator {
        CheckboxViewCoordinator(parent: self)
    }
}

class CheckboxButton: UIButton {
    var isChecked: Bool = false {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addTarget(self, action: #selector(toggleChecked), for: .touchUpInside)
        updateUI()
    }

    @objc private func toggleChecked() {
        animateCheckbox()
    }

    private func updateUI() {
        let imageName = isChecked ? "square.fill" : "square"
        let image = UIImage(systemName: imageName)
        setImage(image, for: .normal)
        tintColor = isChecked ? .arinDarkGreen : .gray
    }

    private func animateCheckbox() {
        isChecked.toggle()
        let scale: CGFloat = isChecked ? 1.3 : 0.7

        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        })

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

class InvitationCodeViewController: UIViewController {
    
    @State private var invitationCode: String?
    @State private var invitationQL: InvitationQL?
    
    private var promptMessage: UILabel!
    
}

struct InvitationCodeView: View {
    
    @State private var invitationCodeInput: String = ""
    @State private var invitationQL: InvitationQL?
    @State private var submitting: Bool = false
    
    @State var errorMessage: String = ""
    
    private var promptMessage: String = "If you downloaded Lumena through an invitaiton, enter their referral code here!"
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        
        ZStack {
            
            VStack{
                
                HStack{
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                    })
                    .padding(.leading)
                    
                    Text("招待コード")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "number.circle.fill")
                        .font(.title)
                    
                    Spacer()
                }
                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                .padding(.top)
                .padding(.bottom, 5)
                
                Spacer()
            }
            
            
            VStack {
                
                Spacer()
                
                Text(promptMessage)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                    .padding(.vertical)
                
                
                TextField("", text: $invitationCodeInput)
                    .placeholder(when: invitationCodeInput.isEmpty) {
                        Text("招待コード").foregroundColor(.gray)
                    }
                    .frame(height: 23)
                    .padding(.all, 15)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(15)
                    .padding(.bottom, 15)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .submitLabel(.next)
                    .onSubmit {
                        //
                    }
                    .disabled(submitting)
                    .padding(.bottom, 150)
                
                Spacer()
            }
            .padding(.all)
            
            
            VStack {
                
                Spacer()
                
                ScrollView {
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                        .foregroundStyle(Color(uiColor: colorScheme == .light ? UIColor.white : UIColor.arinPink))
                }
                .padding(.all, 15)
                .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width-32, height: 90)
                .background(Color.red.opacity(0.3))
                .cornerRadius(15)
                .padding(.bottom, 15)
                .opacity(errorMessage.isEmpty ? 0 : 1)
                
                VStack {
                    Button(action: {
                        
                        // button label -> skip -> when enters full code (validate) -> returns organization name -> button label changes to submit
                        
                        // check button -> fetches organization name by looking up the invitaion code from origanization table
                        // prints out the name of the organization
                        
                        
                        // call api with invitaion code and useridentityID
                        // api validates the code by looking up with the database of organizationID
                        // appends invitation to InvitationQL table
                        // returns 200 or 400
                        
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 140, height: 35)
                                .cornerRadius(50)
                                .foregroundColor(.primary)
                            
                            Text(invitationCodeInput.isEmpty ? "スキップ" : "次へ")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor(Color(UIColor.background))
                        }
                        .padding(.bottom)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.3)
            }
        }
    }
}

#Preview("InvitationCodePreview") {
    
    InvitationCodeView()
}
