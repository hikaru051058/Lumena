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

import AVKit
import AVFoundation


// MARK: - Horizontal Pagging of Vertical Lumes viewcontroller
class LumeHorizontalTabViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, TabBarDelegate {
    
    var pageViewController: UIPageViewController!
    var viewControllers: [UIViewController] = []
    
    
    private var bottomIslandViewController: BottomIslandViewController!
    
    var tabBarViewController: TabBarViewController!
    private var tabBarNames: [String] = ["おすすめ", "フォロー"]
    
    
    private var uploadProgressBarViewController: UploadProgressBarViewController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHorizontalTab()
        setupBottomIsland()
        setupTabBar()
        setupUploadProgressBar()
        
        pageViewController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupHorizontalTab() {
        // Create view controllers for each tab
        let firstViewController = UIViewController()
        firstViewController.view.backgroundColor = .red
        firstViewController.tabBarItem = UITabBarItem(title: tabBarNames[0], image: nil, selectedImage: nil)
        
        let secondViewController = UIViewController()
        secondViewController.view.backgroundColor = .green
        secondViewController.tabBarItem = UITabBarItem(title: tabBarNames[1], image: nil, selectedImage: nil)
        
        // Add view controllers to the array
        viewControllers = [LumeVerticalInfiniteScrollViewController(), LumeVerticalInfiniteScrollViewController()]
        
        // Create a page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        
        // Set the first view controller
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        // Add the page view controller as a child view controller
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        view.backgroundColor = UIColor.black
        
        pageViewController.didMove(toParent: self)
    }
    
    
    private func setupBottomIsland() {
        
        bottomIslandViewController = BottomIslandViewController()
        
        addChild(bottomIslandViewController)
        view.addSubview(bottomIslandViewController.view)
        bottomIslandViewController.didMove(toParent: self)
        
        bottomIslandViewController.view.backgroundColor = UIColor.clear
        
        // Set constraints for the hosting controller's view
        bottomIslandViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomIslandViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomIslandViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomIslandViewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomIslandViewController.view.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(of: visibleViewController) {
            selectedTabChanged(to: index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = index - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex < viewControllers.count else {
            return nil
        }
        return viewControllers[nextIndex]
    }
}

extension LumeHorizontalTabViewController {
    
    private func setupTabBar() {
        tabBarViewController = TabBarViewController()
        tabBarViewController.delegate = self
        tabBarViewController.tabs = self.tabBarNames
        addChild(tabBarViewController)
        view.addSubview(tabBarViewController.view)
        tabBarViewController.didMove(toParent: self)
        
        tabBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBarViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarViewController.view.heightAnchor.constraint(equalToConstant: 50),
            tabBarViewController.view.widthAnchor.constraint(equalToConstant: view.bounds.width - 70),
            tabBarViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.07)
        ])
    }
    
    func selectedTabChanged(to newIndex: Int) {
        tabBarViewController.selectedTab = newIndex
    }

    
    // MARK: TabBarDelegate
    func tabBar(_ tabBar: TabBarViewController, didSelectTabAtIndex index: Int) {
        if index != tabBarViewController.selectedTab {
            let direction: UIPageViewController.NavigationDirection = index > tabBarViewController.selectedTab ? .forward : .reverse
            pageViewController.setViewControllers([viewControllers[index]], direction: direction, animated: true, completion: nil)
            selectedTabChanged(to: index)  // Update the tab selection state
        }
    }
}

extension LumeHorizontalTabViewController {
    
    private func setupUploadProgressBar() {
        uploadProgressBarViewController = UploadProgressBarViewController()

        // Add as a child view controller
        addChild(uploadProgressBarViewController)
        view.addSubview(uploadProgressBarViewController.view)
        uploadProgressBarViewController.didMove(toParent: self)
        
        uploadProgressBarViewController.view.backgroundColor = UIColor.clear

        // Set constraints
        uploadProgressBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadProgressBarViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadProgressBarViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: ((view.bounds.height * 0.07) - 20)),
            uploadProgressBarViewController.view.heightAnchor.constraint(equalToConstant: 22),
            uploadProgressBarViewController.view.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
}

