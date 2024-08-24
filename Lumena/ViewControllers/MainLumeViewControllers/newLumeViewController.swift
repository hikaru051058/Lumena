//
//  newLumeViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/24.
//

import Foundation
import UIKit
import SwiftUI
import AVKit
import XLPagerTabStrip

class newLumeHorizontalViewController: ButtonBarPagerTabStripViewController {
    
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if !initialized {
            moveToViewController(at: defaultIndex, animated: false)
            initialized = true
        }
        
        navigationController?.navigationBar.tintColor = .arinGreen
        navigationController?.navigationBar.backgroundColor = .arinYellow
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if navigationController?.isNavigationBarHidden == false {
            navigationController?.isNavigationBarHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        pageViewControllers = []
        
        if userLoggedIn {
            let followingVC = newLumeVerticalViewController(title: NSLocalizedString(LumeMainPageTabRep.following.rawValue, comment: ""))
            pageViewControllers.append(followingVC)
        }
        
        let recommendedVC = newLumeVerticalViewController(title: NSLocalizedString(LumeMainPageTabRep.recommended.rawValue, comment: ""))
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
        self.settings.style.buttonBarItemTitleColor = .black
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

/// FIXED VIDEO PLAYBACK LOGIC ISSUE
/// FIXED VIDEO MUTE LOGIC
/// FIXED UI COMPONENTS

class newLumeVerticalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero // Ensure no section insets
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInset = .zero // Ensure no content insets
        return collectionView
    }()
    
    // Refresh control for pull-to-refresh
    private let refreshControl = UIRefreshControl()
    
    var contentData: [String] = [] // Your data source
    var isMuted: Bool = false
    private var isLoadingMoreData = false
    private var autoLoadRandomLumes: Bool = true
    
    var itemInfo: IndicatorInfo = IndicatorInfo(title: "")
    
    // New initializer to pass an array of Lume objects
    init(lumes: [String] = [], autoLoadRandomLumes: Bool = true) {
        self.contentData = lumes
        self.autoLoadRandomLumes = autoLoadRandomLumes
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(title: String) {
        self.init()
        self.itemInfo.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        // Load initial data if auto-loading is enabled and no initial data was passed
        if contentData.isEmpty && autoLoadRandomLumes {
            Task {
                await loadInitialData()
            }
        }
        
        collectionView.contentInsetAdjustmentBehavior = .never
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccessHandler), name: .authStatusChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(newLumeIndividualViewCell.self, forCellWithReuseIdentifier: "LumeCell")
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        // Add refresh control
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    @objc private func handleRefresh(_ sender: UIRefreshControl) {
        Task {
            await loadInitialData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.collectionView.reloadData()
            sender.endRefreshing()
        }
    }
    
    private func loadInitialData() async {
        await loadInitialLumes()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       guard let lumeCell = cell as? newLumeIndividualViewCell else { return }
       lumeCell.onAppear() // Notify the cell that it has appeared
   }
   
   func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       guard let lumeCell = cell as? newLumeIndividualViewCell else { return }
       lumeCell.onDisappear() // Notify the cell that it has disappeared
   }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LumeCell", for: indexPath) as! newLumeIndividualViewCell
        cell.delegate = self
        cell.configure(with: contentData[indexPath.item], isMuted: isMuted)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = collectionView.visibleCells
        let collectionViewCenter = collectionView.bounds.size.height / 2
        
        for cell in visibleCells {
            guard let _ = collectionView.indexPath(for: cell),
                  let lumeCell = cell as? newLumeIndividualViewCell else { continue }
            
            // Determine the center of the cell relative to the collection view
            let cellCenter = collectionView.convert(lumeCell.center, to: collectionView.superview).y
            let distanceFromCenter = abs(collectionViewCenter - cellCenter)
            let scaleX = max(0.97, 1 - distanceFromCenter / collectionViewCenter * 0.03)
            let scaleY = max(0.98, 1 - distanceFromCenter / collectionViewCenter * 0.02)
            
            UIView.animate(withDuration: 0.008, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
                lumeCell.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                lumeCell.layer.cornerRadius = 50
                lumeCell.layer.masksToBounds = true
            }, completion: nil)
            
            // Check if the cell is more than half visible
            let cellFrame = collectionView.convert(lumeCell.frame, to: collectionView.superview)
            let visibleHeight = collectionView.bounds.height
            let halfVisibleHeight = visibleHeight / 2
            
