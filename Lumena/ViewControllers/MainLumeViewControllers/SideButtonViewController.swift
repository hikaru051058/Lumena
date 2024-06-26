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


class SideButtonsViewController: UIViewController, ObservableObject {
    
    @Published var lume: Lume
    @Published var currentLume: UUID?
    @Published var refreshProfileView: Bool = false
    
    var userLiked: Bool
    
    let buttonConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular, scale: .default)
    let buttonPadding: CGFloat = 25.0
    
    // SwiftUI hosting for SideButtonProfileView
    private var sideButtonProfileHost: UIHostingController<SideButtonProfileView>?
    private var likeButton = HeartButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private var likeCountLabel = UILabel()
    private let cosmeticsButton = UIButton()
    private let commentButton = UIButton()
    private let furtherActionButton = UIButton()
    

    init(lume: Lume, userLiked: Bool) {
        self.lume = lume
        self.userLiked = userLiked
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileButton()
        setupLikeButton()
        //setupCommentButton()
        setupCosmeticButton()
        setupFurtherActionButton()
    }
    
    func updateCurrentLume(with newCurrentLume: UUID) {
        currentLume = newCurrentLume
        
        userLiked = lume.checkUserLikedPost()
        likeButton.isLiked = userLiked
        
        self.refreshProfileView.toggle()
    }
}


//profile button
extension SideButtonsViewController {
    
    private func setupProfileButton() {
        let sideButtonProfileView = SideButtonProfileView(sideButtonsController: self, postUserID: lume.postUserIID)
        sideButtonProfileHost = UIHostingController(rootView: sideButtonProfileView)
        guard let profileView = sideButtonProfileHost?.view else { return }
        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.backgroundColor = UIColor(Color.clear)
        
        profileView.layer.shadowColor = UIColor.black.cgColor
        profileView.layer.shadowOpacity = 0.25
        profileView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        profileView.layer.shadowRadius = 0.25
        profileView.layer.masksToBounds = false
        
        self.addChild(sideButtonProfileHost!)
        view.addSubview(profileView)
        
        NSLayoutConstraint.activate([
            profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileView.widthAnchor.constraint(equalToConstant: 50),
            profileView.heightAnchor.constraint(equalToConstant: 50),
        ])
        sideButtonProfileHost?.didMove(toParent: self)
    }
}

//like button
extension SideButtonsViewController {
    
    private func setupLikeButton() {
        likeButton = HeartButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.symbolSize = 36
        
        likeButton.layer.shadowColor = UIColor.black.cgColor
        likeButton.layer.shadowOpacity = 0.25
        likeButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        likeButton.layer.shadowRadius = 0.25
        likeButton.layer.masksToBounds = false
        
        view.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: sideButtonProfileHost!.view.bottomAnchor, constant: buttonPadding),
            likeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        likeButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
        
        setupLikeCounter()
        
        likeCountLabel.text = formatNumber(lume.likeCnt)
        
        userLiked = lume.userLiked
        likeButton.isLiked = userLiked
    }
    
    private func setupLikeCounter() {
        // Setup the label that displays the number of likes
        likeCountLabel = UILabel()
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.font = UIFont.systemFont(ofSize: 14)
        likeCountLabel.textColor = .white
        view.addSubview(likeCountLabel)
        
        // Setting shadow properties
        likeCountLabel.layer.shadowColor = UIColor.black.cgColor  // Shadow color
        likeCountLabel.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        likeCountLabel.layer.shadowOpacity = 0.25  // Shadow opacity
        likeCountLabel.layer.shadowRadius = 0.25
        
        likeCountLabel.text = formatNumber(lume.likeCnt)
        
        NSLayoutConstraint.activate([
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 3),
            likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor)
        ])
    }
    
    @objc private func toggleLike() {
        userLiked.toggle()
        likeButton.animateLike() // Trigger the animation
        
        lume.likedLume(userLikeInput: userLiked)
        likeCountLabel.text = formatNumber(lume.likeCnt)
    }
    
    private func formatNumber(_ num: Int) -> String {
        let thousand = 1_000
        let million = 1_000_000
        
        if num < thousand {
            return "\(num)"
        } else if num < million {
            return String(format: "%.1fk", Double(num) / Double(thousand))
        } else {
            return String(format: "%.1fm", Double(num) / Double(million))
        }
    }
}

