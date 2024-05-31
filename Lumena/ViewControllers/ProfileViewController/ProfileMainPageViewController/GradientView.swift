//
//  GradientView.swift
//  TwitterProfile_Example
//
//  Created by ugur on 31.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class GradientView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
            gradientLayer.locations = [0.5, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
    }
}
