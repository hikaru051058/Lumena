//
//  CameraRecordButtonUIView.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import Foundation
import UIKit

protocol CameraRecordButtonUIViewDelegate: AnyObject {
    func didChangeRecordStatus(_ isRecording: Bool)
    func didTakePicture()
}

class CameraRecordButtonUIView: UIView {
    
    private var outerRingView: UIView!
    private var innerCircleView: UIView!
    private var progressLayer: CAShapeLayer!
    private var progressBackgroundLayer: CAShapeLayer!
    
    private var outerRingouterDiameter: CGFloat = 70
    private var outerRinginnerDiameter: CGFloat = 62
    private var outerRingLineWidth: CGFloat = 8
    private var innerOuterSpacing: CGFloat = 0
    public var minDimension: CGFloat = 80
    
    private var innerCircleWidthConstraint: NSLayoutConstraint!
    private var innerCircleHeightConstraint: NSLayoutConstraint!
    
    private var animateOpacity: Bool = true
    private var isRecording: Bool = false
    public var currentCameraProcessStatus: CameraProcessStatus = .prepping
    public var progress: Double = 0.0 {
        didSet {
            self.updateProgressIndicator(self.progress)
        }
    }
    
    public var cameraMode: CameraMode = .video {
        didSet {
            if self.cameraMode == .photo {
                self.updateProgressIndicator(1.0)
            } else {
                self.updateProgressIndicator(self.progress)
            }
        }
    }
    
    weak var delegate: CameraRecordButtonUIViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        
        outerRingouterDiameter = minDimension * 0.85
        outerRinginnerDiameter = minDimension * 0.8
        outerRingLineWidth = minDimension * 0.05
        innerOuterSpacing = minDimension * 0.03
        
