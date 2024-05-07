//
//  TabBarViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/06.
//

import Foundation
import UIKit


class TabBarViewController: UIViewController {
    var tabs: [String] = ["First", "Second"]  // Tab titles
    var buttons: [UIButton] = []
    var indicator: UIView!
    
    var selectedTab: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    // This delegate will be used to notify the parent controller about tab changes
    weak var delegate: TabBarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        updateUI()
    }
    
    private func setupTabs() {
        let buttonWidth = view.bounds.width / CGFloat(tabs.count)
        for (index, title) in tabs.enumerated() {
            let button = UIButton(frame: CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: 50))
            button.setTitle(title, for: .normal)
            button.setTitleColor(.gray, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.tag = index
            button.addTarget(self, action: #selector(tabSelected(_:)), for: .touchUpInside)
            view.addSubview(button)
            buttons.append(button)
        }
        
        indicator = UIView(frame: CGRect(x: 0, y: 40, width: 50, height: 3))
        indicator.backgroundColor = .white
        indicator.layer.cornerRadius = 1.5
        view.addSubview(indicator)
    }
    
    @objc private func tabSelected(_ sender: UIButton) {
        delegate?.tabBar(self, didSelectTabAtIndex: sender.tag)
    }
    
    private func updateUI() {
        for (index, button) in buttons.enumerated() {
            button.isSelected = index == selectedTab
        }
        UIView.animate(withDuration: 0.3) {
            let buttonWidth = self.view.bounds.width / CGFloat(self.tabs.count)
            self.indicator.frame.origin.x = CGFloat(self.selectedTab) * buttonWidth + (buttonWidth - 50) / 2
        }
    }
}

protocol TabBarDelegate: AnyObject {
    func tabBar(_ tabBar: TabBarViewController, didSelectTabAtIndex index: Int)
}

