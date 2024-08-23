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
        label.textColor = .arinGreen
        return label
    }()
    
    private let followerTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("フォロワー", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondary
        return label
    }()
    
    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .arinBlue
        return label
    }()
    
    private let followingTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("フォロー中", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondary
        return label
    }()
    
    private let postsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .arinDarkPink
        return label
    }()
    
    private let postsTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("ライク数", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondary
        return label
    }()
    
    private let streaksCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .arinYellow
        return label
    }()
    
    private let streaksTextLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("ストリーク", comment: "")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondary
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
        
        let streaksStackView = UIStackView(arrangedSubviews: [streaksCountLabel, streaksTextLabel])
        streaksStackView.axis = .vertical
        streaksStackView.alignment = .center
        
        statsStackView.addArrangedSubview(followerStackView)
        statsStackView.addArrangedSubview(followingStackView)
        statsStackView.addArrangedSubview(postsStackView)
        statsStackView.addArrangedSubview(streaksStackView)
        
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
        streaksCountLabel.text = "\(profile.streaksStartDate ?? 0)"
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

//struct skinSettingsProfileBubbleView: View {
//    
//    @State var skinSettings: SkinSettingsAttributes = SkinSettingsAttributes()
//    
//    var body: some View {
//        VStack {
//            HStack {
//                skinSettingsProfileBubbleIndividualView(text: skinSettings.sensitivity.rawValue, backgroundColor: UIColor.arinDarkPink)
//                skinSettingsProfileBubbleIndividualView(text: skinSettings.uv.rawValue, backgroundColor: UIColor.arinGreen)
//                skinSettingsProfileBubbleIndividualView(text: skinSettings.skinType.rawValue, backgroundColor: UIColor.arinYellow)
//                skinSettingsProfileBubbleIndividualView(text: "Skin Color", backgroundColor: UIColor.color(from: skinSettings.skinColor))
//            }
//            
//            HStack {
//                skinSettingsProfileBubbleIndividualView(text: skinSettings.concerns.rawValue, backgroundColor: UIColor.arinDarkPink)
//                skinSettingsProfileBubbleIndividualView(text: "Eye Color", backgroundColor: UIColor.color(from: skinSettings.eyeColor))
//                skinSettingsProfileBubbleIndividualView(text: skinSettings.personalColor.rawValue, backgroundColor: UIColor.arinBlue)
//            }
//        }
//    }
//}
//
//struct skinSettingsProfileBubbleIndividualView: View {
//    var text: String
//    var backgroundColor: UIColor
//    
//    var body: some View {
//        Text(text)
//            .font(.caption2)
//            .fontWeight(.bold)
//            .fixedSize(horizontal: false, vertical: true)
//            .foregroundStyle(.white)
//            .multilineTextAlignment(.center)
//            .frame(width: 75, height: 22)
//            .padding(.all, 3)
//            .background(Color(backgroundColor))
//            .cornerRadius(15)
//    }
//}
//
//#Preview("skinSettingsProfileBubbleViewPreview") {
//    skinSettingsProfileBubbleView()
//}


class SkinSettingsProfileBubbleViewController: UIViewController {
    
    private var stackView1: UIStackView!
    private var stackView2: UIStackView!
    private var mainStackView: UIStackView!
    
    var skinSettings: SkinSettingsAttributes!
    
    init(skinSettings: SkinSettingsAttributes) {
        self.skinSettings = skinSettings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStackViews()
        updateSkinSettings(skinSettings: skinSettings)
    }
    
    private func setupStackViews() {
        stackView1 = UIStackView()
        stackView1.axis = .horizontal
        stackView1.distribution = .equalSpacing
        stackView1.alignment = .center
        stackView1.spacing = 10
        
        stackView2 = UIStackView()
        stackView2.axis = .horizontal
        stackView2.distribution = .equalSpacing
        stackView2.alignment = .center
        stackView2.spacing = 10
        
        mainStackView = UIStackView(arrangedSubviews: [stackView1, stackView2])
        mainStackView.axis = .vertical
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .center
        mainStackView.spacing = 10
        
        view.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func updateSkinSettings(skinSettings: SkinSettingsAttributes) {
        self.skinSettings = skinSettings
        // Clear existing arranged subviews
        stackView1.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView2.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add bubbles to stack views based on the updated skinSettings
        stackView1.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: skinSettings.sensitivity.rawValue, backgroundColor: .arinDarkPink))
        stackView1.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: skinSettings.uv.rawValue, backgroundColor: .arinGreen))
        stackView1.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: skinSettings.skinType.rawValue, backgroundColor: .arinYellow))
        stackView1.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: "肌色", backgroundColor: UIColor.color(from: skinSettings.skinColor)))
        
        stackView2.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: skinSettings.concerns.rawValue, backgroundColor: .arinDarkPink))
        stackView2.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: "虹彩色", backgroundColor: UIColor.color(from: skinSettings.eyeColor)))
        stackView2.addArrangedSubview(SkinSettingsProfileBubbleIndividualViewController(text: skinSettings.personalColor.rawValue, backgroundColor: .arinBlue))
        
        view.layoutIfNeeded()
    }
}

class SkinSettingsProfileBubbleIndividualViewController: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    init(text: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        
        label.text = NSLocalizedString(text, comment: "")
        addSubview(label)
        
        // Add constraints to mimic fixed size and padding in SwiftUI
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
        
        // Setting fixed size for the bubble
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 75),
            heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



struct SkinSettingsProfileBubbleViewController_Preview: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SkinSettingsProfileBubbleViewController {
        return SkinSettingsProfileBubbleViewController(skinSettings: SkinSettingsAttributes())
    }
    
    func updateUIViewController(_ uiViewController: SkinSettingsProfileBubbleViewController, context: Context) {
        // Update the view controller if needed
    }
}
