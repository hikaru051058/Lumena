//
//  LoginView.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/12.
//


import Foundation
import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

struct LoginView: View{
    
    @State private var loading: Bool = true
    
    @State private var userInput: String = ""
    @State private var password: String = ""
    
    @State private var changePassword: Bool = false
    
    @State private var isActive: Bool = false
    
    @State private var isLoginSuccessful: Bool = false
    @State private var errorMessage: String?
    
    @State var messageLabel: String = ""
    @State private var loginLoading: Bool = false
    @State private var showConfirmationSheet: Bool = false
    @State private var reConfirmationSuccess: Bool = false
    
    @State private var isPresented: Bool = false
    
    @State private var passwordMessage: String = ""
    @State private var passwordChangeLoading: Bool = false
    
    enum FocusTextFields {
        case userInput
        case password
    }
    
    @FocusState var focusState: FocusTextFields?
    @Environment(\.colorScheme) var colorScheme
    
    var onNavigateMain: () -> Void = {}
    var onNavigateCreateAccount: () -> Void = {}
    
    var body: some View {
        
        //NavigationStack {
        
        ZStack{
            GradientEffectView(
                .constant(
                    AnimatedGradient.Model(
                        colors: [
                            Color(red: 0.723, green: 0.88, blue: 0.825),
                            Color(red: 0.552, green: 0.724, blue: 0.831),
                            Color(red: 0.946, green: 0.76, blue: 0.839),
                            (colorScheme == .dark ? Color.black : Color.white)
                        ]
                    )
                )
            )
            .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                
                Image("Lumena-White")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // Adjust the width and height as needed
                    .padding(.all)
                    .padding(.top)
                
                
                if (loading) {
                    
                    Spacer()
                    
                    Image("arin-white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.caption2)
                        .padding([.top, .leading, .trailing], 150)
                        .padding([.bottom], 100)
                    
                } else {
                    
                    ZStack{
                        VStack{
                            
                            Spacer()
                            
                            VStack{
                                TextField("", text: $userInput)
                                    .focused($focusState, equals: .userInput)
                                    .placeholder(when: userInput.isEmpty) {
                                        Text("ユーザー名・電話番号・Email").foregroundColor(.gray)
                                    }
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
                                
                                SecureField("", text: $password)
                                    .focused($focusState, equals: .password)
                                    .placeholder(when: password.isEmpty) {
                                        Text("パスワード").foregroundColor(.gray)
                                    }
                                    .padding(.all, 15)
                                    .foregroundColor(.black)
                                    .background(Color.white.opacity(0.4))
                                    .cornerRadius(15)
                                    .textContentType(.password)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        
                                        if !userInput.isEmpty || !password.isEmpty {
                                            withAnimation {
                                                loginLoading = true
                                            }
                                            Task {
                                                
                                                do {
                                                    
                                                    let signOutResult = await AuthenticationManager.shared.signOut()
                                                    print(signOutResult)
                                                    
                                                    _ = try await AuthenticationManager.shared.signIn(username: userInput, password: password)
                                                    
                                                    loginLoading = false
                                                    isPresented.toggle()
                                                    
                                                    onNavigateMain()
                                                    
                                                } catch {
                                                    messageLabel = "Sign in failed: \(error)"
                                                    loginLoading = false
                                                    if error as? AuthError == AuthError.confirmationRequired {
                                                        showConfirmationSheet = true
                                                    }
                                                    print("Failed with Error: \(messageLabel)")
                                                }
                                            }
                                        }
                                    }
                                
                                
                                HStack{
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        passwordChangeLoading = true
                                        
                                        Task{
                                            
                                            do {
                                                let message = try await AuthenticationManager.shared.resetPassword(username: userInput)
                                                print(message)
                                                passwordMessage = "パスワード変更用のリンクをメールに送信しました。"
                                            } catch {
                                                messageLabel = "パスワード変更先が見つかりませんでした。正しい Email またはユーザーネームを上記に入力してください。Error: \(error)"
                                            }
                                            changePassword = true
                                        }
                                    }){
                                        if passwordChangeLoading {
                                            ProgressView()
                                        } else {
                                            Text("パスワードを忘れた場合")
                                        }
                                    }
                                    .font(.caption2)
                                    .foregroundColor(Color.gray)
                                    .disabled(userInput.isEmpty)
                                    .opacity(userInput.isEmpty ? 0 : 1)
                                    .sheet(isPresented: $changePassword){
                                        ResetPasswordLoginView(username: userInput)
                                    }
                                }
                                .padding(.top, 10)
                                .opacity(loginLoading ? 0 : 1)
                                
                            }
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 50)
                            
                            
                            Spacer()
                            
                            
                            if !loginLoading {
                                
                                Button(action: {
                                    withAnimation {
                                        loginLoading = true
                                    }
                                    
                                    Task {
                                        do {
                                            let signOutResult = await AuthenticationManager.shared.signOut()
                                            print(signOutResult)
                                            
                                            _ = try await AuthenticationManager.shared.signIn(username: userInput, password: password)
                                            
                                            loginLoading = false
                                            isPresented.toggle()
                                            
                                            onNavigateMain()
                                            
                                        } catch {
                                            messageLabel = "Sign in failed: \(error)"
                                            loginLoading = false
                                            if error as? AuthError == AuthError.confirmationRequired {
                                                showConfirmationSheet = true
                                            }
                                            print("Failed with Error: \(messageLabel)")
                                        }
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 140, height: 35)
                                            .cornerRadius(50)
                                            .foregroundColor(.white.opacity((userInput.isEmpty || password.isEmpty) ? 0.4 : 1))
                                        
                                        Text("ログイン")
                                            .fontWeight(.bold)
                                            .font(.caption)
                                            .foregroundColor((userInput.isEmpty || password.isEmpty) ? .gray : .black)
                                    }
                                }
                                .disabled(userInput.isEmpty || password.isEmpty)
                                .padding(.vertical, 15)
                                .sheet(isPresented: $showConfirmationSheet){
                                    
                                    UserReConfirmationCodeView(username: userInput, password: password, reConfirmationSuccess: $reConfirmationSuccess)
                                }
                                .onChange(of: reConfirmationSuccess){ _ in
                                    
                                    if !userInput.isEmpty && !password.isEmpty {
                                        withAnimation {
                                            loginLoading = true
                                        }
                                        
                                        Task {
                                            
                                            do {
                                                
                                                let message = try await AuthenticationManager.shared.signIn(username: userInput, password: password)
                                                
                                                print(message)
                                                loginLoading = false
                                                isPresented.toggle()
                                            } catch {
                                                
                                                messageLabel = "Sign in failed: \(error)"
                                                loginLoading = false
                                                
                                                if error as! AuthError == AuthError.confirmationRequired {
                                                    
                                                    showConfirmationSheet = true
                                                }
                                                
                                                print("Failed with Error: \(messageLabel)")
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {onNavigateCreateAccount()}) {
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 140, height: 35)
                                            .cornerRadius(50)
                                            .foregroundColor(.white)
                                        
                                        Text("新規登録")
                                            .fontWeight(.bold)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.bottom)
                                
                                
                                Text(messageLabel)
                                    .font(.caption2)
                                    .foregroundColor(Color.red)
                                    .padding()
                                    .opacity((messageLabel.isEmpty && !isPresented) ? 0 : 1)
                                    .opacity(isLoginSuccessful ? 0 : 1)
                                
                                
                            } else {
                                
                                ProgressView()
                                    .foregroundColor(Color.gray)
                                    .font(.title)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                
                withAnimation(.easeOut){
                    loading = false
                }
            }
        }
        .navigationBarHidden(true)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}


struct UserReConfirmationCodeView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var username: String
    
    @State var password: String
    
    @Binding var reConfirmationSuccess: Bool
    
    @State private var confirmationCode: String = ""
    
    @State private var confirmState: Bool = false
    
    @State private var errorMessage: Bool = false
    @State private var errorMessageReturn: String = ""
    
    @State private var loading: Bool = false
    
    @State private var confirmedSignUpCheck: Bool = false
    
    var body: some View {
        
        ZStack{
            
            VStack{
                
                HStack{
                    
                    Text("アカウント認証")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "checkmark.shield")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Spacer()
                    
                    
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Text("完了")
                        
                    })
                    
                }
                .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                .padding()
                .padding([.horizontal, .top], 8)
                
                Spacer()
            }
            
            VStack{
                
                Image(systemName: "envelope.badge.fill")
                    .font(Font.system(size: 60))
                    .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                
                
                Text("メールの確認のため、\n６桁の番号を送信させていただきました。\n\n見つからない場合は、再送信のボタンを押してください。\n\nワンタイム確認コードを以下の\n記入欄に入力してください。")
                    .font(.callout)
                    .font(.callout)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.bottom, 20)
                
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
            }
            
            
            VStack{
                
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
                                let message: () = try await AuthenticationManager.shared.confirmSignUp(username: username, confirmationCode: confirmationCode)
                                print(message)
                                confirmedSignUpCheck = true
                            } catch {
                                errorMessageReturn = "\(error)"
                                errorMessage = true
                                loading = false
                            }
                            
