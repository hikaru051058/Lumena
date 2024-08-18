//
//  CommentsViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/16.
//

import Foundation
import UIKit
import SwiftUI

protocol CommentSheetViewDelegate: AnyObject {
    func didUpdatedLume(_ lume: Lume)
}

class CommentsSheetViewController: UIViewController {
    
    private var commentsList: CommentsListViewController!
    private var commentTextInput: CommentTextInputViewController!
    
    private var commentsListBottomConstraint: NSLayoutConstraint!
    private var commentTextInputHeightConstraint: NSLayoutConstraint!
    private var commentTextInputBottomConstraint: NSLayoutConstraint!
    
    private var keyboardIsVisible: Bool = false
    private var keyboardHeight: CGFloat = 0.0
    private var lastHeight: CGFloat = 40.0
    
//    private var comments: [Comment] = []
//    private var lumeqlID: String = ""
    
    private var lume: Lume = Lume()
    
    weak var delegate: CommentSheetViewDelegate?
    
//    init(lumeqlID: String = "", comments: [Comment] = []) {
//        self.lumeqlID = lumeqlID
//        self.comments = comments
//        super.init(nibName: nil, bundle: nil)
//    }
    
    init(lume: Lume) {
        self.lume = lume
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        navigationItem.title = "Comments"
//        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
//        navigationController?.navigationBar.shadowImage = UIImage()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.compactAppearance = navigationBarAppearance
        
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        
        setupCommentTextField()
        setupCommentsList()
        view.bringSubviewToFront(commentTextInput.view)
        
        registerForKeyboardNotifications()
        fetchNewComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            keyboardHeight = keyboardFrame.height
            adjustForKeyboard(height: keyboardFrame.height)
            keyboardIsVisible = true
            didUpdatedHeight(lastHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        keyboardHeight = 0.0
        adjustForKeyboard(height: 0)
        keyboardIsVisible = false
        didUpdatedHeight(lastHeight)
    }
    
    private func adjustForKeyboard(height: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension CommentsSheetViewController: CommentsListDelegate {
    
    private func setupCommentsList() {
        commentsList = CommentsListViewController(comments: lume.userComments, isLoading: !lume.userCommentFetchedAll)
        commentsList.delegate = self
        addChild(commentsList)
        view.addSubview(commentsList.view)
        commentsList.didMove(toParent: self)
        
        commentsList.view.translatesAutoresizingMaskIntoConstraints = false
        
        commentsListBottomConstraint = commentsList.view.bottomAnchor.constraint(equalTo: commentTextInput.view.topAnchor)
        
        NSLayoutConstraint.activate([
            commentsList.view.topAnchor.constraint(equalTo: view.topAnchor),
            commentsListBottomConstraint,
            commentsList.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentsList.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func didScrollList(_ lastContentOffset: CGPoint) {
        view.endEditing(true)
    }
    
    func fetchNewComments() {
        DispatchQueue.main.async { [self] in
            Task {
                await lume.fetchComment()
                commentsList.setComments(lume.userComments)
            }
        }
    }
}

extension CommentsSheetViewController: CommentTextFieldDelegate {
    
    private func setupCommentTextField() {
        commentTextInput = CommentTextInputViewController()
        commentTextInput.delegate = self
        addChild(commentTextInput)
        view.addSubview(commentTextInput.view)
        commentTextInput.didMove(toParent: self)
        
        commentTextInput.view.translatesAutoresizingMaskIntoConstraints = false
        
        let commentTextInputHeight = commentTextInput.getCurrentHeight() + view.safeAreaInsets.bottom // -> 34 + 40 = 74
        
        commentTextInputHeightConstraint = commentTextInput.view.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: commentTextInputHeight + 4)
        commentTextInputBottomConstraint = commentTextInput.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        
        NSLayoutConstraint.activate([
            commentTextInputHeightConstraint,
            commentTextInputBottomConstraint,
            commentTextInput.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentTextInput.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Add a border only on the top
        let topBorder = UIView()
        topBorder.backgroundColor = .systemGray6 // Set the border color here
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        commentTextInput.view.addSubview(topBorder)
        
        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: commentTextInput.view.topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: commentTextInput.view.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: commentTextInput.view.trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func didUpdatedHeight(_ height: CGFloat) {
        lastHeight = height
        
        let commentTextFieldHeight = height + (keyboardIsVisible ? 0 : view.safeAreaInsets.bottom)
        
        // Deactivate the old constraint
        commentTextInputHeightConstraint.isActive = false
        commentTextInputBottomConstraint.isActive = false
        commentsListBottomConstraint.isActive = false
        
        if keyboardIsVisible {
            commentTextInputHeightConstraint = commentTextInput.view.heightAnchor.constraint(equalToConstant: commentTextFieldHeight + 4)
            commentTextInputBottomConstraint = commentTextInput.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardHeight-4)
        } else {
            commentTextInputHeightConstraint = commentTextInput.view.heightAnchor.constraint(equalToConstant: commentTextFieldHeight + 4)
            commentTextInputBottomConstraint = commentTextInput.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        }
        
        // Update the comments list constraint
        commentsListBottomConstraint = commentsList.view.bottomAnchor.constraint(equalTo: commentTextInput.view.topAnchor)
        
        commentTextInputHeightConstraint.isActive = true
        commentTextInputBottomConstraint.isActive = true
        commentsListBottomConstraint.isActive = true
        view.layoutIfNeeded()
    }
    
    func didPostComment(_ comment: Comment) {
        Task {
            await self.sendComment(comment: comment)
        }
    }
}

extension CommentsSheetViewController {
    
    private func sendComment(comment: Comment) async {
        
        if let userIdentityID = AuthenticationManager.shared.identityID {
            let commentID = lume.postID + ":\(userIdentityID):\(Int(Date.now.timeIntervalSince1970))"
            
            comment.commentID = commentID
            comment.lumeQLID = lume.postID
            
            do {
                comment.userProfile = try await ProfileManager.shared.getProfile(withID: userIdentityID)
            } catch {
                print(error)
            }
            
            do {
                let message = try await comment.postComment()
                DispatchQueue.main.async {
                    print(message)
                    self.lume.userComments.append(comment)
                    self.delegate?.didUpdatedLume(self.lume)
                    self.commentsList.setComments(self.lume.userComments)
                }
            } catch {
                print(error)
            }
        } else {
            print("no identity ID found")
        }
    }
}

protocol CommentTextFieldDelegate: AnyObject {
    func didUpdatedHeight(_ height: CGFloat)
    func didPostComment(_ comment: Comment)
}

class CommentTextInputViewController: UIViewController {
    
    weak var delegate: CommentTextFieldDelegate!
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let postButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)?.withTintColor(.arinBlue, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var textfieldHostingController: UIHostingController<CommentTextField>!
    private var userInput = UserInput(text: "")
    private var textFieldHeightAnchor: NSLayoutConstraint!
    private var textFieldBottomAnchor: NSLayoutConstraint!
    
    private var defaultHeight: CGFloat = 40
    
    // Label for calculating height
    private let sizingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17) // Match the font used in the text field
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupView()
        addTextField()
        addActionButton()
    }
    
    private func setupView() {
        // Add profile image view to the main view
        if let userIdentityID = AuthenticationManager.shared.identityID {
            profileImageView.image = ProfileManager.shared.returnProfileImage(userIdentityID: userIdentityID)?.image
        }
        
        view.addSubview(profileImageView)
        
        // Set constraints for the profile image view
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 56),
            profileImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func addTextField() {
        // Create the CommentTextField SwiftUI view
        let swiftUIView = CommentTextField(
            placeholder: "Make a comment...",
            userInput: userInput,
            characterLimit: 300,
            onTextChanged: { [weak self] newText in
                self?.adjustTextFieldHeight(for: newText)
            }
        )
        
        // Create a hosting controller for the SwiftUI view
        textfieldHostingController = UIHostingController(rootView: swiftUIView)
        
        // Add the hosting controller's view to the main view
        addChild(textfieldHostingController)
        view.addSubview(textfieldHostingController.view)
        textfieldHostingController.didMove(toParent: self)
        
        // Set constraints for the hosting controller's view
        textfieldHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldBottomAnchor = textfieldHostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        textFieldHeightAnchor = textfieldHostingController.view.heightAnchor.constraint(equalToConstant: 40)
        
        NSLayoutConstraint.activate([
            textfieldHostingController.view.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            textfieldHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldBottomAnchor,
            textFieldHeightAnchor,
        ])
        
        DispatchQueue.main.async { [self] in
            defaultHeight = getMinHeight()
        }
    }
    
    private func addActionButton() {
        // Add the action button to the main view
        postButton.alpha = 0
        view.addSubview(postButton)
        
        // Set constraints for the action button
        NSLayoutConstraint.activate([
            postButton.trailingAnchor.constraint(equalTo: textfieldHostingController.view.trailingAnchor, constant: -5),
            postButton.leadingAnchor.constraint(equalTo: textfieldHostingController.view.trailingAnchor, constant: -35),
            postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            postButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35)
        ])
        
        postButton.addTarget(self, action: #selector(postActionTapped), for: .touchUpInside)
    }
    
    @objc private func postActionTapped() {
        delegate?.didPostComment(exportAsComment())
        DispatchQueue.main.async {
            self.userInput.text = ""
        }
    }
    
    private func adjustTextFieldHeight(for text: String) {
        sizingLabel.text = text
        let requiredHeight = sizingLabel.requiredHeight(for: textfieldHostingController.view.frame.width - 24) + defaultHeight
        let adjustedHeight = min(120, max(requiredHeight, 40))
        textFieldBottomAnchor = textfieldHostingController.view.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor)
        textFieldHeightAnchor.constant = adjustedHeight
        delegate.didUpdatedHeight(adjustedHeight)
        
        postButton.alpha = text.isEmpty ? 0 : 1
        
        view.layoutIfNeeded()
    }
    
    func getCurrentHeight() -> CGFloat {
        let requiredHeight = sizingLabel.requiredHeight(for: textfieldHostingController.view.frame.width - 24) + defaultHeight
        let adjustedHeight = min(120, max(requiredHeight, 40))
        return adjustedHeight
    }
    
    func getMinHeight() -> CGFloat {
        sizingLabel.text = "aaaaa"
        let minHeight = sizingLabel.requiredHeight(for: textfieldHostingController.view.frame.width - 24)
        sizingLabel.text = ""
        return minHeight
    }
    
    func exportAsComment() -> Comment {
        let returnComment = Comment(content: userInput.text)
        return returnComment
    }
}

struct CommentTextField: View {
    
    @State var placeholder: String
    @ObservedObject var userInput: UserInput
    var characterLimit: Int
    var onTextChanged: (String) -> Void
    
    var body: some View {
        TextField(NSLocalizedString(placeholder, comment: ""), text: $userInput.text, axis: .vertical)
            .onChange(of: userInput.text) { newValue in
                if userInput.text.count > characterLimit {
                    userInput.text = String(userInput.text.prefix(characterLimit))
                }
                onTextChanged(userInput.text)
            }
            .padding(.horizontal, 12) // Add padding inside the text field
            .padding(.vertical, 8) // Add padding inside the text field
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 1) // Add a border with a stroke
            )
    }
}

protocol CommentsListDelegate: AnyObject {
    func didScrollList(_ lastContentOffset: CGPoint)
    func fetchNewComments()
}

class CommentsListViewController: UIViewController, UIScrollViewDelegate, CommentCellDelegate {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var topPaddingView: UIView?
    
    private var noCommentsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Comments Yet!"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let noCommentsSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Be the first one to leave a nice comment!"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var cellHeightConstraints: [CommentCell: NSLayoutConstraint] = [:]
    
    private var comments: [Comment]
    private var addedCommentIDs: Set<String> = []
    
    var isLoading: Bool = true
    
    weak var delegate: CommentsListDelegate?
    
    init(comments: [Comment], isLoading: Bool = true) {
        self.comments = comments
        self.isLoading = isLoading
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        setupScrollView()
        setupStackView()
        updateViewForComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func updateViewForComments() {
        
        if comments.isEmpty {
            
            let topSpacerView = UIView()
            topSpacerView.backgroundColor = .clear
            topSpacerView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(topSpacerView)
            
            if isLoading {
                // Add the loading spinner
                stackView.addArrangedSubview(loadingSpinner)
                loadingSpinner.startAnimating()
                
                NSLayoutConstraint.activate([
                    loadingSpinner.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                    loadingSpinner.topAnchor.constraint(equalTo: topSpacerView.bottomAnchor),
                    loadingSpinner.bottomAnchor.constraint(equalTo: topSpacerView.bottomAnchor, constant: 50)
                ])
                
            } else {
                // Display the "No Comments Yet!" message
                stackView.addArrangedSubview(noCommentsLabel)
                stackView.addArrangedSubview(noCommentsSubtitleLabel)
                
                NSLayoutConstraint.activate([
                    noCommentsLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    noCommentsLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    noCommentsLabel.topAnchor.constraint(equalTo: topSpacerView.bottomAnchor),
                    noCommentsLabel.bottomAnchor.constraint(equalTo: topSpacerView.bottomAnchor, constant: 50),
                    
                    noCommentsSubtitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    noCommentsSubtitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    noCommentsSubtitleLabel.topAnchor.constraint(equalTo: noCommentsLabel.bottomAnchor),
                    noCommentsSubtitleLabel.bottomAnchor.constraint(equalTo: noCommentsLabel.bottomAnchor, constant: 50),
                ])
            }
            
            let bottomSpacerView = UIView()
            bottomSpacerView.backgroundColor = .clear
            bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(bottomSpacerView)
            
            NSLayoutConstraint.activate([
                topSpacerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                topSpacerView.bottomAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -50),
                
                bottomSpacerView.topAnchor.constraint(equalTo: isLoading ? loadingSpinner.bottomAnchor : noCommentsSubtitleLabel.bottomAnchor),
                bottomSpacerView.heightAnchor.constraint(equalTo: topSpacerView.heightAnchor, constant: 1),
            ])
            
        } else {
            // Display the comments
            if isLoading {
                stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
            addCommentsToStackView()
        }
    }
    
    private func addCommentsToStackView() {
        // Check if the top padding view has been added
        if topPaddingView == nil {
            // Create and add the spacer view at the top for padding
            topPaddingView = UIView()
            topPaddingView?.translatesAutoresizingMaskIntoConstraints = false
            topPaddingView?.heightAnchor.constraint(equalToConstant: 8).isActive = true
            stackView.insertArrangedSubview(topPaddingView!, at: 0)
        }

        for comment in comments {
            // Check if the comment has already been added
            if addedCommentIDs.contains(comment.commentID) {
                continue // Skip this comment if it's already been added
            }
            
            let commentCell = CommentCell(style: .default, reuseIdentifier: "commentCell")
            commentCell.delegate = self
            commentCell.configure(with: comment) // Configure the cell with the comment data
            
            // Add the comment cell to the stack view
            stackView.addArrangedSubview(commentCell)
            
            // Set the initial height constraint
            let heightConstraint = commentCell.heightAnchor.constraint(equalToConstant: 76)
            heightConstraint.isActive = true
            cellHeightConstraints[commentCell] = heightConstraint
            
            // Mark this comment as added
            addedCommentIDs.insert(comment.commentID)
        }
    }
    
    func setComments(_ newComments: [Comment]) {
        DispatchQueue.main.async {
            // Filter out comments that are already in the list
            let newUniqueComments = newComments.filter { newComment in
                !self.comments.contains(where: { $0.commentID == newComment.commentID })
            }
            
            // Append only the new unique comments
            self.comments.append(contentsOf: newUniqueComments)
            
            self.updateViewForComments()
            
            self.isLoading = false
        }
    }
    
    func didUpdateHeight(for cell: CommentCell, height: CGFloat) {
        guard let heightConstraint = cellHeightConstraints[cell] else { return }
        
        // Update the existing height constraint
        heightConstraint.constant = max(60, height) //76
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScrollList(scrollView.contentOffset)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        // Check if the user has scrolled near the bottom (e.g., within 100 points of the bottom)
        if offsetY > contentHeight - scrollViewHeight - 100 {
            delegate?.fetchNewComments()
        }
    }
}

protocol CommentCellDelegate: AnyObject {
    func didUpdateHeight(for cell: CommentCell, height: CGFloat)
}

class CommentCell: UITableViewCell {
    weak var delegate: CommentCellDelegate?
    
    private var isExpanded: Bool = false
    
    private let backgroundRectView: UIView = {
        let view = UIView()
        view.backgroundColor = .background // Set your desired background color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let expandableView: CommentCellExpandableViewController = {
        let expandableView = CommentCellExpandableViewController(text: "")
        return expandableView
    }()
    
//    private var replyButton: UIButton!
//    private var likeButton: CommentLikeUIButton!
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private let usernameAndTimeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 12
        return stackView
    }()
    
    private var expandableViewHeightConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
//        setupLikeButton()
//        setupReplyButton()
//        
        contentView.addSubview(backgroundRectView)
        
        expandableView.delegate = self
        
        // Add the username and time label to the horizontal stack view
        usernameAndTimeStackView.addArrangedSubview(usernameLabel)
        usernameAndTimeStackView.addArrangedSubview(timeLabel)
        
        stackView.addArrangedSubview(usernameAndTimeStackView)
        stackView.addArrangedSubview(expandableView)
//        stackView.addArrangedSubview(replyButton)
        
        containerStackView.addArrangedSubview(userImageView)
        containerStackView.addArrangedSubview(stackView)
//        containerStackView.addArrangedSubview(likeButton)
        
        contentView.addSubview(containerStackView)
        
        let expandableHeight = expandableView.getCurrentHeight()
        expandableViewHeightConstraint = expandableView.heightAnchor.constraint(equalToConstant: expandableHeight)
        expandableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            backgroundRectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundRectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundRectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundRectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: containerStackView.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: containerStackView.topAnchor, constant: 40),
            userImageView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: 40),
            
