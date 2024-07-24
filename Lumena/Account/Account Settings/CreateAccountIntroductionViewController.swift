//
//  CreateAccountIntroductionViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/07/19.
//

import Foundation
import UIKit
import SwiftUI

enum createAccountIntroPagePrompts {
    case onLumena
    case productVerification
    case noSponser
}

class CreateAccountIntroViewController: UIViewController {
    private var hostingController: UIHostingController<CreateAccountIntroView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        let createAccountIntroView = CreateAccountIntroView(onNavigateSkinSetting: navigateSkinSetting)

        hostingController = UIHostingController(rootView: createAccountIntroView)
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
    
    func navigateSkinSetting(profile: ProfileSettings) {
        DispatchQueue.main.async {
            let skinSettingVC = SkinSettingViewController(profile: profile)
            self.isModalInPresentation = true
            self.navigationController?.pushViewController(skinSettingVC, animated: true)
        }
    }
}


struct CreateAccountIntroView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State private var promptMessage: [String] = [
        "On Lumena...",
        "This means that the Lume / Product has been verified on our platform",
        "NO SPONSORED\nCONTENT ALLOWED"
    ]
    
    var onNavigateSkinSetting: (ProfileSettings) -> Void = { _ in }
    
    @State private var createAccountPage: createAccountIntroPagePrompts = .onLumena
    @State private var showDescription: Bool = false
    
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
                    
                    Text("How Lumena Works")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title)
                    
                    Spacer()
                }
                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                .padding([.top, .horizontal])
                .padding(.bottom, 5)
                
                Spacer()
            }
            
            VStack {
                
                Spacer()
                
                VStack {
                    
                    switch createAccountPage {
                    case .onLumena:
                        Image(systemName: "bubbles.and.sparkles.fill")
                            .font(Font.system(size: 100))
                            .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                        
                        Text(promptMessage[0])
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                            .padding(.bottom, 40)
                        
                        VStack {
                            (Text("Find")
                                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkestGreen : UIColor.arinLightGreen)) +
                             Text(" reliable products")
                                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen)))
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical)
                            
                            (Text("Learn")
                                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkestGreen : UIColor.arinLightGreen)) +
                             Text(" more about beauty")
                                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen)))
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .fontWeight(.bold)
                            
                            (Text("Share")
                                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkestGreen : UIColor.arinLightGreen)) +
                             Text(" your favorite products")
                                .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen)))
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        }
                        .frame(height: 200)
                        
                    case .productVerification:
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(Font.system(size: 100))
                            .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                        
                        Text(promptMessage[1])
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                            .padding(.bottom, 20)
                            .padding(.horizontal)
                        
                        VStack {
                            Button(action: {withAnimation{showDescription.toggle()}}, label: {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(Font.system(size: 30))
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                            })
                            .padding(.bottom)
                            
                            Text("When you create a video on our app, it automatically adds a check mark to indicate the content's authenticity. Additionally, when you post a video featuring a product, you can scan the product to verify its presence. Scanning successfully adds a check mark to the product on the tagged list, reassuring viewers of its authenticity.")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .opacity(showDescription ? 1 : 0)
                        }
                        .frame(height: 250)
                        
                    case .noSponser:
                        Image(systemName: "bubble.left.and.exclamationmark.bubble.right.fill")
                            .font(Font.system(size: 100))
                            .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                        
                        Text(promptMessage[2])
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                            .padding(.bottom, 20)
                            .padding(.horizontal)
                        
                        VStack {
                            Button(action: {withAnimation{showDescription.toggle()}}, label: {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(Font.system(size: 30))
                                    .foregroundColor(Color(uiColor: colorScheme == .light ? UIColor.arinDarkGreen : UIColor.arinMatGreen))
                            })
                            .padding(.bottom)
                            
                            Text("Our platform was made to help people find reliable products through reliable reviews. We want YOUR own thoughts and feedback and not what other companies want you to say. Posting content sponsored by companies can be against our terms of use and can potentially lead to being banned on our platform.")
                                .foregroundColor(Color(UIColor.secondaryLabel))
                                .multilineTextAlignment(.center)
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .opacity(showDescription ? 1 : 0)
                        }
                        .frame(height: 250)
                    }
                }
                    
                Spacer()
            }
            
            VStack {
      
                Spacer()
                
                Button(action: {
                    withAnimation {
                        if let nextCreateAccountPage = nextPage() {
                            createAccountPage = nextCreateAccountPage
                            showDescription = false
                        } else {
                            onNavigateSkinSetting(GI.shared.profileSettings ?? ProfileManager.shared.getProfile(withID: GI.shared.identityID!))
                        }
                    }
                    
                }) {
                    ZStack {
                        Rectangle()
                            .frame(width: 140, height: 35)
                            .cornerRadius(50)
                            .foregroundColor(.primary)
                        
                        Text("次へ")
                            .fontWeight(.bold)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.background))
                    }
                    .padding(.bottom)
                }
            }
            .padding(.all)
        }
        .navigationBarHidden(true)
    }
    
    
    private func nextPage() -> createAccountIntroPagePrompts? {
        switch createAccountPage {
        case .onLumena:
            return .productVerification
        case .productVerification:
            return .noSponser
        case .noSponser:
            return nil
        }
    }
}

struct CreateAccountIntroductionViewController_Previews: PreviewProvider {
    
    static var Onnavigation : (ProfileSettings) -> Void = { _ in }
    
    static var previews: some View {
        CreateAccountIntroView(onNavigateSkinSetting: Onnavigation)
    }
}
