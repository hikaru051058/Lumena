//
//  SideButtonViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/05.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import XLPagerTabStrip


class LumeSideButtonsViewController: UIViewController, ObservableObject, LumeIndividualDataUpdateDelegate {
    
    func didUpdateDescriptionHeight(_ height: CGFloat?) {
    }
    
    @Published var lume: Lume
    @Published var currentLume: UUID?
    @Published var refreshProfileView: Bool = false
    
    var userLiked: Bool
    var userLoggedIn: Bool {
        didSet {
            // Update UI or perform other actions when the login state changes
        }
    }
    var profile: ProfileSettings? {
        didSet {
            // Notify the UI to update whenever profile changes
            refreshProfileView.toggle()
        }
    }
    
    let buttonConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .default)
    let buttonPadding: CGFloat = 25.0
    
    var likeButton = HeartUIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private var likeCountLabel = UILabel()
    private var likeContainerView = UIView()
    private let cosmeticsButton = UIButton()
    private let commentButton = UIButton()
    private let furtherActionButton = UIButton()
    
    private let stackView = UIStackView()
    
    init(lume: Lume, userLiked: Bool, userLoggedIn: Bool) {
        self.lume = lume
        self.userLiked = userLiked
        self.userLoggedIn = userLoggedIn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPosterProfile()
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccessHandler), name: .authStatusChanged, object: nil)
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = buttonPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        setupLikeButton()
        setupCosmeticButton()
        setupCommentButton()
        setupFurtherActionButton()
    }
    
    func updateCurrentLume(with newCurrentLume: UUID) {
        currentLume = newCurrentLume
        
        userLiked = lume.checkUserLikedPost()
        likeButton.isLiked = userLiked
        
        self.refreshProfileView.toggle()
    }
    
    func didUpdateData(_ data: ProfileSettings?) {
        self.profile = data
    }
    
    func fetchPosterProfile() {
        self.profile = lume.returnPostUser()
    }
    
    @objc private func authSuccessHandler() {
        userLoggedIn = AuthenticationManager.shared.authStatus == .authenticated
    }
}

extension LumeSideButtonsViewController {
    