            usernameAndTimeStackView.topAnchor.constraint(equalTo: containerStackView.topAnchor),
            usernameAndTimeStackView.bottomAnchor.constraint(equalTo: containerStackView.topAnchor, constant: 18),
            
//            replyButton.topAnchor.constraint(equalTo: expandableView.bottomAnchor),
//            replyButton.bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        backgroundRectView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        expandableView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with comment: Comment) {
        usernameLabel.text = comment.userProfile.preferredUsername
        expandableView.text = comment.content
        userImageView.image = comment.userProfile.profileImage?.image
        timeLabel.text = "\(comment.timestampString)"
        
        self.layoutIfNeeded()
    }
    
//
//    private func setupLikeButton() {
//        likeButton = CommentLikeUIButton()
//        likeButton.translatesAutoresizingMaskIntoConstraints = false
//        likeButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
//    }
//    
//    private func setupReplyButton() {
//        replyButton = UIButton(type: .system)
//        replyButton.setTitle("reply", for: .normal)
//        replyButton.translatesAutoresizingMaskIntoConstraints = false
//        replyButton.addTarget(self, action: #selector(tapReply), for: .touchUpInside)
//    }
}

extension CommentCell: CommentCellExpandableViewControllerDelegate {
    func didUpdateHeight(_ height: CGFloat) {
        let newHeight = height
        delegate?.didUpdateHeight(for: self, height: newHeight + 26)// + 44) // 4 + 4 (4 spacing) + 18 + 18 = 44
        expandableViewHeightConstraint?.constant = newHeight
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    func didToggleExpand(_ expand: Bool) {
        isExpanded = expand
    }
}

extension CommentCell {
    @objc func toggleLike() {
//        likeButton.animateLike()
    }
    