// MARK: ^-



// MARK: - Vertical Lumes viewcontroller

class LumeVerticalInfiniteScrollViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var scrollView: UIScrollView!
    var contentStackView: UIStackView!
    private var refreshControl: UIRefreshControl!
    private var lumes: [Lume] = []
    
    private var loadAutomatically: Bool = true

    // Mimic SwiftUI's currentReel
    private var currentLume: UUID?
    private var currentLumePostID: String?
    
    var mute: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(lumes: [Lume], loadAutomatically: Bool = true, currentLumePostID: String = "") {
        self.lumes = lumes
        self.loadAutomatically = loadAutomatically
        self.currentLumePostID = currentLumePostID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if loadAutomatically {
            loadInitialLumes()
        } else {
            self.addTabs()
        }
        scrollToCurrentLumeIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToCurrentLumeIfNeeded()
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
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        scrollView.refreshControl = refreshControl
        
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
                lumes.append(contentsOf: try await GraphQL.shared.fetchRandomLumes())
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

    private func addTabs() {
        for lume in lumes {
            let lumeVC = LumeIndividualViewController(
                lume: lume,
                currentLume: currentLume ?? UUID(),
                mute: mute
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
    }
    
    private func scaleToOriginalSize() {
        self.contentStackView.subviews.forEach { view in
            view.transform = CGAffineTransform.identity
        }
    }
    
    private func updateCurrentLume() {
        if let visibleIndex = getCurrentVisibleLumeIndex() {
            let newCurrentLume = lumes[visibleIndex].id
            
            newLumeAppearSetup()
            
            if newCurrentLume != currentLume {
                currentLume = newCurrentLume
                notifyCurrentLumeChange()
                
                // Load more contents at the very end
                if lumes.count - 1 == visibleIndex {
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
        mute = !mute
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
class LumeIndividualViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var pages: [UIViewController] = []
    
    var lume: Lume
    var currentLume: UUID
    
    var postUsername: String = ""
    
    // within individual Lume to identify which content is displayed
    var currentContentID: UUID?
    
    var mute: Bool
    var userLiked: Bool = false
    
    // UI Components
    private var muteButton: UIButton!
    private var loveImageView: UIImageView!
    
    var sideButtonsViewController: SideButtonsViewController!
    
    private var descriptionText = MarqueeTextViewController()
    private var usernameText = MarqueeTextViewController()
    private var invisibleRectangleLeft: UIView!
    private var invisibleRectangleRight: UIView!
    
    private var pageControl = UIPageControl(frame: .zero)

    
    // To manage user interactions similar to SwiftUI's gestures
    private var lastTapTime: Date?
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    
    init(lume: Lume, currentLume: UUID, mute: Bool) {
        self.lume = lume
        self.currentLume = currentLume
        self.mute = mute
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupPages()
        setupGestureRecognizers()
        setupUIComponents()
        setupMarqueeLabel()
        setupFetchUsername()
        setupSideButtonsViewController()
        setupPageIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
            invisibleRectangleLeft.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        invisibleRectangleRight = UIView()
        invisibleRectangleRight.backgroundColor = UIColor.clear
        view.addSubview(invisibleRectangleRight)
        
        invisibleRectangleRight.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invisibleRectangleRight.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            invisibleRectangleRight.topAnchor.constraint(equalTo: view.topAnchor),
            invisibleRectangleRight.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            invisibleRectangleRight.widthAnchor.constraint(equalToConstant: 60)
        ])
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
        } else {
            scrollView.isPagingEnabled = true
        }
    }
}

extension LumeIndividualViewController {
    
    private func setupSideButtonsViewController() {
        // Initialize the side buttons view controller with the necessary data
        sideButtonsViewController = SideButtonsViewController(lume: lume, userLiked: false)  // Adjust parameters as necessary
        addChild(sideButtonsViewController)
        view.addSubview(sideButtonsViewController.view)
        sideButtonsViewController.didMove(toParent: self)
        
        // Setup constraints or frame for placing it at the trailing bottom edge
        sideButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideButtonsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sideButtonsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-view.bounds.height * 0.035) - 60), // safe area + username box + padding
            sideButtonsViewController.view.widthAnchor.constraint(equalToConstant: 50),
            sideButtonsViewController.view.heightAnchor.constraint(equalToConstant: 250)
        ])

    }
    
    private func setupMarqueeLabel() {
        descriptionText = MarqueeTextViewController(
            text: (lume.postDescription ?? ""),
            font: UIFont.systemFont(ofSize: 16),
            leftFade: 16,
            rightFade: 16,
            startDelay: 3,
            alignment: .leading  // Adjust based on layout needs
        )
        
        addChild(descriptionText)
        view.addSubview(descriptionText.view)
        descriptionText.didMove(toParent: self)
        
        descriptionText.view.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.view.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            descriptionText.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionText.view.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            descriptionText.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035),
            descriptionText.view.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupFetchUsername() {
        Task {
            do {
                self.postUsername = try await ProfileManager.shared.getProfile(withID: lume.postUserIID).preferredUsername
                setupUsernameLabel()
            } catch {
                print(error)
            }
        }
    }
    
    private func setupUsernameLabel() {
        usernameText = MarqueeTextViewController(
            text: lume.returnPostUser().preferredUsername,
            font: UIFont.systemFont(ofSize: 16),
            leftFade: 16,
            rightFade: 16,
            startDelay: 3,
            alignment: .center  // Adjust based on layout needs
        )
        
        addChild(usernameText)
        view.addSubview(usernameText.view)
        usernameText.didMove(toParent: self)
        
        usernameText.view.translatesAutoresizingMaskIntoConstraints = false
        usernameText.view.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            usernameText.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            usernameText.view.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 65),
            usernameText.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035),
            usernameText.view.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupPageIndicator() {
        pageControl = UIPageControl(frame: .zero)
        pageControl.numberOfPages = lume.contents.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-view.bounds.height * 0.035) - 50),
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
        
        // Configure and add to view...
    }
    
    @objc private func handleSingleTap() {
        // Toggle mute and update UI accordingly
        mute.toggle()
        lume.muteVideos(mute: mute)
        updateMuteStatusOnUI(mute)
    }
    
    @objc private func handleDoubleTap() {
        // Handle like action and update UI accordingly
        lume.likedLume(userLikeInput: !lume.userLiked)
        updateLikeStatusOnUI(lume.userLiked)
    }
    
    private func updateMuteStatusOnUI(_ mute: Bool) {
        // Update mute button UI based on mute status
    }
    
    private func updateLikeStatusOnUI(_ liked: Bool) {
        // Update love image view UI based on like status
    }
}

