//
//  CameraFlashSliderView.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/30.
//

import Foundation
import UIKit
import AVFoundation

protocol FlashLightCustomSliderViewDelegate: AnyObject {
    func didUpdateFlashLevel(_ level: CGFloat)
}

class FlashLightCustomSliderView: UIView {
    
    weak var delegate: FlashLightCustomSliderViewDelegate?
    
    private let sliderBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 10 // Reduced corner radius
        return view
    }()
    
    private let sliderFill: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.552, green: 0.724, blue: 0.831, alpha: 1)
        view.layer.cornerRadius = 10 // Reduced corner radius
        return view
    }()
    
    private var sliderHeightConstraint: NSLayoutConstraint!
    private var sliderMaxHeight: CGFloat = 150
    var sliderLastDragValue: CGFloat = 0
    var sliderProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addPanGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Configure the slider background
        addSubview(sliderBackground)
        sliderBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            sliderBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            sliderBackground.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        // Configure the slider fill
        addSubview(sliderFill)
        sliderFill.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sliderFill.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderFill.trailingAnchor.constraint(equalTo: trailingAnchor),
            sliderFill.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        sliderHeightConstraint = sliderFill.heightAnchor.constraint(equalToConstant: 0)
        sliderHeightConstraint.isActive = true
        
        layer.cornerRadius = 10 // Reduced corner radius
        clipsToBounds = true
    }
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .changed:
            var newHeight = -translation.y + sliderLastDragValue
            newHeight = min(max(0, newHeight), sliderMaxHeight)
            
            sliderHeightConstraint.constant = newHeight
            sliderProgress = newHeight / sliderMaxHeight
            
            updateCameraModel(sliderProgress)
            
        case .ended, .cancelled:
            sliderLastDragValue = sliderHeightConstraint.constant
            
        default:
            break
        }
    }
    
    private func updateCameraModel(_ level: CGFloat) {
        delegate?.didUpdateFlashLevel(level)
    }
    
    func setSlideValue(to value: CGFloat) {
        // Ensure the value is between 0 and 1
        let clampedValue = max(0, min(1, value))
        let newHeight = CGFloat(clampedValue) * sliderMaxHeight
        
        sliderHeightConstraint.constant = newHeight
        sliderProgress = CGFloat(clampedValue)
        sliderLastDragValue = newHeight
        
        // Notify the delegate about the updated value
        updateCameraModel(clampedValue)
    }
}
