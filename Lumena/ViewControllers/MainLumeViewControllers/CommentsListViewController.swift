//
//  CommentsViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/16.
//

import Foundation
import UIKit
import SwiftUI

class CommentsViewControllerOLD: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCellOLD
        let comment = userComments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }
}

class CommentCellOLD: UITableViewCell {
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


// MARK: - Previous Comment View

struct CommentSlideView: View {
    
    @Binding var reel: Lume
//    @State private var selectedTab: Int = 0
    
    @State private var loading: Bool = false
    @State private var likers: Bool = false

//    let tabs: [Tab] = [
//        .init(title: "コメント"),
//        .init(title: "ライク")
//    ]
    
    var body: some View {
        
        ZStack{
            
            if loading {
                
                ProgressView()
                    .font(.title)
                    .foregroundColor(Color.secondary)
                
            } else {
                
                VStack{
                    
                    ZStack{
                        Text("コメント")
                            .font(.title3)
                            .fontWeight(.bold)
                        
//                        HStack{
//
//                            Spacer()
//
//
//                            Button(action:{
//                                withAnimation{
//                                    likers.toggle()
//                                }
//                            }){
//                                Image(systemName: likers ? "heart.fill" : "heart")
//                                    .font(.title3)
//                                    .fontWeight(.bold)
//                            }
//                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.top, 10)
                    
                    ZStack{
                        
                        VStack{
                            Divider()
                            
                            Spacer()
                        }
                        
                        ZStack{
                            
//                            if likers {
//                                LikeView(reel: $reel)
//                            } else {
//                                CommentView(reel: $reel)
                                CommentView()
//                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.container)
        .onAppear{
            
            loading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                withAnimation{
                    loading = false
                }
            }
        }
    }
}

struct CommentView: View {
    
//    @Binding var reel: Lume
    @State private var reel: Lume = Lume()
    @State private var writeComment: String = ""
    @State private var scrollToCommentId: UUID?
    
    @FocusState private var keyboardFocus: Bool
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        ZStack {
            
            VStack {
                
                Group{
                    ScrollView(showsIndicators: false) {
                        ScrollViewReader { scrollView in
                            VStack {
                                
                                // Poster's description
                                if let postDescription = reel.postDescription,
                                   postDescription != ""
                                {
                                    Rectangle()
                                        .frame(height: 16)
                                        .foregroundColor(Color.clear)
                                    
                                    Text(postDescription)
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                    
                                    Divider()
                                        .padding(.top)
                                }
                                
                                if !reel.userComments.isEmpty {
                                    ForEach(reel.userComments.indices, id: \.self) { index in
                                        let comment = reel.userComments[index]
                                        IndividualCommentView(comment: comment)
                                            .id(comment.id)
                                            .onAppear {
                                                if index == reel.userComments.count - 2 {
                                                    reel.fetchComment()
                                                }
                                            }
                                    }
                                    .padding(.vertical, 5)
                                    .onChange(of: scrollToCommentId) { value in
                                        if let value = value {
                                            withAnimation {
                                                scrollView.scrollTo(value, anchor: .bottom)
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    Spacer()
                                    
                                    Text("まだ誰もコメントしてません")
                                        .font(.title2)
                                        .foregroundColor(Color.primary)
                                        .fontWeight(.heavy)
                                    Text("コメントを追加してみよう！")
                                        .font(.callout)
                                        .foregroundColor(Color.secondary)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                            }
                            .onTapGesture {
                                if(keyboardFocus) {
                                    
                                    keyboardFocus = false
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                HStack(alignment: .bottom) {
                    
                    TextField("コメントを書く", text: $writeComment, onCommit: {
                        if !writeComment.isEmpty {
                            
                            if let userProfile = GI.shared.profileSettings {
                                
                                let commentID = reel.postID + ":\(userProfile.identityID):\(Int(Date.now.timeIntervalSince1970))"
                                
                                let newComment = Comment(commentID: commentID, userProfile: userProfile, content: writeComment, lumeQLID: reel.postID)
                                
                                Task {
                                    do {
                                        let message = try await newComment.postComment()
                                        print(message)
                                    } catch {
                                        print(error)
                                    }
                                }
                                
                                reel.userComments.append(newComment)
                                scrollToCommentId = newComment.id
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                writeComment = ""
                            }
                        }
                    })
                    .focused($keyboardFocus)
                    .padding(.all, 20)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.gray, lineWidth: 0.5)  // This adds a border
                            .background(Color.clear)  // This makes the fill color clear
                    )
                    .foregroundColor(Color.primary)
                    .keyboardType(.twitter)
                    
                    
                    if writeComment.isEmpty {
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.primary)
                        }
                    } else {
                        Button(action: {
                            
                            if let userProfile = GI.shared.profileSettings {
                                
                                let commentID = reel.postID + ":\(userProfile.identityID):\(Int(Date.now.timeIntervalSince1970))"
                                
                                let newComment = Comment(commentID: commentID, userProfile: userProfile, content: writeComment, lumeQLID: reel.postID)
                                
                                Task {
                                    do {
                                        let message = try await newComment.postComment()
                                        print(message)
                                    } catch {
                                        print(error)
                                    }
                                }
                                
                                reel.userComments.append(newComment)
                                scrollToCommentId = newComment.id
                            }
                            
                            writeComment = ""
                            
                            keyboardFocus = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, keyboardFocus ? 0 : 25)
                .padding(.bottom, keyboardFocus ? keyboardResponder.currentHeight : 0)
            }
            .onAppear{
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .ignoresSafeArea(.container)
    }
}

struct IndividualCommentView: View {
    
    let comment: Comment
    
    var body: some View {
        
        HStack(alignment: .top) {
            
            
            if let userProfileImage = comment.userProfile.profileImage?.image {
                Image(uiImage: userProfileImage)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(comment.userProfile.preferredUsername)
                    Text(comment.timestampString)
                    Spacer()
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 3)
                
                Text(comment.content)
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
            .padding(.leading, 6)
            .multilineTextAlignment(.leading)
        }
    }
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
    
    private var comments: [Comment] = []
    private var lumeqlID: String = ""
    
    init(lumeqlID: String = "", comments: [Comment] = []) {
        self.lumeqlID = lumeqlID
        self.comments = comments
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        view.backgroundColor = .background
        
        setupCommentTextField()
        setupCommentsList()
        view.bringSubviewToFront(commentTextInput.view)
        registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        commentsList = CommentsListViewController(comments: comments)
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
        
        commentTextInputHeightConstraint = commentTextInput.view.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: commentTextInputHeight)
        commentTextInputBottomConstraint = commentTextInput.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            commentTextInputHeightConstraint,
            commentTextInputBottomConstraint,
            commentTextInput.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentTextInput.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
            commentTextInputHeightConstraint = commentTextInput.view.heightAnchor.constraint(equalToConstant: commentTextFieldHeight)
            commentTextInputBottomConstraint = commentTextInput.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardHeight)
        } else {
            commentTextInputHeightConstraint = commentTextInput.view.heightAnchor.constraint(equalToConstant: commentTextFieldHeight)
            commentTextInputBottomConstraint = commentTextInput.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            let commentID = lumeqlID + ":\(userIdentityID):\(Int(Date.now.timeIntervalSince1970))"
            
            comment.commentID = commentID
            comment.lumeQLID = lumeqlID
            
            do {
                comment.userProfile = try await ProfileManager.shared.getProfile(withID: userIdentityID)
            } catch {
                print(error)
            }
            
            do {
                let message = try await comment.postComment()
                DispatchQueue.main.async {
                    print(message)
                    //add comment back to lume's comment
//                    self.userComments.append(comment)
                    self.comments.append(comment)
                    self.commentsList.addSingleCommentToStackView(comment: comment)
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
        imageView.contentMode = .scaleAspectFit
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
        view.addSubview(postButton)
        
        // Set constraints for the action button
        NSLayoutConstraint.activate([
            postButton.trailingAnchor.constraint(equalTo: textfieldHostingController.view.trailingAnchor, constant: -2),
            postButton.leadingAnchor.constraint(equalTo: textfieldHostingController.view.trailingAnchor, constant: -32),
            postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            postButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
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
        // Use the sizingLabel to calculate the required height
//        if textIsEmpty() && defaultHeight < 0.0 {
//            calculateDefaultHeight()
//        }
        
        sizingLabel.text = text
        let requiredHeight = sizingLabel.requiredHeight(for: textfieldHostingController.view.frame.width - 24) + defaultHeight
        let adjustedHeight = min(120, max(requiredHeight, 40))
        print("adjustedHeight: \(adjustedHeight)")
        // Adjust the top anchor while keeping the bottom anchor fixed
//        textFieldTopAnchor.constant = max(20, requiredHeight) - textfieldHostingController.view.frame.height
        textFieldBottomAnchor = textfieldHostingController.view.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor)
        textFieldHeightAnchor.constant = adjustedHeight
        delegate.didUpdatedHeight(adjustedHeight)
        view.layoutIfNeeded()
    }
    
    func getCurrentHeight() -> CGFloat {
//        if textIsEmpty() && defaultHeight < 0.0 {
//            calculateDefaultHeight()
//        }
        let requiredHeight = sizingLabel.requiredHeight(for: textfieldHostingController.view.frame.width - 24) + defaultHeight
        let adjustedHeight = min(120, max(requiredHeight, 40))
        print("adjustedHeight: \(adjustedHeight)")
        return adjustedHeight
    }
    
    func getMinHeight() -> CGFloat {
        sizingLabel.text = "aaaaa"
        let minHeight = sizingLabel.requiredHeight(for: textfieldHostingController.view.frame.width - 24)
        sizingLabel.text = ""
        print("adjustedHeight: min: \(minHeight)")
        return minHeight
    }
    
    func textIsEmpty() -> Bool {
        return userInput.text.isEmpty
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
    
    private var cellHeightConstraints: [CommentCell: NSLayoutConstraint] = [:]
    
    private var comments: [Comment]
    
    weak var delegate: CommentsListDelegate?
    
    init(comments: [Comment]) {
        self.comments = comments
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
            
            // Display the "No Comments Yet!" message
            stackView.addArrangedSubview(noCommentsLabel)
            stackView.addArrangedSubview(noCommentsSubtitleLabel)
            
            let bottomSpacerView = UIView()
            bottomSpacerView.backgroundColor = .clear
            bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(bottomSpacerView)
            
            NSLayoutConstraint.activate([
                
                topSpacerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                topSpacerView.bottomAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -50),
                
                noCommentsLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                noCommentsLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                noCommentsLabel.heightAnchor.constraint(equalToConstant: 50),
                noCommentsLabel.topAnchor.constraint(equalTo: topSpacerView.bottomAnchor),
                noCommentsSubtitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                noCommentsSubtitleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                noCommentsSubtitleLabel.heightAnchor.constraint(equalToConstant: 50),
                noCommentsSubtitleLabel.topAnchor.constraint(equalTo: noCommentsLabel.bottomAnchor),
                
                bottomSpacerView.topAnchor.constraint(equalTo: noCommentsSubtitleLabel.bottomAnchor),
                bottomSpacerView.heightAnchor.constraint(equalTo: topSpacerView.heightAnchor, constant: 1),
            ])
            
        } else {
            // Display the comments
            addCommentsToStackView()
        }
    }
    
    private func addCommentsToStackView() {
        for comment in comments {
            let commentCell = CommentCell(style: .default, reuseIdentifier: "commentCell")
            commentCell.delegate = self
            commentCell.configure(with: comment) // Configure the cell with the comment data
            
            // Add the comment cell to the stack view
            stackView.addArrangedSubview(commentCell)
            
            // Set the initial height constraint
            let heightConstraint = commentCell.heightAnchor.constraint(equalToConstant: 76)
            heightConstraint.isActive = true
            cellHeightConstraints[commentCell] = heightConstraint
        }
    }
    
    func addSingleCommentToStackView(comment: Comment) {
        comments.append(comment)
        addCommentsToStackView()
    }
    
    func didUpdateHeight(for cell: CommentCell, height: CGFloat) {
        guard let heightConstraint = cellHeightConstraints[cell] else { return }
        
        // Update the existing height constraint
        heightConstraint.constant = max(76, height)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScrollList(scrollView.contentOffset)
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
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expandableView: CommentCellExpandableViewController = {
        let expandableView = CommentCellExpandableViewController()
//        expandableView.translatesAutoresizingMaskIntoConstraints = false
        return expandableView
    }()
    
    private var replyButton: UIButton!
    private var likeButton: CommentLikeUIButton!
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
//        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 12
//        stackView.translatesAutoresizingMaskIntoConstraints = false
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
        
        setupLikeButton()
        setupReplyButton()
        
        contentView.addSubview(backgroundRectView)
        
        expandableView.delegate = self
        
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(expandableView)
        stackView.addArrangedSubview(replyButton)
        
        containerStackView.addArrangedSubview(userImageView)
        containerStackView.addArrangedSubview(stackView)
        containerStackView.addArrangedSubview(likeButton)
        
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
//            userImageView.widthAnchor.constraint(equalToConstant: 50),
//            userImageView.heightAnchor.constraint(equalToConstant: 50),
//            
//            usernameLabel.heightAnchor.constraint(equalToConstant: 18),
//            replyButton.heightAnchor.constraint(equalToConstant: 18),
            
            userImageView.topAnchor.constraint(equalTo: containerStackView.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: containerStackView.topAnchor, constant: 50),
            userImageView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: 50),
            
            usernameLabel.topAnchor.constraint(equalTo: containerStackView.topAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: containerStackView.topAnchor, constant: 18),
            
            replyButton.topAnchor.constraint(equalTo: expandableView.bottomAnchor),
            replyButton.bottomAnchor.constraint(equalTo: containerStackView.bottomAnchor),
            
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        backgroundRectView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        expandableView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(with comment: Comment) {
        // Populate the cell's UI elements with data from the Comment object
//        usernameLabel.text = comment.userProfile.preferredUsername
//        expandableView.text = comment.content
    }
    
    private func setupLikeButton() {
        likeButton = CommentLikeUIButton()
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
    }
    
    private func setupReplyButton() {
        replyButton = UIButton(type: .system)
        replyButton.setTitle("reply", for: .normal)
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        replyButton.addTarget(self, action: #selector(tapReply), for: .touchUpInside)
    }
}

extension CommentCell: CommentCellExpandableViewControllerDelegate {
    func didUpdateHeight(_ height: CGFloat) {
        let newHeight = height
        delegate?.didUpdateHeight(for: self, height: newHeight + 44) // 4 + 4 (4 spacing) + 18 + 18 = 44
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
        likeButton.animateLike()
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
    var text: String = String().loresIpsumShort
    
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