            if cellFrame.origin.y < halfVisibleHeight && cellFrame.origin.y + cellFrame.height > halfVisibleHeight {
                lumeCell.setMute(isMuted: isMuted)
                lumeCell.onAppear() // Notify the cell that it has appeared
                
            } else {
                lumeCell.onDisappear()
            }
        }
        
        // Infinite scrolling logic
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        // Load more data when the user scrolls to the bottom and auto-loading is enabled
        if autoLoadRandomLumes && offsetY > contentHeight - frameHeight * 2 {
            if !isLoadingMoreData {
                isLoadingMoreData = true
                Task {
                    await loadMoreLumes()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Reset scale transformation when user stops scrolling
        UIView.animate(withDuration: 0.05) {
            self.scaleToOriginalSize()
        }
    }
    
    private func scaleToOriginalSize() {
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {
            cell.transform = CGAffineTransform.identity
            if let lumeCell = cell as? newLumeIndividualViewCell {
                lumeCell.layer.cornerRadius = 0
                lumeCell.layer.masksToBounds = true
            }
        }
    }
}

extension newLumeVerticalViewController: newLumeIndividualViewCellDelegate {

    func didToggleMute(isMuted: Bool) {
        self.isMuted = isMuted
        applyMuteStateToVisibleCells()
    }
    
    func didRequestNavigation(to profileID: String) {
        let profileVC = TwitterParallaxViewController(userIdentityID: profileID)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    private func applyMuteStateToVisibleCells() {
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {
            if let lumeCell = cell as? newLumeIndividualViewCell {
                lumeCell.setMute(isMuted: isMuted)
            }
        }
    }
}

extension newLumeVerticalViewController {
    
    private func fetchLumes() async -> Bool {
        do {
            let returnedLumes = try await GraphQL.shared.fetchRandomLumes()

            // Use a set to track existing lume IDs for fast lookup
//            var existingIds = Set(contentData)

            // Filter out duplicates
//            let uniqueLumes = returnedLumes.filter { lume in
//                if existingIds.contains(lume.postID) {
//                    return false // This lume is a duplicate
//                } else {
//                    existingIds.insert(lume.postID)
//                    return true // This lume is unique
//                }
//            }
            
            let uniqueLumes = returnedLumes

            // Append unique lumes' IDs to contentData
            contentData.append(contentsOf: uniqueLumes.map { $0.postID })

            return true
        } catch {
            print(error)
            return false
        }
    }
    
    private func loadInitialLumes() async {
        let success = await fetchLumes()
        DispatchQueue.main.async {
            if success {
                self.collectionView.reloadData() // Reload the collection view with the new data
            } else {
                print("Failed to fetch lumes.")
            }
        }
    }
    
    private func loadMoreLumes() async {
        let success = await fetchLumes()
        DispatchQueue.main.async {
            if success {
                self.collectionView.reloadData() // Reload the collection view with the new data
                self.isLoadingMoreData = false
            } else {
                print("Failed to fetch more lumes.")
                self.isLoadingMoreData = false
            }
        }
    }
    
    @objc private func authSuccessHandler() {
        DispatchQueue.main.async {
            // Handle authentication success
        }
    }
}

extension newLumeVerticalViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}



protocol newLumeIndividualViewCellDelegate: AnyObject {
    func didToggleMute(isMuted: Bool)
    func didRequestNavigation(to profileID: String)
}


class newLumeIndividualViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let contentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    weak var delegate: newLumeIndividualViewCellDelegate?
    
    private var lume: Lume!
    
    private var contentData: [LumeContent] = [] // Array of content (images, videos)
    private var lastPlayedIndexPath: IndexPath?
    private var isMuted: Bool = false
    private var originalMuteState: Bool = false // To store the original mute state
    
    // New properties for side and bottom buttons
    var sideButtonsViewController: LumeSideButtonsViewController!
    var bottomButtonsViewController: LumeBottomButtonsViewController!
    
    private var bottomPadding: CGFloat = 85
    
    private var darkView: UIView!
    private var lumeBottomViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Remove the previous side buttons view controller's view if it exists
        sideButtonsViewController?.view.removeFromSuperview()
        sideButtonsViewController = nil
        
        // Remove the previous bottom buttons view controller's view if it exists
        bottomButtonsViewController?.view.removeFromSuperview()
        bottomButtonsViewController = nil
        
        // Clear the content data and pause all videos
        contentData = []
        contentCollectionView.reloadData()
        pauseAllVideos()
    }
    
    private func setupCollectionView() {
        contentView.addSubview(contentCollectionView)
        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self
        contentCollectionView.register(LumeContentCell.self, forCellWithReuseIdentifier: "ContentCell")
        contentCollectionView.frame = contentView.bounds
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapGesture)
        
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    @objc private func handleTapGesture() {
        isMuted.toggle() // Toggle the mute state
        applyMuteState() // Apply the mute state to all visible videos
        delegate?.didToggleMute(isMuted: isMuted)
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
    
    private func applyMuteState() {
        if let lume = self.lume {
            if lume.voiceOverURL.isEmpty { // assume all videos are already muted at the appear
                for cell in contentCollectionView.visibleCells {
                    if let contentCell = cell as? LumeContentCell, contentCell.isVideoContent {
                        contentCell.setMute(isMuted: isMuted)
                    }
                }
            } else {
                for cell in contentCollectionView.visibleCells {
                    if let contentCell = cell as? LumeContentCell, contentCell.isVideoContent {
                        contentCell.setMute(isMuted: true)
                    }
                }
                lume.mute(mute: isMuted)
            }
        } else {
            for cell in contentCollectionView.visibleCells {
                if let contentCell = cell as? LumeContentCell, contentCell.isVideoContent {
                    contentCell.setMute(isMuted: isMuted)
                }
            }
        }
    }
    
    func configure(with modelID: String, isMuted: Bool) {
        self.isMuted = isMuted
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    //                    let mockLume = try await GraphQL.shared.fetchSingleReelQL(reelQLId: modelID)
                    let mockLume = try await LumeManager.shared.getLume(withID: modelID)
                    self.lume = mockLume
                    self.contentData = mockLume.contents
                    contentCollectionView.reloadData()
                    setupSideButtonsViewController()
                    setupBottomButtonsViewController()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func onAppear() {
        // Store the original mute state
        originalMuteState = isMuted
        lume?.mute(mute: isMuted)
        applyMuteState()
        
        // Temporarily mute if a voice-over exists
        if lume?.voiceOver.hasRecording == true {
            isMuted = true
        }

        playVisibleVideo()
        lume?.playAudio(repeatAudio: true)
    }

    func onDisappear() {
        pauseAllVideos()
        lume?.stopAudio()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let lumeCell = cell as? newLumeIndividualViewCell else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let lumeCell = cell as? newLumeIndividualViewCell else { return }
//        lumeCell.onDisappear() // Notify the cell that it has disappeared
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCell", for: indexPath) as! LumeContentCell
        cell.configure(with: contentData[indexPath.item], isMuted: isMuted)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = contentCollectionView.visibleCells
        for cell in visibleCells {
            if let indexPath = contentCollectionView.indexPath(for: cell),
               let lumeCell = cell as? LumeContentCell {
                let cellFrame = contentCollectionView.convert(lumeCell.frame, to: contentCollectionView.superview)
                let visibleWidth = contentCollectionView.frame.width
                let halfVisibleWidth = visibleWidth / 2
                
                // Check if the cell is more than half visible
                if cellFrame.origin.x < halfVisibleWidth && cellFrame.origin.x + cellFrame.width > halfVisibleWidth {
                    lumeCell.playVideo()
                    lastPlayedIndexPath = indexPath
                } else {
                    lumeCell.pauseVideo()
                }
            }
        }
    }
    
    func playVisibleVideo() {
        for cell in contentCollectionView.visibleCells {
            if let contentCell = cell as? LumeContentCell, contentCell.isVideoContent {
                contentCell.playVideo()
            }
        }
    }
    
    func pauseAllVideos() {
        for cell in contentCollectionView.visibleCells {
            if let contentCell = cell as? LumeContentCell, contentCell.isVideoContent {
                contentCell.pauseVideo()
            }
        }
    }
    
    func setMute(isMuted: Bool) {
        self.isMuted = isMuted
        applyMuteState()
    }
}

extension newLumeIndividualViewCell {
    // MARK: - Side and Bottom Buttons Setup
    
    private func setupSideButtonsViewController() {
        let userLoggedInStatus = AuthenticationManager.shared.authStatus == .authenticated
        sideButtonsViewController = LumeSideButtonsViewController(lume: lume, userLiked: false, userLoggedIn: userLoggedInStatus)
        addSubview(sideButtonsViewController.view)
        
        sideButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sideButtonsViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sideButtonsViewController.view.widthAnchor.constraint(equalToConstant: 50),
            sideButtonsViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomPadding),
        ])
    }
}

