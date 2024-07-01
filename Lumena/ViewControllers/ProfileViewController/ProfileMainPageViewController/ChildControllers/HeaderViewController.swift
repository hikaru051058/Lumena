//
//  HeaderViewController.swift
//  TwitterProfile
//
//  Created by OfTheWolf on 08/18/2019.
//  Copyright (c) 2019 OfTheWolf. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class HeaderViewController: UIViewController {
    
    var coverImageHeightConstraint: NSLayoutConstraint!
    
    private var userImageViewShimmerView: ShimmerView!
    
    var userImageView: UIImageView!
    var userGivenNameLabel: UILabel!
    var userNameLabel: UILabel!
    
    private let profileInfoZPosition: CGFloat = 50
    private let backgroundZPosition: CGFloat = 45
    
    var profileBackground: UIView!
    var coverImageView: UIImageView!
    
    var titleView: UIScrollView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var profileToolButtonVC: ProfileToolButtonViewController!
    
    var toolBar: ProfileToolButtonViewController!
    private var toolBarTopAnchor: NSLayoutConstraint!
    
    var visualEffectView: UIVisualEffectView!
    var descriptionContainer: UIView!
    var bottomViewController: BottomViewController!
    var profileStatFollowNumber: ProfileStatsViewController!
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
    
    @ObservedObject var profile: ProfileSettings
    var userIdentityID: String!
    
    weak var backButtonDelegate: ProfileToolButtonDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(profile: ProfileSettings, userIdentityID: String) {
        self.profile = profile
        self.userIdentityID = userIdentityID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurAnimation()
        if initialValuesSet {
            update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetAnimator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidLayoutOnce {
            viewDidLayoutOnce = true
            titleInitialCenterY = titleView.center.y
            titleView.setContentOffset(CGPoint(x: 0, y: -titleView.frame.height), animated: true)
            initialValuesSet = true
            adaptCoverImageHeight()
            update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
        }
    }
}

extension HeaderViewController {
    
    private func setupBindings() {
        profile.$preferredUsername.sink { [weak self] preferredUsername in
            self?.updateUserNameLabel(with: preferredUsername)
        }.store(in: &cancellables)
        
        profile.$givenName.sink { [weak self] givenName in
            self?.updateUserGivenNameLabel(with: givenName)
        }.store(in: &cancellables)
        
        profile.$bio.sink { [weak self] bio in
            self?.updateBioLabel(with: bio)
        }.store(in: &cancellables)
        
        profile.$profileImage.sink { [weak self] profileImage in
            self?.updateUserProfileImageView(with: profileImage?.image)
        }.store(in: &cancellables)
    }
    
    private func updateUserNameLabel(with preferredUsername: String) {
        userNameLabel.text = "@\(preferredUsername)"
    }
    
    private func updateUserGivenNameLabel(with givenName: String) {
        userGivenNameLabel.text = givenName
    }
    
    private func updateBioLabel(with bio: String) {
        expandableTextViewController.text = bio
    }
    
    private func updateUserProfileImageView(with profileImage: UIImage?) {
        userImageView.image = profileImage
    }
}

extension HeaderViewController {
    
