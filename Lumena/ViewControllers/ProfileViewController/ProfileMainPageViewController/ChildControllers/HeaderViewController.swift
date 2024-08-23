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
    private var userNoProfileImage: UIImageView!
    
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
    var profileStatSkinSettings: SkinSettingsProfileBubbleViewController! //UIHostingController<skinSettingsProfileBubbleView>!
    var followButtonVC: UIHostingController<ProfileFollowButtonView>!
    var expandableTextViewController: ExpandableTextViewController!
    
    private var expandableTextViewBottomAnchor: NSLayoutConstraint!
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var animator: UIViewPropertyAnimator?
    
    var titleInitialCenterY: CGFloat!
    var covernitialCenterY: CGFloat!
    var covernitialHeight: CGFloat!
    var stickyCover = true
    var viewDidLayoutOnce = false
    
    var lastProgress: CGFloat = .zero
    var lastMinHeaderHeight: CGFloat = .zero
    
    var initialValuesSet = false
    
    var isAccountUser: Bool = false
    
    @ObservedObject var profile: ProfileSettings
    var userIdentityID: String!
    
    weak var backButtonDelegate: ProfileToolButtonDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(profile: ProfileSettings, userIdentityID: String, isAccountUser: Bool = false) {
        self.profile = profile
        self.userIdentityID = userIdentityID
        self.isAccountUser = isAccountUser
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
        if let profileSkinSetting = profile.skinSetting {
            profileStatSkinSettings.updateSkinSettings(skinSettings: profileSkinSetting)
        }
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
    
    func updateUserNameLabel(with preferredUsername: String) {
        userNameLabel.text = "@\(preferredUsername)"
    }
    
    func updateUserGivenNameLabel(with givenName: String) {
        userGivenNameLabel.text = givenName
    }
    
    func updateBioLabel(with bio: String) {
        expandableTextViewController.text = bio
        didUpdateHeight(expandableTextViewController.getCurrentHeight())
        adaptCoverImageHeight()
        update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
    }
    
    func updateUserProfileImageView(with profileImage: UIImage?) {
        profile.profileImage?.image = profileImage
        userImageView.subviews.forEach { $0.removeFromSuperview() }
        userImageView.image = profileImage
        userImageView.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
}

extension HeaderViewController {
    
    private func setupConstraints() {
        animator = blurAnimator()
        
        // Set initial zPosition values
        coverImageView.layer.zPosition = 10
        visualEffectView.layer.zPosition = 20
        
        profileBackground.layer.zPosition = backgroundZPosition // Profile background
//        userImageViewShimmerView.layer.zPosition = profileInfoZPosition
        stackView.layer.zPosition = profileInfoZPosition
        titleView.layer.zPosition = profileInfoZPosition
        
        if followButtonVC != nil {
            view.bringSubviewToFront(followButtonVC.view)
        }
        view.bringSubviewToFront(stackView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func setupUI() {
        
        addCoverImage()
        
        addProfileInfo()
        
        addProfileBackground()
        
        addTitleBar()
        
        addBottomViewController()
        
        addToolBar()
        
        adaptCoverImageHeight()
    }
    
    private func adaptCoverImageHeight() {
        UIView.animate(withDuration: 0.2) { [self] in
            let profileBackgroundHeight = self.stackView.frame.height + 50
            let dynamicHeight = UIScreen.main.bounds.height - profileBackgroundHeight
            self.coverImageHeightConstraint.constant = dynamicHeight
            self.covernitialHeight = dynamicHeight
            self.covernitialCenterY = dynamicHeight/2
            self.update(with: lastProgress, minHeaderHeight: lastMinHeaderHeight)
            self.stackView.layoutIfNeeded()
        }
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
        profileToolButtonVC = ProfileToolButtonViewController(frame: .zero, profile: profile, userIdentityID: userIdentityID, addShadow: false, color: .primary)
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
        
        
        if expandableTextViewController != nil {
            let profileBackgroundBottomAnchor = profileBackground.bottomAnchor.constraint(equalTo: expandableTextViewController.bottomAnchor, constant: 16)
            profileBackgroundBottomAnchor.isActive = true
        } else if followButtonVC != nil {
            let profileBackgroundBottomAnchor = profileBackground.bottomAnchor.constraint(equalTo: followButtonVC.view.bottomAnchor, constant: 16)
            profileBackgroundBottomAnchor.isActive = true
        } else if profileStatSkinSettings != nil {
            let profileBackgroundBottomAnchor = profileBackground.bottomAnchor.constraint(equalTo: profileStatSkinSettings.view.bottomAnchor, constant: 16)
            profileBackgroundBottomAnchor.isActive = true
        } else {
            let profileBackgroundBottomAnchor = profileBackground.bottomAnchor.constraint(equalTo: profileStatFollowNumber.view.bottomAnchor, constant: 16)
            profileBackgroundBottomAnchor.isActive = true
        }
        
        NSLayoutConstraint.activate([
            profileBackground.widthAnchor.constraint(equalTo: view.widthAnchor),
            profileBackground.topAnchor.constraint(equalTo: userImageView.centerYAnchor),
        ])
    }
    
    private func addProfileInfo() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        addUserProfileImageView(to: stackView)
        addUserGivenNameLabel(to: stackView)
        addUserPreferredUsernameLabel(to: stackView)
        addFollowNumberInfo(to: stackView)
        addSkinSettingsInfo(to: stackView)
        addFollowButton(to: stackView)
        addExpandableTextViewController(to: stackView)
        
        view.bringSubviewToFront(stackView)
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
        toolBar = ProfileToolButtonViewController(frame: .zero, profile: profile, userIdentityID: userIdentityID, color: .background)
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

extension HeaderViewController: ExpandableTextViewControllerDelegate {
    
    private func addUserProfileImageView(to stackView: UIStackView) {
        // Container view to hold both the shimmer view and the actual profile image view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        stackView.addArrangedSubview(containerView)
        
        // Actual profile image (UIImageView)
        if let profileImage = profile.profileImage?.image {
            userImageView = UIImageView(image: profileImage)
        } else {
            userImageView = UIImageView()
        }
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.layer.cornerRadius = 50
        userImageView.backgroundColor = .systemGray5
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderColor = UIColor.background.cgColor
        userImageView.layer.borderWidth = 4
        
        containerView.addSubview(userImageView)
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            userImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            userImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            userImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        setupDefaultImageAppearance(imageView: userImageView, text: "", icon: "person.fill")
        
        containerView.bringSubviewToFront(userImageView)
    }

    private func setupDefaultImageAppearance(imageView: UIImageView, text: String?, icon: String) {
        imageView.subviews.forEach { $0.removeFromSuperview() } // Always clear previous subviews first
        
        if imageView.image == nil {
            imageView.backgroundColor = .systemGray5
            
            if let text = text, !text.isEmpty {
                let iconImage = UIImage(systemName: icon)?.withTintColor(.primary, renderingMode: .alwaysOriginal)
                let iconImageView = UIImageView(image: iconImage)
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                
                let label = UILabel()
                label.text = text
                label.textColor = .white
                label.font = UIFont.systemFont(ofSize: 16)
                label.translatesAutoresizingMaskIntoConstraints = false
                
                let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.spacing = 8
                stackView.translatesAutoresizingMaskIntoConstraints = false
                
                imageView.addSubview(stackView)
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                ])
            } else {
                let iconImage = UIImage(systemName: icon)?.withTintColor(.primary, renderingMode: .alwaysOriginal)
                let iconImageView = UIImageView(image: iconImage)
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                
                imageView.addSubview(iconImageView)
                NSLayoutConstraint.activate([
                    iconImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    iconImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
                    iconImageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.7),
                    iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
                ])
            }
        } else {
            imageView.backgroundColor = .clear
        }
        
        imageView.layoutIfNeeded()
    }

    private func addUserGivenNameLabel(to stackView: UIStackView) {
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
        stackView.addArrangedSubview(userGivenNameLabel)
        
        view.bringSubviewToFront(userGivenNameLabel)
    }

    private func addUserPreferredUsernameLabel(to stackView: UIStackView) {
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
        stackView.addArrangedSubview(userNameLabel)
        
        view.bringSubviewToFront(userNameLabel)
    }

    private func addFollowNumberInfo(to stackView: UIStackView) {
        profileStatFollowNumber = ProfileStatsViewController()
        profileStatFollowNumber.profile = profile
        addChild(profileStatFollowNumber)
        stackView.addArrangedSubview(profileStatFollowNumber.view)
        profileStatFollowNumber.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStatFollowNumber.view.heightAnchor.constraint(equalToConstant: 50)
        ])
        profileStatFollowNumber.didMove(toParent: self)
        
        view.bringSubviewToFront(profileStatFollowNumber.view)
    }
    
    private func addSkinSettingsInfo(to stackView: UIStackView) {
//        if !isAccountUser {
//            return
//        }
        profileStatSkinSettings = SkinSettingsProfileBubbleViewController(skinSettings: profile.skinSetting ?? SkinSettingsAttributes())
        addChild(profileStatSkinSettings)
        stackView.addArrangedSubview(profileStatSkinSettings.view)
        profileStatSkinSettings.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileStatSkinSettings.view.heightAnchor.constraint(equalToConstant: 75)
        ])
        profileStatSkinSettings.didMove(toParent: self)
        
        view.bringSubviewToFront(profileStatSkinSettings.view)
    }

    private func addFollowButton(to stackView: UIStackView) {
        if isAccountUser {
            return
        }
        
        followButtonVC = UIHostingController(rootView: ProfileFollowButtonView(otherUserIdentityID: profile.identityID, onNavigateLogin: {
            self.logoutAndNavigateToLumeHorizontalTabViewController()
        }))
        
        addChild(followButtonVC)
        followButtonVC.view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(followButtonVC.view)
        NSLayoutConstraint.activate([
            followButtonVC.view.widthAnchor.constraint(equalToConstant: 100),
            followButtonVC.view.heightAnchor.constraint(equalToConstant: 30)
        ])
        followButtonVC.didMove(toParent: self)
        
        view.bringSubviewToFront(followButtonVC.view)
    }

    private func addExpandableTextViewController(to stackView: UIStackView) {
        
        let descriptionText = profile.bio
        expandableTextViewController = ExpandableTextViewController(text: descriptionText)
        expandableTextViewController.delegate = self
        view.addSubview(expandableTextViewController)
        expandableTextViewController.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(expandableTextViewController)
        
        let textBoxHeight = profile.bio.isEmpty ? 0 : max(expandableTextViewController.getCurrentHeight(), 32) + 16
        
        if followButtonVC != nil {
            
            DispatchQueue.main.async { [self] in
                expandableTextViewBottomAnchor = expandableTextViewController.bottomAnchor.constraint(equalTo: followButtonVC.view.bottomAnchor, constant: textBoxHeight)
                expandableTextViewBottomAnchor.isActive = true
                
                NSLayoutConstraint.activate([
                    expandableTextViewController.topAnchor.constraint(equalTo: followButtonVC.view.safeAreaLayoutGuide.bottomAnchor),
                    expandableTextViewController.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    expandableTextViewController.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                ])
            }
            
        } else {
            
            DispatchQueue.main.async { [self] in
                expandableTextViewBottomAnchor = expandableTextViewController.bottomAnchor.constraint(equalTo: profileStatSkinSettings.view.bottomAnchor, constant: textBoxHeight)
                expandableTextViewBottomAnchor.isActive = true
                
                NSLayoutConstraint.activate([
                    expandableTextViewController.topAnchor.constraint(equalTo: profileStatSkinSettings.view.safeAreaLayoutGuide.bottomAnchor),
                    expandableTextViewController.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    expandableTextViewController.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                ])
            }
        }
        
        view.bringSubviewToFront(expandableTextViewController)
    }
    
    private func logoutAndNavigateToLumeHorizontalTabViewController() {
        
        if let viewControllers = navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController is LumeHorizontalTabViewController {
                    self.navigationController?.delegate = backButtonDelegate as? any UINavigationControllerDelegate
                    self.navigationController?.popViewController(animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let lumeVC = viewController as? LumeHorizontalTabViewController {
                            lumeVC.showLoginSheet()
                        }
                    }
                    return
                }
            }
        }
        
        self.navigationController?.delegate = backButtonDelegate as? any UINavigationControllerDelegate
        self.navigationController?.popViewController(animated: true)
        
        // After navigation is complete, present the login sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let rootVC = self.navigationController?.viewControllers.first as? LumeHorizontalTabViewController {
                rootVC.showLoginSheet()
            }
        }
    }
}