                            if confirmedSignUpCheck {
                                
                                do {
                                    let message = try await AuthenticationManager.shared.signIn(username: username, password: password)
                                    print("Successfully logged in: \(message)")
                                    
                                    confirmState = true
                                    reConfirmationSuccess = true
                                    
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    print("Failed with error: \(error)")
                                    errorMessageReturn = "\(error)"
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
                                    .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53).opacity(confirmationCode.count != 6 ? 0.4 : 1))
                                
                                Text("認証")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .foregroundColor(confirmationCode.count != 6 ? .gray : .black)
                            }
                            .padding(.bottom)
                        }
                    }
                    .padding(.top)
                    .disabled((loading || confirmationCode.count != 6))
                    
                    Button(action: {
                        Task{
                            do {
                                let message = try await AuthenticationManager.shared.resendCode(username: username, password: password)
                                print(message)
                            }
                        }
                        
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 140, height: 35)
                                .cornerRadius(50)
                                .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53).opacity(1))
                            
                            Text("再送信")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        .padding(.bottom)
                    }
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}


struct ResetPasswordLoginView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var confirmationCode: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPass: String = ""
    
    @State private var showNewPass: Bool = false
    @State private var showConfPass: Bool = false
    
    @State private var loading: Bool = false
    
    @State var username: String
    
    @State private var resetMessage: String = ""
    
    @State private var successReset: Bool = false
    
    var body: some View {
        
        ZStack{
            
            
            Color(red: 0.86, green: 0.92, blue: 0.87)
                .ignoresSafeArea()
            
            
            VStack{
                HStack{
                    
                    Text("パスワードの変更")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "lock.shield")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Spacer()
                    
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Text("完了")
                        
                    })
                }
                .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                .padding()
                .padding([.horizontal], 8)
                
                Spacer()
                
            }
            .padding()
                
            
            VStack{
                
                Group{
                    
                    TextField("", text: $confirmationCode)
                        .placeholder(when: confirmationCode.isEmpty) {
                            Text("パスワード変更用コードを入力").foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 1)
                        .keyboardType(.numberPad)
                        .disableAutocorrection(true)
                        .onChange(of: confirmationCode) { newValue in
                            if newValue.count > 6 {
                                self.confirmationCode = String(newValue.prefix(6))
                            }
                        }
                    
                    Divider()
                        .padding()
                }
                
                
                Group {
                    ZStack{
                        Group {
                            if !showNewPass {
                                SecureField("", text: $newPassword)
                            } else {
                                TextField("", text: $newPassword)
                            }
                        }
                        .placeholder(when: newPassword.isEmpty) {
                            Text("新しいパスワードを入力").foregroundColor(.gray)
                        }
                        .disableAutocorrection(true)
                        .textContentType(.newPassword)
                        
                        HStack{
                            
                            Spacer()
                            
                            Button(action: {
                                showNewPass.toggle()
                            }){
                                Image(systemName: showNewPass ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 1)
                    .padding(.top)
                    
                    Divider()
                        .padding()
                }
                
                
                Group{
                    ZStack{
                        Group {
                            if !showConfPass {
                                SecureField("", text: $confirmNewPass)
                                
                            } else {
                                TextField("", text: $confirmNewPass)
                            }
                        }
                        .placeholder(when: newPassword.isEmpty) {
                            Text("確認用に新しいパスワードを再入力").foregroundColor(.gray)
                        }
                        .disableAutocorrection(true)
                        .textContentType(.newPassword)
                        
                        HStack{
                            
                            Spacer()
                            
                            Button(action: {
                                showConfPass.toggle()
                            }){
                                Image(systemName: showConfPass ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 1)
                    .padding(.top)
                    
                    Divider()
                        .padding()
                    
                }
            }
            .padding(.horizontal, 25)
            
            VStack{
                
                Spacer()
                
                Text("\(resetMessage)")
                    .font(.callout)
                    .foregroundColor(successReset ? Color.black : Color.red)
                    .padding()
                
                Button(action: {
                    
                    loading = true
                    
                    if newPassword != confirmNewPass {
                        
                        resetMessage = "確認用のパスワードが新しいパスワードと異なるため、再入力してください。"
                        loading = false
                        
                    } else {
                        
                        Task {
                            
                            do {
                                let message = try await AuthenticationManager.shared.confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode)
                                
                                resetMessage = message
                                successReset = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } catch {
                                resetMessage = "\(error)"
                            }
                            
                            print(resetMessage)
                            loading = false
                        }
                    }
                }){
                    
                    if loading {
                        
                        ProgressView()
                        
                    } else {
                        ZStack {
                            Rectangle()
                                .frame(width: 140, height: 35)
                                .cornerRadius(50)
                                .foregroundColor(.white.opacity((confirmationCode.isEmpty || newPassword.isEmpty || confirmNewPass.isEmpty) ? 0.4 : 1))
                            
                            Text("変更")
                                .fontWeight(.bold)
                                .font(.caption)
                                .foregroundColor((confirmationCode.isEmpty || newPassword.isEmpty || confirmNewPass.isEmpty) ? .gray : .black)
                            //.foregroundColor((confirmationCode.isEmpty || newPassword.isEmpty || confirmNewPass.isEmpty || (newPassword != confirm)) ? .gray : .black)
                        }
                        .padding(.bottom)
                    }
                }
                .padding(.top)
                .disabled(confirmationCode.isEmpty && newPassword.isEmpty && confirmNewPass.isEmpty)
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 25)
        }
        .navigationBarHidden(true)
    }
}


struct ResetPasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordLoginView(username: "null")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


struct LoadingView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationStack {
            
            ZStack{
                GradientEffectView(
                    .constant(
                        AnimatedGradient.Model(
                            colors: [
                                Color(red: 0.723, green: 0.88, blue: 0.825),
                                Color(red: 0.552, green: 0.724, blue: 0.831),
                                Color(red: 0.946, green: 0.76, blue: 0.839),
                                (colorScheme == .dark ? Color.black : Color.white)
                            ]
                        )
                    )
                )
                .ignoresSafeArea()
                
                VStack {
                    
                    Spacer()
                    
                    
                    Image("Lumena-White")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300) // Adjust the width and height as needed
                        .padding(.all)
                        .padding(.top)
                    
                    
                    
                    Spacer()
                    
                    Image("arin-white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(.caption2)
                        .padding([.top, .leading, .trailing], 150)
                        .padding([.bottom], 100)
                    
                }
            }
        }
        .navigationBarHidden(true)
    }
}
