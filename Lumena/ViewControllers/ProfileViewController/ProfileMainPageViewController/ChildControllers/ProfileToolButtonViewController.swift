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
    func didTapSttingsButton()
}


class ProfileToolButtonViewController: UIView {
    
    var profile: ProfileSettings!
    var colorScheme: UIUserInterfaceStyle = .dark {
        didSet {
            updateButtonColors()
        }
    }
    var tabButtonOpacity: CGFloat = 1.0
    
    private let buttonConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .default)
    
    private var backButton: UIButton!
    private var followRequestButton: UIButton!
    private var settingsButton: UIButton!
    
    var addShadow: Bool = true
    
    weak var delegate: ProfileToolButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(frame: CGRect, profile: ProfileSettings, addShadow: Bool = true) {
        self.profile = profile
        self.addShadow = addShadow
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
        
        updateButtonColors()
    }
    
    private func setupBackButton() {
        backButton = createButton(action: #selector(backButtonTapped), imageName: "chevron.backward", tintColor: buttonTintColor(), shadow: addShadow)
    }
    
    private func setupRequestButton() {
        followRequestButton = createButton(action: #selector(followRequestButtonTapped), imageName: "person.fill.checkmark", tintColor: buttonTintColor(), shadow: addShadow)
        followRequestButton.isHidden = !profile.lockState
    }
    
    private func setupSettingButton() {
        settingsButton = createButton(action: #selector(settingsButtonTapped), imageName: "gear", tintColor: buttonTintColor(), shadow: addShadow)
    }
    
    private func createButton(action: Selector, imageName: String, tintColor: UIColor, shadow: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName, withConfiguration: buttonConfig)?.withTintColor(tintColor), for: .normal)
        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        if shadow {
            addShadow(to: button)
        }
        
        return button
    }
    
    private func updateButtonColors() {
        backButton.tintColor = buttonTintColor()
        followRequestButton?.tintColor = buttonTintColor()
        settingsButton.tintColor = buttonTintColor()
    }
    
    private func buttonTintColor() -> UIColor {
        return colorScheme == .dark ? .white : .black
    }
    
    @objc private func backButtonTapped() {
        delegate?.didTapBackButton()
    }
    
    @objc private func followRequestButtonTapped() {
        delegate?.didTapFollowRequestButton()
    }
    
    @objc private func settingsButtonTapped() {
        delegate?.didTapSttingsButton()
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
