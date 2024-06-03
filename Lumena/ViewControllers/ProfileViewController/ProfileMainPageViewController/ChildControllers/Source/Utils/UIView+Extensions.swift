//
//  UIView+Extensions.swift
//  InstagramTransition
//
//  Created by Kolos Foltanyi on 2023. 07. 22..
//

import UIKit

extension UIView {
    var frameInWindow: CGRect? {
        return superview?.convert(frame, to: nil)
    }

    static func animate(
        duration: TimeInterval,
        curve: CAMediaTimingFunction? = nil,
        options: UIView.AnimationOptions = [],
        animations: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(curve)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: animations,
            completion: { _ in completion?() }
        )
        CATransaction.commit()
    }
}

extension UIView {
    func pinToEdges(of parentView: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parentView.topAnchor),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
}
