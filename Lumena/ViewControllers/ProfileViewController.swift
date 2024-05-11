//
//  ProfileViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/04/24.
//

import Foundation
import UIKit
import SwiftUI

class ProfileViewController: UIViewController {
    private var hostingController: UIHostingController<Profile>?
    
    private var skinSettingVariables: [Int]
    private var mainOrSetting: Bool
    
    // Initializer to receive user data
    init(skinSettingVariables: [Int] = [0,0,0], mainOrSetting: Bool = true) {
        self.skinSettingVariables = skinSettingVariables
        self.mainOrSetting = mainOrSetting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented for ProfileViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize your SwiftUI view
        var profileView = Profile()
        
        // Initialize your SwiftUI view
        profileView.onNavigate = navigateToLogin
        profileView.onNavigateSkinSetting = navigateSkinSetting

        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: profileView)
        
        // Add the hosting controller as a child view controller
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Setup constraints for layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }
    
    func navigateToLogin() {
        let profileVC = LoginViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func navigateSkinSetting(skinSetting: [Int] = [0,0,0], mainOrSetting: Bool = true) {
        let skinSettingVC = SkinSettingViewController(skinSettingVariables: skinSetting, mainOrSetting: mainOrSetting)
        navigationController?.pushViewController(skinSettingVC, animated: true)
    }
}

extension ProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}




class NewProfileViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let headerView = UIView()
    var headerHeightConstraint: NSLayoutConstraint!
    let headerViewHeight: CGFloat = (UIScreen.main.bounds.height * 0.65)
    
    let fixedBox = UIView()  // Fixed box in the header
    let fixedBoxHeight: CGFloat = 80

    let contentView = UIView()
    var backgroundGradient: GradientEffectViewController!
    
    
    let tabBarOverlay = UIView()
    var tabBarOverlayHeightConstraint: NSLayoutConstraint!
    let tabBarHeight: CGFloat = 50
    
    let pagesContainerView = UIView()
    var pageControl = UIPageControl()
    
    let pagingScrollView = UIScrollView()
    let page1 = UIView()
    let page2 = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    private func setupScrollView() {
        
        scrollView.delegate = self
        scrollView.backgroundColor = .lightGray
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupHeaderView() {
        
        headerView.backgroundColor = .clear
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: fixedBoxHeight),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight)
        ])
    }
    
    private func setupFixedBoxView() {
        
        fixedBox.backgroundColor = .darkGray
        headerView.addSubview(fixedBox)
        
        fixedBox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fixedBox.topAnchor.constraint(equalTo: view.topAnchor),
            fixedBox.leftAnchor.constraint(equalTo: view.leftAnchor),
            fixedBox.rightAnchor.constraint(equalTo: view.rightAnchor),
            fixedBox.heightAnchor.constraint(equalToConstant: fixedBoxHeight),  // Height of the fixed box
        ])
    }
    
    private func setupContentView() {
        
        contentView.backgroundColor = .clear
        scrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupBackgroundGradient() {
        
        backgroundGradient = GradientEffectViewController(colors: [Color(red: 0.723, green: 0.88, blue: 0.825), Color(red: 0.552, green: 0.724, blue: 0.831), Color(red: 0.946, green: 0.76, blue: 0.839),])
        
        addChild(backgroundGradient)
        scrollView.addSubview(backgroundGradient.view)
        backgroundGradient.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundGradient.view.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundGradient.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundGradient.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundGradient.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundGradient.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    private func setupPagingScrollView() {
        
        pagingScrollView.addSubview(pagesContainerView)
        
        pagingScrollView.delegate = self
        pagingScrollView.isPagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = false
        contentView.addSubview(pagingScrollView)
        
        pagingScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            pagingScrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: tabBarHeight),
            pagingScrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            pagingScrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            pagingScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            pagingScrollView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            pagingScrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
    }
    
    private func setupTabBarOverlay() {
        tabBarOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        tabBarOverlay.backgroundColor = .orange
        headerView.addSubview(tabBarOverlay)
        
        NSLayoutConstraint.activate([
            
            tabBarOverlay.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabBarOverlay.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            tabBarOverlay.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            tabBarOverlay.heightAnchor.constraint(equalToConstant: tabBarHeight),
        ])
    }
    
    private func setupTabPages() {
        // Setup pages inside pagesContainerView
        page1.backgroundColor = .red
        pagesContainerView.addSubview(page1)
        
        page2.backgroundColor = .green
        pagesContainerView.addSubview(page2)
        
        pagesContainerView.translatesAutoresizingMaskIntoConstraints = false
        page1.translatesAutoresizingMaskIntoConstraints = false
        page2.translatesAutoresizingMaskIntoConstraints = false
        
        setupHeaderConstraint()
        
        
        // Setting up constraints for pagesContainerView
        NSLayoutConstraint.activate([
            pagesContainerView.leadingAnchor.constraint(equalTo: pagingScrollView.leadingAnchor),
            pagesContainerView.trailingAnchor.constraint(equalTo: pagingScrollView.trailingAnchor),
            pagesContainerView.topAnchor.constraint(equalTo: pagingScrollView.topAnchor),
            pagesContainerView.bottomAnchor.constraint(equalTo: pagingScrollView.bottomAnchor),
            pagesContainerView.heightAnchor.constraint(equalTo: pagingScrollView.heightAnchor)
        ])
        
        var previousPage: UIView? = nil
        for page in [page1, page2] {  // Assuming only two pages for simplicity
            page.translatesAutoresizingMaskIntoConstraints = false
            pagesContainerView.addSubview(page)
            
            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: pagesContainerView.topAnchor),
                page.bottomAnchor.constraint(equalTo: pagesContainerView.bottomAnchor),
                page.widthAnchor.constraint(equalTo: view.widthAnchor),
                page.heightAnchor.constraint(equalTo: view.heightAnchor),
            ])
            
            if let previous = previousPage {
                page.leadingAnchor.constraint(equalTo: previous.trailingAnchor).isActive = true
            } else {
                page.leadingAnchor.constraint(equalTo: pagesContainerView.leadingAnchor).isActive = true
            }
            
            previousPage = page
        }
        
        previousPage?.trailingAnchor.constraint(equalTo: pagesContainerView.trailingAnchor).isActive = true
    }
    
    
    func setupViews() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        setupScrollView()
        
        setupHeaderView()
        
        setupFixedBoxView()
        
        setupContentView()
        
        setupBackgroundGradient()
        
        setupPagingScrollView()
        
        setupTabBarOverlay()
        
        setupTabPages()
    }
    
    
    
    func setupHeaderConstraint() {
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerViewHeight)  // Updated for new fixed box height
        headerHeightConstraint.isActive = true
    }
    
    func scrollToTop() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let scrollOffset = scrollView.contentOffset.y
            let headerCollapseHeight = max(0, headerViewHeight - scrollOffset)
            headerHeightConstraint.constant = headerCollapseHeight
            view.layoutIfNeeded()
        }
        
        if scrollView == pagingScrollView {
            let pageIndex = round(scrollView.contentOffset.x / view.frame.size.width)
            pageControl.currentPage = Int(pageIndex)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == pagingScrollView {
            scrollToTop()
        }
    }
    
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
}



class TestCustomViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let scrollViewContent = UIView()
    
    var backgroundGradientView: GradientEffectViewController!
    
    let topBox = UIView()
    let bottomBox = UIView()
    
    var topBoxTopConstraint: NSLayoutConstraint!
    
    var topBoxHeight: CGFloat = (UIScreen.main.bounds.height * 0.65)
    var bottomBoxHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupHorizontalPagingViewController()
    }
    
    private func setupViews() {
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Configure background gradient view controller
        setupBackgroundGradientView()
        
        // Configure scrollView
        scrollView.delegate = self
        scrollView.backgroundColor = .lightGray
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        // Configure scrollViewContent
        scrollViewContent.backgroundColor = .clear // add background blur here
        scrollViewContent.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollViewContent)
        
        // Configure topBox
        topBox.backgroundColor = .clear
        topBox.translatesAutoresizingMaskIntoConstraints = false
        topBox.insetsLayoutMarginsFromSafeArea = false
        view.addSubview(topBox)
        
        // Configure bottomBox
        bottomBox.backgroundColor = .red
        bottomBox.translatesAutoresizingMaskIntoConstraints = false
        bottomBox.insetsLayoutMarginsFromSafeArea = false
        view.addSubview(bottomBox)
        
    }
    
    private func setupConstraints() {
        topBoxTopConstraint = topBox.bottomAnchor.constraint(equalTo: view.topAnchor, constant: topBoxHeight)
                
        NSLayoutConstraint.activate([
            topBoxTopConstraint,
            topBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBox.heightAnchor.constraint(equalToConstant: topBoxHeight),
            
            bottomBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBox.heightAnchor.constraint(equalToConstant: bottomBoxHeight),
            bottomBox.topAnchor.constraint(equalTo: topBox.bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: bottomBox.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollViewContent.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupHorizontalPagingViewController() {
        // Initialize PageContainerViewController
        let pageContainer = PageContainerViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.topBoxHeight = self.topBoxHeight
        addChild(pageContainer)
        scrollViewContent.addSubview(pageContainer.view)

        // Configure constraints for PageContainerViewController's view
        pageContainer.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageContainer.view.topAnchor.constraint(equalTo: scrollViewContent.topAnchor),
            pageContainer.view.bottomAnchor.constraint(equalTo: scrollViewContent.bottomAnchor),
            pageContainer.view.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor),
            pageContainer.view.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor)
        ])

        // Notify the pageContainer that it has been moved to a parent
        pageContainer.didMove(toParent: self)
        
        // Adjust scrollViewContent height to match the pageContainer height
        let contentHeight = pageContainer.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentHeight.priority = .defaultLow
        NSLayoutConstraint.activate([contentHeight])
    }
    
    private func setupBackgroundGradientView() {
        
        backgroundGradientView = GradientEffectViewController(colors: [Color(red: 0.723, green: 0.88, blue: 0.825), Color(red: 0.552, green: 0.724, blue: 0.831), Color(red: 0.946, green: 0.76, blue: 0.839),])
        
        addChild(backgroundGradientView)
        view.addSubview(backgroundGradientView.view)
        backgroundGradientView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundGradientView.view.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundGradientView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundGradientView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundGradientView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundGradientView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
}

