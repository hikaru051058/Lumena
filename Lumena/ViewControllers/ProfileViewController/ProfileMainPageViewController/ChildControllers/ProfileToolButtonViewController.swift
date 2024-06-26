//
//  ProfileToolButtonViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/28.
//

import UIKit
import SwiftUI


protocol ProfileToolButtonDelegate: AnyObject {
    func didTapBackButton()
    func didTapFollowRequestButton()
    func didTapSettingsButton()
}

class ProfileToolButtonViewController: UIView {
    
    var profile: ProfileSettings!
    var color: UIColor = .primary {
        didSet {
            updateButtonColors()
        }
    }
    var tabButtonOpacity: CGFloat = 1.0
    
    private var backButton: UIButton!
    private var followRequestButton: UIButton!
    private var settingsButton: UIButton!
    
    private let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
    private let buttonTextConfig = UIFont.systemFont(ofSize: 18, weight: .bold)
    var addShadow: Bool = true
    
    weak var delegate: ProfileToolButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(frame: CGRect, profile: ProfileSettings, addShadow: Bool = true, color: UIColor) {
        self.profile = profile
        self.addShadow = addShadow
        self.color = color
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupToolbar()
    }
    
    private func setupToolbar() {
        self.backgroundColor = .clear
        
        setupBackButton()
        setupRequestButton()
        setupSettingButton()
        
        let stackView = UIStackView(arrangedSubviews: [backButton, createFlexibleSpace(), followRequestButton, createFixedSpace(), settingsButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
//        updateButtonColors()
    }
    
    private func setupBackButton() {
        backButton = createButton(action: #selector(backButtonTapped), imageName: "chevron.backward", buttonLabel: "", tintColor: self.color, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    private func setupRequestButton() {
        followRequestButton = createButton(action: #selector(followRequestButtonTapped), imageName: "person.fill.checkmark", buttonLabel: "", tintColor: self.color, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
        followRequestButton.isHidden = !profile.lockState
    }
    
    private func setupSettingButton() {
        settingsButton = createButton(action: #selector(settingsButtonTapped), imageName: "gear", buttonLabel: "", tintColor: self.color, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    private func createButton(action: Selector, imageName: String, buttonLabel: String, tintColor: UIColor, shadow: Bool, buttonTextConfig: UIFont, buttonImageConfig: UIImage.SymbolConfiguration) -> UIButton {
        let button = UIButton()
        if imageName == "" {
            button.setTitle(buttonLabel, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.titleLabel?.font = buttonTextConfig
        } else {
            if let image = UIImage(systemName: imageName, withConfiguration: buttonImageConfig) {
                button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
        
        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        if shadow {
            addShadow(to: button)
        }
        
        return button
    }
    
    private func updateButtonColors() {
        if backButton != nil {
            backButton.tintColor = color
        }
        if followRequestButton != nil {
            followRequestButton?.tintColor = color
        }
        if settingsButton != nil {
            settingsButton.tintColor = color
        }
    }
    
    func updateProfile(profile: ProfileSettings) {
        self.profile = profile
        commonInit()
    }
    
    @objc private func backButtonTapped() {
        delegate?.didTapBackButton()
    }
    
    @objc private func followRequestButtonTapped() {
        delegate?.didTapFollowRequestButton()
    }
    
    @objc private func settingsButtonTapped() {
        delegate?.didTapSettingsButton()
    }
    
    private func createFlexibleSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        return space
    }
    
    private func createFixedSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            space.widthAnchor.constraint(equalToConstant: 16)
        ])
        return space
    }
    
    private func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
    }
}
