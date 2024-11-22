//
//  PrepPostDescriptionViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/11/05.
//

import Foundation
import UIKit
import SwiftUI

#Preview("PrepPostDescriptionViewPreview") {
    PrepPostDescriptionViewRepresentable()
}

struct PrepPostDescriptionViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> PrepPostDescriptionViewController {
        return PrepPostDescriptionViewController()
    }
    
    func updateUIViewController(_ uiViewController: PrepPostDescriptionViewController, context: Context) {
        // Update the view controller if needed
    }
}

protocol PrepPostDescriptionProtocol: AnyObject {
    func didUpdateText(_ text: String)
}

class PrepPostDescriptionViewController: UIViewController {
    
    private var userInput: UserInput
    private var characterLimit: Int = 300
    private var textfield: UIHostingController<TextBasedVerticalTextField>!
    
    weak var delegate: PrepPostDescriptionProtocol?
    
    init(text: String = "") {
        self.userInput = UserInput(text: text)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        addTextField()
    }
    
    private func addTextField() {
        let swiftUIView = TextBasedVerticalTextField(
            placeholder: "ここから始める",
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
            textfield.view.topAnchor.constraint(equalTo: view.topAnchor),
            textfield.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textfield.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textfield.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
