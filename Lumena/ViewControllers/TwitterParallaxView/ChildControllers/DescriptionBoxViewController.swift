//
//  DescriptionBoxViewController.swift
//  test
//
//  Created by 島田晃 on 2024/05/20.
//

import UIKit

class ExpandableTextViewController: UIViewController {

    var descriptionLabel: UILabel!
    var readMoreButton: UIButton!
    var isExpanded: Bool = false
    
    var descriptionLabelHeightConstraint: NSLayoutConstraint!
    var readMoreButtonBottomConstraint: NSLayoutConstraint!
    
    let text = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
        """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 2
        descriptionLabel.text = text
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(descriptionLabel)
        
        descriptionLabelHeightConstraint = descriptionLabel.heightAnchor.constraint(equalToConstant: 40) // Initial height for 2 lines of text
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionLabelHeightConstraint,
            descriptionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        readMoreButton = UIButton(type: .system)
        readMoreButton.setTitle("  more", for: .normal)
        readMoreButton.tintColor = .secondaryLabel
        readMoreButton.addTarget(self, action: #selector(didTapReadMore), for: .touchUpInside)
        readMoreButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(readMoreButton)
        
        readMoreButtonBottomConstraint = readMoreButton.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6)
        
        NSLayoutConstraint.activate([
            readMoreButton.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            readMoreButtonBottomConstraint
        ])
        
        addGradientToButton(readMoreButton)
    }
    
    private func addGradientToButton(_ button: UIButton) {
        let gradientLayer = CAGradientLayer()
        let edgeColor = UIColor.white.cgColor.copy(alpha: 0.01)
        gradientLayer.colors = [edgeColor!, UIColor.gray.cgColor]
        gradientLayer.locations = [0.0, 0.4]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.4, y: 0.5)
        gradientLayer.frame = button.bounds
        
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc private func didTapReadMore() {
        isExpanded.toggle()
        
        if isExpanded {
            descriptionLabel.numberOfLines = 0
            readMoreButton.setTitle("  close", for: .normal)
            
            let height = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
            descriptionLabelHeightConstraint.constant = height
        } else {
            descriptionLabel.numberOfLines = 2
            readMoreButton.setTitle("  more", for: .normal)
            
            let height = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
            descriptionLabelHeightConstraint.constant = height > 40 ? 40 : height // Reset to initial height for 2 lines of text
        }
        
//        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
    private func updateGradientFrame() {
        if let gradientLayer = readMoreButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = readMoreButton.bounds
        }
    }
}
