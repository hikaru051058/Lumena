//
//  PrepPostTagProductsViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/11/20.
//

import Foundation
import UIKit
import SwiftUI

#Preview("PrepPostTagProductsViewRepPreview") {
    PrepPostTagProductsViewRep()
}

struct PrepPostTagProductsViewRep: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> PrepPostTagProductsViewController {
        return PrepPostTagProductsViewController()
    }
    
    func updateUIViewController(_ uiViewController: PrepPostTagProductsViewController, context: Context) {
        // Update the view controller if needed
    }
}

class PrepPostTagProductsViewController: UIViewController, BarcodeScannerProtocol {
    
    private var searchBar: PrepPostTagProductsSearchBar!
    private var customListView: CustomListView!
    private var barcodeScannerVC: BarcodeScannerViewController!
    private var searchBarHeightConstraint: NSLayoutConstraint!
    private var searchBarHeight: CGFloat = 45
    private var previousOffset: CGFloat = 0
    private var isSearchBarFocused: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        setupListView()
        setupSearchBar()
    }
}

extension PrepPostTagProductsViewController: PrepPostTagProductsSearchBarDelegate {
    
    private func setupSearchBar() {
        searchBar = PrepPostTagProductsSearchBar()
        searchBar.delegate = self
        searchBar.backgroundColor = .clear
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: searchBarHeight) // Initial height
        searchBarHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func searchBarDidBeginEditing() {
        isSearchBarFocused = true // Lock the search bar height
        searchBarHeightConstraint.constant = searchBarHeight // Ensure the search bar is fully expanded
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarDidEndEditing() {
        isSearchBarFocused = false // Unlock the search bar height
    }
    
    func searchBarBarcodeTapped() {
        barcodeScannerVC = BarcodeScannerViewController()
        barcodeScannerVC.delegate = self
        barcodeScannerVC.modalPresentationStyle = .pageSheet
        if let sheetController = barcodeScannerVC.sheetPresentationController {
            // Set a custom detent for 40% of the screen height
            let customDetent = UISheetPresentationController.Detent.custom(identifier: .init("40Percent")) { context in
                return context.maximumDetentValue * 0.4 // 40% of the maximum height
            }
            sheetController.detents = [customDetent]
            sheetController.prefersGrabberVisible = true // Shows the grabber at the top
        }
        barcodeScannerVC.sheetPresentationController?.prefersGrabberVisible = true // Shows grabber at the top
        present(barcodeScannerVC, animated: true, completion: nil)
    }
    
    func searchBarSubmitCosmetic() {
        
    }
    
    // for BarcodeScannerViewController
    func didScanBarcode(withCode code: String) {
        // Dismiss the BarcodeScannerViewController
        barcodeScannerVC.dismiss(animated: true) {
            // Replace the search bar's text with the scanned barcode
            self.searchBar.updateSearchText(with: code)
        }
    }
}

extension PrepPostTagProductsViewController: CustomListViewDelegate {
    
    private func setupListView() {
        customListView = CustomListView()
        customListView.delegate = self
        self.view.backgroundColor = .clear
        
        customListView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customListView)
        
