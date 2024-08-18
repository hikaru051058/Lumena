//
//  LumeViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/04.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import XLPagerTabStrip

import AVKit
import AVFoundation

enum LumeMainPageTabRep: String {
    case recommended = "おすすめ"
    case following = "フォロー中"
}

// MARK: - Horizontal Paging of Vertical Lumes viewcontroller
class LumeHorizontalTabViewController: ButtonBarPagerTabStripViewController {
    
    var userLoggedIn: Bool
    var pageViewControllers: [UIViewController] = []
    
    private var defaultIndex: Int {
        return pageViewControllers.count > 1 ? (userLoggedIn ? 1 : 0) : 0
    }
    private var initialized: Bool = false
    
    init(userLoggedIn: Bool = false) {
        self.userLoggedIn = userLoggedIn
        super.init(nibName: nil, bundle: nil)
        setupTabBarStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUploadProgressBar()
        setupCustomTabBar()
        setupBottomIsland()
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccessHandler), name: .authStatusChanged, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if !initialized {
            moveToViewController(at: defaultIndex, animated: false)
            initialized = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        pageViewControllers = []
        
        if userLoggedIn {
            let followingVC = LumeVerticalInfiniteScrollViewController(title: NSLocalizedString(LumeMainPageTabRep.following.rawValue, comment: ""), userLoggedIn: userLoggedIn)
            
            pageViewControllers.append(followingVC)
        }
        
        let recommendedVC = LumeVerticalInfiniteScrollViewController(title: NSLocalizedString(LumeMainPageTabRep.recommended.rawValue, comment: ""), userLoggedIn: userLoggedIn)
        pageViewControllers.append(recommendedVC)
        
        return pageViewControllers
    }
    
    @objc private func authSuccessHandler(notification: Notification) {
        DispatchQueue.main.async {
            self.userLoggedIn = AuthenticationManager.shared.authStatus == .authenticated
            self.settings.style.selectedBarWidthPercentage = self.userLoggedIn ? 0.5 : 0.25
            self.reloadData()
        }
    }
    
    private func reloadData() {
        self.reloadPagerTabStripView()
        self.buttonBarView.reloadData() // Ensure the ButtonBarView is reloaded to reflect the changes
    }
    
    private var bottomIslandViewController: BottomIslandViewController!
    private var uploadProgressBarViewController: UploadProgressBarViewController!
    
    private func setupBottomIsland() {
        bottomIslandViewController = BottomIslandViewController(userLoggedIn: userLoggedIn)
        
        addChild(bottomIslandViewController)
        view.addSubview(bottomIslandViewController.view)
        bottomIslandViewController.didMove(toParent: self)
        
        bottomIslandViewController.view.backgroundColor = UIColor.clear
        
        bottomIslandViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomIslandViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomIslandViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomIslandViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            bottomIslandViewController.view.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.bringSubviewToFront(bottomIslandViewController.view)
    }
    
    private func setupUploadProgressBar() {
        uploadProgressBarViewController = UploadProgressBarViewController()
        
        addChild(uploadProgressBarViewController)
        view.addSubview(uploadProgressBarViewController.view)
        uploadProgressBarViewController.didMove(toParent: self)
        
        uploadProgressBarViewController.view.backgroundColor = UIColor.clear

        uploadProgressBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.bringSubviewToFront(uploadProgressBarViewController.view)
        
        NSLayoutConstraint.activate([
            uploadProgressBarViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uploadProgressBarViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            uploadProgressBarViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            uploadProgressBarViewController.view.heightAnchor.constraint(equalToConstant: 22)  // Ensure height is set
        ])
    }
    
    private func setupCustomTabBar() {
        view.addSubview(containerView)
        view.addSubview(buttonBarView)
        
        buttonBarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonBarView.layer.shadowColor = UIColor.black.cgColor
        buttonBarView.layer.shadowOpacity = 0.1
        buttonBarView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        buttonBarView.layer.shadowRadius = 0.25
        buttonBarView.layer.masksToBounds = false
        
        NSLayoutConstraint.activate([
            buttonBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBarView.topAnchor.constraint(equalTo: uploadProgressBarViewController.view.topAnchor),
            buttonBarView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.bringSubviewToFront(buttonBarView)
    }
    
    private func setupTabBarStyle() {
        self.settings.style.buttonBarBackgroundColor = .clear
        self.settings.style.buttonBarItemBackgroundColor = .clear
        self.settings.style.selectedBarBackgroundColor = .white
        self.settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        self.settings.style.selectedBarHeight = 3.0
        self.settings.style.selectedBarWidthPercentage = self.userLoggedIn ? 0.5 : 0.25
        self.settings.style.selectedBarCornerRadius = 2.5
        self.settings.style.buttonBarMinimumLineSpacing = 20
        self.settings.style.buttonBarItemTitleColor = .white
        self.settings.style.buttonBarItemsShouldFillAvailableWidth = true
        self.settings.style.buttonBarLeftContentInset = 50
        self.settings.style.buttonBarRightContentInset = 50
        
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .secondary
            newCell?.label.textColor = .white
        }
    }
    
    func showLoginSheet() {
        let loginVC = LoginViewController()
        loginVC.onLoginSuccess = {
            NotificationCenter.default.post(name: .authStatusChanged, object: nil, userInfo: ["status": "login"])
            if AuthenticationManager.shared.authStatus == .authenticated {
                self.dismiss(animated: true, completion: nil)
            }
        }
        let navController = UINavigationController(rootViewController: loginVC)
        navController.modalPresentationStyle = .automatic
        present(navController, animated: true, completion: nil)
    }
}



// MARK: ^-
// MARK: - Vertical Lumes viewcontroller
class LumeVerticalInfiniteScrollViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = IndicatorInfo(title: "")
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    var scrollView: UIScrollView!
    var contentStackView: UIStackView!
    private var refreshControl: UIRefreshControl!
    private var lumes: [Lume] = []
    