extension TestCustomViewController: PageScrollDelegate {
    func pageDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let newTopBoxTop = max(0, topBoxHeight - offsetY)
        topBoxTopConstraint.constant = newTopBoxTop
        view.layoutIfNeeded()
    }
}

protocol PageScrollDelegate: AnyObject {
    func pageDidScroll(_ scrollView: UIScrollView)
}

class PageContainerViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var previousPageOffset: CGFloat = 0
    var subViewControllers: [PageViewController] = []
    var topBoxHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        setupSubViewControllers()
    }
    
    private func setupSubViewControllers() {
        subViewControllers = [
            PageViewController(heightMultiplier: 2.0, color: .blue),
            PageViewController(heightMultiplier: 2.0, color: .green),
            PageViewController(heightMultiplier: 2.0, color: .red)
        ]
        
        if let firstViewController = subViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
        }
        
        for viewController in subViewControllers {
            viewController.delegate = self.parent as? PageScrollDelegate
            prepareScrollView(for: viewController)
        }
    }
    
    private func prepareScrollView(for page: PageViewController) {
        
        page.view.layoutIfNeeded()
        
        if previousPageOffset < topBoxHeight || page.scrollView.contentOffset.y == 0{
            page.scrollView.contentOffset.y = previousPageOffset
        } else {
            if page.scrollView.contentOffset.y <= topBoxHeight {
                if previousPageOffset >= topBoxHeight {
                    page.scrollView.contentOffset.y = topBoxHeight
                } else {
                    page.scrollView.contentOffset.y = previousPageOffset
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = subViewControllers.firstIndex(of: viewController as! PageViewController), index > 0 else {
            return nil
        }
        return subViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = subViewControllers.firstIndex(of: viewController as! PageViewController), index < subViewControllers.count - 1 else {
            return nil
        }
        return subViewControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let currentPage = viewControllers?.first as? PageViewController {
            
            // Only update previousPageOffset when user has actually scrolled in this page
            if currentPage.scrollView.contentOffset.y != currentPage.lastScrollPosition {
                previousPageOffset = currentPage.scrollView.contentOffset.y
            }
            
            // Preemptively adjust the scroll position of the page that will be transitioned to
            if currentPage.scrollView.contentOffset.y != currentPage.lastScrollPosition {
                if let nextPage = pendingViewControllers.first as? PageViewController {
                    prepareScrollView(for: nextPage)
                }
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentPage = viewControllers?.first as? PageViewController {
            previousPageOffset = currentPage.scrollView.contentOffset.y
        }
    }
}


class PageViewController: UIViewController {
    
    weak var delegate: PageScrollDelegate?
    
    var scrollView: UIScrollView = UIScrollView()
    var contentView:UIView = UIView()
    var heightMultiplier: CGFloat
    var color: UIColor
    
    var lastScrollPosition: CGFloat = 0
    
    init(heightMultiplier: CGFloat, color: UIColor) {
        self.heightMultiplier = heightMultiplier
        self.color = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        scrollView.insetsLayoutMarginsFromSafeArea = false
        
        contentView.backgroundColor = color
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: heightMultiplier)
        ])

    }
}

extension PageViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        lastScrollPosition = scrollView.contentOffset.y
        delegate?.pageDidScroll(scrollView)
    }
}
