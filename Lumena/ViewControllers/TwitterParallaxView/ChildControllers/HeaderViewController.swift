//
//  HeaderViewController.swift
//  TwitterProfile
//
//  Created by OfTheWolf on 08/18/2019.
//  Copyright (c) 2019 OfTheWolf. All rights reserved.
//

import UIKit
import SwiftUI

class HeaderViewController: UIViewController {
    
    var coverImageHeightConstraint: NSLayoutConstraint!
    var userImageView: UIImageView!
    var userNameLabel: UILabel!
    var verifiedImageView: UIImageView!
    
    let profileInfoZPosition: CGFloat = 40
    
    var profileBackground: UIView!
    var covermageView: UIImageView!
    
    var titleView: UIScrollView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    
    var visualEffectView: UIVisualEffectView!
    var descriptionContainer: UIView!
    var bottomViewController: UIViewController!
    var expandableTextViewController: ExpandableTextViewController!

    private var animator: UIViewPropertyAnimator?

    var titleInitialCenterY: CGFloat!
    var covernitialCenterY: CGFloat!
    var covernitialHeight: CGFloat!
    var stickyCover = true
    var viewDidLayoutOnce = false
    
    var lastProgress: CGFloat = .zero
    var lastMinHeaderHeight: CGFloat = .zero
    
    var initialValuesSet = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        animator = blurAnimator()

        // Set initial zPosition values
        covermageView.layer.zPosition = 10
        visualEffectView.layer.zPosition = 20
        titleView.layer.zPosition = 30
        
        userImageView.layer.zPosition = profileInfoZPosition
        userNameLabel.layer.zPosition = profileInfoZPosition
        verifiedImageView.layer.zPosition = profileInfoZPosition
        expandableTextViewController.view.layer.zPosition = profileInfoZPosition
        view.bringSubviewToFront(expandableTextViewController.view)

        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurAnimation()
        if initialValuesSet {
            update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetAnimator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayoutOnce {
            viewDidLayoutOnce = true
            covernitialCenterY = covermageView.center.y
            covernitialHeight = covermageView.frame.height
            titleInitialCenterY = titleView.center.y
            titleView.setContentOffset(CGPoint(x: 0, y: -titleView.frame.height), animated: true)
            initialValuesSet = true
            update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
        }
    }
    
    private func setupUI() {
        
        addCoverImage()
        
        addTitleBar()
        
        addProfileInfo()
        
        addExpandableTextViewController()
        
        addProfileBackground()
        
        addBottomViewController()
    }
    
    private func addCoverImage() {
        
        covermageView = UIImageView(image: UIImage(named: "cover"))
        covermageView.backgroundColor = .clear
        covermageView.translatesAutoresizingMaskIntoConstraints = false
        covermageView.contentMode = .scaleAspectFill
        view.addSubview(covermageView)
        
        coverImageHeightConstraint = covermageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height*0.75)
        coverImageHeightConstraint.isActive = true
        NSLayoutConstraint.activate([
            covermageView.topAnchor.constraint(equalTo: view.topAnchor),
            covermageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            covermageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: covermageView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: covermageView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: covermageView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addTitleBar() {
        
        titleView = UIScrollView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.topAnchor.constraint(equalTo: covermageView.bottomAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add titleLabel
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "TITLE"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.alpha = 0 // Initially hidden
        titleView.addSubview(titleLabel)
        
        // Add subtitleLabel
        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "SUBTITLE"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.alpha = 0 // Initially hidden
        titleView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        ])
    }
    
    private func addProfileBackground() {
        profileBackground = UIView()
        profileBackground.translatesAutoresizingMaskIntoConstraints = false
        profileBackground.backgroundColor = .background
        profileBackground.layer.masksToBounds = true
        profileBackground.layer.zPosition = profileInfoZPosition - 5
        profileBackground.layer.cornerRadius = 40 // Set the corner radius
        if #available(iOS 13.0, *) {
            profileBackground.layer.cornerCurve = .continuous // Use continuous corner curve for a smoother look
        }
        profileBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Round top-left and top-right corners
        view.addSubview(profileBackground)
        NSLayoutConstraint.activate([
            profileBackground.widthAnchor.constraint(equalTo: view.widthAnchor),
            profileBackground.topAnchor.constraint(equalTo: userImageView.centerYAnchor),
            profileBackground.bottomAnchor.constraint(equalTo: expandableTextViewController.view.bottomAnchor)
        ])
    }
    