    @objc func tapReply() {
        print("tapped reply")
    }
}

protocol CommentCellExpandableViewControllerDelegate: AnyObject {
    func didUpdateHeight(_ height: CGFloat)
    func didToggleExpand(_ expand: Bool)
}

class CommentCellExpandableViewController: UIView, UIScrollViewDelegate {
    
    private let scrollView = UIScrollView()
    private let commentLabel = UILabel()
    private var expanded = false
    var text: String = String().loresIpsumShort {
        didSet {
            commentLabel.text = self.text
            updateDescriptionHeight()
            self.layoutIfNeeded()
        }
    }
    
    var scrollViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: CommentCellExpandableViewControllerDelegate?
    
    private var topFadeLayer: CAGradientLayer?
    private var bottomFadeLayer: CAGradientLayer?
    
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
        scrollView.delegate = self
        addSubview(scrollView)
        
        // Configure the label
        commentLabel.text = text
        commentLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        commentLabel.textColor = .primary
        commentLabel.numberOfLines = 2
        commentLabel.textAlignment = .left
        commentLabel.lineBreakMode = .byTruncatingTail
        commentLabel.isUserInteractionEnabled = true
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(commentLabel)
        
        // Set constraints for the label
        NSLayoutConstraint.activate([
            commentLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            commentLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            commentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            commentLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            commentLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Calculate the required height for the label after the layout has been applied
        DispatchQueue.main.async {
            let requiredHeight = self.commentLabel.requiredHeight(for: self.bounds.width)
            self.scrollViewBottomConstraint = self.scrollView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: requiredHeight)
            self.scrollViewBottomConstraint.isActive = true
            
            self.delegate?.didUpdateHeight(requiredHeight)
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
        ])
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescription))
        commentLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func toggleDescription() {
        expanded.toggle()
        delegate?.didToggleExpand(expanded)
        updateDescriptionHeight()
    }
    
    private func addFadeOutLayer() {
        topFadeLayer = CAGradientLayer()
        topFadeLayer?.colors = [
            UIColor.clear.cgColor,
            UIColor.background.withAlphaComponent(1).cgColor,
        ]
        topFadeLayer?.locations = [0.0, 1.0]
        topFadeLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
        topFadeLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
        topFadeLayer?.frame = CGRect(
            x: 0,
            y: scrollView.frame.height * 0.9,
            width: scrollView.frame.width,
            height: scrollView.frame.height * 0.1
        )
        if let topFadeLayer = topFadeLayer {
            self.layer.addSublayer(topFadeLayer)
        }
        
        bottomFadeLayer = CAGradientLayer()
        bottomFadeLayer?.colors = [
            UIColor.background.withAlphaComponent(1).cgColor,
            UIColor.clear.cgColor,
        ]
        bottomFadeLayer?.locations = [0.0, 1.0]
        bottomFadeLayer?.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomFadeLayer?.endPoint = CGPoint(x: 0.5, y: 1.0)
        bottomFadeLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.frame.width,
            height: scrollView.frame.height * 0.1
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
        self.commentLabel.numberOfLines = self.expanded ? 0 : 2
        
        var requiredHeight: CGFloat = 0.0
        if !text.isEmpty {
            requiredHeight = commentLabel.requiredHeight(for: bounds.width)
        }
        scrollView.isScrollEnabled = expanded
        
        delegate?.didUpdateHeight(requiredHeight)
        
        // Notify the superview (CommentCell) to update its layout
        if let superview = self.superview as? UITableViewCell {
            superview.setNeedsLayout()
            superview.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.scrollViewBottomConstraint?.constant = requiredHeight
            self.layoutIfNeeded()
        }
    }
    
    func getCurrentHeight() -> CGFloat {
        let heightReturn = min(scrollView.frame.height, commentLabel.requiredHeight(for: bounds.width))
        return heightReturn
    }
    
    func getFullHeight() -> CGFloat {
        let heightReturn = commentLabel.requiredHeight(for: bounds.width)
        return heightReturn
    }
}

class CommentLikeUIButton: UIButton {
    var isLiked: Bool = false {
        didSet {
            updateUI()
        }
    }

    // Property to control the symbol size
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
        let newColor = isLiked ? UIColor.arinPink.saturated(by: 1.7) : .primary // Change color as needed
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


extension UINavigationItem {

    func setTitleView(withTitle title: String, subTitile: String) {

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black

        let subTitleLabel = UILabel()
        subTitleLabel.text = subTitile
        subTitleLabel.font = .systemFont(ofSize: 14)
        subTitleLabel.textColor = .gray

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical

        self.titleView = stackView
    }
}
