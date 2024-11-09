import UIKit
import TwitterProfile
import XLPagerTabStrip

enum profilePage: String {
    case post = "Post"
    case likes = "Likes"
    case saved = "Saved"
}

class ProfileXLPagerTabStripViewController: ButtonBarPagerTabStripViewController, PagerAwareProtocol, UINavigationControllerDelegate {
    
    // MARK: PagerAwareProtocol
    
    var profile: ProfileSettings!
    var userIdentityID: String!
    
    weak var pageDelegate: BottomPageDelegate?
    weak var refreshDelegate: RefreshDelegate?
    
    var currentViewController: UIViewController? {
        return viewControllers[currentIndex]
    }
    
    var pagerTabHeight: CGFloat? {
        return 44
    }

    // MARK: Properties
    var isReload = false
    var transitionAnimator = SharedTransitionAnimator()
    
    init(profile: ProfileSettings?, userIdentityID: String) {
        self.profile = profile
        self.userIdentityID = userIdentityID
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .background
        settings.style.buttonBarItemBackgroundColor = .background
        settings.style.selectedBarBackgroundColor = .arinBlue
        settings.style.buttonBarItemTitleColor = .arinBlue
        settings.style.selectedBarHeight = 2
        settings.style.selectedBarWidthPercentage = userIdentityID == AuthenticationManager.shared.identityID ? 0.5 : 0.25

        super.viewDidLoad()
        
        delegate = self
        
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = .twitterGray
            newCell?.label.textColor = .arinBlue
        }
        
        view.backgroundColor = .background
        navigationController?.delegate = self
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = createBottomViewController(pageIndex: 0, title: .post)
        
        var viewControllers: [UIViewController] = [child_1]
        
        if userIdentityID == AuthenticationManager.shared.identityID {
            let child_2 = createBottomViewController(pageIndex: 1, title: .likes)
            viewControllers.append(child_2)
        }
        
        return viewControllers
    }

    override func reloadPagerTabStripView() {
        pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0)
        super.reloadPagerTabStripView()
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)

        guard indexWasChanged else { return }

        // Notify the master scroll controller which view to control in the bottom section
        self.pageDelegate?.tp_pageViewController(self.currentViewController, didSelectPageAt: toIndex)
    }
    
    func updateProfile(profile: ProfileSettings) {
        self.profile = profile
        for vc in viewControllers {
            if let bottomVC = vc as? BottomViewController {
                bottomVC.updateProfile(profile: profile)
            }
        }
    }
    
    // Helper method to create bottom view controllers
    private func createBottomViewController(pageIndex: Int, title: profilePage) -> BottomViewController {
        let bottomVC = BottomViewController(profile: profile)
        bottomVC.pageIndex = pageIndex
        bottomVC.pageTitle = title.rawValue
        return bottomVC
    }
    
    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // Forward the delegate calls to the current view controller if it conforms to UINavigationControllerDelegate
        if let bottomVC = currentViewController as? BottomViewController {
            return bottomVC.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        }
        return nil
    }
}

extension ProfileXLPagerTabStripViewController: RefreshDelegate {
    
    func didStartRefreshing() {
        print("Started refreshing in XLPagerTabStripExampleViewController")
        if let bottomVC = currentViewController as? BottomViewController {
            bottomVC.didStartRefreshing()
        }
    }
    
    func didEndRefreshing() {
        print("Ended refreshing in XLPagerTabStripExampleViewController")
        if let bottomVC = currentViewController as? BottomViewController {
            bottomVC.didEndRefreshing()
        }
    }
}