//comment button
extension SideButtonsViewController {
    
    private func setupCommentButton() {
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setImage(UIImage(systemName: "bubble.right.fill"), for: .normal)
        commentButton.tintColor = .white
        
        commentButton.layer.shadowColor = UIColor.black.cgColor
        commentButton.layer.shadowOpacity = 0.25
        commentButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        commentButton.layer.shadowRadius = 0.25
        commentButton.layer.masksToBounds = false
        
        view.addSubview(commentButton)
        
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            commentButton.topAnchor.constraint(equalTo: likeCountLabel.bottomAnchor, constant: buttonPadding),
            commentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 44),
            commentButton.heightAnchor.constraint(equalToConstant: 37),
        ])
        
        commentButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)
    }
    
    @objc private func showComments() {
        // Present or push the comments view controller
        let commentsViewController = CommentsViewController(lume: lume)
        commentsViewController.lume = lume  // assuming CommentsViewController can handle a reel
        navigationController?.pushViewController(commentsViewController, animated: true)
    }
}

//cosmetic button
extension SideButtonsViewController {
    
    private func setupCosmeticButton() {
        
        // Cosmetics Button
        cosmeticsButton.setImage(UIImage(systemName: "cross.vial", withConfiguration: buttonConfig), for: .normal)
        cosmeticsButton.tintColor = .white
        
        cosmeticsButton.layer.shadowColor = UIColor.black.cgColor
        cosmeticsButton.layer.shadowOpacity = 0.25
        cosmeticsButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cosmeticsButton.layer.shadowRadius = 0.25
        cosmeticsButton.layer.masksToBounds = false
        
        view.addSubview(cosmeticsButton)
        
        cosmeticsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cosmeticsButton.topAnchor.constraint(equalTo: likeCountLabel.bottomAnchor, constant: buttonPadding),
            cosmeticsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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

//further button
extension SideButtonsViewController {
    
    private func setupFurtherActionButton() {
        furtherActionButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: buttonConfig), for: .normal)
        furtherActionButton.tintColor = .white
        
        furtherActionButton.layer.shadowColor = UIColor.black.cgColor
        furtherActionButton.layer.shadowOpacity = 0.25
        furtherActionButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        furtherActionButton.layer.shadowRadius = 0.25
        furtherActionButton.layer.masksToBounds = false
        
        view.addSubview(furtherActionButton)

        furtherActionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            furtherActionButton.topAnchor.constraint(equalTo: cosmeticsButton.bottomAnchor, constant: buttonPadding),
            furtherActionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            furtherActionButton.widthAnchor.constraint(equalToConstant: 50),
            furtherActionButton.heightAnchor.constraint(equalToConstant: 22),
        ])

        furtherActionButton.addTarget(self, action: #selector(furtherActionTapped), for: .touchUpInside)
    }
    
    @objc private func furtherActionTapped() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let reportAction = UIAlertAction(title: "報告", style: .destructive) { _ in
            // Handle the report action
            print("Report action selected")
        }
        
        let removeAction = UIAlertAction(title: "Remove current lume", style: .destructive) { _ in
            // Handle removing the current reel
            print("Remove lume action selected")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        actionSheet.addAction(reportAction)
        actionSheet.addAction(removeAction)
        actionSheet.addAction(cancelAction)

        // Present the action sheet
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = furtherActionButton
            popoverController.sourceRect = furtherActionButton.bounds
        }
        present(actionSheet, animated: true)
    }

}