        NSLayoutConstraint.activate([
            customListView.topAnchor.constraint(equalTo: view.topAnchor),
            customListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customListView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Sample data
        let sampleData = Array(repeating: (
            productImage: UIImage(systemName: "star"),
            productName: "Sample Product",
            productBrand: "Brand",
            hasLink: true
        ), count: 12)
        
        customListView.updateData(sampleData)
    }
    
    // MARK: - CustomListViewDelegate
    func listViewDidScroll(to yOffset: CGFloat) {
        guard !isSearchBarFocused else { return } // Skip collapsing when focused
        
        let maxSearchBarHeight: CGFloat = searchBarHeight
        let minSearchBarHeight: CGFloat = 0
        
        let tableView = customListView.exposedTableView
        
        if yOffset <= 0 {
            searchBarHeightConstraint.constant = maxSearchBarHeight
        } else if yOffset >= (tableView.contentSize.height - tableView.bounds.height - maxSearchBarHeight) {
            searchBarHeightConstraint.constant = minSearchBarHeight
        } else {
            let isScrollingDown = yOffset > previousOffset
            let isScrollingUp = yOffset < previousOffset
            
            if isScrollingDown {
                searchBarHeightConstraint.constant = max(minSearchBarHeight, searchBarHeightConstraint.constant - abs(yOffset - previousOffset))
            } else if isScrollingUp {
                searchBarHeightConstraint.constant = min(maxSearchBarHeight, searchBarHeightConstraint.constant + abs(yOffset - previousOffset))
            }
        }
        
        searchBar.updateHeight(to: searchBarHeightConstraint.constant)
        
        previousOffset = yOffset
        self.view.layoutIfNeeded()
    }
}


protocol PrepPostTagProductsSearchBarDelegate: AnyObject {
    func searchBarDidBeginEditing()
    func searchBarDidEndEditing()
    func searchBarBarcodeTapped()
    func searchBarSubmitCosmetic()
}

class PrepPostTagProductsSearchBar: UIView, UISearchBarDelegate {
    
    // MARK: - Subviews
    private let searchBar = UISearchBar()
    private let button1 = UIButton(type: .system)
    private let button2 = UIButton(type: .system)
    private let clearButton = UIButton(type: .system) // New clear button
    private let dummyBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) // Apply blur effect
    
    // Height constraint for the dummy background
    private var dummyBackgroundHeightConstraint: NSLayoutConstraint?
    private let maxHeight: CGFloat = 45
    private let visibilityThreshold: CGFloat = 35 // or maxHeight * 0.9
    
    weak var delegate: PrepPostTagProductsSearchBarDelegate? // Delegate property
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupView() {
        searchBar.delegate = self
        
        // Configure Dummy Background View
        dummyBackgroundView.layer.cornerRadius = maxHeight / 2 // Rounded corners for aesthetics
        dummyBackgroundView.layer.masksToBounds = true
        dummyBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dummyBackgroundView)
        
        // Configure Search Bar
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage() // Removes the default background image
        searchBar.searchTextField.backgroundColor = .clear // Make the text field background clear
        searchBar.layer.borderWidth = 0 // Remove border if any
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.clearButtonMode = .never // Disable the X button
        }
        dummyBackgroundView.contentView.addSubview(searchBar)
        
        // Configure Button 1 with vial.viewfinder image
        let config = UIImage.SymbolConfiguration(pointSize: 23, weight: .semibold) // Adjust size of the icon
        button1.setImage(UIImage(systemName: "vial.viewfinder", withConfiguration: config), for: .normal)
        button1.tintColor = UIColor(red: 0.486, green: 0.629, blue: 0.53, alpha: 1.0)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.alpha = 1.0 // Initially visible
        dummyBackgroundView.contentView.addSubview(button1)
        
