//
//  SharedTransitionConfig.swift
//  InstagramTransition
//
//  Created by Kolos Foltanyi on 2023. 07. 24..
//

import UIKit

public struct SharedTransitionConfig {
    var duration: CGFloat
    var curve: CAMediaTimingFunction
    var animationOptions: UIView.AnimationOptions // Add this property
    var maskCornerRadius: CGFloat
    var overlayOpacity: Float
    var interactionScaleFactor: CGFloat = .zero
    var placeholderColor: UIColor
}

extension SharedTransitionConfig {
    static var `default`: SharedTransitionConfig {
        .init(
            duration: 0.15,
            curve: CAMediaTimingFunction(controlPoints: 0.5, 0, 0.6, 1),
            animationOptions: .curveEaseOut,
            maskCornerRadius: 39,
            overlayOpacity: 1,
            placeholderColor: .background
        )
    }

    static var interactive: SharedTransitionConfig {
        .init(
            duration: 0.2,
            curve: CAMediaTimingFunction(controlPoints: 0.57, 0.27, 0.21, 0.97),
            animationOptions: .curveEaseOut,
            maskCornerRadius: 39,
            overlayOpacity: 1,
            interactionScaleFactor: 0.6,
            placeholderColor: .background
        )
    }
}