struct SideButtonProfileView: View {
    @ObservedObject var sideButtonsController: SideButtonsViewController
    @State var postUserID: String
    @State private var followButton: Bool = false
    @State private var followAnimation: Bool = false

    var body: some View {
        ZStack {
            if let userProfile = ProfileManager.shared.profiles[postUserID],
               let userIdentityID = GI.shared.identityID,
               postUserID != userIdentityID {
                NavigationLink(destination: OtherUserProfile(identityID: userProfile.identityID, followState: $followButton)) {
                    profileImage(userProfile: userProfile)
                }
                followButtonView(userIdentityID: userIdentityID)
            }
        }
        .onAppear {
            fetchRelationshipStatus()
        }
        .onChange(of: sideButtonsController.refreshProfileView) { _ in
            fetchRelationshipStatus()
        }
    }

    func fetchRelationshipStatus() {
        guard let userIdentityID = GI.shared.identityID else { return }
        DispatchQueue.main.async {
            Task {
                let status = await ProfileManager.shared.getRelationshipStat(fromUserID: userIdentityID, toUserID: postUserID)
                self.followButton = (status == .following) || (status == .mutual)
                self.followAnimation = (status == .following) || (status == .mutual)
            }
        }
    }

    @ViewBuilder
    private func profileImage(userProfile: ProfileSettings) -> some View {
        if let userUiProfile = userProfile.profileImage?.image {
            Image(uiImage: userUiProfile)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
        } else {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 45, height: 45)
                .foregroundColor(.white)
                .background(Color.gray)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
        }
    }

    @ViewBuilder
    private func followButtonView(userIdentityID: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: (followButton ? 20 : 40), height: 20)
                .foregroundColor(followButton ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 0.946, green: 0.76, blue: 0.839))
            Group {
                Text(followButton ? "" : "フォロー")
                    .font(.system(size: 9))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Image(systemName: followButton ? "checkmark" : "")
                    .font(.system(size: 9))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 55)
        .onTapGesture {
            toggleFollow(userIdentityID: userIdentityID)
        }
        .opacity(followAnimation ? 0 : 1)
    }

    private func toggleFollow(userIdentityID: String) {
        ProfileManager.shared.updateFollowingStatus(fromUserID: userIdentityID, toUserID: postUserID, follow: followButton)
        withAnimation {
            followButton.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                followAnimation.toggle()
            }
        }
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
        let newColor = isLiked ? UIColor(red: 0.919, green: 0.767, blue: 0.834, alpha: 1.0) : .white
        setImage(newImage?.withTintColor(newColor, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    func animateLike() {
        isLiked.toggle()
        UIView.animate(withDuration: 0.1, animations: {
            let scale = self.isLiked ? 1.3 : 0.7
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        })
    }
}



struct SideButtonCosmeticsTagView: View {
    
    @State var TagCosmetics: [TagCosmetic]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider() // Adds a visual line
                    .background(Color.clear)

                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(TagCosmetics.indices, id: \.self) { index in
                            SideButtonIndividualTagCosmeticsTagView(TagCosmetic: TagCosmetics[index], showDetails: index == 0)
                        }
                    }
                    .padding(.top, 25)
                }
            }
            .navigationBarTitle(Text("Tagged Cosmetics"), displayMode: .inline)
        }
    }
}

struct SideButtonIndividualTagCosmeticsTagView: View {
    
    @ObservedObject var TagCosmetic: TagCosmetic
    
    @State var cosmetic: Cosmetic?
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showDetails: Bool = false
    @State var showInside: Bool = false
    
    @State private var verticalOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack {
            
            Color.clear
                .onAppear{
                    let CosmeticID = TagCosmetic.cosmeticID
                    cosmetic = CosmeticManager.shared.getCosmetic(withID: CosmeticID)
                }
            
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 3)
                .foregroundColor(colorScheme == .light ? Color.white : Color.black)
            
