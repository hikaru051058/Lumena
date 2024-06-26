//
//  TwitterParallaxViewController.swift
//  test
//
//  Created by 島田晃 on 2024/05/14.
//

import UIKit
import TwitterProfile
import XLPagerTabStrip
import SwiftUI


protocol RefreshDelegate: AnyObject {
    func didStartRefreshing()
    func didEndRefreshing()
}


class TwitterParallaxViewController: UIViewController, TPDataSource, TPProgressDelegate, UINavigationControllerDelegate {
    
    var headerVC: HeaderViewController?
    var bottomVC: XLPagerTabStripExampleViewController!
    var backgroundVC: ProfileBackgroundViewController!
    
    private var viewLoading: Bool = true
    var isBackButtonTapped = false
    var isSettingsButtonTapped = false
    
    var userIdentityID: String!
    var profile: ProfileSettings = ProfileSettings()
    var profileSettings: ProfileSettingsViewController!
    
    private let transitionAnimator = SharedTransitionAnimator()
    private var originalDelegate: UINavigationControllerDelegate?
    
    weak var refreshDelegate: RefreshDelegate?
    let refresh = UIRefreshControl()
    
    init(userIdentityID: String, profile: ProfileSettings = ProfileSettings()) {
        self.userIdentityID = userIdentityID
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        fetchUserProfile()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary
        self.tp_configure(with: self, delegate: self)
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self;
        originalDelegate = self
        setupBackgroundViewController()
        viewLoading = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.delegate = self
        fetchUserProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil
    }
    
    func fetchUserProfile() {
//        DispatchQueue.main.async { [self] in
            self.profile = ProfileManager.shared.getProfile(withID: userIdentityID)
            if viewLoading {
                self.headerVC?.updateProfile(profile: profile)
                self.bottomVC?.updateProfile(profile: profile)
                self.backgroundVC?.updateProfile(profile: profile)
            }
//        }
    }
    
    // MARK: TPDataSource
    func headerViewController() -> UIViewController {
        headerVC = HeaderViewController(profile: profile)
        headerVC?.backButtonDelegate = self
        return headerVC!
    }
    
    func bottomViewController() -> UIViewController & PagerAwareProtocol {
        bottomVC = XLPagerTabStripExampleViewController(profile: profile)
        bottomVC.refreshDelegate = self
        return bottomVC
    }
    
    // Stop scrolling header at this point
    func minHeaderHeight() -> CGFloat {
        return (topInset + 44)
    }
    
    // MARK: TPProgressDelegate
    func tp_scrollView(_ scrollView: UIScrollView, didUpdate progress: CGFloat) {
        headerVC?.update(with: progress, minHeaderHeight: minHeaderHeight())
    }
    
    func tp_scrollViewDidLoad(_ scrollView: UIScrollView) {
        //refresh.tintColor = .background
        refresh.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        let refreshView = UIView(frame: CGRect(x: 0, y: 44, width: 0, height: 0))
        scrollView.addSubview(refreshView)
        refreshView.addSubview(refresh)
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Bypass transition animation if back button was tapped
        if isBackButtonTapped || isSettingsButtonTapped{
            // Reset the flag
            isBackButtonTapped = false
            isSettingsButtonTapped = false
            return nil
        }
        
        if let bottomVC = bottomVC.currentViewController as? BottomViewController {
            return bottomVC.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        }
        
        if fromVC is TwitterParallaxViewController, toVC is DetailScreen {
            transitionAnimator.transition = .push
            return transitionAnimator
        }
        if toVC is TwitterParallaxViewController, fromVC is DetailScreen {
            transitionAnimator.transition = .pop
            return transitionAnimator
        }
        
        return nil
    }
    
    private func setupBackgroundViewController() {
        backgroundVC = ProfileBackgroundViewController(profile: profile)
        addChild(backgroundVC)
        view.insertSubview(backgroundVC.view, at: 0)
        backgroundVC.didMove(toParent: self)
        
        backgroundVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func returnButton() {
        if let navigationController = self.view.window?.rootViewController as? UINavigationController {
            navigationController.popViewController(animated: true)
        } else {
            // Handle the case where there is no navigation controller
            print("No navigation controller found")
        }
    }
}

// MARK: - RefreshDelegate

extension TwitterParallaxViewController: RefreshDelegate {
    
    @objc func handleRefreshControl() {
        print("refreshing")
        refreshDelegate = bottomVC
        refreshDelegate?.didStartRefreshing()
        
        self.fetchUserProfile()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refresh.endRefreshing()
            self.refreshDelegate?.didEndRefreshing()
        }
    }
    
    func didStartRefreshing() {
        print("Started refreshing in TwitterParallaxViewController")
        // Add any specific logic you want to execute when refresh starts
    }
    
    func didEndRefreshing() {
        print("Ended refreshing in TwitterParallaxViewController")
        // Add any specific logic you want to execute when refresh ends
    }
}

// MARK: - SharedTransitioning

extension TwitterParallaxViewController: SharedTransitioning {
    var sharedFrame: CGRect {
        guard let bottomVC = bottomVC,
              let selectedIndexPath = (bottomVC.currentViewController as? BottomViewController)?.selectedIndexPath,
              let cell = (bottomVC.currentViewController as? BottomViewController)?.collectionView.cellForItem(at: selectedIndexPath),
              let frame = cell.frameInWindow else { return .zero }
        return frame
    }

    func prepare(for transition: SharedTransitionAnimator.Transition) {
        guard let bottomVC = bottomVC,
              let selectedIndexPath = (bottomVC.currentViewController as? BottomViewController)?.selectedIndexPath else { return }
        
        (bottomVC.currentViewController as? BottomViewController)?.collectionView.verticalScrollItemVisible(at: selectedIndexPath, with: 40, animated: false)
        
//        switch transition {
//        case .push:
//            // Entering the detail view
//            reduceViewSize()
//        case .pop:
//            // Exiting the detail view
//            break
//        }
    }
    
    func reduceViewSize() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    func restoreViewSize() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform.identity
        })
    }
}

extension TwitterParallaxViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TwitterParallaxViewController: ProfileToolButtonDelegate {
    
    func didTapBackButton() {
        self.isBackButtonTapped = true
        self.navigationController?.delegate = originalDelegate
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapFollowRequestButton() {
        print("tapped follow request")
    }
    
    func didTapSettingsButton() {
        self.isSettingsButtonTapped = true
        if profileSettings == nil {
            profileSettings = ProfileSettingsViewController()
        }
        profileSettings.profile = profile
        self.navigationController?.delegate = originalDelegate
        self.navigationController?.pushViewController(profileSettings, animated: true)
    }
}
