//
//  TextBasedContentViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/30.
//

import Foundation
import UIKit
import SwiftUI


//
//class TextBasedContentViewController: UIViewController {
//    
//    private var
//}


class TextBasedContentViewController: UIViewController {
    
    private var userInput: UserInput
    
    private var textfield: UIHostingController<TextBasedVerticalTextField>!
    private var characterCountLabel: UILabel!
    
    init(text: String = "") {
        self.userInput = UserInput(text: text)
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
        addTextBody()
    }
}

// MARK: - UserInfo Header

extension TextBasedContentViewController {
    
}


// MARK: - textfield setup

extension TextBasedContentViewController {
    
    private func addTextBody() {
        addTextField()
        //addBottomInfoText()
    }
    
    private func addTextField() {
        let swiftUIView = TextBasedVerticalTextField(placeholder: "What's New?", userInput: userInput, characterLimit: 300)
        textfield = UIHostingController(rootView: swiftUIView)
        
        addChild(textfield)
        view.addSubview(textfield.view)
        textfield.didMove(toParent: self)
        
        textfield.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textfield.view.topAnchor.constraint(equalTo: view.topAnchor),
            textfield.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textfield.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textfield.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

struct TextBasedVerticalTextField: View {
    
    @State var placeholder: String
    @ObservedObject var userInput: UserInput
    var characterLimit: Int
    
    var body: some View {
        VStack {
            TextField(NSLocalizedString(placeholder, comment: ""), text: $userInput.text, axis: .vertical)
                .autocapitalization(.none)
                .onReceive(userInput.text.publisher) { newValue in
                    if userInput.text.count > characterLimit {
                        userInput.text = String(userInput.text.prefix(characterLimit))
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                Text("\(userInput.text.count) / \(characterLimit)")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.vertical, 50)
        .padding(.leading, 20)
        .padding(.trailing, 60)
    }
}
