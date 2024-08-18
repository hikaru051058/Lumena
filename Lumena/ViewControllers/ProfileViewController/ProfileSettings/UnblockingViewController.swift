//
//  UnblockingViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/18.
//

import Foundation
import UIKit
import SwiftUI

struct UnblockViewControllerPreview: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UnblockViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct UnblockViewController_PreviewProvider: PreviewProvider {
    static var previews: some View {
        UnblockViewControllerPreview()
            .edgesIgnoringSafeArea(.all)
    }
}

class UnblockViewController: UIViewController {

    private var toolbarView: UnblockToolbarView!
    private var unblockListViewController: UnblockListViewController!
    
    var userIdentityID: String = ""
    
    init(userIdentityID: String = "") {
        self.userIdentityID = userIdentityID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupUnblockListViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBlockingUsers()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        addToolbarView()
    }

    private func addToolbarView() {
        toolbarView = UnblockToolbarView()
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        toolbarView.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        view.addSubview(toolbarView)

        NSLayoutConstraint.activate([
            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Setup Unblock List View

    private func setupUnblockListViewController() {
        unblockListViewController = UnblockListViewController(userIdentityID: userIdentityID)
        addChild(unblockListViewController)
        view.addSubview(unblockListViewController.view)
        unblockListViewController.didMove(toParent: self)
        
        unblockListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unblockListViewController.view.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
            unblockListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            unblockListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            unblockListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Fetch Blocking Users
    
    private func fetchBlockingUsers() {
        DispatchQueue.main.async { [self] in
            unblockListViewController.startLoading()
            Task {
                let blockingUsers = await ProfileManager.shared.returnBlockingUsers()
                unblockListViewController.updateBlockingUsers(users: blockingUsers)
            }
        }
    }
}

class UnblockToolbarView: UIView {

    private var stackView: UIStackView!
    private var backButton: UIButton!
    private var titleLabel: UILabel!

    private let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
    private let buttonTextConfig = UIFont.systemFont(ofSize: 18, weight: .bold)
    
    var addShadow: Bool = false

    var onBackButtonTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        self.backgroundColor = .systemBackground
        
        setupBackButton()
        
        stackView = UIStackView(arrangedSubviews: [backButton, createFlexibleSpace()])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupTitleLabel()
    }

    private func setupBackButton() {
        backButton = createButton(action: #selector(backButtonTapped), imageName: "chevron.backward", buttonLabel: "", tintColor: UIColor.arinDarkGreen, shadow: addShadow, buttonTextConfig: buttonTextConfig, buttonImageConfig: buttonImageConfig)
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("Blocked Users", comment: "")
        titleLabel.font = buttonTextConfig
        titleLabel.textColor = .arinDarkGreen
        titleLabel.textAlignment = .center
        
        stackView.addSubview(titleLabel)
                
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
        ])
    }

    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
    
    private func createButton(action: Selector, imageName: String, buttonLabel: String, tintColor: UIColor, shadow: Bool, buttonTextConfig: UIFont, buttonImageConfig: UIImage.SymbolConfiguration) -> UIButton {
        let button = UIButton()
        if imageName == "" {
            button.setTitle(buttonLabel, for: .normal)
            button.setTitleColor(tintColor, for: .normal)
            button.titleLabel?.font = buttonTextConfig
        } else {
            if let image = UIImage(systemName: imageName, withConfiguration: buttonImageConfig) {
                button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }

        button.contentMode = .scaleAspectFit
        button.tintColor = tintColor
        button.addTarget(self, action: action, for: .touchUpInside)

        if shadow {
            addShadow(to: button)
        }

        return button
    }

    private func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 2
    }

    private func createFlexibleSpace() -> UIView {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        return space
    }
}

class UnblockListViewController: UITableViewController, UnblockTableViewCellDelegate {
    
    private var blockingUsers: [ProfileSettings] = []
    var userIdentityID: String
    
    init(userIdentityID: String) {
        self.userIdentityID = userIdentityID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Activity indicator (spinner) for loading
    private let loadingSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // Label for empty state (no blocking users)
    private let noUsersLabel: UILabel = {
        let label = UILabel()
        label.text = "No blocked users"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActivityIndicator()
        setupNoUsersLabel()
        tableView.register(UnblockTableViewCell.self, forCellReuseIdentifier: "UnblockCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.separatorStyle = .none
        
        startLoading() // Start the loading indicator
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupActivityIndicator() {
        view.addSubview(loadingSpinner)
        
        NSLayoutConstraint.activate([
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNoUsersLabel() {
        view.addSubview(noUsersLabel)
        
        NSLayoutConstraint.activate([
            noUsersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noUsersLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Initially hidden
        noUsersLabel.isHidden = true
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockingUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnblockCell", for: indexPath) as! UnblockTableViewCell
        let profile = blockingUsers[indexPath.row]
        cell.delegate = self
        cell.configureCell(profile: profile) // Configure the cell with profile data
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle the cell tap event if needed
    }
    
    // MARK: - Update User Cells
    
    func updateBlockingUsers(users: [ProfileSettings]) {
        DispatchQueue.main.async {
            self.blockingUsers = users
            self.tableView.reloadData()
            self.loadingSpinner.stopAnimating()
            
            // Show empty state if no users
            self.noUsersLabel.isHidden = !self.blockingUsers.isEmpty
            
            self.view.layoutIfNeeded()
        }
    }
    
    func startLoading() {
        DispatchQueue.main.async {
            self.loadingSpinner.startAnimating()
            self.noUsersLabel.isHidden = true
        }
    }
    
    func unblockUser(_ cellUserIdentityID: String) {
        let unblockAlert = UIAlertController(
            title: NSLocalizedString("ブロック解除しますか？", comment: ""),
            message: NSLocalizedString("ブロック解除した場合、相手の投稿やアカウントが表示されるようになります。また、相手のアカウントにもあなたのアカウントが表示されるようになります。", comment: ""),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("キャンセル", comment: ""),
            style: .cancel
        )
        
        let unblockAction = UIAlertAction(
            title: NSLocalizedString("解除", comment: ""),
            style: .default
        ) { [self] _ in
            DispatchQueue.main.async {
                Task {
                    do {
                        // Assuming you have the fromUserID and toUserID available
                        try await ProfileManager.shared.unblockUser(fromUserID: self.userIdentityID, toUserID: cellUserIdentityID)
                        
                        // Update the UI after unblocking
                        self.blockingUsers.removeAll { $0.identityID == cellUserIdentityID }
                        self.tableView.reloadData()
                        
                        if self.blockingUsers.isEmpty {
                            self.noUsersLabel.isHidden = false
                        }
                        
                        self.view.layoutIfNeeded()
                        
                    } catch {
                        print("Failed to unblock user: \(error)")
                    }
                }
            }
        }
        
        unblockAlert.addAction(cancelAction)
        unblockAlert.addAction(unblockAction)
        present(unblockAlert, animated: true, completion: nil)
    }
}

protocol UnblockTableViewCellDelegate: AnyObject {
    func unblockUser(_ cellUserIdentityID: String)
}

class UnblockTableViewCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit  // Use .scaleAspectFit for consistent aspect ratio
        imageView.image = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 45.0 / 2.0
        imageView.tintColor = .arinDarkGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        return imageView
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userIdLabel: UILabel = {
        let label = UILabel()
        label.text = "@userID"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var unblockButton: UIButton!
    
    private var cellUserIdentityID: String = ""
    
    weak var delegate: UnblockTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellLayout() {
        setupUnblockButton()
        
        let stackView = UIStackView(arrangedSubviews: [usernameLabel, userIdLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(unblockButton)
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 38.5),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            unblockButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unblockButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12)
        ])
    }
    
    private func setupUnblockButton() {
        unblockButton = UIButton(type: .system)
        unblockButton.setTitle("Unblock", for: .normal)
        unblockButton.configuration = .tinted()
        unblockButton.tintColor = .arinDarkGreen
        unblockButton.translatesAutoresizingMaskIntoConstraints = false
        unblockButton.addTarget(self, action: #selector(unblockPressed), for: .touchUpInside)
    }
    
    func configureCell(profile: ProfileSettings) {
        if let image = profile.profileImage?.image {
            profileImageView.image = image
            profileImageView.layer.cornerRadius = 40 / 2.0
            profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
            profileImageView.layer.cornerRadius = 45 / 2.0
            profileImageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        usernameLabel.text = profile.givenName
        userIdLabel.text = "@\(profile.preferredUsername)"
        cellUserIdentityID = profile.identityID
        
        self.layoutIfNeeded()
    }
    
    @objc func unblockPressed() {
        delegate?.unblockUser(cellUserIdentityID)
    }
}
