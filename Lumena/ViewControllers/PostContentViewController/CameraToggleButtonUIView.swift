//
//  CameraToggleButtonUIView.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import Foundation
import UIKit

protocol CameraToggleButtonUIButtonDelegate: AnyObject {
    func didToggleCameraModeToggleButton(_ mode: CameraMode)
}

class CameraToggleButtonUIButton: UIButton {
    
    private var cameraButton: UIButton!
    private var videoButton: UIButton!
    private var cameraMode: CameraMode = .video {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.delegate?.didToggleCameraModeToggleButton(self.cameraMode)
                self.updateButtonStyles()
            }
        }
    }
    private var showLight = false
    
    var buttonColor: UIColor = .white {
        didSet {
            updateButtonStyles()
        }
    }
    
    weak var delegate: CameraToggleButtonUIButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Configure the main button's appearance
        self.backgroundColor = .clear
        
        let background = UIButton(type: .system)
        background.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        
        // Create and configure the camera button
        cameraButton = UIButton(type: .system)
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        cameraButton.tintColor = buttonColor
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cameraButton)
        
        // Create and configure the video button
        videoButton = UIButton(type: .system)
        videoButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
        videoButton.addTarget(self, action: #selector(videoButtonTapped), for: .touchUpInside)
        videoButton.tintColor = buttonColor
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videoButton)
        
        // Set initial styles
        updateButtonStyles()
        
        // Layout the buttons
        NSLayoutConstraint.activate([
            background.widthAnchor.constraint(equalTo: self.widthAnchor),
            background.heightAnchor.constraint(equalTo: self.heightAnchor),
            background.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            background.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            cameraButton.widthAnchor.constraint(equalToConstant: 30),
            cameraButton.heightAnchor.constraint(equalToConstant: 30),
            cameraButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            cameraButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            videoButton.widthAnchor.constraint(equalToConstant: 30),
            videoButton.heightAnchor.constraint(equalToConstant: 30),
            videoButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            videoButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateButtonStyles() {
        let cameraScale: CGFloat = (cameraMode == .video) ? 0.6 : 0.9
        let videoScale: CGFloat = (cameraMode == .video) ? 0.9 : 0.6
        
        // Apply scaling while maintaining aspect ratio
        cameraButton.transform = CGAffineTransform(scaleX: cameraScale, y: cameraScale)
        videoButton.transform = CGAffineTransform(scaleX: videoScale, y: videoScale)
        
        // Update tint colors
        cameraButton.tintColor = (cameraMode == .video) ? .secondaryLabel : (showLight ? .label : buttonColor)
        videoButton.tintColor = (cameraMode == .video) ? (showLight ? .label : buttonColor) : .secondaryLabel
        
        // Animate the transformations
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
    }

    @objc private func cameraButtonTapped() {
        cameraMode.toggle()
    }
    
    @objc private func videoButtonTapped() {
        cameraMode.toggle()
    }
}

