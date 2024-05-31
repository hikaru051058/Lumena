//
//  ProfileToolButtonViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/28.
//

import UIKit

class ProfileToolButtonViewController: UIToolbar {
    
    var profile: ProfileSettings!
    var colorScheme: UIUserInterfaceStyle = .dark {
        didSet {
            updateButtonColors()
        }
    }
    var tabButtonOpacity: CGFloat = 1.0
    
    let buttonConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .default)
    
    var backButton: UIBarButtonItem!
    var followRequestButton: UIBarButtonItem!
    var settingsButton: UIBarButtonItem!
    
    var addShadow: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToolbar()
    }
    
    init(frame: CGRect, profile: ProfileSettings, addShadow: Bool = true) {
        self.profile = profile
        self.addShadow = addShadow
        super.init(frame: frame)
        setupToolbar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupToolbar()
    }
    
    private func setupToolbar() {
        
        self.backgroundColor = .clear
        self.barTintColor = .clear
        self.isTranslucent = true
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        self.standardAppearance = appearance
        
        var items = [UIBarButtonItem]()
                
        setupBackButton()
        items.append(backButton)
        
        // Flexible space to push other buttons to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items.append(flexibleSpace)
        
        if profile.lockState {
            setupRequestButton()
            items.append(followRequestButton)
        }
        
        // Adding fixed space between checkmark and gear icons
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 16 // Adjust the width as needed
        items.append(fixedSpace)
        
        setupSettingButton()
        items.append(settingsButton)
        
        setItems(items, animated: false)
    }
    
    private func setupBackButton() {
        backButton = UIBarButtonItem.menuButton(self, action: #selector(backButtonTapped), imageName: "chevron.backward", buttonConfig: buttonConfig, tintColor: buttonTintColor(), shadow: addShadow)
    }
    
    private func setupRequestButton() {
        followRequestButton = UIBarButtonItem.menuButton(self, action: #selector(followRequestButtonTapped), imageName: "person.fill.checkmark", buttonConfig: buttonConfig, tintColor: buttonTintColor(), shadow: addShadow)
    }
    
    private func setupSettingButton() {
        settingsButton = UIBarButtonItem.menuButton(self, action: #selector(settingsButtonTapped), imageName: "gear", buttonConfig: buttonConfig, tintColor: buttonTintColor(), shadow: addShadow)
    }
    
    private func updateButtonColors() {
        backButton.customView?.tintColor = buttonTintColor()
        if followRequestButton != nil {
            followRequestButton.customView?.tintColor = buttonTintColor()
        }
        settingsButton.customView?.tintColor = buttonTintColor()
    }
    
    private func buttonTintColor() -> UIColor {
        return colorScheme == .dark ? .white : .black
    }
    
    @objc private func backButtonTapped() {
        // Handle back button action
    }
    
    @objc private func followRequestButtonTapped() {
        // Handle follow request button action
    }
    
    @objc private func settingsButtonTapped() {
        // Handle settings button action
    }
}

extension UIBarButtonItem {
    
    static func menuButton(_ target: Any?, action: Selector, imageName: String, buttonConfig: UIImage.SymbolConfiguration, tintColor: UIColor, shadow: Bool = true) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName, withConfiguration: buttonConfig)?.withTintColor(tintColor), for: .normal)
        button.contentMode = .scaleToFill
        button.tintColor = tintColor
        button.addTarget(target, action: action, for: .touchUpInside)
        
        // Add shadow
        if shadow {
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.1
            button.layer.shadowRadius = 2
        }
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        return menuBarItem
    }
}