        // Configure Button 2 with barcode.viewfinder image
        button2.setImage(UIImage(systemName: "barcode.viewfinder", withConfiguration: config), for: .normal)
        button2.tintColor = UIColor(red: 0.486, green: 0.629, blue: 0.53, alpha: 1.0)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.alpha = 1.0 // Initially visible
        button2.addTarget(self, action: #selector(handleBarcodeTap), for: .touchUpInside)
        dummyBackgroundView.contentView.addSubview(button2)
        
        // Configure Clear Button (New)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        clearButton.tintColor = .systemGray
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.alpha = 0.0 // Initially hidden
        clearButton.addTarget(self, action: #selector(handleClearButtonTap), for: .touchUpInside)
        dummyBackgroundView.contentView.addSubview(clearButton)
    }
    
    private func setupConstraints() {
        // Constraints for the Dummy Background
        dummyBackgroundHeightConstraint = dummyBackgroundView.heightAnchor.constraint(equalToConstant: maxHeight)
        dummyBackgroundHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            dummyBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            dummyBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            dummyBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            dummyBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Constraints for Button 2
        NSLayoutConstraint.activate([
            button2.trailingAnchor.constraint(equalTo: dummyBackgroundView.trailingAnchor, constant: -8),
            button2.centerYAnchor.constraint(equalTo: dummyBackgroundView.centerYAnchor),
            button2.widthAnchor.constraint(equalToConstant: 36),
            button2.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Constraints for Button 1
        NSLayoutConstraint.activate([
            button1.trailingAnchor.constraint(equalTo: button2.leadingAnchor, constant: -8),
            button1.centerYAnchor.constraint(equalTo: dummyBackgroundView.centerYAnchor),
            button1.widthAnchor.constraint(equalToConstant: 36),
            button1.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Constraints for the Search Bar
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: dummyBackgroundView.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: button1.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: dummyBackgroundView.topAnchor, constant: 5),
            searchBar.bottomAnchor.constraint(equalTo: dummyBackgroundView.bottomAnchor, constant: -5)
        ])
        
        // Constraints for Clear Button (New)
        NSLayoutConstraint.activate([
            clearButton.trailingAnchor.constraint(equalTo: button2.leadingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: dummyBackgroundView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func updateSearchText(with text: String) {
        searchBar.text = text
        searchBar.delegate?.searchBarTextDidBeginEditing?(searchBar) // Notify delegate about the text change
    }
    
    // Barcode Button Action
    @objc private func handleBarcodeTap() {
        delegate?.searchBarBarcodeTapped() // Notify the delegate
    }
    
    
    // MARK: - UISearchBarDelegate Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarDidBeginEditing() // Notify delegate
        
        // Hide Button 1 and show Clear Button
        UIView.animate(withDuration: 0.3) {
            self.button1.alpha = 0.0
            self.clearButton.alpha = 1.0
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarDidEndEditing() // Notify delegate
        
        // Show Button 1 and hide Clear Button
        UIView.animate(withDuration: 0.3) {
            self.button1.alpha = 1.0
            self.clearButton.alpha = 0.0
        }
    }
    
    // MARK: - Clear Button Action
    @objc private func handleClearButtonTap() {
        searchBar.text = "" // Clear search field
        searchBar.resignFirstResponder() // End editing
        delegate?.searchBarDidEndEditing() // Notify delegate manually
    }
    
    // MARK: - Update Height Function
    func updateHeight(to newHeight: CGFloat) {
        // Update the height constraint of the dummy background view
        dummyBackgroundHeightConstraint?.constant = newHeight
        dummyBackgroundView.layer.cornerRadius = newHeight / 2.0
        self.layoutIfNeeded()
        
        // Define the exponential easing factor
        let normalizedHeight = max(0, min(1, newHeight / maxHeight)) // Normalize height to range [0, 1]
        let exponentialFactor = pow(normalizedHeight, 5) // Exponential easing
        
        // Calculate scale and alpha based on exponential factor
        let scaleFactor = 0.5 + (exponentialFactor * 0.5) // Scale between 0.5 and 1.0
        let buttonAlpha = exponentialFactor // Alpha increases exponentially with height
        
        let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        self.button1.transform = scaleTransform
        self.button2.transform = scaleTransform
        self.button1.alpha = buttonAlpha
        self.button2.alpha = buttonAlpha
        self.searchBar.alpha = buttonAlpha
        self.layoutIfNeeded()
    }
}



// MARK: -- Cosmetic List Cell and List

// MARK: -- Cosmetic List Cell and List

class TagIndividualCosmeticsTagCell: UITableViewCell {
    
    // MARK: - Subviews
    private let containerView = UIView()
    private let productImageView = UIImageView()
    private let productNameLabel = UILabel()
    private let productBrandLabel = UILabel()
    private let linkImageView = UIImageView()
    private let separator = UIView()
    
    var tagState: Bool = false {
        didSet {
            updateContainerBackground()
        }
    }
    
    // Callback for tap gestures
    var onLinkTap: (() -> Void)?
    var onTagToggle: (() -> Void)?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
        addTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        addTapGesture()
    }
    
    // MARK: - Setup
    private func setupView() {
        selectionStyle = .none
        
        // Container View
//        containerView.layer.cornerRadius = 20
//        containerView.layer.shadowRadius = 3
//        containerView.layer.shadowOpacity = 0.1
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Product Image
        productImageView.layer.cornerRadius = 16
        productImageView.layer.shadowRadius = 3
        productImageView.layer.shadowOpacity = 0.1
        productImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        productImageView.clipsToBounds = true
        productImageView.contentMode = .scaleAspectFill
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(productImageView)
        
        // Product Name Label
        productNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(productNameLabel)
        
        // Product Brand Label
        productBrandLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        productBrandLabel.textColor = .gray
        productBrandLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(productBrandLabel)
        
        // Link Image
        linkImageView.image = UIImage(systemName: "link.circle.fill")
        linkImageView.tintColor = UIColor.systemBlue
        linkImageView.isUserInteractionEnabled = true
        linkImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(linkImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            // Product Image
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10), // Top padding
            productImageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10), // Bottom padding
            productImageView.widthAnchor.constraint(equalToConstant: 70),
            productImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Product Name Label
            productNameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            productNameLabel.trailingAnchor.constraint(equalTo: linkImageView.leadingAnchor, constant: -10),
            productNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            // Product Brand Label
            productBrandLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            productBrandLabel.trailingAnchor.constraint(equalTo: productNameLabel.trailingAnchor),
            productBrandLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            productBrandLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            // Link Image
            linkImageView.widthAnchor.constraint(equalToConstant: 25),
            linkImageView.heightAnchor.constraint(equalToConstant: 25),
            linkImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            linkImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func addTapGesture() {
        let tagTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTagToggle))
        containerView.addGestureRecognizer(tagTapGesture)
        
        let linkTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLinkTap))
        linkImageView.addGestureRecognizer(linkTapGesture)
    }
    
    private func updateContainerBackground() {
//        let activeColor = UIColor(red: 0.686, green: 0.817, blue: 0.724, alpha: 1.0)
        let activeColor = UIColor.systemGray5
        let inactiveColor = UIColor.systemBackground
        containerView.backgroundColor = tagState ? activeColor : inactiveColor
    }
    
    // MARK: - Handlers
    @objc private func handleTagToggle() {
        tagState.toggle()
        updateContainerBackground()
        onTagToggle?()
    }
    
    @objc private func handleLinkTap() {
        onLinkTap?()
    }
    
    // MARK: - Configure Cell
    func configure(
        productImage: UIImage?,
        productName: String,
        productBrand: String,
        hasLink: Bool
    ) {
        productImageView.image = productImage ?? UIImage(systemName: "cross.vial")
        productNameLabel.text = productName
        productBrandLabel.text = productBrand
        linkImageView.isHidden = !hasLink
    }
}

protocol CustomListViewDelegate: AnyObject {
    func listViewDidScroll(to yOffset: CGFloat)
}

class CustomListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    
    var exposedTableView: UITableView {
        return tableView
    }
    
    private var data: [(productImage: UIImage?, productName: String, productBrand: String, hasLink: Bool)] = []
    
    weak var delegate: CustomListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TagIndividualCosmeticsTagCell.self, forCellReuseIdentifier: "TagIndividualCosmeticsTagCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        // Add a spacer at the top using tableHeaderView
        let spacerView = UIView()
        spacerView.backgroundColor = .clear // Adjust color if needed
        spacerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45)
        tableView.tableHeaderView = spacerView // Set the spacer as the header view
        
        // Add an extra space at the bottom using contentInset
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0) // Add 50pt space at the bottom

        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func updateData(_ newData: [(productImage: UIImage?, productName: String, productBrand: String, hasLink: Bool)]) {
        data = newData
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagIndividualCosmeticsTagCell", for: indexPath) as? TagIndividualCosmeticsTagCell else {
            return UITableViewCell()
        }
        
        let item = data[indexPath.row]
        cell.configure(
            productImage: item.productImage,
            productName: item.productName,
            productBrand: item.productBrand,
            hasLink: item.hasLink
        )
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.listViewDidScroll(to: scrollView.contentOffset.y)
    }
}