        // Set up the outer ring view
        outerRingView = UIView()
        outerRingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outerRingView)
        
        // Set up the inner circle view
        innerCircleView = UIView()
        innerCircleView.translatesAutoresizingMaskIntoConstraints = false
        innerCircleView.backgroundColor = UIColor.arinBlue
        addSubview(innerCircleView)
        
        // Set constraints for outer ring view
        NSLayoutConstraint.activate([
            outerRingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            outerRingView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            outerRingView.widthAnchor.constraint(equalToConstant: outerRingouterDiameter),
            outerRingView.heightAnchor.constraint(equalToConstant: outerRingouterDiameter),
        ])
        
        // Set constraints for inner circle view
        
        innerCircleWidthConstraint = innerCircleView.widthAnchor.constraint(equalToConstant: outerRinginnerDiameter - (innerOuterSpacing + outerRingLineWidth))
        innerCircleHeightConstraint = innerCircleView.heightAnchor.constraint(equalToConstant: innerCircleWidthConstraint.constant)
        
        NSLayoutConstraint.activate([
            innerCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            innerCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            innerCircleWidthConstraint,
            innerCircleHeightConstraint,
        ])
        
        // Set up the progress layers
        let circularPath = UIBezierPath(arcCenter: .zero, radius: outerRingouterDiameter / 2, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)
        
        progressBackgroundLayer = CAShapeLayer()
        progressBackgroundLayer.path = circularPath.cgPath
        progressBackgroundLayer.strokeColor = UIColor.arinBlue.withAlphaComponent(0.5).cgColor
        progressBackgroundLayer.fillColor = UIColor.clear.cgColor
        progressBackgroundLayer.lineWidth = outerRingLineWidth
        progressBackgroundLayer.strokeEnd = CGFloat(1)
        progressBackgroundLayer.lineCap = .round
        progressBackgroundLayer.position = CGPoint(x: outerRingouterDiameter/2, y: outerRingouterDiameter/2)
        outerRingView.layer.addSublayer(progressBackgroundLayer)
        
        progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.arinBlue.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = outerRingLineWidth
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.lineCap = .round
        progressLayer.position = CGPoint(x: outerRingouterDiameter/2, y: outerRingouterDiameter/2)
        outerRingView.layer.addSublayer(progressLayer)
        
        // Set up corner radius for inner circle
        innerCircleView.layer.cornerRadius = (self.outerRinginnerDiameter - (self.innerOuterSpacing + outerRingLineWidth) - (self.innerOuterSpacing)) / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func buttonTapped() {
        if cameraMode == .photo {
            pictureTaken()
        } else {
            videoToggled()
        }
    }
    
    func videoToggled() {
        isRecording.toggle()
        
        delegate?.didChangeRecordStatus(isRecording)
        
        innerOuterSpacing = isRecording ? outerRingouterDiameter * 0.2 : outerRingouterDiameter * 0.0
        outerRingLineWidth = isRecording ? outerRingouterDiameter * 0.1 : outerRingouterDiameter * 0.05
        
        UIView.animate(withDuration: 0.3, animations: {
            // Update progress layer properties with animation
            self.progressLayer.lineWidth = self.outerRingLineWidth
            self.progressLayer.strokeEnd = CGFloat(self.progress)
            self.progressBackgroundLayer.lineWidth = self.outerRingLineWidth
            
            // Animate resizing of the inner circle
            
            self.innerCircleWidthConstraint.constant = self.outerRinginnerDiameter  - (self.innerOuterSpacing + self.outerRingLineWidth)
            self.innerCircleHeightConstraint.constant = self.outerRinginnerDiameter - (self.innerOuterSpacing + self.outerRingLineWidth)
            self.innerCircleView.layer.cornerRadius = (self.outerRinginnerDiameter - (self.innerOuterSpacing + self.outerRingLineWidth) - (self.innerOuterSpacing)) / 2
            self.innerCircleView.center = self.outerRingView.center
            
            self.layoutIfNeeded()
            
        }, completion: { _ in
            if self.isRecording {
                self.startOpacityAnimation()
            } else {
                self.stopOpacityAnimation()
            }
        })
    }
    
    func pictureTaken() {
        let originalWidth = self.innerCircleWidthConstraint.constant
        let originalHeight = self.innerCircleHeightConstraint.constant
        let shrinkFactor: CGFloat = 0.9
        
        delegate?.didTakePicture()
        
        UIView.animate(withDuration: 0.05, animations: {
            self.innerCircleWidthConstraint.constant = originalWidth * shrinkFactor
            self.innerCircleHeightConstraint.constant = originalHeight * shrinkFactor
            self.innerCircleView.layer.cornerRadius = (self.innerCircleWidthConstraint.constant) / 2
            self.layoutIfNeeded()
        }) { _ in
            // Restore the inner circle to its original size
            UIView.animate(withDuration: 0.05, animations: {
                self.innerCircleWidthConstraint.constant = originalWidth
                self.innerCircleHeightConstraint.constant = originalHeight
                self.innerCircleView.layer.cornerRadius = (self.innerCircleWidthConstraint.constant) / 2
                self.layoutIfNeeded()
            })
        }
    }
    
    private func startOpacityAnimation() {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.5
        opacityAnimation.duration = 0.5
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        innerCircleView.layer.add(opacityAnimation, forKey: "opacityAnimation")
    }
    
    private func stopOpacityAnimation() {
        innerCircleView.layer.removeAnimation(forKey: "opacityAnimation")
    }
    
    private func handleStatusChange() {
        if isRecording {
            startOpacityAnimation()
        } else {
            stopOpacityAnimation()
        }
    }
    
    // Update the progress indicator
    private func updateProgressIndicator(_ updateProgress: Double) {
        UIView.animate(withDuration: 0.25, animations: {
            self.progressLayer.strokeEnd = CGFloat(updateProgress)
            self.layoutIfNeeded()
        })
    }
    
    // Public method to update progress from outside
    public func setProgress(_ newProgress: Double) {
        guard newProgress >= 0.0 && newProgress <= 1.0 else { return }
        UIView.animate(withDuration: 0.25, animations: {
            self.progress = newProgress
            self.layoutIfNeeded()
        })
    }
}
