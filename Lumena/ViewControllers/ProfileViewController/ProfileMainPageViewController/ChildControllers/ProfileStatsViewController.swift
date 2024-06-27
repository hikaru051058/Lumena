//
//  ProfileStatsViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/27.
//

import Foundation
import UIKit

class ProfileStatsViewController: UIViewController {
    
    var profile: ProfileSettings!
    
    private let followerCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 0.723, green: 0.88, blue: 0.825, alpha: 1)
        return label
    }()
    
    private let followerTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("フォロワー", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 0.552, green: 0.724, blue: 0.831, alpha: 1)
        return label
    }()
    
    private let followingTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("フォロー中", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let postsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(red: 0.946, green: 0.76, blue: 0.839, alpha: 1)
        return label
    }()
    
    private let postsTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("ライク数", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
//        stackView.distribution = .equalSpacing
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStats()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let followerStackView = UIStackView(arrangedSubviews: [followerCountLabel, followerTextLabel])
        followerStackView.axis = .vertical
        followerStackView.alignment = .center
        
        let followingStackView = UIStackView(arrangedSubviews: [followingCountLabel, followingTextLabel])
        followingStackView.axis = .vertical
        followingStackView.alignment = .center
        
        let postsStackView = UIStackView(arrangedSubviews: [postsCountLabel, postsTextLabel])
        postsStackView.axis = .vertical
        postsStackView.alignment = .center
        
        statsStackView.addArrangedSubview(followerStackView)
        statsStackView.addArrangedSubview(followingStackView)
        statsStackView.addArrangedSubview(postsStackView)
        
        view.addSubview(statsStackView)
        
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statsStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    private func updateStats() {
        followerCountLabel.text = "\(formatNumber(profile.followerCount))"
        followingCountLabel.text = "\(formatNumber(profile.followingCount))"
        postsCountLabel.text = "\(profile.postContents.count)"
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    func updateProfile(profile: ProfileSettings) {
        self.profile = profile
        updateStats()
    }
}
