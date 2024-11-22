//
//  PrepPostStatusBarView.swift
//  Lumena
//
//  Created by 島田晃 on 2024/11/04.
//

import Foundation
import UIKit

protocol PrepPostProgressProtocol: AnyObject {
    func updateProgress(selectedIndex: Int)
}

class PrepPostProgressOptionsView: UIView {
    
    private let mainStackView = UIStackView()
    private let optionStackView = UIStackView()
    private var optionButtons: [UIButton] = []
    
    weak var delegate: PrepPostProgressProtocol?
    
    var labels: [String] = [] {
        didSet {
            setupButtons()
        }
    }
    
    private var isProgrammaticUpdate = false

    var selectedIndex: Int = -1 {
       didSet {
           if !isProgrammaticUpdate {
               delegate?.updateProgress(selectedIndex: selectedIndex) // Notify delegate only if not programmatic
           }
           updateButtonStyles()
       }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
//        setupBackButton()
        
        mainStackView.axis = .horizontal
        mainStackView.alignment = .fill
        mainStackView.spacing = 8
        addSubview(mainStackView)
        
        optionStackView.axis = .horizontal
        optionStackView.alignment = .fill
        optionStackView.distribution = .fillEqually
        optionStackView.spacing = 8
        
//        mainStackView.addArrangedSubview(backButton)
        mainStackView.addArrangedSubview(optionStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }
    
    private func setupButtons() {
        optionButtons.forEach { $0.removeFromSuperview() }
        optionButtons.removeAll()
        
        for (index, label) in labels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(label, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionButtons.append(button)
            optionStackView.addArrangedSubview(button)
        }
        
        updateButtonStyles()
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        if sender.tag == selectedIndex {
            // Ignore if the tapped option is already selected
            return
        }
        selectedIndex = sender.tag
    }
    
    public func updateButton(_ index: Int) {
       isProgrammaticUpdate = true
       selectedIndex = index
       isProgrammaticUpdate = false
    }
    
    private func updateButtonStyles() {
        for (index, button) in optionButtons.enumerated() {
            UIView.animate(withDuration: 0.3, animations: {
                if index == self.selectedIndex {
                    button.setTitleColor(.arinDarkGreen, for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                } else {
                    button.setTitleColor(.gray, for: .normal)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                }
            })
        }
    }
}
