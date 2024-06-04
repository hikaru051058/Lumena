//
//  SharedTransitionAnimator.swift
//  DetailPushAnimator
//
//  Created by Kolos Foltanyi on 2023. 07. 22..
//

import UIKit

class SharedTransitionAnimator: NSObject {

    // MARK: Inner types

    enum Transition {
        case push
        case pop
    }

    // MARK: Public properties

    var transition: Transition = .push

    // MARK: Private properties

    private var config: SharedTransitionConfig = .default
    static var fromFrameYOffset: CGFloat = 0 // Store the y offset
    static var cellFrame: CGRect = CGRect(x: 0, y: 0, width: 129.66666, height: 129.66666)
}

// MARK: - UIViewControllerAnimatedTransitioning

extension SharedTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        return config.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        prepareViewControllers(from: transitionContext, for: transition)

        switch transition {
        case .push:
            pushAnimation(context: transitionContext)
        case .pop:
            popAnimation(context: transitionContext)
        }
    }
}

// MARK: - Animations

extension SharedTransitionAnimator {
    private func pushAnimation(context: UIViewControllerContextTransitioning) {
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: context) else {
            context.completeTransition(false)
            print("Error in push guard")
            return
        }
        
        SharedTransitionAnimator.fromFrameYOffset = fromFrame.origin.y
        calculateYOffset(with: context)
        SharedTransitionAnimator.cellFrame = fromFrame

        let transform: CGAffineTransform = .transform(
            parent: toView.frame,
            soChild: toFrame,
            aspectFills: fromFrame
        )

        let maskFrame = fromFrame.aspectFit(to: toFrame)
        let mask = UIView(frame: maskFrame).then {
            $0.layer.cornerCurve = .continuous
            $0.backgroundColor = .black
        }
        let overlay = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = 0
            $0.frame = fromView.frame
        }
        let placeholder = UIView().then {
            $0.backgroundColor = config.placeholderColor
            $0.frame = fromFrame
        }

        toView.mask = mask
        toView.transform = transform
        fromView.addSubview(placeholder)
        fromView.addSubview(overlay)

        UIView.animate(duration: config.duration, curve: config.curve) { [config] in
            toView.transform = .identity
            mask.frame = toView.frame
            mask.layer.cornerRadius = config.maskCornerRadius
            overlay.layer.opacity = config.overlayOpacity
        } completion: {
            toView.mask = nil
            overlay.removeFromSuperview()
            placeholder.removeFromSuperview()
            context.completeTransition(true)
        }
    }

    private func popAnimation(context: UIViewControllerContextTransitioning) {
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: context) else {
            context.completeTransition(false)
            print("Error in pop guard")
            return
        }

        let transform: CGAffineTransform = .transform(
            parent: fromView.frame,
            soChild: fromFrame,
            aspectFills: toFrame
        )
        let mask = UIView(frame: fromView.frame).then {
            $0.layer.cornerCurve = .continuous
            $0.backgroundColor = .black
            $0.layer.cornerRadius = config.maskCornerRadius
        }
        let overlay = UIView().then {
            $0.backgroundColor = .black
            $0.layer.opacity = config.overlayOpacity
            $0.frame = toView.frame
        }
        let placeholder = UIView().then {
            $0.backgroundColor = config.placeholderColor
            $0.frame = toFrame
        }

        fromView.mask = mask
        toView.addSubview(placeholder)
        toView.addSubview(overlay)

        let maskFrame = toFrame.aspectFit(to: fromFrame)

        UIView.animate(duration: config.duration, curve: config.curve) {
            fromView.transform = transform
            mask.frame = maskFrame
            mask.layer.cornerRadius = 0
            overlay.layer.opacity = 0
        } completion: {
            overlay.removeFromSuperview()
            placeholder.removeFromSuperview()
            let isCancelled = context.transitionWasCancelled
            context.completeTransition(!isCancelled)
        }
    }
}

// MARK: Helpers

extension SharedTransitionAnimator {
    private func prepareViewControllers(from context: UIViewControllerContextTransitioning,
                                        for transition: Transition) {
        let fromVC = context.viewController(forKey: .from) as? SharedTransitioning
        let toVC = context.viewController(forKey: .to) as? SharedTransitioning
        if let customConfig = fromVC?.config {
            config = customConfig
        }
        fromVC?.prepare(for: transition)
        toVC?.prepare(for: transition)
    }
    
    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, CGRect, UIView, CGRect)? {
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else {
            print("Error: Could not get toView or fromView")
            return nil
        }

        if transition == .push {
            context.containerView.addSubview(toView)
        } else {
            context.containerView.insertSubview(toView, belowSubview: fromView)
        }

        guard let toFrame = context.sharedFrame(forKey: .to),
              let fromFrame = context.sharedFrame(forKey: .from) else {
            print("Error: Could not get toFrame or fromFrame")
            return nil
        }
        
        return (fromView, fromFrame, toView, toFrame)
    }
    
    private func calculateYOffset(with context: UIViewControllerContextTransitioning) {
        
        // Get the current visible index path from the LumeVerticalInfiniteScrollViewController in DetailScreen
        if let fromVC = context.viewController(forKey: .to) as? DetailScreen,
           let lumeVerticalInDetail = fromVC.lumeVerticalScroll,
           let visibleIndexPath = lumeVerticalInDetail.getCurrentVisibleIndexPath() {
            
//            let cellWidth: CGFloat = SharedTransitionAnimator.cellFrame.width
            let cellHeight: CGFloat = SharedTransitionAnimator.cellFrame.height
//            let horizontalSpacing: CGFloat = 2.0
            let verticalSpacing: CGFloat = 2.0
            let verticalOffset = SharedTransitionAnimator.fromFrameYOffset // Use the stored y offset
            
            let rowIndex = visibleIndexPath.item / 3 // Calculate which row the cell is in
//            let columnIndex = visibleIndexPath.item % 3 // Calculate the column within the row

            // Calculate the position for the first row, first cell based on fromFrameYOffset
            SharedTransitionAnimator.fromFrameYOffset = verticalOffset - CGFloat(rowIndex) * (cellHeight + verticalSpacing)
        }
    }
}
