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
    private var productTagView: PrepPostTagProductsViewController!
    private var productRatingView: PrepPostRatingViewController!
    
    private var backButton: UIButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated) // Restore the navigation bar for other screens
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        setupProgressBarView()
        setupPrepPostContentCheck()
        setupPrepPostDescription()
        setupPrepPostTagProduct()
        setupPrepPostRatingView()
        
        if let _ = progressOptionsView {
            progressOptionsView.updateButton(0)
        }
        updateProgress(selectedIndex: 0)
    }
    
    private func setupProgressBarView() {
        
        setupBackButton()
        
        progressOptionsView = PrepPostProgressOptionsView()
        progressOptionsView.delegate = self
        progressOptionsView.translatesAutoresizingMaskIntoConstraints = false
        progressOptionsView.labels = ["Option 1", "Option 2", "Option 3", "Option 4"]
        view.addSubview(progressOptionsView)
        
        NSLayoutConstraint.activate([
            progressOptionsView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
            progressOptionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressOptionsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressOptionsView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupPrepPostContentCheck() {
        contentCheckView = PrepPostContentCheckViewController()
        contentCheckView.view.layer.cornerRadius = 40
        contentCheckView.view.clipsToBounds = true
        addChild(contentCheckView)
        view.addSubview(contentCheckView.view)
        contentCheckView.didMove(toParent: self)
        contentCheckView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentCheckView.view.topAnchor.constraint(equalTo: progressOptionsView.bottomAnchor),
            contentCheckView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentCheckView.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentCheckView.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
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
            descriptonView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            descriptonView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            descriptonView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
        ])
    }
    
    private func setupPrepPostTagProduct() {
        productTagView = PrepPostTagProductsViewController()
        addChild(productTagView)
        view.addSubview(productTagView.view)
        productTagView.didMove(toParent: self)
        productTagView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productTagView.view.topAnchor.constraint(equalTo: progressOptionsView.bottomAnchor),
            productTagView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            productTagView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productTagView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupPrepPostRatingView() {
        productRatingView = PrepPostRatingViewController()
        addChild(productRatingView)
        view.addSubview(productRatingView.view)
        productRatingView.didMove(toParent: self)
        productRatingView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            productRatingView.view.topAnchor.constraint(equalTo: progressOptionsView.bottomAnchor),
            productRatingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            productRatingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productRatingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func toggleView(for selectedIndex: Int) {
        UIView.animate(withDuration: 0.2, animations: { [self] in
            // Show the view based on the selected index
            switch selectedIndex {
            case 0:
                contentCheckView.view.alpha = 1
                descriptonView.view.alpha = 0
                productTagView.view.alpha = 0
                productRatingView.view.alpha = 0
            case 1:
                contentCheckView.view.alpha = 0
                descriptonView.view.alpha = 1
                productTagView.view.alpha = 0
                productRatingView.view.alpha = 0
            case 2:
                contentCheckView.view.alpha = 0
                descriptonView.view.alpha = 0
                productTagView.view.alpha = 1
                productRatingView.view.alpha = 0
            case 3:
                contentCheckView.view.alpha = 0
                descriptonView.view.alpha = 0
                productTagView.view.alpha = 0
                productRatingView.view.alpha = 1
            default:
                contentCheckView.view.alpha = 0
                descriptonView.view.alpha = 0
                productTagView.view.alpha = 0
                productRatingView.view.alpha = 0
            }
        })
    }
}

extension PostPrepMainViewController {
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: config)?.withTintColor(UIColor.arinDarkGreen, renderingMode: .alwaysOriginal)
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false // Important for programmatic constraints
        
        // Add to view hierarchy
        view.addSubview(backButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16), // Add padding
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30), // Define width
            backButton.heightAnchor.constraint(equalToConstant: 50) // Define height
        ])
    }

    @objc private func backButtonTapped() {
        // Handle back navigation
        navigationController?.popViewController(animated: true) // Go to the previous view controller
    }
}

extension PostPrepMainViewController: PrepPostProgressProtocol {
    func updateProgress(selectedIndex: Int) {
        toggleView(for: selectedIndex)
    }
}
