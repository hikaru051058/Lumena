import UIKit
import TwitterProfile
import XLPagerTabStrip

class XLPagerTabStripExampleViewController: ButtonBarPagerTabStripViewController, PagerAwareProtocol, UINavigationControllerDelegate {
    
    // MARK: PagerAwareProtocol
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
    
    override func viewDidLoad() {
        print("XLPagerTabStripExampleViewController - viewDidLoad")
        settings.style.buttonBarBackgroundColor = .background
        settings.style.buttonBarItemBackgroundColor = .background
        settings.style.selectedBarBackgroundColor = Colors.twitterBlue
        settings.style.buttonBarItemTitleColor = Colors.twitterBlue
        settings.style.selectedBarHeight = 3

        super.viewDidLoad()
        
        delegate = self
        
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = Colors.twitterGray
            newCell?.label.textColor = Colors.twitterBlue
        }
        
        navigationController?.delegate = self
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        print("XLPagerTabStripExampleViewController - viewControllers for pagerTabStripController")
        let child_1 = createBottomViewController(pageIndex: 0, title: "Post", count: 30)
        let child_2 = createBottomViewController(pageIndex: 1, title: "Likes", count: 1)
        let child_3 = createBottomViewController(pageIndex: 2, title: "Saved", count: 40)
        
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
    private func createBottomViewController(pageIndex: Int, title: String, count: Int) -> BottomViewController {
        print("XLPagerTabStripExampleViewController - createBottomViewController for pageIndex: \(pageIndex), title: \(title)")
        let bottomVC = BottomViewController()
        bottomVC.pageIndex = pageIndex
        bottomVC.pageTitle = title
        //bottomVC.count = count
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