    private func setupConstraints() {
        animator = blurAnimator()
        
        // Set initial zPosition values
        coverImageView.layer.zPosition = 10
        visualEffectView.layer.zPosition = 20
        titleView.layer.zPosition = 30
        
        profileBackground.layer.zPosition = backgroundZPosition // Profile background
            
        userImageView.layer.zPosition = profileInfoZPosition
        userImageViewShimmerView.layer.zPosition = profileInfoZPosition
        userNameLabel.layer.zPosition = profileInfoZPosition
        userGivenNameLabel.layer.zPosition = profileInfoZPosition
        profileStatFollowNumber.view.layer.zPosition = profileInfoZPosition
        expandableTextViewController.view.layer.zPosition = profileInfoZPosition
        titleView.layer.zPosition = profileInfoZPosition
        
        view.bringSubviewToFront(expandableTextViewController.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupUI() {
        
        addCoverImage()
        
        addProfileInfo()
        
        addFollowNumberInfo()
        
        addExpandableTextViewController()
        
        addProfileBackground()
        
        addTitleBar()
        
        addBottomViewController()
        
        addToolBar()
        
        adaptCoverImageHeight()
    }
    
    private func adaptCoverImageHeight() {
        let profileBackgroundHeight = profileBackground.frame.height
        let dynamicHeight = UIScreen.main.bounds.height - profileBackgroundHeight
        coverImageHeightConstraint.constant = dynamicHeight
        covernitialHeight = dynamicHeight
        covernitialCenterY = dynamicHeight/2
        update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
    }
    
    private func addCoverImage() {
        coverImageView = UIImageView()
        coverImageView.backgroundColor = .clear
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        view.addSubview(coverImageView)
        
        coverImageHeightConstraint = coverImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.7)
        coverImageHeightConstraint.isActive = true
        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: view.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addTitleBar() {
        titleView = UIScrollView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Instantiate ProfileToolButtonViewController
        profileToolButtonVC = ProfileToolButtonViewController(frame: .zero, profile: profile, addShadow: false, color: .primary)
        profileToolButtonVC.delegate = backButtonDelegate
        
        titleView.addSubview(profileToolButtonVC)
        profileToolButtonVC.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileToolButtonVC.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            profileToolButtonVC.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            profileToolButtonVC.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            profileToolButtonVC.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
        ])
        
        // Add titleLabel to titleView
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = profile.preferredUsername
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
        ])
        
        // Bring titleLabel to front to stack in z-axis
        titleView.bringSubviewToFront(titleLabel)
    }
    
    private func addProfileBackground() {
        profileBackground = UIView()
        profileBackground.translatesAutoresizingMaskIntoConstraints = false
        profileBackground.backgroundColor = .background
        profileBackground.layer.masksToBounds = true
//        profileBackground.layer.zPosition = profileInfoZPosition - 5
        profileBackground.layer.cornerRadius = 40 // Set the corner radius
        if #available(iOS 13.0, *) {
            profileBackground.layer.cornerCurve = .continuous // Use continuous corner curve for a smoother look
        }
        profileBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Round top-left and top-right corners
        view.addSubview(profileBackground)
        NSLayoutConstraint.activate([
            profileBackground.widthAnchor.constraint(equalTo: view.widthAnchor),
            profileBackground.topAnchor.constraint(equalTo: userImageView.centerYAnchor),
            profileBackground.bottomAnchor.constraint(equalTo: expandableTextViewController.view.bottomAnchor, constant: 16)
        ])
    }
    
    private func addProfileInfo() {
        addUserProfileImageView()
        addUserGivenNameLabel()
        addUserPreferredUsernameLabel()
    }
    
    private func addUserProfileImageView() {
        // Profile circle image placeholder (ShimmerView)
        userImageViewShimmerView = ShimmerView()
        userImageViewShimmerView.translatesAutoresizingMaskIntoConstraints = false
        userImageViewShimmerView.layer.cornerRadius = 50
        userImageViewShimmerView.backgroundColor = .systemGray5
        userImageViewShimmerView.layer.masksToBounds = true
        userImageViewShimmerView.layer.borderColor = UIColor.background.cgColor
        userImageViewShimmerView.layer.borderWidth = 4
        
        view.addSubview(userImageViewShimmerView)
        NSLayoutConstraint.activate([
            userImageViewShimmerView.widthAnchor.constraint(equalToConstant: 100),
            userImageViewShimmerView.heightAnchor.constraint(equalToConstant: 100),
            userImageViewShimmerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImageViewShimmerView.centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor)
        ])
        
        // Actual profile image (UIImageView)
        if let profileImage = profile.profileImage?.image {
            userImageView = UIImageView(image: profileImage)
            userImageViewShimmerView.isHidden = true // Hide the shimmer view
        } else {
            userImageView = UIImageView()
        }
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.layer.cornerRadius = 50
        userImageView.backgroundColor = .systemGray5
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderColor = UIColor.background.cgColor
        userImageView.layer.borderWidth = 4
        
        view.addSubview(userImageView)
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 100),
            userImageView.heightAnchor.constraint(equalToConstant: 100),
            userImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImageView.centerYAnchor.constraint(equalTo: coverImageView.bottomAnchor)
        ])
    }
    
    private func addUserGivenNameLabel() {
        // user profile name
        userGivenNameLabel = UILabel()
        userGivenNameLabel.translatesAutoresizingMaskIntoConstraints = false
        if profile.givenName != "" {
            userGivenNameLabel.text = profile.givenName
            userGivenNameLabel.isHidden = false
        } else {
            userGivenNameLabel.isHidden = true
        }
        userGivenNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        view.addSubview(userGivenNameLabel)
        NSLayoutConstraint.activate([
            userGivenNameLabel.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            userGivenNameLabel.topAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 10)
        ])
    }
    
    private func addUserPreferredUsernameLabel() {
        // username
        userNameLabel = UILabel()
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        if profile.preferredUsername != "" {
            userNameLabel.text = "@\(profile.preferredUsername)"
            userNameLabel.isHidden = false
        } else {
            userNameLabel.isHidden = true
        }
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        userNameLabel.textColor = .systemGray
        view.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userNameLabel.centerXAnchor.constraint(equalTo: userImageView.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: userGivenNameLabel.bottomAnchor)
        ])
    }
    
    private func addFollowNumberInfo() {
        
        profileStatFollowNumber = ProfileStatsViewController()
        profileStatFollowNumber.profile = profile
        addChild(profileStatFollowNumber)
        view.addSubview(profileStatFollowNumber.view)
        profileStatFollowNumber.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStatFollowNumber.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            profileStatFollowNumber.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            profileStatFollowNumber.view.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
        ])
        profileStatFollowNumber.didMove(toParent: self)
    }
    
    private func addExpandableTextViewController() {
        expandableTextViewController = ExpandableTextViewController(text: profile.bio)
        addChild(expandableTextViewController)
        view.addSubview(expandableTextViewController.view)
        expandableTextViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        expandableTextViewController.view.layer.cornerRadius = 15
        expandableTextViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expandableTextViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            expandableTextViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            expandableTextViewController.view.topAnchor.constraint(equalTo: profileStatFollowNumber.view.bottomAnchor, constant: 16),
        ])
        expandableTextViewController.didMove(toParent: self)
    }
    
    private func addBottomViewController() {
        bottomViewController = BottomViewController(profile: profile, headerSpace: true)
        addChild(bottomViewController)
        view.addSubview(bottomViewController.view)
        bottomViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomViewController.view.topAnchor.constraint(equalTo: profileBackground.bottomAnchor),
            bottomViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        bottomViewController.didMove(toParent: self)
    }
    
    
    private func addToolBar() {
        toolBar = ProfileToolButtonViewController(frame: .zero, profile: profile, color: .background)
        toolBar.delegate = backButtonDelegate
        view.addSubview(toolBar)
        view.bringSubviewToFront(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        toolBarTopAnchor = toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4)
        
        NSLayoutConstraint.activate([
            toolBarTopAnchor,
            toolBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            toolBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
}

extension  HeaderViewController {
    private func removeShimmerEffect(from view: UIView) {
        if let sublayers = view.layer.sublayers {
            for layer in sublayers {
                if let gradientLayer = layer as? CAGradientLayer {
                    gradientLayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    private func addShimmerEffect(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(white: 0.85, alpha: 1.0).cgColor,
            UIColor(white: 0.95, alpha: 1.0).cgColor,
            UIColor(white: 0.85, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = view.bounds
        gradientLayer.masksToBounds = true
        view.layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 0.9
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerEffect")
        
        // To ensure the gradient layer resizes with the view
        view.layer.masksToBounds = true
        view.layoutIfNeeded()
    }
}

extension HeaderViewController {
    
    func update(with progress: CGFloat, minHeaderHeight: CGFloat) {
        lastProgress = progress
        lastMinHeaderHeight = minHeaderHeight
        
        let y = progress * (view.frame.height - minHeaderHeight)
        
        guard covernitialHeight != nil else {
            return
        }
        
        coverImageHeightConstraint.constant = max(covernitialHeight, covernitialHeight - y)
        
        let opacity: CGFloat = progress >= 0.7 ? (1 - ((progress - 0.7) * (1 / 0.3))) : 1.0
        
        userImageView.alpha = opacity
        userNameLabel.alpha = opacity
        userGivenNameLabel.alpha = opacity
        profileStatFollowNumber.view.alpha = opacity
        expandableTextViewController.view.alpha = opacity
        
        userImageViewShimmerView.layer.zPosition = opacity
        
        if toolBar != nil {
            UIView.animate(withDuration: 0.1) {
                self.toolBar.alpha = progress >= 0.7 ? opacity - 0.5 : opacity
            }
        }
        
        if progress >= -0.05 {
            UIView.animate(withDuration: 0.15) {
                self.visualEffectView.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.15) {
                self.visualEffectView.alpha = 1
            }
        }
        
        titleView.alpha = progress
        
        let titleOffset: CGFloat
        if expandableTextViewController.text == "" {
            titleOffset = max(min(0, (profileStatFollowNumber.view.convert(profileStatFollowNumber.view.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
        } else {
            titleOffset = max(min(0, (expandableTextViewController.view.convert(expandableTextViewController.view.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
        }
        titleView.contentOffset.y = -titleOffset - titleView.frame.height
        
        if progress < 0 {
            animator?.fractionComplete = abs(min(0, progress))
        } else {
            animator?.fractionComplete = abs(titleOffset / titleView.frame.height)
        }
        
        let topLimit = covernitialHeight - minHeaderHeight
        if y > topLimit {
            coverImageView.center.y = covernitialCenterY + y - topLimit
            if stickyCover {
                self.stickyCover = false
                
                userImageViewShimmerView.layer.zPosition = 0
                userImageView.layer.zPosition = 0
                userNameLabel.layer.zPosition = 0
                userGivenNameLabel.layer.zPosition = 0
                profileStatFollowNumber.view.layer.zPosition = 0
                expandableTextViewController.view.layer.zPosition = 0
                profileBackground.layer.zPosition = -5
            }
        } else {
            coverImageView.center.y = covernitialCenterY
            //let scale = min(1, (1 - progress * 1.3))
            //let t = CGAffineTransform(scaleX: scale, y: scale)
            //userImageView.transform = t.translatedBy(x: 0, y: userImageView.frame.height * (1 - scale))
            
            userImageViewShimmerView.layer.zPosition = profileInfoZPosition + 5
            
            if !stickyCover {
                self.stickyCover = true
                
                // Set zPosition for sticky state
                userImageView.layer.zPosition = profileInfoZPosition
                userImageViewShimmerView.layer.zPosition = profileInfoZPosition
                userNameLabel.layer.zPosition = profileInfoZPosition
                userGivenNameLabel.layer.zPosition = profileInfoZPosition
                profileStatFollowNumber.view.layer.zPosition = profileInfoZPosition
                expandableTextViewController.view.layer.zPosition = profileInfoZPosition
                profileBackground.layer.zPosition = backgroundZPosition
            }
        }
        visualEffectView.center.y = coverImageView.center.y
        titleView.center.y = coverImageView.frame.maxY - titleView.frame.height / 2
        
        profileBackground.layer.cornerRadius = (progress*17)+40 // Set the corner radius
        
        if toolBar != nil {
            if y < 0 {
                toolBarTopAnchor.constant = 4
                toolBar.layer.zPosition = 0
            } else if progress <= 0.75 {
                toolBarTopAnchor.constant = 4 + y
                toolBar.layer.zPosition = -10
            } else if progress <= 0.9{
                toolBarTopAnchor.constant = 4 + y
                toolBar.layer.zPosition = -10
            } else {
                toolBar.alpha = 0
            }
        }
    }
    
    func updateProfile(profile: ProfileSettings) {
        self.profile = profile
        
        if let profileImage =  profile.profileImage?.image {
            userImageView.image = profileImage
            userImageView.isHidden = false // Show the image view
            userImageViewShimmerView.isHidden = true // Hide the shimmer view
            Task {
                ProfileManager.shared.updateProfile(profile)
            }
        }
        
        // Update given name
        if profile.givenName != "" {
            userGivenNameLabel.text = profile.givenName
            userGivenNameLabel.isHidden = false // Show the label
        } else {
            userGivenNameLabel.isHidden = true // Hide the label
        }
        
        // Update username
        if profile.preferredUsername != "" {
            userNameLabel.text = "@\(profile.preferredUsername)"
            userNameLabel.isHidden = false // Show the label
        } else {
            userNameLabel.isHidden = true // Hide the label
        }
        
        titleLabel.text = profile.preferredUsername
        expandableTextViewController.text = profile.bio
        profileStatFollowNumber.updateProfile(profile: profile)
        bottomViewController.updateProfile(profile: profile)
        toolBar.updateProfile(profile: profile)
        profileToolButtonVC.updateProfile(profile: profile)

        adaptCoverImageHeight()
        
        expandableTextViewController.view.layoutIfNeeded()
        view.layoutIfNeeded()
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