extension LumeIndividualViewController {
    
    private func resumeVideoIfNeeded() {
        if let videoVC = currentVisibleViewController() as? VideoContentViewController {
            videoVC.resumeVideo()
        }
    }
    
    private func pauseVideoIfNeeded() {
        if let videoVC = currentVisibleViewController() as? VideoContentViewController {
            videoVC.pauseVideo()
        }
    }
    
    func updateMuteStatus(_ mute: Bool) {
        self.mute = mute
        lume.muteVideos(mute: mute)
    }
}

extension LumeIndividualViewController {
    
    func currentLumeChanged(to newCurrentLume: UUID?) {
        if let newCurrentLume = newCurrentLume, lume.id == newCurrentLume {
            
            VideoDataStore.shared.currentContentID = currentContentID
            resumeVideoIfNeeded()
            sideButtonsViewController.updateCurrentLume(with: newCurrentLume)
            
        } else {
            pauseVideoIfNeeded()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let pageIndex = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = pageIndex
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
            videoVC.pauseVideo() // Pause the current video since a swipe has begun.
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = currentVisibleViewController() as? LumeContentViewController,
           let currentIndex = lume.contents.firstIndex(where: { $0.id == currentVC.contentID })
        {
            pageControl.currentPage = currentIndex
            currentContentID = currentVC.contentID
            lume.currentContent = currentVC.contentID
            
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeVideo()
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
        resumeVideo()
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
    
    func resumeVideo() {
        
        guard VideoDataStore.shared.currentContentID == contentID else {
            return
        }
        
        if let player = videoContent.player, player.currentItem?.status == .readyToPlay {
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