            VStack{
                
                HStack {
                    if let productImages = cosmetic?.productImages {
                        CardStack(productImages) { item in
                            
                            if let uiItemImage = item.image, uiItemImage != UIImage() {
                                
                                Image(uiImage: uiItemImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(radius: 5)
                                
                            } else {
                                
                                Image(systemName: "cross.vial")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(10)
                                    .padding(.trailing)
                            }
                        }
                        .padding(.trailing)
                        
                    } else {
                        
                        Image(systemName: "cross.vial")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .padding(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text(cosmetic?.productName ?? "null")
                            .font(.title2)
                        
                        Text(cosmetic?.companyID ?? "null")
                            .font(.subheadline)
                        
                        HStack {
                            
                            if cosmetic?.price != "0" {
                                Text("\(cosmetic?.price ?? "null")円")
                                    .font(.callout)
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                            }
                            
                            if cosmetic?.amount != "null" {
                                
                                Text(cosmetic?.amount ?? "null")
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                            }
                            
                            if let link = TagCosmetic.attachedURL,
                                let url = URL(string: link)
                            {
                                Link("URL", destination: url)
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                            }
                            
                            if TagCosmetic.authProduct {
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                    .font(.title2)
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .padding(.leading)
                    
                }
                .padding(.vertical)
                
                if showDetails {
                    HStack{
                        
                        VStack{
                            CircularInfoBar(stat: CGFloat(TagCosmetic.effectRating))
                            Text("効果")
                        }
                        .padding()
                        
                        VStack{
                            CircularInfoBar(stat: CGFloat(TagCosmetic.recommendRating))
                            Text("おすすめ度")
                        }
                        .padding()
                        
                        VStack{
                            VStack{
                                HStack{
                                    Text("肌触り")
                                    Spacer()
                                }
                                HStack{
                                    
                                    Text("ベトベト")
                                    
                                    Spacer()
                                    
                                    Text("サラサラ")
                                }
                                .font(.footnote)
                                LinearInfoBar(stat: CGFloat(TagCosmetic.feelingRating))
                            }
                            
                            VStack{
                                HStack{
                                    Text("落ち具合")
                                    Spacer()
                                }
                                HStack{
                                    
                                    Text("落ちやすい")
                                    
                                    Spacer()
                                    
                                    Text("落ちにくい")
                                }
                                .font(.footnote)
                                LinearInfoBar(stat: CGFloat(TagCosmetic.fadingRating))
                            }
                        }
                        .padding(.bottom)
                    }
                    .font(.footnote)
                    .opacity(showInside ? 1 : 0)
                    .offset(y: verticalOffset)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            withAnimation(showInside ? .easeOut : .easeIn){
                showInside.toggle()
                if showInside {
                    verticalOffset = 0
                } else {
                    verticalOffset = -80
                }
            }
            withAnimation{
                showDetails.toggle()
            }
        }
        .onAppear{
            
            showInside = showDetails
        }
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize your SwiftUI view with the ObservableObject
        let bottomIslandView = BottomIsland(onNavigate: navigateToProfile)
        
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
        let userProfile = ProfileManager.shared.getProfile(withID: GI.shared.identityID!)
        let profileVC = TwitterParallaxViewController(userIdentityID: GI.shared.identityID!, profile: userProfile)
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

struct BottomIsland: View {
    
    var onNavigate: () -> Void

    init(onNavigate: @escaping () -> Void = {}) {
        self.onNavigate = onNavigate
    }
    
    var body: some View {
        
        VStack{
            
            Spacer()
            
            ZStack {
                
                Color.clear
                    .background(.ultraThinMaterial)
                VideoProgressSeekBarBottomIsland(maxWidth: 130)
                .frame(width: 130, height: 40)
                
                HStack {
                    
                    Button(action: onNavigate) {
                        Image(systemName: "person.fill")
                    }
                    .padding(.trailing, 10)
                    
                    NavigationLink(destination: VideoHome()){
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
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
                        .foregroundColor(uploadProgress.completionState == .successful ? .blue : .red)
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
