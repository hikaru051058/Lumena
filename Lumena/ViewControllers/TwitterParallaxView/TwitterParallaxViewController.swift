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

class TwitterParallaxViewController: UIViewController, TPDataSource, TPProgressDelegate {
    
    var headerVC: HeaderViewController?
    var bottomVC: XLPagerTabStripExampleViewController!
    var backgroundGradient: GradientEffectViewController!
    
    let refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tp_configure(with: self, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc func handleRefreshControl() {
        print("refreshing")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refresh.endRefreshing()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: TPDataSource
    func headerViewController() -> UIViewController {
        headerVC = HeaderViewController()
        return headerVC!
    }
    
    func bottomViewController() -> UIViewController & PagerAwareProtocol {
        bottomVC = XLPagerTabStripExampleViewController()
        setupBackgroundGradient() // for blur background animation
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
        refresh.tintColor = .white
        refresh.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        
        let refreshView = UIView(frame: CGRect(x: 0, y: 44, width: 0, height: 0))
        scrollView.addSubview(refreshView)
        refreshView.addSubview(refresh)
    }
    
    
    private func setupBackgroundGradient() {
        
        backgroundGradient = GradientEffectViewController(colors: [Color(red: 0.723, green: 0.88, blue: 0.825), Color(red: 0.552, green: 0.724, blue: 0.831), Color(red: 0.946, green: 0.76, blue: 0.839),])
        
        view.addSubview(backgroundGradient.view)
        backgroundGradient.view.frame = view.bounds
        backgroundGradient.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
}


extension UIView {
    func addBorder(borderColor: UIColor, width: CGFloat, cornerRadius: CGFloat) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = width
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
