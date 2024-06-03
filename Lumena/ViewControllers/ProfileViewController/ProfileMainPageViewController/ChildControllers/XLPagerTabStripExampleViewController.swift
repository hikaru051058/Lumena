import UIKit
import TwitterProfile
import XLPagerTabStrip

class XLPagerTabStripExampleViewController: ButtonBarPagerTabStripViewController, PagerAwareProtocol, UINavigationControllerDelegate {
    
    // MARK: PagerAwareProtocol
    
    var profile: ProfileSettings!
    
    weak var pageDelegate: BottomPageDelegate?
    
    var currentViewController: UIViewController? {
        return viewControllers[currentIndex]
    }
    
    var pagerTabHeight: CGFloat? {
        return 44
    }

    // MARK: Properties
    var isReload = false
    var transitionAnimator = SharedTransitionAnimator()
    
    init(profile: ProfileSettings?) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        print("XLPagerTabStripExampleViewController - viewDidLoad")
        settings.style.buttonBarBackgroundColor = .background
        settings.style.buttonBarItemBackgroundColor = .background
        settings.style.selectedBarBackgroundColor = Colors.arinBlue
        settings.style.buttonBarItemTitleColor = Colors.arinBlue
        settings.style.selectedBarHeight = 2

        super.viewDidLoad()
        
        delegate = self
        
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = Colors.twitterGray
            newCell?.label.textColor = Colors.arinBlue
        }
        
        navigationController?.delegate = self
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        print("XLPagerTabStripExampleViewController - viewControllers for pagerTabStripController")
        let child_1 = createBottomViewController(pageIndex: 0, title: "Post")
        let child_2 = createBottomViewController(pageIndex: 1, title: "Likes")
        let child_3 = createBottomViewController(pageIndex: 2, title: "Saved")
        
        return [child_1, child_2, child_3]
    }

    override func reloadPagerTabStripView() {
        print("XLPagerTabStripExampleViewController - reloadPagerTabStripView")
        pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0)
        super.reloadPagerTabStripView()
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        print("XLPagerTabStripExampleViewController - updateIndicator")
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)

        guard indexWasChanged else { return }

        // Notify the master scroll controller which view to control in the bottom section
        self.pageDelegate?.tp_pageViewController(self.currentViewController, didSelectPageAt: toIndex)
    }
    
    // Helper method to create bottom view controllers
    private func createBottomViewController(pageIndex: Int, title: String) -> BottomViewController {
        print("XLPagerTabStripExampleViewController - createBottomViewController for pageIndex: \(pageIndex), title: \(title)")
        let bottomVC = BottomViewController(profile: profile)
        bottomVC.pageIndex = pageIndex
        bottomVC.pageTitle = title
        return bottomVC
    }
    
    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("XLPagerTabStripExampleViewController - Parent Navigation Controller delegate method called.")
        
        // Forward the delegate calls to the current view controller if it conforms to UINavigationControllerDelegate
        if let bottomVC = currentViewController as? BottomViewController {
            return bottomVC.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        }
        return nil
    }
}