    private func addProfileInfo() {
        
        userImageView = UIImageView(image: UIImage(named: "haluk"))
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.layer.cornerRadius = 40
        userImageView.backgroundColor = .gray
        userImageView.layer.masksToBounds = true
        
        userImageView.layer.borderColor = UIColor.background.cgColor
        userImageView.layer.borderWidth = 4 // Adjust the width of the border as needed
        
        view.addSubview(userImageView)
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 80),
            userImageView.heightAnchor.constraint(equalToConstant: 80),
            userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImageView.centerYAnchor.constraint(equalTo: covermageView.bottomAnchor)
        ])
        
        userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.text = "Haluk Levent"
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        view.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor)
        ])
        
        verifiedImageView = UIImageView(image: UIImage(named: "verified"))
        verifiedImageView.translatesAutoresizingMaskIntoConstraints = false
        verifiedImageView.contentMode = .scaleAspectFit
        view.addSubview(verifiedImageView)
        NSLayoutConstraint.activate([
            verifiedImageView.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor),
            verifiedImageView.widthAnchor.constraint(equalToConstant: 18),
            verifiedImageView.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    private func addExpandableTextViewController() {
        expandableTextViewController = ExpandableTextViewController()
        addChild(expandableTextViewController)
        view.addSubview(expandableTextViewController.view)
        expandableTextViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        expandableTextViewController.view.layer.cornerRadius = 15
        expandableTextViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expandableTextViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            expandableTextViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            expandableTextViewController.view.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor),
        ])
        expandableTextViewController.didMove(toParent: self)
    }
    
    private func addBottomViewController() {
        bottomViewController = BottomViewController()
        addChild(bottomViewController)
        view.addSubview(bottomViewController.view)
        bottomViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomViewController.view.topAnchor.constraint(equalTo: expandableTextViewController.view.bottomAnchor),
            bottomViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        bottomViewController.didMove(toParent: self)
    }
    
    func update(with progress: CGFloat, minHeaderHeight: CGFloat) {
        lastProgress = progress
        lastMinHeaderHeight = minHeaderHeight
        
        let y = progress * (view.frame.height - minHeaderHeight)
        
        guard covernitialHeight != nil else {
            return
        }
        
        coverImageHeightConstraint.constant = max(covernitialHeight, covernitialHeight - y)
        
        userImageView.alpha = 1 - progress
        userNameLabel.alpha = 1 - progress
        verifiedImageView.alpha = 1 - progress
        expandableTextViewController.view.alpha = 1 - progress
        
        if progress >= 0{
            //visualEffectView.alpha = progress
            visualEffectView.alpha = 0
        } else {
            visualEffectView.alpha = abs(progress*5)
        }

        // Adjust titleLabel and subtitleLabel alpha
        titleLabel.alpha = progress
        subtitleLabel.alpha = progress
        
        let titleOffset = max(min(0, (userNameLabel.convert(userNameLabel.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
        titleView.contentOffset.y = -titleOffset - titleView.frame.height
        
        if progress < 0 {
            animator?.fractionComplete = abs(min(0, progress))
        } else {
            animator?.fractionComplete = abs(titleOffset / titleView.frame.height)
        }
        
        let topLimit = covernitialHeight - minHeaderHeight
        if y > topLimit {
            covermageView.center.y = covernitialCenterY + y - topLimit
            if stickyCover {
                self.stickyCover = false
                userImageView.layer.zPosition = 0
                userNameLabel.layer.zPosition = 0
                verifiedImageView.layer.zPosition = 0
                expandableTextViewController.view.layer.zPosition = 0
                profileBackground.layer.zPosition = -5
            }
        } else {
            covermageView.center.y = covernitialCenterY
            //let scale = min(1, (1 - progress * 1.3))
            //let t = CGAffineTransform(scaleX: scale, y: scale)
            //userImageView.transform = t.translatedBy(x: 0, y: userImageView.frame.height * (1 - scale))
            
            if !stickyCover {
                self.stickyCover = true
                userImageView.layer.zPosition = profileInfoZPosition
                userNameLabel.layer.zPosition = profileInfoZPosition
                verifiedImageView.layer.zPosition = profileInfoZPosition
                expandableTextViewController.view.layer.zPosition = profileInfoZPosition
                profileBackground.layer.zPosition = profileInfoZPosition-5
            }
        }
        visualEffectView.center.y = covermageView.center.y
        titleView.center.y = covermageView.frame.maxY - titleView.frame.height / 2
        
        // 40 -> 57
        profileBackground.layer.cornerRadius = (progress*17)+40 // Set the corner radius
    }

    
    @objc private func appWillEnterForeground() {
        addBlurAnimation()
    }
    
    @objc private func appDidEnterBackground() {
        resetAnimator()
        //update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
    }
    
    private func blurAnimator() -> UIViewPropertyAnimator {
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) { [weak self] in
            self?.visualEffectView.effect = UIBlurEffect(style: .regular)
        }
        return animator
    }
    
    private func addBlurAnimation() {
        animator?.fractionComplete = lastProgress
    }
    
    private func resetAnimator() {
        animator?.stopAnimation(true)
        animator = blurAnimator()
    }
}