    private var loadAutomatically: Bool = true

    // Mimic SwiftUI's currentReel
    private var currentLume: UUID?
    private var currentLumePostID: String?
    
    var mute: Bool = false
    var userLoggedIn: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(lumes: [Lume], loadAutomatically: Bool = true, currentLumePostID: String = "", userLoggedIn: Bool = false) {
        self.lumes = lumes
        self.loadAutomatically = loadAutomatically
        self.currentLumePostID = currentLumePostID
        self.userLoggedIn = userLoggedIn
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(title: String, userLoggedIn: Bool) {
        self.init()
        self.itemInfo.title = title
        self.userLoggedIn = userLoggedIn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccessHandler), name: .authStatusChanged, object: nil)
        
        setupUI()
        if loadAutomatically {
            loadInitialLumes()
        } else {
            self.addTabs()
            scrollToCurrentLumeIfNeeded()
        }
        scrollView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loadAutomatically {
            scrollToCurrentLumeIfNeeded()
        }
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        if loadAutomatically {
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
            scrollView.addSubview(refreshControl)
            scrollView.refreshControl = refreshControl
        }
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        
        // Add gesture recognizer for interactive transition
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        scrollView.addGestureRecognizer(panGesture)
    }
    
    private func fetchLumes(completion: @escaping (_ success: Bool) -> Void) {
        Task {
            do {
                
                let returnedLumes = try await GraphQL.shared.fetchRandomLumes()
                // Use a set to track existing lume IDs for fast lookup
                var existingIds = Set(lumes.map { $0.postID })

                // Filter out duplicates
                let uniqueLumes = returnedLumes.filter { lume in
                    if existingIds.contains(lume.postID) {
                        return false // This lume is a duplicate
                    } else {
                        existingIds.insert(lume.postID)
                        return true // This lume is unique
                    }
                }
                
                lumes.append(contentsOf: uniqueLumes)
                
                completion(true)
            } catch {
                print(error)
                completion(false)
            }
        }
    }
    
    private func loadInitialLumes() {
        fetchLumes { success in
            DispatchQueue.main.async {
                if success {
                    self.addTabs()
                } else {
                    print("Failed to fetch lumes.")
                }
            }
        }
    }
    
    @objc private func authSuccessHandler() {
        DispatchQueue.main.async {
            self.updateCurrentLume()
        }
    }

    private func addTabs() {
        for lume in lumes {
            let lumeVC = LumeIndividualViewController(
                lume: lume,
                currentLume: currentLume ?? UUID(),
                mute: mute,
                userLoggedIn: userLoggedIn
            )
            
            addChild(lumeVC)
            contentStackView.addArrangedSubview(lumeVC.view)
            lumeVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lumeVC.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height),
                lumeVC.view.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
            ])
            lumeVC.didMove(toParent: self)
        }
        scrollView.layoutIfNeeded()
    }

    @objc private func refreshAction() {
        print("Refreshing content...")
        // Simulate network fetch
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.refreshControl.endRefreshing()
            self.scaleToOriginalSize()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scale: CGFloat = 0.99 // More noticeable scale down to 99%
        UIView.animate(withDuration: 0.008, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            self.contentStackView.subviews.forEach { view in
                if view.frame.intersects(scrollView.bounds) {
                    view.transform = CGAffineTransform(scaleX: scale, y: scale)
                } else {
                    view.transform = CGAffineTransform.identity
                }
            }
        }, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Reset scale transformation when user stops scrolling
        UIView.animate(withDuration: 0.05) {
            self.scaleToOriginalSize()
        }
        
        updateCurrentLume()
    }
    
    private func scaleToOriginalSize() {
        self.contentStackView.subviews.forEach { view in
            view.transform = CGAffineTransform.identity
        }
    }
    
    private func updateCurrentLume() {
        if let visibleIndex = getCurrentVisibleLumeIndex() {
            
            guard lumes.count > visibleIndex else {
                print("no visible index")
                return
            }
            let newCurrentLume = lumes[visibleIndex].id
            
            newLumeAppearSetup()
            
            if newCurrentLume != currentLume {
                currentLume = newCurrentLume
                notifyCurrentLumeChange()
                
                // Load more contents at the very end
                if lumes.count - 1 == visibleIndex && loadAutomatically {
                    loadMoreLumes()
                }
            }
        }
    }
    
    private func newLumeAppearSetup() {
        VideoDataStore.shared.videoPlaybackProgress = 0
    }

    private func notifyCurrentLumeChange() {
        for child in children as! [LumeIndividualViewController] {
            child.currentLumeChanged(to: currentLume)
        }
    }
    
    private func loadMoreLumes() {
        self.fetchLumes { success in
            DispatchQueue.main.async {
                if success {
                    self.addTabs()
                } else {
                    print("Failed to fetch lumes.")
                }
            }
        }
    }
    
    func toggleMute() {
        mute.toggle()
        updateChildViewControllersForMute()
    }

    private func updateChildViewControllersForMute() {
        for child in children as? [LumeIndividualViewController] ?? [] {
            child.updateMuteStatus(mute)
        }
    }
    
    private func scrollToCurrentLumeIfNeeded() {
        guard let currentLumePostID = currentLumePostID else { return }
        if let index = lumes.firstIndex(where: { $0.postID == currentLumePostID }) {
            let offsetY = CGFloat(index) * view.bounds.height
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            self.currentLume = lumes[index].id
            scaleToOriginalSize()
        }
    }
    
    private func getCurrentVisibleLumeIndex() -> Int? {
        let visibleRect = CGRect(x: 0, y: scrollView.contentOffset.y, width: scrollView.bounds.width, height: scrollView.bounds.height)
        for (index, child) in children.enumerated() {
            let childVC = child as! LumeIndividualViewController
            let childViewRect = scrollView.convert(childVC.view.frame, from: contentStackView)
            if visibleRect.intersects(childViewRect) {
                return index
            }
        }
        return nil
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        // Delegate the pan gesture to the interaction controller
        if let interactionController = navigationController?.delegate as? SharedTransitionInteractionController {
            interactionController.update(recognizer)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension LumeVerticalInfiniteScrollViewController {
    func getCurrentVisibleIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        for (index, _) in lumes.enumerated() {
            let lumeView = contentStackView.arrangedSubviews[index]
            if lumeView.frame.contains(visiblePoint) {
                return IndexPath(item: index, section: 0)
            }
        }
        return nil
    }
    
    func getCurrentVisibileIndex() -> Int? {
        return lumes.firstIndex(where: {$0.postID == currentLumePostID})!
    }
}

// MARK: ^-


// MARK: - Individual Lume's viewcontroller

// protocol to pass data from individual to child
protocol LumeIndividualDataUpdateDelegate: AnyObject {
    func didUpdateData(_ data: ProfileSettings?)
}

class LumeIndividualViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var pages: [UIViewController] = []
    
    var lume: Lume
    @Published var profile: ProfileSettings? = nil {
        didSet {
            sideButtonsViewController?.didUpdateData(profile)
            bottomButtonsViewController?.didUpdateData(profile)
        }
    }

    var currentLume: UUID
    
    var postUsername: String = ""
    
    var currentContentID: UUID?
    
    var mute: Bool {
        didSet {
            self.lume.mute(mute: self.mute)
            VideoDataStore.shared.mute = self.mute
        }
    }
    var userLiked: Bool = false
    var userLoggedIn: Bool = false
    
    // UI Components
    private var muteButton: UIButton!
    private var loveImageView: UIImageView!
    
    var sideButtonsViewController: LumeSideButtonsViewController!
    var bottomButtonsViewController: LumeBottomButtonsViewController!
    var darkView: UIView!
    
    private var musicNameText = MarqueeTextViewController()
    private var invisibleRectangleLeft: UIView!
    private var invisibleRectangleRight: UIView!
    
    private var pageControl = UIPageControl(frame: .zero)
    private var autoScrollTimer: Timer?
    
    private var lastTapTime: Date?
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    private var lumeAuthenticityView: UIView!
    private var lumeAuthenticityTitleStack: UIStackView!
    private var lumeAuthenticityTitleIcon: UIImageView!
    private var lumeAuthenticityTitleText: UILabel!
    private var lumeAuthenticityMessage: UILabel!
    
    private var lumeBottomViewHeightConstraint: NSLayoutConstraint!
    
    init(lume: Lume, currentLume: UUID, mute: Bool, userLoggedIn: Bool) {
        self.lume = lume
        self.currentLume = currentLume
        self.mute = mute
        self.userLoggedIn = userLoggedIn
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchUserProfile()
        setupScrollView()
        setupPages()
        setupGestureRecognizers()
        setupUIComponents()
        setupMarqueeLabel()
        setupPageIndicator()
        setupSideButtonsViewController()
        setupBottomButtonsViewController()
        setupLumeAuthenticity()
        fetchMuteStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        VideoDataStore.shared.videoPlaybackProgress = 0
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseVideoIfNeeded()
        lume.voiceOver.stop()
        VideoDataStore.shared.videoPlaybackProgress = 0
        VideoDataStore.shared.currentContentID = nil
        toggleLumeAuthView(shouldAppear: false)
        autoScrollTimer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toggleLumeAuthView(shouldAppear: false)
        lume.voiceOver.stop()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        view.backgroundColor = UIColor.black
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
    }
    
    private func setupPages() {
        var contentWidth: CGFloat = 0
        
        for content in lume.contents {
            guard let contentVC = contentViewController(for: content.id) else {
                print("Error in LumeIndividualViewController SetupPages: Could not add \(content.id) for \(lume.postID) as a child")
                return
            }
            
            addChild(contentVC)
            contentVC.view.frame = CGRect(x: contentWidth, y: 0, width: view.bounds.width, height: view.bounds.height)
            scrollView.addSubview(contentVC.view)
            contentVC.didMove(toParent: self)
            pages.append(contentVC)

            contentWidth += view.bounds.width
        }

        scrollView.contentSize = CGSize(width: contentWidth, height: view.bounds.height)
        updateCurrentPage()  // Set initial page based on first content
        handleSingleContentScenario()
        setupInvisibleBar()
    }
    
    private func setupInvisibleBar() {
        
        invisibleRectangleLeft = UIView()
        invisibleRectangleLeft.backgroundColor = UIColor.clear
        view.addSubview(invisibleRectangleLeft)
        
        invisibleRectangleLeft.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invisibleRectangleLeft.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            invisibleRectangleLeft.topAnchor.constraint(equalTo: view.topAnchor),
            invisibleRectangleLeft.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            invisibleRectangleLeft.widthAnchor.constraint(equalToConstant: 62)
        ])
        
        invisibleRectangleRight = UIView()
        invisibleRectangleRight.backgroundColor = UIColor.clear
        view.addSubview(invisibleRectangleRight)
        
        invisibleRectangleRight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invisibleRectangleRight.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            invisibleRectangleRight.topAnchor.constraint(equalTo: view.topAnchor),
            invisibleRectangleRight.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            invisibleRectangleRight.widthAnchor.constraint(equalToConstant: 62)
        ])
    }
    
    private func setupLumeAuthenticity() {
        
        if !lume.lumeAuth {
            return
        }
        
        // Main container view
        let cornerRadius: CGFloat = 30
        lumeAuthenticityView = UIView()
        lumeAuthenticityView.backgroundColor = .clear
        lumeAuthenticityView.layer.cornerRadius = cornerRadius
        lumeAuthenticityView.layer.masksToBounds = true
        lumeAuthenticityView.alpha = 0
        lumeAuthenticityView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Initially scaled down
        
        // Visual effect view for systemThinMaterial background
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = cornerRadius
        blurEffectView.layer.masksToBounds = true
        lumeAuthenticityView.addSubview(blurEffectView)
        
        view.addSubview(lumeAuthenticityView)
        
        lumeAuthenticityView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lumeAuthenticityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lumeAuthenticityView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lumeAuthenticityView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            blurEffectView.topAnchor.constraint(equalTo: lumeAuthenticityView.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: lumeAuthenticityView.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: lumeAuthenticityView.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: lumeAuthenticityView.bottomAnchor),
        ])
        
        // Title Stack
        lumeAuthenticityTitleStack = UIStackView()
        lumeAuthenticityTitleStack.axis = .horizontal
        lumeAuthenticityTitleStack.alignment = .center
        lumeAuthenticityTitleStack.distribution = .equalSpacing
        lumeAuthenticityTitleStack.spacing = 0
        lumeAuthenticityTitleStack.translatesAutoresizingMaskIntoConstraints = false
        lumeAuthenticityView.addSubview(lumeAuthenticityTitleStack)
        
        lumeAuthenticityTitleIcon = UIImageView()
        if let image = UIImage(systemName: "video.fill.badge.checkmark") {
            //checkmark.seal.fill
            lumeAuthenticityTitleIcon.image = image
            lumeAuthenticityTitleIcon.tintColor = .white
            lumeAuthenticityTitleIcon.contentMode = .scaleAspectFit
        }
        lumeAuthenticityTitleStack.addArrangedSubview(lumeAuthenticityTitleIcon)

        // Set the size of the icon to match the font size of the text
        let fontSize: CGFloat = 22.0
        lumeAuthenticityTitleIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lumeAuthenticityTitleIcon.widthAnchor.constraint(equalToConstant: fontSize + 5),
            lumeAuthenticityTitleIcon.heightAnchor.constraint(equalToConstant: fontSize + 5)
        ])

        lumeAuthenticityTitleText = UILabel()
        lumeAuthenticityTitleText.text = "Video Verification"
        lumeAuthenticityTitleText.textColor = .white
        lumeAuthenticityTitleText.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        lumeAuthenticityTitleText.textAlignment = .center
        lumeAuthenticityTitleText.translatesAutoresizingMaskIntoConstraints = false
        lumeAuthenticityTitleStack.addArrangedSubview(lumeAuthenticityTitleText)

        // Message Label
        lumeAuthenticityMessage = UILabel()
        lumeAuthenticityMessage.text = "This icon confirms that the content was filmed or recorded on Lumena without using any editing software, filters, or modifications"
        lumeAuthenticityMessage.textColor = .white
        lumeAuthenticityMessage.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lumeAuthenticityMessage.numberOfLines = 0
        lumeAuthenticityMessage.textAlignment = .center
        lumeAuthenticityMessage.translatesAutoresizingMaskIntoConstraints = false
        lumeAuthenticityView.addSubview(lumeAuthenticityMessage)
        
        // Constraints for title stack and message label
        NSLayoutConstraint.activate([
            lumeAuthenticityTitleStack.topAnchor.constraint(equalTo: lumeAuthenticityView.topAnchor, constant: 16),
            lumeAuthenticityTitleStack.leadingAnchor.constraint(equalTo: lumeAuthenticityView.leadingAnchor, constant: 48),
            lumeAuthenticityTitleStack.trailingAnchor.constraint(equalTo: lumeAuthenticityView.trailingAnchor, constant: -48),
            
            lumeAuthenticityMessage.topAnchor.constraint(equalTo: lumeAuthenticityTitleStack.bottomAnchor, constant: 16),
            lumeAuthenticityMessage.leadingAnchor.constraint(equalTo: lumeAuthenticityView.leadingAnchor, constant: 16),
            lumeAuthenticityMessage.trailingAnchor.constraint(equalTo: lumeAuthenticityView.trailingAnchor, constant: -16),
            lumeAuthenticityMessage.bottomAnchor.constraint(equalTo: lumeAuthenticityView.bottomAnchor, constant: -16),
        ])
        
        // Add tap gesture recognizer to lumeAuthenticityView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(lumeAuthButtonTapped))
        lumeAuthenticityView.addGestureRecognizer(tapGesture)
        lumeAuthenticityView.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(lumeAuthButtonTapped), name: .lumeAuthenticationExpanded, object: nil)
    }

    @objc private func lumeAuthButtonTapped() {
        
        if !lume.lumeAuth {
            return
        }
        
        if lumeAuthenticityView.alpha == 0 {
            toggleLumeAuthView(shouldAppear: true)
        } else {
            toggleLumeAuthView(shouldAppear: false)
        }
    }
    
    private func toggleLumeAuthView(shouldAppear: Bool, animation: Bool = true) {
        
        if !lume.lumeAuth {
            return
        }
        if shouldAppear {
            UIView.animate(withDuration: animation ? 0.15 : 0, animations: {
                self.lumeAuthenticityView.alpha = 1
                self.lumeAuthenticityView.transform = CGAffineTransform.identity
            })
        } else {
            UIView.animate(withDuration: animation ? 0.15 : 0, animations: {
                self.lumeAuthenticityView.alpha = 0
                self.lumeAuthenticityView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
        }
    }
    
    private func updateCurrentPage() {
        if let firstContent = lume.contents.first {
            currentContentID = firstContent.id
            let firstPageIndex = lume.contents.firstIndex(where: { $0.id == firstContent.id }) ?? 0
            let offsetX = CGFloat(firstPageIndex) * view.bounds.width
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
        }
    }

    private func handleSingleContentScenario() {
        if lume.contents.count == 1 {
            scrollView.isPagingEnabled = false
            pageControl.alpha = 0
        } else {
            scrollView.isPagingEnabled = true
            pageControl.alpha = 1
        }
    }
    
    private func createButton(action: Selector, imageName: String, tintColor: UIColor, buttonImageConfig: UIImage.SymbolConfiguration) -> UIButton {
        let button = UIButton()
        if let image = UIImage(systemName: imageName, withConfiguration: buttonImageConfig) {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Add shadow properties
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 1
        button.layer.masksToBounds = false
        
        return button
    }
}

extension LumeIndividualViewController: DescriptionExpandableViewControllerDelegate {
    
    private func setupSideButtonsViewController() {
        // Initialize the side buttons view controller with the necessary data
        self.sideButtonsViewController = LumeSideButtonsViewController(lume: lume, userLiked: userLiked, userLoggedIn: userLoggedIn)
        addChild(sideButtonsViewController)
        view.addSubview(sideButtonsViewController.view)
        sideButtonsViewController.didMove(toParent: self)
        
        // Setup constraints or frame for placing it at the trailing bottom edge
        sideButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideButtonsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sideButtonsViewController.view.widthAnchor.constraint(equalToConstant: 50),
            sideButtonsViewController.view.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -30),
        ])
    }
    
    private func setupDarkShadeDescriptionBackground() {
        darkView = UIView()
        darkView.backgroundColor = UIColor(Color.black.opacity(0.4))
        darkView.alpha = 0
        view.addSubview(darkView)
        darkView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            darkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            darkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            darkView.topAnchor.constraint(equalTo: view.topAnchor),
            darkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(darkViewTapped))
        darkView.addGestureRecognizer(tapGesture)
    }

    @objc private func darkViewTapped() {
        UIView.animate(withDuration: 0.2) {
            self.bottomButtonsViewController.sideButtonDescriptionView.toggleDescription()
            self.darkView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func closeDescription() {
        UIView.animate(withDuration: 0.2) {
            self.bottomButtonsViewController.sideButtonDescriptionView.setDescriptionExpand(input: false)
            self.darkView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupBottomButtonsViewController() {
        setupDarkShadeDescriptionBackground()
        
        // Initialize the bottom buttons view controller with necessary data
        self.bottomButtonsViewController = LumeBottomButtonsViewController(lume: lume, userLiked: userLiked, userLoggedIn: userLoggedIn)
        
        // Add as a child view controller
        addChild(bottomButtonsViewController)
        view.addSubview(bottomButtonsViewController.view)
        bottomButtonsViewController.didMove(toParent: self)
        
        bottomButtonsViewController.sideButtonDescriptionView.lumeIndividualViewControllerdelegate = self
        
        bottomButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async { [self] in
            lumeBottomViewHeightConstraint = bottomButtonsViewController.view.heightAnchor.constraint(equalToConstant: bottomButtonsViewController.sideButtonDescriptionView.getCurrentHeight() + 45)
            lumeBottomViewHeightConstraint.isActive = true
        }
        
        NSLayoutConstraint.activate([
            bottomButtonsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomButtonsViewController.view.trailingAnchor.constraint(equalTo: sideButtonsViewController.view.leadingAnchor, constant: -16),
            bottomButtonsViewController.view.bottomAnchor.constraint(equalTo: sideButtonsViewController.view.bottomAnchor),
        ])
    }

    func didUpdateHeight(_ height: CGFloat) {
        lumeBottomViewHeightConstraint.constant = height + 45
        UIView.animate(withDuration: 0.2) {
            if self.darkView.alpha == 0 {
                self.darkView.alpha = 1
            } else {
                self.darkView.alpha = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupMarqueeLabel() {
        musicNameText = MarqueeTextViewController(
            text: (lume.tagMusic.trackName),
            font: UIFont.systemFont(ofSize: 16),
            leftFade: 16,
            rightFade: 16,
            startDelay: 3,
            alignment: .leading  // Adjust based on layout needs
        )
        
        addChild(musicNameText)
        view.addSubview(musicNameText.view)
        musicNameText.didMove(toParent: self)
        
        musicNameText.view.translatesAutoresizingMaskIntoConstraints = false
        musicNameText.view.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            musicNameText.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            musicNameText.view.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            musicNameText.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  -view.bounds.height * 0.035),
            musicNameText.view.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupFetchUserProfile() {
        Task {
            do {
                let profile = try await ProfileManager.shared.getProfile(withID: lume.postUserIID)
                DispatchQueue.main.async {
                    self.profile = profile
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func setupPageIndicator() {
        pageControl = UIPageControl(frame: .zero)
        pageControl.numberOfPages = lume.contents.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        
        pageControl.layer.shadowColor = UIColor.black.cgColor
        pageControl.layer.shadowOpacity = 0.25
        pageControl.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        pageControl.layer.shadowRadius = 0.25
        pageControl.layer.masksToBounds = false
        
        pageControl.isHidden = (lume.contents.count <= 1)
        
        view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 65),
            pageControl.centerYAnchor.constraint(equalTo: musicNameText.view.centerYAnchor),
        ])
        
        pageControl.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
    }
}

extension LumeIndividualViewController {
    
    private func contentViewController(for contentUUID: UUID) -> UIViewController? {
        guard let content = lume.contents.first(where: { $0.id == contentUUID }) else {
            print("Content with UUID \(contentUUID) not found.")
            return nil
        }
        
        VideoDataStore.shared.currentContentID = contentUUID

        switch content {
        case .video(let videoContent):
            let videoViewController = VideoContentViewController(contentID: contentUUID, videoContent: videoContent)
            videoViewController.mute = mute
            return videoViewController
        case .image(let imageContent):
            let imageViewController = ImageContentViewController(contentID: contentUUID, imageContent: imageContent)
            return imageViewController
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let contentViewController = viewController as? LumeContentViewController,
              let currentIndex = lume.contents.firstIndex(where: { $0.id == contentViewController.contentID }),
              currentIndex > 0 else {
            return nil
        }
        
        let previousIndex = currentIndex - 1
        return self.contentViewController(for: lume.contents[previousIndex].id)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let contentViewController = viewController as? LumeContentViewController,
              let currentIndex = lume.contents.firstIndex(where: { $0.id == contentViewController.contentID }),
              currentIndex < lume.contents.count - 1 else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        return self.contentViewController(for: lume.contents[nextIndex].id)
    }
}

extension LumeIndividualViewController {
    
    private func setupGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
        doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGestureRecognizer)
        
        // Ensure the single tap doesn't fire when the double tap is recognized
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
    }
    
    private func setupUIComponents() {
        // Example for setting up a mute button and love image view, similar to the SwiftUI view
        muteButton = UIButton()
        loveImageView = UIImageView(image: UIImage(systemName: "heart.fill"))
    }
    
    @objc private func handleSingleTap() {
        // Toggle mute and update UI accordingly
        mute.toggle()
    }
    
    @objc private func handleDoubleTap() {
        // Handle like action and update UI accordingly
        if !lume.userLiked {
            lume.likedLume(userLikeInput: !lume.userLiked)
            updateLikeStatusOnUI(lume.userLiked)
        } else {
            sideButtonsViewController.likeButton.animateLike(onlyAnimation: true)
        }
    }
    
    private func updateLikeStatusOnUI(_ liked: Bool) {
        sideButtonsViewController.toggleLike()
    }
    
    private func fetchMuteStatus() {
        mute = VideoDataStore.shared.mute
    }
}

extension LumeIndividualViewController {
    
    private func setupAutoScrollTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc private func autoScroll() {
        let nextPage = (pageControl.currentPage + 1) % lume.contents.count
        selectViewController(at: nextPage)
    }

}

extension LumeIndividualViewController {
    
    private func resumeVideoIfNeeded() {
        if let videoVC = currentVisibleViewController() as? VideoContentViewController {
            videoVC.resumeVideoIfNeeded()
        }
    }
    
    private func resumeVideoAtPage(index: Int) {
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }
        if let videoVC = pages[index] as? VideoContentViewController {
            VideoDataStore.shared.currentContentID = lume.contents[index].id
            videoVC.resumeVideoIfNeeded()
        }
    }
    
    private func pauseVideoIfNeeded() {
        if let videoVC = currentVisibleViewController() as? VideoContentViewController {
            videoVC.pauseVideo()
            VideoDataStore.shared.videoPlaybackProgress = 0
        }
    }
    
    private func pauseAllVideo() {
        for page in pages {
            if let videoVC = page as? VideoContentViewController {
                videoVC.pauseVideo()
            }
        }
        VideoDataStore.shared.videoPlaybackProgress = 0
    }
    
    func updateMuteStatus(_ mute: Bool) {
        self.mute = mute
        VideoDataStore.shared.mute = mute
    }
}

extension LumeIndividualViewController {
    
    func currentLumeChanged(to newCurrentLume: UUID?) {
        if let newCurrentLume = newCurrentLume, lume.id == newCurrentLume {
            sideButtonsViewController.updateCurrentLume(with: newCurrentLume)
            setupAutoScrollTimer()
            let currentPage = currentViewControllerIndex()
            let currentContentID = lume.contents[currentPage].id
            VideoDataStore.shared.currentContentID = currentContentID
            resumeVideoIfNeeded()
            lume.voiceOver.play(repeatAudio: true)
        } else {
            toggleLumeAuthView(shouldAppear: false)
            autoScrollTimer?.invalidate()
            pauseAllVideo()
            lume.voiceOver.stop()
            closeDescription()
        }
    }
    
    private func currentVisibleViewController() -> UIViewController? {
        let pageIndex = Int(round(scrollView.contentOffset.x / view.frame.width))
        return pageIndex >= 0 && pageIndex < pages.count ? pages[pageIndex] : nil
    }
    
    private func currentViewControllerIndex() -> Int {
        let pageIndex = Int(round(scrollView.contentOffset.x / view.frame.width))
        pageControl.currentPage = pageIndex
        return pageIndex
    }
    
    private func selectViewController(at index: Int) {
        guard index >= 0 && index < pages.count else {
            print("Index out of bounds")
            return
        }
        
        pauseVideoIfNeeded()
        VideoDataStore.shared.videoPlaybackProgress = 0
        toggleLumeAuthView(shouldAppear: false)
        
        let targetOffsetX = CGFloat(index) * scrollView.frame.width
        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
        pageControl.currentPage = index
        
        let currentContentID = lume.contents[index].id
        VideoDataStore.shared.currentContentID = currentContentID
        resumeVideoAtPage(index: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let pageIndex = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = pageIndex
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Update the current page and print the content ID
        let currentPage = currentViewControllerIndex()
        let currentContentID = lume.contents[currentPage].id
        VideoDataStore.shared.currentContentID = currentContentID
        resumeVideoIfNeeded()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseVideoIfNeeded()
        VideoDataStore.shared.videoPlaybackProgress = 0
        toggleLumeAuthView(shouldAppear: false)
        autoScrollTimer?.invalidate()
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let targetIndex = sender.currentPage
        let targetOffsetX = CGFloat(targetIndex) * scrollView.frame.width
        pageControl.currentPage = targetIndex
        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        // This method is called before a transition begins.
        if let videoVC = currentVisibleViewController() as? VideoContentViewController {
            videoVC.pauseVideo()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = currentVisibleViewController() as? LumeContentViewController,
           let currentIndex = lume.contents.firstIndex(where: { $0.id == currentVC.contentID })
        {
            pageControl.currentPage = currentIndex
            currentContentID = currentVC.contentID
            lume.currentContent = currentVC.contentID
            
            print(currentVC.contentID)
            
            withAnimation {
                VideoDataStore.shared.videoPlaybackProgress = 0
            }
        }
    }
}

// MARK: ^-
// MARK: - Content type for Lume viewcontroller

// LumeContentViewController is a base view controller for content that has an identifier
class LumeContentViewController: UIViewController {
    var contentID: UUID

    init(contentID: UUID) {
        self.contentID = contentID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// VideoContentViewController is responsible for displaying video content
class VideoContentViewController: LumeContentViewController {
    
    var videoContent: LumeVideo
    
    private var cancellables: Set<AnyCancellable> = []
    
    var mute: Bool = false {
        didSet {
            videoContent.player?.isMuted = mute
        }
    }
    
    init(contentID: UUID, videoContent: LumeVideo) {
        self.videoContent = videoContent
        super.init(contentID: contentID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        setupNotifications()
        setupVideoPlaybackObserver()
        self.contentID = videoContent.id
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeVideoIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseVideo()
        VideoDataStore.shared.videoPlaybackProgress = 0
    }
    
    private var timeObserverToken: Any?

    private func setupVideoPlayer() {
        guard let player = videoContent.player else {
            print("Player is nil.")
            return
        }

        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        addChild(playerViewController)
        view.addSubview(playerViewController.view)

        setupVideoGravity(player: player, playerViewController: playerViewController)

        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        playerViewController.didMove(toParent: self)
        playerViewController.videoGravity = .resizeAspectFill
        
        registerEndOfVideoNotification()
    }

    private func registerEndOfVideoNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVideoEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: videoContent.player?.currentItem
        )
    }

    @objc private func handleVideoEnd() {
        // Seek to the beginning
        videoContent.player?.seek(to: .zero, completionHandler: { [weak self] _ in
            self?.videoContent.player?.play()  // Restart playback
        })
    }
    
    deinit {
        if let timeObserverToken = timeObserverToken {
            videoContent.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }

    private func setupVideoGravity(player: AVPlayer, playerViewController: AVPlayerViewController) {
        Task {
            do {
                if let videoTrack = try await player.currentItem?.asset.loadTracks(withMediaType: .video).first {
                    let size = try await videoTrack.load(.naturalSize)
                    let aspectRatio = size.width / size.height
                    DispatchQueue.main.async {
                        playerViewController.videoGravity = aspectRatio > 1 ? .resizeAspect : .resizeAspectFill
                    }
                }
            } catch {
                print("Error loading video track properties: \(error.localizedDescription)")
            }
        }
    }
    
    func resumeVideoIfNeeded() {
        
        guard VideoDataStore.shared.currentContentID == contentID else {
            print("current content ID does not match to play the video.")
            return
        }
        
        if let player = videoContent.player, player.currentItem?.status == .readyToPlay {
            mute = VideoDataStore.shared.mute
            player.isMuted = mute
            player.play()
        } else {
            print("Player not ready or content not loaded properly.")
        }
    }
    
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseVideo), name: .pauseVideoNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeVideoFromNotification(_:)), name: .resumeVideoNotification, object: nil)
    }
    
    @objc func pauseVideo() {
        videoContent.player?.pause()
    }
    
    @objc func resumeVideoFromNotification(_ notification: Notification) {
        
        guard VideoDataStore.shared.currentContentID == contentID else {
            return
        }
        
        if let progress = notification.userInfo?["progress"] as? CGFloat {
            videoContent.seekVideo(to: progress)
            videoContent.player?.play()
        }
    }

    private func setupVideoPlaybackObserver() {
        guard let player = videoContent.player else {
            print("No player available")
            return
        }

        let interval = CMTime(seconds: 0.3, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self = self, let _ = player.currentItem, !VideoDataStore.shared.isDragging else { return }
            if let progress = self.videoContent.currentPlaybackProgress() {
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.3)) {
                        VideoDataStore.shared.videoPlaybackProgress = progress
                    }
                }
            }
        }
    }
}


// ImageContentViewController is responsible for displaying image content
class ImageContentViewController: LumeContentViewController {
    var imageContent: LumeImage
    private var imageView: UIImageView!
    private var spinner: UIActivityIndicatorView!

    init(contentID: UUID, imageContent: LumeImage) {
        self.imageContent = imageContent
        super.init(contentID: contentID)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        loadImage()
    }
    
    private func setupImageView() {
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFill  // Fill the entire screen and maintain aspect ratio
        imageView.clipsToBounds = true  // Ensure that the image does not bleed outside the bounds of the view
        view.addSubview(imageView)

        // Ensure imageView fills the entire parent view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.color = UIColor(Color.white)
        view.addSubview(spinner)
    }

    private func loadImage() {
        // Using Task to run async code
        Task {
            guard let image = self.imageContent.image else {
                self.spinner.startAnimating()
                
                // Load image asynchronously
                if let loadedImage = await self.imageContent.loadAgain() {
                    DispatchQueue.main.async {
                        self.imageView.image = loadedImage
                        self.spinner.stopAnimating()
                        
                        // Calculate the aspect ratio of the image
                        let imageAspectRatio = loadedImage.size.width / loadedImage.size.height
                        
                        if imageAspectRatio > 1.0 {
                            // Image is wider than the view
                            self.imageView.contentMode = .scaleAspectFit
                        } else {
                            // Image is taller than the view or square
                            self.imageView.contentMode = .scaleAspectFill
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        if let _ = self.imageContent.url {
                            print("Image could not be downloaded")
                        } else {
                            print("Image URL is not available.")
                        }
                        self.spinner.stopAnimating()
                    }
                }
                return
            }

            // Image is already available
            DispatchQueue.main.async {
                self.imageView.image = image
                self.spinner.stopAnimating()
                
                // Calculate the aspect ratio of the image
                let imageAspectRatio = image.size.width / image.size.height
                
                if imageAspectRatio > 1.0 {
                    // Image is wider than the view
                    self.imageView.contentMode = .scaleAspectFit
                } else {
                    // Image is taller than the view or square
                    self.imageView.contentMode = .scaleAspectFill
                }
            }
        }
    }

}

// MARK: ^-


// stops page from being scrolled
extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            var isEnabled: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    isEnabled = subView.isScrollEnabled
                }
            }
            return isEnabled
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.isScrollEnabled = newValue
                }
            }
        }
    }
}