    func navigateToProfile() {
        DispatchQueue.main.async { [self] in
            let profileVC = ProfileParallaxViewController(userIdentityID: lume.postUserIID, isAccountUser: lume.postUserIID == GI.shared.identityID)
            self.navigationController?.pushViewController(profileVC, animated: true)
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

// Like Button
extension LumeSideButtonsViewController {
    
    private func setupLikeButton() {
        // Create a container view for the like button and counter
        let likeContainerView = UIView()
        likeContainerView.translatesAutoresizingMaskIntoConstraints = false

        // Setup the like button
        likeButton = HeartUIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.symbolSize = 36
        
        likeButton.layer.shadowColor = UIColor.black.cgColor
        likeButton.layer.shadowOpacity = 0.25
        likeButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        likeButton.layer.shadowRadius = 0.25
        likeButton.layer.masksToBounds = false
        
        likeContainerView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: likeContainerView.topAnchor),
            likeButton.centerXAnchor.constraint(equalTo: likeContainerView.centerXAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        likeButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
        
        // Setup the like counter label
        setupLikeCounter(in: likeContainerView)
        
        likeCountLabel.text = formatNumber(lume.likeCnt)
        
        userLiked = lume.userLiked
        likeButton.isLiked = userLiked
        
        // Add the container view to the stack view
        stackView.addArrangedSubview(likeContainerView)
        
        NSLayoutConstraint.activate([
            likeContainerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            likeContainerView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupLikeCounter(in containerView: UIView) {
        // Setup the label that displays the number of likes
        likeCountLabel = UILabel()
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.font = UIFont.systemFont(ofSize: 14)
        likeCountLabel.textColor = .white
        
        // Setting shadow properties
        likeCountLabel.layer.shadowColor = UIColor.black.cgColor  // Shadow color
        likeCountLabel.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        likeCountLabel.layer.shadowOpacity = 0.25  // Shadow opacity
        likeCountLabel.layer.shadowRadius = 0.25
        
        containerView.addSubview(likeCountLabel)
        
        NSLayoutConstraint.activate([
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor),
            likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor)
        ])
    }
    
    @objc func toggleLike() {
        if AuthenticationManager.shared.authStatus == .authenticated {
            userLiked.toggle()
            likeButton.animateLike()
            lume.likedLume(userLikeInput: userLiked)
            likeCountLabel.text = formatNumber(lume.likeCnt)
        } else {
            showLoginSheet()
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        let thousand = 1_000
        let million = 1_000_000
        
        if num < thousand {
            return "\(num)"
        } else if num < million {
            return String(format: "%.1fk", Double(num) / Double(thousand))
        } else {
            return String(format: "%.1m", Double(num) / Double(million))
        }
    }
}

// Cosmetic Button
extension LumeSideButtonsViewController {
    
    private func setupCosmeticButton() {
        
        if lume.tagProducts.isEmpty {
            return
        }
        
        // Cosmetics Button
        cosmeticsButton.setImage(UIImage(systemName: "cross.vial", withConfiguration: buttonConfig), for: .normal)
        cosmeticsButton.tintColor = .white
        
        cosmeticsButton.layer.shadowColor = UIColor.black.cgColor
        cosmeticsButton.layer.shadowOpacity = 0.25
        cosmeticsButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cosmeticsButton.layer.shadowRadius = 0.25
        cosmeticsButton.layer.masksToBounds = false
        
        stackView.addArrangedSubview(cosmeticsButton)
        
        NSLayoutConstraint.activate([
            cosmeticsButton.widthAnchor.constraint(equalToConstant: 50),
            cosmeticsButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        cosmeticsButton.addTarget(self, action: #selector(showCosmetics), for: .touchUpInside)
    }
    
    @objc private func showCosmetics() {
        // Initialize the SwiftUI view
        let cosmeticTagView = SideButtonCosmeticsTagView(TagCosmetics: lume.tagProducts)
        
        // Create a UIHostingController to wrap the SwiftUI view
        let hostingController = UIHostingController(rootView: cosmeticTagView)
        
        // Configure the presentation style as a sheet
        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium(),
                             .custom { context in
                                 return context.maximumDetentValue * 0.25
                                         },
                             .custom { context in
                                 return context.maximumDetentValue * 0.98
                                         },
            ]
        }
        
        // Present the sheet
        self.present(hostingController, animated: true)
    }
}

// Comment Button
extension LumeSideButtonsViewController: CommentSheetViewDelegate {
    
    private func setupCommentButton() {
        
        commentButton.setImage(UIImage(systemName: "text.bubble", withConfiguration: buttonConfig), for: .normal)
        commentButton.tintColor = .white
        
        commentButton.layer.shadowColor = UIColor.black.cgColor
        commentButton.layer.shadowOpacity = 0.25
        commentButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        commentButton.layer.shadowRadius = 0.25
        commentButton.layer.masksToBounds = false
        
        stackView.addArrangedSubview(commentButton)
        
        NSLayoutConstraint.activate([
            commentButton.widthAnchor.constraint(equalToConstant: 50),
            commentButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        commentButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)
    }
    
    @objc private func showComments() {
        if AuthenticationManager.shared.authStatus == .authenticated {
            
//            let commentsSheetViewController = CommentsSheetViewController(lumeqlID: lume.postID, comments: lume.userComments)
            let commentsSheetViewController = CommentsSheetViewController(lume: lume)
            commentsSheetViewController.delegate = self
            
            // Embed the CommentsSheetViewController in a UINavigationController
            let navController = UINavigationController(rootViewController: commentsSheetViewController)
            navController.modalPresentationStyle = .pageSheet
            
            if let sheet = navController.sheetPresentationController {
                // Create a custom medium detent with 65% height
                let customMediumDetent = UISheetPresentationController.Detent.custom() { context in
                    return context.maximumDetentValue * 0.65
                }
                
                sheet.detents = [customMediumDetent, .large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(navController, animated: true, completion: nil)
        } else {
            showLoginSheet()
        }
    }
    
    func didUpdatedLume(_ lume: Lume) {
        DispatchQueue.main.async {
            self.lume = lume
        }
    }
}

// Further Action Button
extension LumeSideButtonsViewController {
    
    private func setupFurtherActionButton() {
        furtherActionButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: buttonConfig), for: .normal)
        furtherActionButton.tintColor = .white
        
        furtherActionButton.layer.shadowColor = UIColor.black.cgColor
        furtherActionButton.layer.shadowOpacity = 0.25
        furtherActionButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        furtherActionButton.layer.shadowRadius = 0.25
        furtherActionButton.layer.masksToBounds = false
        
        stackView.addArrangedSubview(furtherActionButton)

        NSLayoutConstraint.activate([
            furtherActionButton.widthAnchor.constraint(equalToConstant: 50),
            furtherActionButton.heightAnchor.constraint(equalToConstant: 22),
        ])

        furtherActionButton.addTarget(self, action: #selector(furtherActionTapped), for: .touchUpInside)
    }
    
    @objc private func furtherActionTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let reportAction = UIAlertAction(title: NSLocalizedString("投稿を報告", comment: ""), style: .destructive) { _ in
            // Handle the report action
            
            // Show a thank you message after reporting
            let thankYouAlert = UIAlertController(title: NSLocalizedString("ご報告ありがとうございます", comment: ""), message: NSLocalizedString("いただいた情報は、Lumenaコミュニティーをより安全かつ、楽しめる場にするために役立たせていただきます", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            thankYouAlert.addAction(okAction)
            
            self.present(thankYouAlert, animated: true)
        }
        
        let blockAction = UIAlertAction(title: NSLocalizedString("ユーザーをブロック", comment: ""), style: .destructive) { [self] _ in
            // Check if user is logged in
            if AuthenticationManager.shared.authStatus != .authenticated {
                let loginAlert = UIAlertController(title: NSLocalizedString("ログインが必要です", comment: ""), message: NSLocalizedString("ユーザーをブロックするには、Lumenaアカウントにサインインしてください", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel)
                let loginAction = UIAlertAction(title: NSLocalizedString("ログイン", comment: ""), style: .default) { _ in
                    self.showLoginSheet()
                }
                
                loginAlert.addAction(okAction)
                loginAlert.addAction(loginAction)
                self.present(loginAlert, animated: true, completion: nil)
                return
            }
            
            // Handle the report action
            let trailingMessage = "this user"
            let blockUserNameMessage = String(format: NSLocalizedString("block_message", comment: ""), trailingMessage)
            
            let blockAlertController = UIAlertController(title: blockUserNameMessage, message: nil, preferredStyle: .alert)
            
            let blockBlock = UIAlertAction(title: NSLocalizedString("ブロック", comment: ""), style: .destructive) { [self] _ in
                // Handle block action if needed
                Task {
                    do {
                        if let userIdentityID = AuthenticationManager.shared.identityID,
                           let toUserIdentityProfile = profile
                        {
                            try await ProfileManager.shared.blockUser(fromUserID: userIdentityID, toUserID:  toUserIdentityProfile.identityID)
                        }
                    } catch {
                        print(error)
                    }
                }
                
                let thankYouAlert = UIAlertController(title: NSLocalizedString("ブロックしました", comment: ""), message: NSLocalizedString("ブロック解除はプロファイル設定画面から行えます", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                thankYouAlert.addAction(okAction)
                
                self.present(thankYouAlert, animated: true, completion: nil)
            }
            
            let cancelBlock = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { _ in
                // Handle cancel action if needed
                print("User tapped Cancel")
            }
            
            blockAlertController.addAction(blockBlock)
            blockAlertController.addAction(cancelBlock)
            
            // Present the alert controller
            self.present(blockAlertController, animated: true, completion: nil)
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        actionSheet.addAction(reportAction)
        actionSheet.addAction(blockAction)
        actionSheet.addAction(cancelAction)

        // Present the action sheet
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = furtherActionButton
            popoverController.sourceRect = furtherActionButton.bounds
        }
        present(actionSheet, animated: true)
    }
}

class HeartUIButton: UIButton {
    var isLiked: Bool = false {
        didSet {
            updateUI()
        }
    }

    // Add a property to control the symbol size
    var symbolSize: CGFloat = UIFont.systemFontSize {  // Default to system font size
        didSet {
            updateUI()
        }
    }
    
    private var unlikedImage: UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: symbolSize, weight: .regular, scale: .default)
        return UIImage(systemName: "heart", withConfiguration: config)
    }
    
    private var likedImage: UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: symbolSize, weight: .regular, scale: .default)
        return UIImage(systemName: "heart.fill", withConfiguration: config)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        let newImage = isLiked ? likedImage : unlikedImage
        let newColor = isLiked ? UIColor.arinPink.saturated(by: 1.7) : .white
        setImage(newImage?.withTintColor(newColor, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    func animateLike(onlyAnimation: Bool = false) {
        if !onlyAnimation {
            isLiked.toggle()
        }
        UIView.animate(withDuration: 0.1, animations: {
            let scale = self.isLiked ? 1.3 : 0.7
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        })
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

class MarqueeTextViewController: UIViewController {
    
    private var hostingController: UIHostingController<MarqueeText>?
    
    var text: String
    var font: UIFont
    var textColor: UIColor
    var leftFade: CGFloat
    var rightFade: CGFloat
    var startDelay: Double
    var alignment: Alignment
    
    // Custom initializer with color parameter
    init(text: String = "", font: UIFont = UIFont.systemFont(ofSize: 16), textColor: UIColor = .white, leftFade: CGFloat = 16, rightFade: CGFloat = 16, startDelay: Double = 3, alignment: Alignment = .leading) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SwiftUI view that we wish to host
        let marqueeView = MarqueeText(text: text, font: font, textColor: textColor, leftFade: leftFade, rightFade: rightFade, startDelay: startDelay, alignment: alignment)
        
        hostingController = UIHostingController(rootView: marqueeView)
        guard let hostingView = hostingController?.view else { return }
        
        // Manage the lifecycle and view hierarchy
        if let hostingController = hostingController {
            addChild(hostingController)
            view.addSubview(hostingView)
            hostingController.didMove(toParent: self)
        }
        
        hostingView.backgroundColor = UIColor.clear
        
        // Set constraints for the hosting view
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.pinToEdges(of: view)
    }
}


public struct MarqueeText : View {
    public var text: String
    public var font: UIFont
    public var textColor: UIColor = .primary
    public var leftFade: CGFloat
    public var rightFade: CGFloat
    public var startDelay: Double
    public var alignment: Alignment
    
    @State private var animate = false
    var isCompact = false
    
    public var body : some View {
        let stringWidth = text.widthOfString(usingFont: font)
        let stringHeight = text.heightOfString(usingFont: font)
        
        let animation = Animation
            .linear(duration: Double(stringWidth) / 30)
            .delay(startDelay)
            .repeatForever(autoreverses: false)
        
        let nullAnimation = Animation
            .linear(duration: 0)
        
        return ZStack {
            GeometryReader { geo in
                if stringWidth > geo.size.width { // don't use self.animate as conditional here
                    Group {
                        Text(self.text)
                            .lineLimit(1)
                            .font(.init(font))
                            .foregroundColor(Color(textColor))
                            .offset(x: self.animate ? -stringWidth - stringHeight * 2 : 0)
                            .animation(self.animate ? animation : nullAnimation, value: self.animate)
                            .onAppear {
                                DispatchQueue.main.async {
                                    self.animate = geo.size.width < stringWidth
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.leading)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        
                        Text(self.text)
                            .lineLimit(1)
                            .font(.init(font))
                            .foregroundColor(Color(textColor))
                            .offset(x: self.animate ? 0 : stringWidth + stringHeight * 2)
                            .animation(self.animate ? animation : nullAnimation, value: self.animate)
                            .onAppear {
                                DispatchQueue.main.async {
                                    self.animate = geo.size.width < stringWidth
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.leading)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }
                    
                    .offset(x: leftFade)
                    .mask(
                        HStack(spacing:0) {
                            Rectangle()
                                .frame(width:2)
                                .opacity(0)
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                .frame(width:leftFade)
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
                                .frame(width:rightFade)
                            Rectangle()
                                .frame(width:2)
                                .opacity(0)
                        })
                    .frame(width: geo.size.width + leftFade)
                    .offset(x: leftFade * -1)
                } else {
                    Text(self.text)
                        .font(.init(font))
                        .foregroundColor(Color(textColor))
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: alignment)
                        .padding(.leading)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
            }
        }
        .foregroundColor(Color.white)
        .frame(height: stringHeight)
        .frame(maxWidth: isCompact ? stringWidth : nil)
        .onDisappear { self.animate = false }
    }
    
    public init(text: String, font: UIFont, textColor: UIColor, leftFade: CGFloat, rightFade: CGFloat, startDelay: Double, alignment: Alignment? = nil) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment != nil ? alignment! : .topLeading
    }
}

extension MarqueeText {
    public func makeCompact(_ compact: Bool = true) -> Self {
        var view = self
        view.isCompact = compact
        return view
    }
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}


protocol LumeBottomButtonsViewDelegate: AnyObject {
    func didRequestNavigation(to profileID: String)
    func showLoginSheetView()
}

class LumeBottomButtonsViewController: UIViewController, ObservableObject, LumeIndividualDataUpdateDelegate {
    
    var sideButtonDescriptionView: DescriptionExpandableViewController!
    
    private var profileViewBottomConstraint: NSLayoutConstraint!
    private var descriptionViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: LumeBottomButtonsViewDelegate?
    
    @Published var lume: Lume
    @Published var currentLume: UUID?
    @Published var refreshProfileView: Bool = false
    
    var userLiked: Bool
    var userLoggedIn: Bool {
        didSet {
            // Update UI or perform other actions when the login state changes
        }
    }
    var profile: ProfileSettings? {
        didSet {
            refreshProfileView.toggle()
            updateProfileInfo(profileImage: self.profile?.profileImage?.image, username: self.profile?.preferredUsername)
        }
    }
    
    private var lumeAuthenticityViewButton: UIButton!
    @State var lumeAuthenticityExpanded: Bool = false
    
    let buttonConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .default)
    let buttonPadding: CGFloat = 5.0
    
    var profileImageButton: UIButton!
    var usernameButton: UIButton!
    var followButton: FollowBubbleButton!

    init(lume: Lume, userLiked: Bool, userLoggedIn: Bool) {
        self.lume = lume
        self.userLiked = userLiked
        self.userLoggedIn = userLoggedIn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didUpdateData(_ data: ProfileSettings?) {
        self.profile = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        profile = lume.returnPostUser()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        setupDescriptionButton()
        setupLumeAuthenticity()
        setupProfileButton()
    }
}

extension LumeBottomButtonsViewController: FollowBubbleButtonDelegate {
    
    private func setupProfileButton() {
        // Create the profile image button
        profileImageButton = createProfileImageButton()
        
        // Create the username button
        usernameButton = createUsernameButton()
        
        // Create the follow button using FollowBubbleButton
        followButton = FollowBubbleButton()
        followButton.delegate = self
        
        // Create a horizontal stack view to contain profile image and username button
        let profileStackView = UIStackView(arrangedSubviews: [profileImageButton, usernameButton])
        profileStackView.axis = .horizontal
        profileStackView.spacing = 8
        profileStackView.alignment = .center
        
        // Create the container view for the profile button section
        let profileContainerView = UIView()
        profileContainerView.backgroundColor = .clear
        
        // Add the stack view and follow button to the container view
        profileContainerView.addSubview(profileStackView)
        profileContainerView.addSubview(followButton)
        
        // Add the container view to the main view
        view.addSubview(profileContainerView)
        
        // Set up constraints for profileContainerView and its subviews
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
        
        profileViewBottomConstraint = profileContainerView.bottomAnchor.constraint(equalTo: sideButtonDescriptionView.topAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            // Profile container view constraints
            profileContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileContainerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -60),
            profileContainerView.topAnchor.constraint(equalTo: sideButtonDescriptionView.topAnchor, constant: -53),
            profileViewBottomConstraint,
            
            // Profile stack view constraints
            profileStackView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor),
            profileStackView.centerYAnchor.constraint(equalTo: profileContainerView.centerYAnchor),
            
            // Follow button constraints
            followButton.leadingAnchor.constraint(equalTo: profileStackView.trailingAnchor, constant: 8),
            followButton.trailingAnchor.constraint(lessThanOrEqualTo: profileContainerView.trailingAnchor, constant: -8),
            followButton.centerYAnchor.constraint(equalTo: profileContainerView.centerYAnchor),
        ])
        
        // Set visibility based on username text
        usernameButton.isHidden = usernameButton.title(for: .normal)?.isEmpty ?? true
        
        // Add shadow to the profile container view
        profileContainerView.layer.shadowColor = UIColor.black.cgColor
        profileContainerView.layer.shadowOpacity = 0.25
        profileContainerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        profileContainerView.layer.shadowRadius = 0.25
        profileContainerView.layer.masksToBounds = false
    }
    
    private func createProfileImageButton() -> UIButton {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.layer.cornerRadius = 45 / 2.0 // Set corner radius to half the width/height for a circle
        button.widthAnchor.constraint(equalToConstant: 45).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        // Set the profile image or fallback image
        if let profileImage = profile?.profileImage?.image {
            button.setImage(profileImage, for: .normal)
        } else {
            button.setImage(createDefaultProfileImage(), for: .normal)
        }
        
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        return button
    }
    
    private func createUsernameButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .left
        
        if let username = profile?.preferredUsername {
            button.setTitle(username, for: .normal)
        }
        
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        return button
    }
    
    @objc private func profileButtonTapped() {
        delegate?.didRequestNavigation(to: lume.postUserIID)  // Use the delegate to trigger navigation
    }
    
    private func createDefaultProfileImage() -> UIImage? {
        // Create a circular image with a white background and gray person.fill icon
        let size = CGSize(width: 45, height: 45)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw the gray circle background
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size))
        context?.setFillColor(UIColor.systemGray.cgColor)
        circlePath.fill()
        
        // Draw the person.fill icon in white
        if let personImage = UIImage(systemName: "person.fill") {
            let iconRect = CGRect(x: 5, y: 5, width: 35, height: 35) // Adjust the size and position as needed
            personImage.withTintColor(.white).draw(in: iconRect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func getFollowStat() async -> Bool {
        let postUserID = lume.postUserIID
        if let userIdentityID = AuthenticationManager.shared.identityID {
            let status = await ProfileManager.shared.getRelationshipStat(fromUserID: userIdentityID, toUserID: postUserID)
            return (status == .following) || (status == .mutual)
        }
        return true
    }
    
    func didUpdateFollowStat(_ following: Bool) {
        if AuthenticationManager.shared.authStatus != .authenticated {
            delegate?.showLoginSheetView()
        } else {
            let postUserID = lume.postUserIID
            if let userIdentityID = AuthenticationManager.shared.identityID {
                ProfileManager.shared.updateFollowingStatus(fromUserID: userIdentityID, toUserID: postUserID, follow: following)
            }
        }
    }
    
    func updateProfileInfo(profileImage: UIImage?, username: String?) {
        // Update profile image
        if let profileImage = profileImage {
            profileImageButton.setImage(profileImage, for: .normal)
        } else {
            profileImageButton.setImage(createDefaultProfileImage(), for: .normal)
        }
        
        // Update username
        if let username = username, !username.isEmpty {
            usernameButton.setTitle(username, for: .normal)
            usernameButton.isHidden = false
        } else {
            usernameButton.setTitle(nil, for: .normal)
            usernameButton.isHidden = true
        }
        
        // Update follow button status
        DispatchQueue.main.async {
            Task {
                self.followButton.updateFollowStatus(isFollowing: await self.getFollowStat())
            }
        }
    }
}


protocol FollowBubbleButtonDelegate: AnyObject {
    func didUpdateFollowStat(_ following: Bool)
}

class FollowBubbleButton: UIButton {
    
    weak var delegate: FollowBubbleButtonDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private var following: Bool = false
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    init(following: Bool = false) {
        
        self.following = following
        super.init(frame: .zero)
        
        self.backgroundColor = following ? .arinBlue : .arinPink
        self.layer.cornerRadius = 11
        self.clipsToBounds = true
        
        label.text = NSLocalizedString("フォロー", comment: "")
        addSubview(label)
        
        // Add constraints to mimic fixed size and padding in SwiftUI
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        // Set initial width and height constraints
        widthConstraint = widthAnchor.constraint(equalToConstant: following ? 22 : 60)
        heightConstraint = heightAnchor.constraint(equalToConstant: 22)
        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint,
            centerXAnchor.constraint(equalTo: centerXAnchor),
            centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped() {
        if AuthenticationManager.shared.authStatus != .authenticated {
            delegate?.didUpdateFollowStat(false)
        } else {
            following.toggle()
            delegate?.didUpdateFollowStat(following)
            updateUI()
        }
    }
    
    private func updateUI(animation: Bool = true) {
        // Update label text based on following state
        label.text = following ? "✓" : NSLocalizedString("フォロー", comment: "")
        
        UIView.animate(withDuration: animation ? 0.4 : 0, animations: {
            self.widthConstraint.constant = self.following ? 22 : 60
            self.backgroundColor = self.following ? .arinBlue : .arinPink
            self.superview?.layoutIfNeeded()
        })
    }
    
    func updateFollowStatus(isFollowing: Bool) {
        DispatchQueue.main.async { [self] in
            following = isFollowing
            updateUI(animation: false)
        }
    }
}

// lume Authenticity
extension LumeBottomButtonsViewController {

    private func setupLumeAuthenticity() {
        
        if !lume.lumeAuth {
            return
        }
        
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
        
        lumeAuthenticityViewButton = createButton(action: #selector(lumeAuthButtonTapped), imageName: "checkmark.seal.fill", tintColor: .white, buttonImageConfig: buttonImageConfig)
        
        lumeAuthenticityViewButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lumeAuthenticityViewButton)
        
        NSLayoutConstraint.activate([
            lumeAuthenticityViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lumeAuthenticityViewButton.heightAnchor.constraint(equalToConstant: 21),
            lumeAuthenticityViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
        ])
    }

    @objc private func lumeAuthButtonTapped() {
        
        if !lume.lumeAuth {
            return
        }
        
        lumeAuthenticityExpanded.toggle()
        NotificationCenter.default.post(name: .lumeAuthenticationExpanded, object: nil, userInfo: ["expand": self.lumeAuthenticityExpanded])
    }
    
    private func createButton(action: Selector, imageName: String, tintColor: UIColor, buttonImageConfig: UIImage.SymbolConfiguration) -> UIButton {
        let button = UIButton()
        if let image = UIImage(systemName: imageName, withConfiguration: buttonImageConfig) {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // Add shadow properties
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0.25, height: 0.25)
        button.layer.shadowRadius = 2
        button.layer.masksToBounds = false
        
        return button
    }
}

// bottom description
extension LumeBottomButtonsViewController: DescriptionExpandableViewControllerDelegate {
    
    private func setupDescriptionButton() {
        
        // Create the DescriptionExpandableViewController with the post description
        sideButtonDescriptionView = DescriptionExpandableViewController(
            text: lume.postDescription ?? ""
        )
        
        sideButtonDescriptionView.lumeBottomViewControllerdelegate = self
        
        // Add the description view to the controller's view
        sideButtonDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideButtonDescriptionView)
        
        // Configure the description view's appearance
        sideButtonDescriptionView.backgroundColor = UIColor.clear
        sideButtonDescriptionView.layer.shadowColor = UIColor.black.cgColor
        sideButtonDescriptionView.layer.shadowOpacity = 0.25
        sideButtonDescriptionView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        sideButtonDescriptionView.layer.shadowRadius = 0.25
        sideButtonDescriptionView.layer.masksToBounds = false
        
        guard let postDescription = lume.postDescription else { return }
        
        descriptionViewTopConstraint = sideButtonDescriptionView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: postDescription.isEmpty ? 0 : -sideButtonDescriptionView.getCurrentHeight())
        
        // Set the constraints for the description view
        NSLayoutConstraint.activate([
            sideButtonDescriptionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sideButtonDescriptionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sideButtonDescriptionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            descriptionViewTopConstraint
        ])
    }
    
    func getCurrentHeight() -> CGFloat{
        return sideButtonDescriptionView.getCurrentHeight()
    }
    
    func didUpdateHeight(_ height: CGFloat) {
        
        // Update the height constraint of sideButtonDescriptionView
        if let heightConstraint = sideButtonDescriptionView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = -height
        }
        
        // Update bottom constraint if needed
        descriptionViewTopConstraint.constant = -height
        
        // Update any related constraints (e.g., profile view)
        profileViewBottomConstraint = descriptionViewTopConstraint
        
        // Animate the layout change
        UIView.animate(withDuration: 0.2) { [self] in
            view.layoutIfNeeded()
        }
    }
}

class VideoDataStore: ObservableObject {
    
    static let shared = VideoDataStore()
    
    @Published var videoPlaybackProgress: CGFloat = 0.0
    @Published var isDragging: Bool = false {
        didSet {
            if isDragging {
                NotificationCenter.default.post(name: .pauseVideoNotification, object: nil)
            } else {
                NotificationCenter.default.post(name: .resumeVideoNotification, object: nil, userInfo: ["progress": videoPlaybackProgress])
            }
        }
    }
    
    @Published var currentContentID: UUID?
    @Published var mute: Bool = false

    func updatePlaybackProgress(_ progress: CGFloat) {
        videoPlaybackProgress = progress
    }

    func setIsDragging(_ dragging: Bool) {
        isDragging = dragging
    }
    
    func setContentID(_ contentID: UUID) {
        currentContentID = contentID
    }
}

class BottomIslandViewController: UIViewController {
    private var hostingController: UIHostingController<BottomIsland>?
    private var videoDataStore = VideoDataStore()
    private var userLoggedIn: Bool
    
    init(userLoggedIn: Bool = true) {
        self.userLoggedIn = userLoggedIn
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for login success notification
        NotificationCenter.default.addObserver(self, selector: #selector(authSuccessHandler), name: .authStatusChanged, object: nil)
        
        // Initialize your SwiftUI view with the appropriate navigation function
        let bottomIslandView = BottomIsland(
            onNavigateProfile: userLoggedIn ? navigateToProfile : showLoginSheet,
            onNavigateCreatePost: userLoggedIn ? navigateToCreatePost : showLoginSheet
        )
    
        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: bottomIslandView)
        // Add the hosting controller as a child view controller
        guard let hostingController = hostingController else { return }
        
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Setup constraints for layout
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.backgroundColor = UIColor.clear
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func navigateToProfile() {
        guard let UserProfileIdentity = AuthenticationManager.shared.identityID else { return }
        let profileVC = ProfileParallaxViewController(userIdentityID: UserProfileIdentity, isAccountUser: true)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func navigateToCreatePost() {
        DispatchQueue.main.async {
            let videoRecordVC = VideoHomeViewController()
            self.navigationController?.pushViewController(videoRecordVC, animated: true)
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
    
    @objc private func authSuccessHandler() {
        DispatchQueue.main.async {
            self.userLoggedIn = AuthenticationManager.shared.authStatus == .authenticated
            
            // Update the SwiftUI view with new navigation functions
            let bottomIslandView = BottomIsland(
                onNavigateProfile: self.userLoggedIn ? self.navigateToProfile : self.showLoginSheet,
                onNavigateCreatePost: self.userLoggedIn ? self.navigateToCreatePost : self.showLoginSheet
            )
            
            self.hostingController?.rootView = bottomIslandView
            if AuthenticationManager.shared.authStatus == .authenticated {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

struct BottomIsland: View {
    
    var onNavigateProfile: () -> Void
    var onNavigateCreatePost: () -> Void

    init(
        onNavigateProfile: @escaping () -> Void = {},
        onNavigateCreatePost: @escaping () -> Void = {}
    ) {
        self.onNavigateProfile = onNavigateProfile
        self.onNavigateCreatePost = onNavigateCreatePost
    }
    
    var body: some View {
        
        VStack {
            Spacer()
            
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                
                HStack {
                    Button(action: onNavigateProfile) {
                        Image(systemName: "person.fill")
                    }
                    .padding(.trailing, 10)
                    
                    Button(action: onNavigateCreatePost) {
                        Image(systemName: "plus")
                    }
                    .padding(.leading, 10)
                }
                .foregroundColor(.white)
                .font(.title2)
            }
            .frame(width: 130, height: 40)
            .cornerRadius(30)
        }
    }
}

struct VideoProgressSeekBarBottomIsland: View {
    var maxWidth: CGFloat
    @ObservedObject private var dataStore = VideoDataStore.shared

    var onSliderChanged: ((CGFloat) -> Void)?
    var onPauseVideo: (() -> Void)?
    var onResumeVideo: ((CGFloat) -> Void)?

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: dataStore.videoPlaybackProgress * maxWidth)
            }
            .frame(width: maxWidth)
            .cornerRadius(30)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    let newProgress = updateSliderWhileDragged(with: value)
                    dataStore.isDragging = true
                    onPauseVideo?()
                    dataStore.videoPlaybackProgress = newProgress
                    onSliderChanged?(newProgress)
                })
                .onEnded({ value in
                    let finalProgress = updateSlider(with: value, lastDragValue: dataStore.videoPlaybackProgress * maxWidth)
                    dataStore.isDragging = false
                    dataStore.videoPlaybackProgress = finalProgress
                    onResumeVideo?(finalProgress)
                })
            )
        }
    }

    private func updateSlider(with value: DragGesture.Value, lastDragValue: CGFloat) -> CGFloat {
        let translation = value.translation.width
        let newWidth = max(0, min(lastDragValue+translation, maxWidth))
        return newWidth / maxWidth
    }
    
    private func updateSliderWhileDragged(with value: DragGesture.Value) -> CGFloat {
        let translation = value.translation.width
        let newWidth = max(0, min(dataStore.videoPlaybackProgress+translation, maxWidth))
        return newWidth / maxWidth
    }
}

class UploadProgressBarViewController: UIViewController {
    private var hostingController: UIHostingController<UploadProgressBarView>?
    private var uploadProgress = UploadProgress()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear

        let progressBarView = UploadProgressBarView(uploadProgress: uploadProgress)
        hostingController = UIHostingController(rootView: progressBarView)
        setupHostingController(hostingController)
        
        hostingController!.view.backgroundColor = UIColor.clear
        
        // Setup Notification Listener
        NotificationCenter.default.addObserver(self, selector: #selector(handleUploadProgress(notification:)), name: .uploadProgressUpdated, object: nil)
    }

    private func setupHostingController(_ hostingController: UIHostingController<UploadProgressBarView>?) {
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hostingController.view.widthAnchor.constraint(equalToConstant: 100),
            hostingController.view.heightAnchor.constraint(equalToConstant: 22),
        ])
    }

    @objc func handleUploadProgress(notification: Notification) {
        DispatchQueue.main.async {
            if let progress = notification.userInfo?["progress"] as? Double {
                self.uploadProgress.isVisible = true
                self.uploadProgress.progress = progress
            }
            if let status = notification.userInfo?["status"] as? UploadProgressBarView.CompletionState {
                self.uploadProgress.completionState = status
                if status == .inProgress {
                    self.uploadProgress.isVisible = true
                } else if status == .successful {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.uploadProgress.isVisible = false
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.uploadProgress.isVisible = false
                        }
                    }
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct UploadProgressBarView: View {
    @ObservedObject var uploadProgress: UploadProgress
    
    enum CompletionState: Equatable {
        case inProgress, successful, failed
    }
    
    let barWidth: CGFloat = 100
    let barHeight: CGFloat = 6
    let circleSize: CGFloat = 22
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                if uploadProgress.completionState == .inProgress {
                    Group {
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.3))
                            .frame(width: geometry.size.width, height: barHeight)
                            .cornerRadius(barHeight / 2)
                        
                        Rectangle()
                            .foregroundColor(Color.white)
                            .frame(width: geometry.size.width * CGFloat(uploadProgress.progress), height: barHeight, alignment: .leading)
                            .cornerRadius(barHeight / 2)
                            .animation(.easeInOut(duration: 0.5), value: uploadProgress.progress)
                    }
                    .frame(width: barWidth, height: barHeight, alignment: .leading)
                }

                // Completion view centered in the middle
                if uploadProgress.completionState != .inProgress {
                    Image(systemName: uploadProgress.completionState == .successful ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(uploadProgress.completionState == .successful ? Color(.arinGreen) : .red)
                        .frame(width: circleSize, height: circleSize)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(.opacity)
                }
            }
            .frame(width: geometry.size.width, height: max(barHeight, circleSize))
            .animation(.easeInOut(duration: 0.5), value: uploadProgress.completionState)
            .animation(.easeInOut(duration: 0.5), value: uploadProgress.progress)
        }
        .frame(height: max(barHeight, circleSize))
        .opacity(uploadProgress.isVisible ? 1 : 0)
    }
}

class UploadProgress: ObservableObject {
    @Published var progress: Double = 0
    @Published var completionState: UploadProgressBarView.CompletionState = .inProgress
    @Published var isVisible: Bool = false
}




struct DescriptionExpandableViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> DescriptionExpandableViewController {
        return DescriptionExpandableViewController()
    }
    
    func updateUIView(_ uiView: DescriptionExpandableViewController, context: Context) {
        // Update the view if needed
    }
}

protocol DescriptionExpandableViewControllerDelegate: AnyObject {
    func didUpdateHeight(_ height: CGFloat)
}

class DescriptionExpandableViewController: UIView, ShimmeringViewProtocol {
    
    private let scrollView = UIScrollView()
    private let descriptionLabel = UILabel()
    private var expanded = false
    private var maximumExpandedHeight: CGFloat = 300 // Renamed for clarity
    var text: String = String().loresIpsum
    
    var scrollViewTopConstraint: NSLayoutConstraint!
    
    private var topFadeLayer: CAGradientLayer?
    private var bottomFadeLayer: CAGradientLayer?
    
    var shimmeringAnimatedItems: [UIView] {
        [
            scrollView
        ]
    }
    
    weak var lumeBottomViewControllerdelegate: DescriptionExpandableViewControllerDelegate?
    weak var lumeIndividualViewControllerdelegate: DescriptionExpandableViewControllerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure the scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
//        scrollView.backgroundColor = .gray
        addSubview(scrollView)
        
        startShimmerEffect()
        
        // Configure the label
        descriptionLabel.text = text
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .left
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(descriptionLabel)
        
        // Set constraints for the label
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Calculate the required height for the label after the layout has been applied
        DispatchQueue.main.async {
            let requiredHeight = self.descriptionLabel.requiredHeight(for: self.bounds.width)
            self.scrollViewTopConstraint = self.scrollView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -requiredHeight)
            self.scrollViewTopConstraint.isActive = true
            self.lumeBottomViewControllerdelegate?.didUpdateHeight(requiredHeight)
            // Animate the layout change
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescription))
        descriptionLabel.addGestureRecognizer(tapGesture)
        
        stopShimmerEffect()
    }
    
    @objc func toggleDescription() {
        expanded.toggle()
        updateDescriptionHeight()
    }
    
    func setDescriptionExpand(input: Bool) {
        expanded = input
        updateDescriptionHeight()
    }
    
    private func addFadeOutLayer() {
        topFadeLayer = CAGradientLayer()
        topFadeLayer?.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor,
        ]
        topFadeLayer?.locations = [0.0, 1.0]
        topFadeLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
        topFadeLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
        topFadeLayer?.frame = CGRect(
            x: 0,
            y: maximumExpandedHeight * 0.9,
            width: scrollView.frame.width,
            height: maximumExpandedHeight * 0.1
        )
        if let topFadeLayer = topFadeLayer {
            self.layer.addSublayer(topFadeLayer)
        }
        
        bottomFadeLayer = CAGradientLayer()
        bottomFadeLayer?.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor,
        ]
        bottomFadeLayer?.locations = [0.0, 1.0]
        bottomFadeLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFadeLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
        bottomFadeLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.frame.width,
            height: maximumExpandedHeight * 0.1
        )
        if let bottomFadeLayer = bottomFadeLayer {
            self.layer.addSublayer(bottomFadeLayer)
        }
    }
    
    private func removeFadeOutLayer() {
        topFadeLayer?.removeFromSuperlayer()
        bottomFadeLayer?.removeFromSuperlayer()
    }
    
    private func updateDescriptionHeight() {
        self.descriptionLabel.numberOfLines = self.expanded ? 0 : 2
        
        // Calculate the required height for the expanded label content
        var requiredHeight: CGFloat = 0.0
        if !text.isEmpty {
            requiredHeight = min(maximumExpandedHeight, descriptionLabel.requiredHeight(for: bounds.width))
        }
        scrollView.isScrollEnabled = expanded
        
        lumeBottomViewControllerdelegate?.didUpdateHeight(requiredHeight)
        lumeIndividualViewControllerdelegate?.didUpdateHeight(requiredHeight)
        
        // Animate the height change
        UIView.animate(withDuration: 0.2) { [weak self] in
             guard let self = self else { return }
            self.scrollViewTopConstraint?.constant = -requiredHeight
            self.layoutIfNeeded()
        }
    }
    
    func getCurrentHeight() -> CGFloat {
        let heightReturn = min(maximumExpandedHeight, descriptionLabel.requiredHeight(for: bounds.width))
        return heightReturn
    }
    
    func getFullHeight() -> CGFloat {
        let heightReturn = descriptionLabel.requiredHeight(for: bounds.width)
        return heightReturn
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFadeLayersVisibility()
    }
    
    private func updateFadeLayersVisibility() {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        UIView.animate(withDuration: 0.2) {
            // Handle top fade layer visibility
            if offsetY <= 0 {
                // At the very top, hide the top fade
                self.topFadeLayer?.opacity = 1.0
                self.bottomFadeLayer?.opacity = 0.0
            } else if offsetY + frameHeight >= contentHeight {
                // At the very bottom, hide the bottom fade
                self.topFadeLayer?.opacity = 0.0
                self.bottomFadeLayer?.opacity = 1.0
            } else {
                // In between, show both fades
                self.topFadeLayer?.opacity = 1.0
                self.bottomFadeLayer?.opacity = 1.0
            }
        }
    }
    
    func startShimmerEffect() {
        // Start the shimmer animation
        DispatchQueue.main.async {
            self.setTemplateWithSubviews(true, viewBackgroundColor: .clear)
        }
    }
    
    func stopShimmerEffect() {
        DispatchQueue.main.async {
            self.setTemplateWithSubviews(false)
        }
    }
}

extension UILabel {
    func requiredHeight(for width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let requiredSize = self.sizeThatFits(maxSize)
        return requiredSize.height
    }
}

#Preview("DescriptionExpandableViewPreview") {
    
//    DescriptionExpandableView()
    DescriptionExpandableViewRepresentable()
        .padding(.trailing, 50)
}
