//
//  SharedInteractionController.swift
//  InstagramTransition
//
//  Created by Kolos Foltanyi on 2023. 07. 23..
//

import UIKit

class SharedTransitionInteractionController: NSObject {

    // MARK: Inner types

    struct Context {
        var transitionContext: UIViewControllerContextTransitioning
        var fromFrame: CGRect
        var toFrame: CGRect
        var fromView: UIView
        var toView: UIView
        var mask: UIView
        var transform: CGAffineTransform
        var overlay: UIView
        var placeholder: UIView
    }

    // MARK: Private properties

    private var alreadyFinished = false
    private var alreadyCancelled = false
    private var config: SharedTransitionConfig = .interactive
    private var context: Context?
    
}

// MARK: - UIViewControllerInteractiveTransitioning

extension SharedTransitionInteractionController: UIViewControllerInteractiveTransitioning {
    var wantsInteractiveStart: Bool { false }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        prepareViewController(from: transitionContext)

        guard let (fromView, fromFrame, toView, toFrame) = setup(with: transitionContext) else {
            transitionContext.completeTransition(false)
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
//        let overlay = UIView().then {
//            $0.backgroundColor = .white
//            $0.layer.opacity = config.overlayOpacity
//            $0.frame = toView.frame
//        }
        
        let blurEffect = UIBlurEffect(style: .regular)
        let overlay = UIVisualEffectView(effect: blurEffect).then {
            $0.frame = toView.frame
            $0.layer.opacity = config.overlayOpacity
        }

        let placeholder = UIView().then {
            $0.frame = toFrame
            $0.backgroundColor = config.placeholderColor
        }

        context = Context(
            transitionContext: transitionContext,
            fromFrame: fromFrame,
            toFrame: toFrame,
            fromView: fromView,
            toView: toView,
            mask: mask,
            transform: transform,
            overlay: overlay,
            placeholder: placeholder
        )

        fromView.mask = mask
        toView.addSubview(placeholder)
        toView.addSubview(overlay)

        if alreadyFinished {
            finish()
        }

        if alreadyCancelled {
            cancel()
        }
    }
}

// MARK: - Event handlers

extension SharedTransitionInteractionController {
    func update(_ recognizer: UIPanGestureRecognizer) {
        guard let context else { return }
        let window = UIApplication.keyWindow!
        let translation = recognizer.translation(in: window)
        let progress = translation.x / window.frame.width
        context.transitionContext.updateInteractiveTransition(progress)
        var scaleFactor = 1 - progress * (1 - config.interactionScaleFactor)
        scaleFactor = min(max(scaleFactor, config.interactionScaleFactor), 1)
        context.fromView.transform = .init(scaleX: scaleFactor, y: scaleFactor)
            .translatedBy(x: translation.x, y: translation.y)
    }

    func cancel() {
        guard let context else {
            alreadyCancelled = true
            return
        }
        context.transitionContext.cancelInteractiveTransition()
        let maskRadius = config.maskCornerRadius
        let overlayOpacity = config.overlayOpacity
        UIView.animate(duration: config.duration, curve: config.curve) {
            context.fromView.transform = .identity
            context.mask.frame = context.fromView.frame
            context.mask.layer.cornerRadius = maskRadius
            context.overlay.layer.opacity = overlayOpacity
        } completion: {
            context.overlay.removeFromSuperview()
            context.placeholder.removeFromSuperview()
            context.toView.removeFromSuperview()
            context.transitionContext.completeTransition(false)
        }
    }

    func finish() {
        guard let context else {
            alreadyFinished = true
            return
        }
        context.transitionContext.finishInteractiveTransition()
        let maskFrame = context.toFrame.aspectFit(to: context.fromFrame)
        UIView.animate(duration: config.duration, curve: config.curve) {
            context.fromView.transform = context.transform
            context.mask.frame = maskFrame
            context.mask.layer.cornerRadius = 0
            context.overlay.layer.opacity = 0
        } completion: {
            context.overlay.removeFromSuperview()
            context.placeholder.removeFromSuperview()
            context.transitionContext.completeTransition(true)
        }
    }
}

// MARK: - Helpers

extension SharedTransitionInteractionController {
    private func prepareViewController(from context: UIViewControllerContextTransitioning) {
        let toVC = context.viewController(forKey: .to) as? SharedTransitioning
        toVC?.prepare(for: .pop)
    }
    
    // pop
    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, CGRect, UIView, CGRect)? {
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else {
            print("Error: Unable to retrieve fromView or toView from the transition context")
            return nil
        }

        context.containerView.insertSubview(toView, belowSubview: fromView)

        guard let fromFrame = context.sharedFrame(forKey: .from) else {
            print("Error: Unable to retrieve fromFrame from the transition context")
            return nil
        }

        // Get the current visible index path from the LumeVerticalInfiniteScrollViewController in DetailScreen
        if let fromVC = context.viewController(forKey: .from) as? DetailScreen,
           let lumeVerticalInDetail = fromVC.lumeVerticalScroll,
           let visibleIndexPath = lumeVerticalInDetail.getCurrentVisibleIndexPath() {
            
            let cellWidth: CGFloat = SharedTransitionAnimator.cellFrame.width
            let cellHeight: CGFloat = SharedTransitionAnimator.cellFrame.height
            let horizontalSpacing: CGFloat = 2.0
            let verticalSpacing: CGFloat = 2.0
            let verticalOffset = SharedTransitionAnimator.fromFrameYOffset // Use the stored y offset
            
            let toFrame = calculateReturningFrame(for: visibleIndexPath.item, cellWidth: cellWidth, cellHeight: cellHeight, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, verticalOffset: verticalOffset)
            
            print("Calculated toFrame: \(toFrame)")
            return (fromView, fromFrame, toView, toFrame)
        }

        // Fallback to a default frame if the above calculation fails
        guard let toFrame = context.sharedFrame(forKey: .to) else {
            print("Error: Unable to retrieve toFrame from the transition context")
            return nil
        }

        return (fromView, fromFrame, toView, toFrame)
    }
    
    func calculateReturningFrame(for index: Int, cellWidth: CGFloat, cellHeight: CGFloat, horizontalSpacing: CGFloat, verticalSpacing: CGFloat, verticalOffset: CGFloat) -> CGRect {
        let rowIndex = index / 3 // Calculate which row the cell is in
        let columnIndex = index % 3 // Calculate the column within the row

        // Calculate the frame for the cell
        let xPosition = CGFloat(columnIndex) * (cellWidth + horizontalSpacing)
        let yPosition = CGFloat(rowIndex) * (cellHeight + verticalSpacing) + verticalOffset
        let frame = CGRect(x: xPosition, y: yPosition, width: cellWidth, height: cellHeight)
        
        return frame
    }
}
