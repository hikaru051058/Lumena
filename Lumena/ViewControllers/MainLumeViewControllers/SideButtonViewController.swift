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
    
    var likeButton = HeartButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
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
//        setupCommentButton()
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
            let profileVC = TwitterParallaxViewController(userIdentityID: lume.postUserIID, isAccountUser: lume.postUserIID == GI.shared.identityID)
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
        likeButton = HeartButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
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
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 3),
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

// Comment Button
extension LumeSideButtonsViewController {
    
    private func setupCommentButton() {
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setImage(UIImage(systemName: "bubble.right.fill"), for: .normal)
        commentButton.tintColor = .white
        
        commentButton.layer.shadowColor = UIColor.black.cgColor
        commentButton.layer.shadowOpacity = 0.25
        commentButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        commentButton.layer.shadowRadius = 0.25
        commentButton.layer.masksToBounds = false
        
        stackView.addArrangedSubview(commentButton)
        
        NSLayoutConstraint.activate([
            commentButton.widthAnchor.constraint(equalToConstant: 44),
            commentButton.heightAnchor.constraint(equalToConstant: 37),
        ])
        
        commentButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)
    }
    
    @objc private func showComments() {
        if AuthenticationManager.shared.authStatus == .authenticated {
            let commentsViewController = CommentsViewController(lume: lume)
            commentsViewController.lume = lume  // assuming CommentsViewController can handle a reel
            navigationController?.pushViewController(commentsViewController, animated: true)
        } else {
            showLoginSheet()
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
                        try await GraphQL.shared.blockUser(blockuserprofileqlID: profile!.identityID, blockAction: .block)
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

class HeartButton: UIButton {
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

class CommentsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    var lume: Lume
    var userComments: [Comment]
    var keyboardHeight: CGFloat = 0
    
    private let tableView = UITableView()
    private let commentTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    init(lume: Lume) {
        self.lume = lume
        self.userComments = lume.userComments
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        registerForKeyboardNotifications()
        setupTableView()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        view.addSubview(tableView)
        
        commentTextField.placeholder = "コメントを書く"
        commentTextField.borderStyle = .roundedRect
        commentTextField.delegate = self
        view.addSubview(commentTextField)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        view.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor),
            
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8),
            commentTextField.heightAnchor.constraint(equalToConstant: 50),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func sendComment() {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        // Logic to send comment
        if let userProfile = GI.shared.profileSettings {
            
            let commentID = lume.postID + ":\(userProfile.identityID):\(Int(Date.now.timeIntervalSince1970))"
            
            let newComment = Comment(commentID: commentID, userProfile: userProfile, content: text, lumeQLID: lume.postID)
            
            Task {
                do {
                    let message = try await newComment.postComment()
                    DispatchQueue.main.async {
                        print(message)
                        self.userComments.append(newComment)
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        commentTextField.text = "" // Clear text field
        dismissKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1) {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillBeHidden(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.1) {
            self.view.frame.origin.y = 0
        }
    }
    
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTableView() {
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        let comment = userComments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }
}

class CommentCell: UITableViewCell {
    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let commentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        
        usernameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        usernameLabel.textColor = .darkGray
        
        commentLabel.font = .systemFont(ofSize: 16)
        commentLabel.textColor = .black
        commentLabel.numberOfLines = 0
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
    }
    
    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
            
            commentLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            commentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with comment: Comment) {
        // Assuming `profileImage` and `username` are properties of `userProfile`
        if let profileImage = comment.userProfile.profileImage, let image = profileImage.image {
            profileImageView.image = image
        }
        usernameLabel.text = comment.userProfile.preferredUsername
        commentLabel.text = comment.content
    }
}

class MarqueeTextViewController: UIViewController {
    
    private var hostingController: UIHostingController<MarqueeText>?
    
    var text: String
    var font: UIFont
    var leftFade: CGFloat
    var rightFade: CGFloat
    var startDelay: Double
    var alignment: Alignment
    
    // Custom initializer with default values
    init(text: String = "", font: UIFont = UIFont.systemFont(ofSize: 16), leftFade: CGFloat = 16, rightFade: CGFloat = 16, startDelay: Double = 3, alignment: Alignment = .leading) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.alignment = alignment
        super.init(nibName: nil, bundle: nil) // Proper call to the superclass initializer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SwiftUI view that we wish to host
        let marqueeView = MarqueeText(text: text, font: font, leftFade: leftFade, rightFade: rightFade, startDelay: startDelay, alignment: alignment)
        
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
    
    public init(text: String, font: UIFont, leftFade: CGFloat, rightFade: CGFloat, startDelay: Double, alignment: Alignment? = nil) {
        self.text = text
        self.font = font
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



class LumeBottomButtonsViewController: UIViewController, ObservableObject, LumeIndividualDataUpdateDelegate {
    
    private var sideButtonProfileHost: UIHostingController<SideButtonProfileView>?
    var sideButtonDescriptionView: DescriptionExpandableViewController!
    
    private var profileViewBottomConstraint: NSLayoutConstraint!
    private var descriptionViewTopConstraint: NSLayoutConstraint!
    
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
    
    private var lumeAuthenticityViewButton: UIButton!
    @State var lumeAuthenticityExpanded: Bool = false
    
    let buttonConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .default)
    let buttonPadding: CGFloat = 5.0

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
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        setupDescriptionButton()
//        setupLumeAuthenticity()
        setupProfileButton()
    }
}

// profile button
extension LumeBottomButtonsViewController {
    
    private func setupProfileButton() {
        let sideButtonProfileView = SideButtonProfileView(
            sideButtonsController: self,
            postUserID: lume.postUserIID,
            onNavigateProfile: navigateToProfile
        )
        sideButtonProfileHost = UIHostingController(rootView: sideButtonProfileView)
        
        guard let profileView = sideButtonProfileHost?.view else { return }
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.backgroundColor = UIColor.clear
        
        profileView.layer.shadowColor = UIColor.black.cgColor
        profileView.layer.shadowOpacity = 0.25
        profileView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        profileView.layer.shadowRadius = 0.25
        profileView.layer.masksToBounds = false
        
        self.addChild(sideButtonProfileHost!)
        view.addSubview(profileView)
        sideButtonProfileHost?.didMove(toParent: self)
        profileViewBottomConstraint = profileView.bottomAnchor.constraint(equalTo: sideButtonDescriptionView.topAnchor)
        
        // Set up the constraints
        NSLayoutConstraint.activate([
            profileView.widthAnchor.constraint(equalTo: view.widthAnchor),
            profileViewBottomConstraint
        ])
    }
    
    func navigateToProfile() {
        DispatchQueue.main.async { [self] in
            let profileVC = TwitterParallaxViewController(userIdentityID: lume.postUserIID, isAccountUser: lume.postUserIID == GI.shared.identityID)
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
    
    struct SideButtonProfileView: View {
        @ObservedObject var sideButtonsController: LumeBottomButtonsViewController
        @State var postUserID: String
        @State private var followButton: Bool = false
        @State private var profileImage: UIImage? = nil

        var onNavigateProfile: (() -> Void)?

        var body: some View {
            HStack {
                if let userIdentityID = GI.shared.identityID, postUserID != userIdentityID {
                    if AuthenticationManager.shared.authStatus == .authenticated {
                        Button(action: { onNavigateProfile?() }) {
                            profileImageView()
                            
                            Text(sideButtonsController.profile?.preferredUsername ?? "")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                        }
                        
                        followButtonView(userIdentityID: userIdentityID)
                    }
                }
                Spacer()
            }
            .onAppear {
                fetchRelationshipStatus()
                if let userProfile = sideButtonsController.profile {
                    profileImage = userProfile.profileImage?.image
                }
                NotificationCenter.default.addObserver(forName: .didChangeFollowStatus, object: nil, queue: .main) { _ in
                    self.fetchRelationshipStatus()
                }
            }
            .onChange(of: sideButtonsController.refreshProfileView) { _ in
                fetchRelationshipStatus()
            }
            .onChange(of: sideButtonsController.profile) { newProfile in
                profileImage = newProfile?.profileImage?.image
            }
        }

        func fetchRelationshipStatus() {
            guard let userIdentityID = GI.shared.identityID else { return }
            DispatchQueue.main.async {
                Task {
                    let status = await ProfileManager.shared.getRelationshipStat(fromUserID: userIdentityID, toUserID: postUserID)
                    followButton = (status == .following) || (status == .mutual)
                }
            }
        }

        @ViewBuilder
        private func profileImageView() -> some View {
            ZStack {
                if let profileImage = self.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 42, height: 42)
                        .clipShape(Circle())
                } else {
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 42, height: 42)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
            }
        }

        @ViewBuilder
        private func followButtonView(userIdentityID: String) -> some View {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .frame(width: (followButton ? 22 : 50), height: 22)
                    .foregroundColor(followButton ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 0.946, green: 0.76, blue: 0.839))
                Group {
                    Text(followButton ? "" : "フォロー")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Image(systemName: followButton ? "checkmark" : "")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                toggleFollow(userIdentityID: userIdentityID)
            }
        }

        private func toggleFollow(userIdentityID: String) {
            let isCurrentlyFollowing = ProfileManager.shared.isFollowing(userIdentityID, to: postUserID)
            ProfileManager.shared.updateFollowingStatus(fromUserID: userIdentityID, toUserID: postUserID, follow: !isCurrentlyFollowing)
            withAnimation {
                followButton.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
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
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
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
        guard let UserProfileIdentity = GI.shared.identityID else { return }
        let profileVC = TwitterParallaxViewController(userIdentityID: UserProfileIdentity, isAccountUser: true)
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

class DescriptionExpandableViewController: UIView {
    
    private let scrollView = UIScrollView()
    private let descriptionLabel = UILabel()
    private var expanded = false
    private var maximumExpandedHeight: CGFloat = 300 // Renamed for clarity
    var text: String = String().loresIpsum
    
    private var scrollViewTopConstraint: NSLayoutConstraint!
    
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
        
    }
    
    private func applyVerticalFadeMask() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.05, 0.95, 1.0]
        
        self.layer.mask = gradientLayer
    }
    
    private func removeVerticalFadeMask() {
        self.layer.mask = nil
    }
    
    @objc func toggleDescription() {
        expanded.toggle()
        updateDescriptionHeight()
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
        print(heightReturn)
        return heightReturn
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
