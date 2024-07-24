//
//  ProfileStatsViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/27.
//

import Foundation
import UIKit
import SwiftUI

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
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private var followButtonHost: UIHostingController<ProfileFollowButtonView>?
    
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
        
        mainStackView.addArrangedSubview(statsStackView)
        
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Bring the mainStackView to the front
        view.bringSubviewToFront(mainStackView)
    }
    
    private func updateFollowerCount(followState: Bool) {
        // Increment or decrement the follower count
        if followState {
            profile.followerCount += 1
        } else {
            profile.followerCount -= 1
        }
        
        // Update the stats labels
        updateStats()
    }
    
    private func updateStats() {
        followerCountLabel.text = "\(formatNumber(profile.followerCount))"
        followingCountLabel.text = "\(formatNumber(profile.followingCount))"
        postsCountLabel.text = "\(profile.postContentsID.count)"
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


struct ProfileFollowButtonView: View {
    
    @State private var followState: Bool = false
    private var otherUserIdentityID: String
    var onNavigateLogin: (() -> Void)?
    
    init(otherUserIdentityID: String, onNavigateLogin: (() -> Void)? = nil) {
        self.otherUserIdentityID = otherUserIdentityID
        self.onNavigateLogin = onNavigateLogin
    }
    
    var body: some View {
        Button(action: {
            toggleFollowState()
        }) {
            ZStack {
                Rectangle()
                    .frame(width: 100, height: 30)
                    .cornerRadius(15)
                    .foregroundColor(followState ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 0.946, green: 0.76, blue: 0.839))
                
                Text(followState ? "フォロー中" : "フォロー")
                    .fontWeight(.bold)
                    .font(.callout)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            fetchFollowState()
            NotificationCenter.default.addObserver(forName: .didChangeFollowStatus, object: nil, queue: .main) { _ in
                self.fetchFollowState()
            }
        }
    }
    
    func toggleFollowState() {
        guard let userIdentityID = GI.shared.identityID else {
            print("No user identity id was extracted in toggleFollowState()")
            return
        }
        
        if AuthenticationManager.shared.authStatus != .authenticated {
            onNavigateLogin?()
            return
        }
        
        ProfileManager.shared.updateFollowingStatus(fromUserID: userIdentityID, toUserID: otherUserIdentityID, follow: !followState)
        withAnimation {
            followState.toggle()
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func fetchFollowState() {
        guard let userIdentityID = GI.shared.identityID else { return }
        DispatchQueue.main.async {
            Task {
                let status = await ProfileManager.shared.getRelationshipStat(fromUserID: userIdentityID, toUserID: otherUserIdentityID)
                self.followState = (status == .following) || (status == .mutual)
            }
        }
    }
}