extension HeaderViewController {
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
        
        stackView.alpha = opacity
//        userImageViewShimmerView.layer.zPosition = opacity
        
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
        if profile.bio.isEmpty {
            if isAccountUser {
                if profileStatSkinSettings != nil {
                    titleOffset = max(min(0, (profileStatSkinSettings.view.convert(profileStatSkinSettings.view.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
                } else {
                    titleOffset = max(min(0, (profileStatFollowNumber.view.convert(profileStatFollowNumber.view.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
                }
            } else {
                if followButtonVC != nil {
                    titleOffset = max(min(0, (followButtonVC.view.convert(followButtonVC.view.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
                } else {
                    titleOffset = max(min(0, (profileStatSkinSettings.view.convert(profileStatSkinSettings.view.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
                }
            }
        } else {
            titleOffset = max(min(0, (expandableTextViewController.convert(expandableTextViewController.bounds, to: nil).minY - minHeaderHeight)), -titleView.frame.height)
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
                
//                userImageViewShimmerView.layer.zPosition = 0
                stackView.layer.zPosition = 0
                profileBackground.layer.zPosition = -5
            }
        } else {
            coverImageView.center.y = covernitialCenterY
            //let scale = min(1, (1 - progress * 1.3))
            //let t = CGAffineTransform(scaleX: scale, y: scale)
            //userImageView.transform = t.translatedBy(x: 0, y: userImageView.frame.height * (1 - scale))
            
//            userImageViewShimmerView.layer.zPosition = profileInfoZPosition + 5
            
            if !stickyCover {
                self.stickyCover = true
                
//                userImageViewShimmerView.layer.zPosition = profileInfoZPosition
                stackView.layer.zPosition = profileInfoZPosition
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
        
//        if let profileImage =  profile.profileImage?.image {
//            userImageView.image = profileImage
//            userImageView.isHidden = false // Show the image view
////            userImageViewShimmerView.isHidden = true // Hide the shimmer view
//            Task {
//                ProfileManager.shared.updateProfile(profile)
//            }
//        }
        
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
        profileStatFollowNumber.updateProfile(profile: profile)
        bottomViewController.updateProfile(profile: profile)
        toolBar.updateProfile(profile: profile)
        profileToolButtonVC.updateProfile(profile: profile)
        
        expandableTextViewController.text = profile.bio
        expandableTextViewController.layoutIfNeeded()
        
        adaptCoverImageHeight()
        
        view.layoutIfNeeded()
    }
    
    func updateSkinSettings(newSkinSettings: SkinSettingsAttributes) {
        profileStatSkinSettings.updateSkinSettings(skinSettings: newSkinSettings)
    }
    
    func didUpdateHeight(_ height: CGFloat) {
        guard expandableTextViewBottomAnchor != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.expandableTextViewBottomAnchor.constant = self.expandableTextViewController.text.isEmpty ? 0 : max(height, 32) + 16
            print("height updated: \(self.expandableTextViewBottomAnchor.constant)")
            self.adaptCoverImageHeight()
            self.expandableTextViewController.layoutIfNeeded()
        }
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
