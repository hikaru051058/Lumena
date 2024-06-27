//
//  CreateAccount.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/13.
//

import UIKit
import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

struct CreateAccount: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var lastName: String = ""
    @State var firstName: String = ""
    @State var tempPhoneNum: String = "+81"
    @State var dob = Date()
    @State var sex: String = ""
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authPage: Bool = false
    
    @State private var showPassword: Bool = false
    @State private var showPasswordInfo: Bool = false
    @State private var passwordRequirement: Bool = false
    
    @State private var loadingSignUp: Bool = false
    
    @State private var errorMessage: String = ""
    
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
                            .padding(.leading, 15)
                        
                    })
                    
                    Text("新規登録")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                    
                    Spacer()
                }
                .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                .padding(.vertical, 5)
                
                HStack{
                    Text ("MyPaletteアカウントの作成")
                        .foregroundColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                        .fontWeight(.bold)
                        .font(.footnote)
                    
                    Spacer()
                }
                .padding(.leading, 45)
                
                Spacer()
            }
            
            
            VStack{
                
                Spacer()
                
                if(lastName.isEmpty || firstName.isEmpty ||
                   dob.description.isEmpty || email.isEmpty ||
                   username.isEmpty || password.isEmpty || !passwordRequirement) {
                    
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
                    
                    Text("\(errorMessage)")
                        .font(.caption2)
                        .foregroundColor(Color.red)
                        .padding()
                    
                    
                    Button(action: {
                        
                        loadingSignUp = true
                        
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX") // Set the locale to avoid any potential issues
                        formatter.dateFormat = "MM/DD/YYYY"

                        var birthDateString = formatter.string(from: dob)
                        
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.day, .month, .year], from: dob)
                        if let day = components.day, let month = components.month, let year = components.year {
                            birthDateString = String(format: "%02d/%02d/%04d", month, day, year)
                        }

                        Task {
                            do {
                                let message = try await AuthenticationManager.shared.signUp(username: username, password: password, email: email, givenName: firstName, familyName: lastName, preferredUsername: username, birthdate: birthDateString, phoneNumber: tempPhoneNum)
                                
                                print("Success: \(message)")
                                authPage = true
                                
                                navigateToUserConfirmationCodeView(username, password, email)
                                
                            } catch {
                                print("Failure: \(error)")
                                errorMessage = "Error: \(error)"
                            }
                            loadingSignUp = false
                        }
                        
                        
                        
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
                
                Text("サインアップすることにより、利用規約、データ・プライバシー ポリシー、Cookie ポリシー、コミュニティーガイドライン、プラットフォームポリシーに同意したことになります。")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .ignoresSafeArea(.keyboard)
            
            VStack{
                    
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
                        
                        VStack{
                            HStack {
                                TextField("", text: $tempPhoneNum)
                                    .placeholder(when: tempPhoneNum.isEmpty) {
                                        Text("電話番号（ハイフン不要）").foregroundColor(.gray)
                                    }
                                    .keyboardType(.phonePad)
                                    .submitLabel(.next)
                                    .focused($focusState, equals: .tempPhoneNum)
                                    .onSubmit {
                                        focusState = .dob
                                    }
                                    .padding(.horizontal, 5)
                                
                                Spacer()
                            }
                            
                            Divider()
                                .frame(minHeight: 1)
                                .overlay(Color.secondary)
                            
                            Spacer()
                                .padding(.bottom, 5)
                        }
                        .padding(.horizontal, 40)
                        .frame(minHeight: 15)
                        
                        VStack{
                            
                            HStack{
                                
                                Text("誕生日: ")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 5)
                                
                                DatePicker("誕生日", selection: $dob, displayedComponents: .date)
                                    .accentColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                                    .labelsHidden()
                                    .padding(.horizontal, 5)
                                    .datePickerStyle(.compact)
                                    .focused($focusState, equals: .dob)
                             
                                Spacer()
                            }
                            
                            Spacer()
                            
                            Divider()
                                .frame(minHeight: 1)
                                .overlay(Color.secondary)
                            
                            Spacer()
                                .padding(.bottom, 15)
                            
                        }
                        .padding(.horizontal, 40)
                        .frame(minHeight: 15)
                        
                        
                        /*
                        VStack{
                            HStack{
                                
                                Menu(sex.isEmpty ? "性別" : sex) {
                                    Button("女性", action: {sex = "女性"})
                                    Button("男性", action: {sex = "男性"})
                                    Button("その他", action: {sex = "その他"})
                                }
                                .padding(.horizontal, 5)
                                .foregroundColor(sex.isEmpty ? .gray : .black)
                                
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
                         
                         */
                        
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
                            
                            if showPasswordInfo {
                                
                                HStack {
                                    Spacer()
                                    Text("８文字以上\n数字を1つ以上含む\n大文字のアルファベットを1つ以上\n小文字のアルファベットを1つ以上含む").padding().background(Color(red: 0.452, green: 0.634, blue: 0.521)).clipShape(BubbleShape(myMessage: true)).foregroundColor(.white)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                }
                                .padding(.leading, 55)
                                .opacity(showPasswordInfo ? 1 : 0)
                                
                            }
                            
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
                            }
                            
                            Divider()
                                .frame(minHeight: 1)
                                .overlay(passwordRequirement ? Color.secondary : Color.red)
                        }
                        .padding(.horizontal, 40)
                        .frame(minHeight: 15)
                    }
                }
                .foregroundColor(Color.black)
                .frame(height: UIScreen.main.bounds.height*0.6)
                
                Spacer()
            }
            .padding(.top, 120)
        }
        .navigationBarHidden(true)
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
    
    func passwordIsValid() -> Bool {
            let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
            let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
            let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
            let hasMinimumLength = password.count >= 8
            
            return hasUppercase && hasLowercase && hasNumber && hasMinimumLength
        }
}