extension newLumeIndividualViewCell: DescriptionExpandableViewControllerDelegate {
    
    func didUpdateHeight(_ height: CGFloat) {
        lumeBottomViewHeightConstraint.constant = height + 45
        UIView.animate(withDuration: 0.2) {
            if self.darkView.alpha == 0 {
                self.darkView.alpha = 1
            } else {
                self.darkView.alpha = 0
            }
            self.layoutIfNeeded()
        }
    }

    private func setupBottomButtonsViewController() {
        setupDarkShadeDescriptionBackground()

        let userLoggedInStatus = AuthenticationManager.shared.authStatus == .authenticated
        bottomButtonsViewController = LumeBottomButtonsViewController(lume: lume, userLiked: false, userLoggedIn: userLoggedInStatus)
        bottomButtonsViewController.delegate = self
        addSubview(bottomButtonsViewController.view)
        
        bottomButtonsViewController.sideButtonDescriptionView.lumeIndividualViewControllerdelegate = self

        bottomButtonsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        lumeBottomViewHeightConstraint = bottomButtonsViewController.view.heightAnchor.constraint(equalToConstant: 90)
        lumeBottomViewHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            bottomButtonsViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomButtonsViewController.view.trailingAnchor.constraint(equalTo: sideButtonsViewController.view.leadingAnchor, constant: -16),
            bottomButtonsViewController.view.bottomAnchor.constraint(equalTo: sideButtonsViewController.view.bottomAnchor),
        ])
    }

    private func setupDarkShadeDescriptionBackground() {
        darkView = UIView()
        darkView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        darkView.alpha = 0
        addSubview(darkView)

        darkView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            darkView.leadingAnchor.constraint(equalTo: leadingAnchor),
            darkView.trailingAnchor.constraint(equalTo: trailingAnchor),
            darkView.topAnchor.constraint(equalTo: topAnchor),
            darkView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(darkViewTapped))
        darkView.addGestureRecognizer(tapGesture)
    }

    @objc private func darkViewTapped() {
        UIView.animate(withDuration: 0.2) {
            self.bottomButtonsViewController.sideButtonDescriptionView.toggleDescription()
            self.darkView.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    private func updateLikeStatusOnUI(_ liked: Bool) {
        sideButtonsViewController.toggleLike()
    }
}

extension newLumeIndividualViewCell: LumeBottomButtonsViewDelegate {
    func didRequestNavigation(to profileID: String) {
        delegate?.didRequestNavigation(to: profileID)
    }
}


class LumeContentCell: UICollectionViewCell {
    
    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var videoPlayerView: VideoPlayerView? // Custom view to handle video playback
    
    var isVideoContent: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(contentImageView)
        contentImageView.frame = contentView.bounds
        // Set a random background color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImageView.image = nil
        videoPlayerView?.removeFromSuperview()
        videoPlayerView = nil
        isVideoContent = false
    }
    
    func configure(with content: LumeContent, isMuted: Bool) {
        switch content {
        case .image(let imageContent):
            contentImageView.isHidden = false
            contentImageView.image = imageContent.image
            isVideoContent = false
        case .video(let videoContent):
            contentImageView.isHidden = true
            setupVideoPlayer(with: videoContent, isMuted: isMuted)
            isVideoContent = true
        }
    }
    
    private func setupVideoPlayer(with videoContent: LumeVideo, isMuted: Bool) {
        guard let url = videoContent.getVideoURL() else { return }
        videoPlayerView = VideoPlayerView(frame: contentView.bounds, url: url)
        contentView.addSubview(videoPlayerView!)
        videoPlayerView?.setMute(isMuted: isMuted)
    }
    
    func playVideo() {
        videoPlayerView?.play()
    }
    
    func pauseVideo() {
        videoPlayerView?.pause()
    }
    
    func setMute(isMuted: Bool) {
        videoPlayerView?.setMute(isMuted: isMuted)
    }
}

class VideoPlayerView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    init(frame: CGRect, url: URL) {
        super.init(frame: frame)
        setupPlayer(with: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayer(with url: URL) {
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        setupLooping()
    }
    
    private func setupLooping() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }
    
    @objc private func playerDidFinishPlaying() {
        // Seek to the beginning
        player?.seek(to: .zero)
        // Replay the video
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }

    func setMute(isMuted: Bool) {
        player?.isMuted = isMuted
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
