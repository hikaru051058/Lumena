//
//  PrepPostMainViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/11/04.
//

import Foundation
import UIKit
import SwiftUI

#Preview("PostPrepMainViewPreview") {
    PrepPostMainViewRepresentable()
}

struct PrepPostMainViewRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> PostPrepMainViewController {
        return PostPrepMainViewController()
    }
    
    func updateUIViewController(_ uiViewController: PostPrepMainViewController, context: Context) {
        // Update the view controller if needed
    }
}

class PostPrepMainViewController: UIViewController {
    
    private var progressOptionsView: PrepPostProgressOptionsView!
    
    private var contentCheckView: PrepPostContentCheckViewController!
    private var descriptonView: PrepPostDescriptionViewController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupView(){
        setupProgressBarViwe()
//        setupPrepPostContentCheck()
        setupPrepPostDescription()
    }
    
    private func setupProgressBarViwe() {
        progressOptionsView = PrepPostProgressOptionsView()
//        progressOptionsView.backgroundColor = .arinBlue
        progressOptionsView.delegate = self
        progressOptionsView.translatesAutoresizingMaskIntoConstraints = false
        progressOptionsView.labels = ["Option 1", "Option 2", "Option 3", "Option 4"]
        view.addSubview(progressOptionsView)
        
        NSLayoutConstraint.activate([
            progressOptionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressOptionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressOptionsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressOptionsView.heightAnchor.constraint(equalToConstant: 50) // Define a fixed height
        ])
    }

    private func setupPrepPostContentCheck() {
        contentCheckView = PrepPostContentCheckViewController()
        contentCheckView.view.layer.cornerRadius = 25
        contentCheckView.view.clipsToBounds = true
        addChild(contentCheckView)
        view.addSubview(contentCheckView.view)
        contentCheckView.didMove(toParent: self)
        contentCheckView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentCheckView.view.topAnchor.constraint(equalTo: progressOptionsView.bottomAnchor),
            contentCheckView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentCheckView.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentCheckView.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupPrepPostDescription() {
        descriptonView = PrepPostDescriptionViewController()
        addChild(descriptonView)
        view.addSubview(descriptonView.view)
        descriptonView.didMove(toParent: self)
        descriptonView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptonView.view.topAnchor.constraint(equalTo: progressOptionsView.bottomAnchor, constant: 25),
            descriptonView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            descriptonView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            descriptonView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
        ])
    }
}

extension PostPrepMainViewController: PrepPostProgressProtocol {
    func updateProgress(selectedIndex: Int) {
        // Handle progress update (e.g., update a progress bar)
        print("Progress updated to step \(selectedIndex + 1)")
    }
}