struct UserConfirmationCodeView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var username: String
    
    @State var password: String
    
    @State var email: String
    
    @State private var confirmationCode: String = ""
    
    @State private var confirmState: Bool = false
    
    @State private var errorMessage: Bool = false
    @State private var errorMessageReturn: String = ""
    
    @State private var loading: Bool = false
    
    @State private var confirmedSignUpCheck: Bool = false
    
    @State private var canResendCode: Bool = true
    @State private var lastResendTime: Date = Date(timeIntervalSince1970: 0)
    
    var onNavigateSkinSetting: ([Int]) -> Void = { _ in }
    
    var body: some View {
        
        ZStack{
            
            Color(red: 0.86, green: 0.92, blue: 0.87)
                .ignoresSafeArea()
            
            VStack{
                
                HStack{
                    
                    Text("アカウント認証")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                    
                    Image(systemName: "checkmark.shield")
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                    
                    Spacer()
                }
                .padding()
//                .padding(.vertical, 5)
                
                
                Spacer()
            }
            
            VStack{
                
                Image(systemName: "envelope.badge.fill")
                    .font(Font.system(size: 50))
                    .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                
                
                VStack{
                    HStack {
                        TextField("", text: $confirmationCode)
                            .placeholder(when: confirmationCode.isEmpty) {
                                Text("認証コードを入力").foregroundColor(.gray)
                            }
                            .foregroundColor(Color.black)
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 5)
                            .disableAutocorrection(true)
                            .onChange(of: confirmationCode) { newValue in
                                if newValue.count > 6 {
                                    self.confirmationCode = String(newValue.prefix(6))
                                }
                            }
                        
                        Spacer()
                    }
                    
                    Divider()
                        .frame(minHeight: 1)
                        .overlay(Color.secondary)
                }
                .padding(.horizontal, 40)
                .frame(minHeight: 15)
                .padding(.bottom, 200)
                
                Text("メールの確認のため、\n６桁の番号を送信させていただきました。\n\n見つからない場合は、再送信のボタンを押してください。\n\nワンタイム確認コードを以下の\n記入欄に入力してください。")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.bottom, 20)
                
            }
            .padding(.top)
            
            VStack {
                
                Spacer()
                
                if errorMessage {
                    Text("\(errorMessageReturn)")
                        .foregroundColor(Color.red)
                        .font(.caption2)
                }
                    
                if !confirmState {
                    Button(action: {
                        loading = true
                        Task {
                            
                            do {
                                try await AuthenticationManager.shared.confirmSignUp(username: username, confirmationCode: confirmationCode)
                                confirmedSignUpCheck = true
                            } catch {
                                print("error in confirmSignUp: \(error)")
                                errorMessageReturn = "\(error)"
                                errorMessage = true
                                loading = false
                            }
                            
                            if confirmedSignUpCheck {
                                
                                do {
                                    let _ = await AuthenticationManager.shared.signOut()
                                    let signInMessage = try await AuthenticationManager.shared.signIn(username: username, password: password)
                                    print("Successfully logged in: \(signInMessage)")
                                    confirmState = true
                                    
                                } catch {
                                    print("Sign-in after confirmation failed with error: \(error)")
                                    errorMessageReturn = "\((error))"
                                    errorMessage = true
                                    loading = false
                                }
                            }
                        }
                    }) {
                        if loading {
                            
                            ProgressView()
                            
                        } else {
                            ZStack {
                                Rectangle()
                                    .frame(width: 140, height: 35)
                                    .cornerRadius(50)
                                    .foregroundColor(.white.opacity(confirmationCode.count != 6 ? 0.4 : 1))
                                
                                Text("認証")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .foregroundColor(confirmationCode.count != 6 ? .gray : .black)
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
                                    .foregroundColor(.white.opacity(!canResendCode ? 0.4 : 1))
                                
                                Text("再送信")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .foregroundColor(!canResendCode ? .gray : .black)
                            }
                            .padding(.bottom)
                        }
                    }
                    .disabled(loading || !canResendCode)
                    
                } else {
                    
                    Button(action: {onNavigateSkinSetting(GI.shared.profileSettings?.skinSetting ?? [])} ) {
                        ZStack {
                            Rectangle()
                                .frame(width: 140, height: 35)
                                .cornerRadius(50)
                                .foregroundColor(.white.opacity(1))
                            
                            Text("次へ")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
