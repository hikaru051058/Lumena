//
//  PrepPostRatingViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/11/23.
//

import Foundation
import UIKit
import SwiftUI

#Preview("PrepPostRatingViewRepPreview") {
    PrepPostRatingViewRep()
}

struct PrepPostRatingViewRep: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> PrepPostRatingViewController {
        return PrepPostRatingViewController()
    }
    
    func updateUIViewController(_ uiViewController: PrepPostRatingViewController, context: Context) {
        // Update the view controller if needed
    }
}

class PrepPostRatingViewController: UIViewController {
    
    private var customListView: RatingListView!
    private var searchBar: PrepPostRatingProductsSearchBar!
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

extension PrepPostRatingViewController: PrepPostRatingProductsSearchBarDelegate {
    
    private func setupSearchBar() {
        searchBar = PrepPostRatingProductsSearchBar()
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
}

extension PrepPostRatingViewController: RatingListViewDelegate {
    
    private func setupListView() {
        customListView = RatingListView()
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
        let sampleData: [(productImage: UIImage?, productName: String, productBrand: String, sliders: [RatingSliderView3])] = (1...12).map { index in
            let slider1 = RatingSliderView3(
                frame: .zero,
                configuration: RatingSliderConfiguration(
                    tagCosmeticID: "cosmeticID\(index)",
                    title: "Effectiveness",
                    maxWidth: 300,
                    minRatingText: "Low",
                    maxRatingText: "High"
                )
            )
            
            let slider2 = RatingSliderView3(
                frame: .zero,
                configuration: RatingSliderConfiguration(
                    tagCosmeticID: "cosmeticID\(index)",
                    title: "Recommendation",
                    maxWidth: 300,
                    minRatingText: "1",
                    maxRatingText: "5"
                )
            )
            
            return (
                productImage: UIImage(systemName: "star"),
                productName: "Sample Product \(index)",
                productBrand: "Brand \(index)",
                sliders: [slider1, slider2]
            )
        }
        
        customListView.updateData(sampleData)
    }
    
    func listViewDidScroll(to yOffset: CGFloat) {
        guard !isSearchBarFocused else { return } // Skip collapsing when focused
        
        let maxSearchBarHeight: CGFloat = searchBarHeight
        let minSearchBarHeight: CGFloat = 0
        
//        let tableView = customListView.exposedTableView
        
        if yOffset <= 0 {
            searchBarHeightConstraint.constant = maxSearchBarHeight
//        } else if yOffset >= (tableView.contentSize.height - tableView.bounds.height - maxSearchBarHeight) {
//            searchBarHeightConstraint.constant = minSearchBarHeight
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

protocol PrepPostRatingProductsSearchBarDelegate: AnyObject {
    func searchBarDidBeginEditing()
    func searchBarDidEndEditing()
}

class PrepPostRatingProductsSearchBar: UIView, UISearchBarDelegate {
    
    // MARK: - Subviews
    private let searchBar = UISearchBar()
    private let clearButton = UIButton(type: .system) // New clear button
    private let dummyBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) // Apply blur effect
    
    // Height constraint for the dummy background
    private var dummyBackgroundHeightConstraint: NSLayoutConstraint?
    private let maxHeight: CGFloat = 45
    private let visibilityThreshold: CGFloat = 35 // or maxHeight * 0.9
    
    weak var delegate: PrepPostRatingProductsSearchBarDelegate? // Delegate property
    
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
            clearButton.trailingAnchor.constraint(equalTo: dummyBackgroundView.trailingAnchor, constant: -8),
            clearButton.centerYAnchor.constraint(equalTo: dummyBackgroundView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 36),
            clearButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Constraints for the Search Bar
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: dummyBackgroundView.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: dummyBackgroundView.topAnchor, constant: 5),
            searchBar.bottomAnchor.constraint(equalTo: dummyBackgroundView.bottomAnchor, constant: -5)
        ])
    }
    
    func updateSearchText(with text: String) {
        searchBar.text = text
        searchBar.delegate?.searchBarTextDidBeginEditing?(searchBar) // Notify delegate about the text change
    }
    
    // MARK: - UISearchBarDelegate Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarDidBeginEditing() // Notify delegate
        
        // Hide Button 1 and show Clear Button
        UIView.animate(withDuration: 0.3) {
            self.clearButton.alpha = 1.0
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        delegate?.searchBarDidEndEditing() // Notify delegate
        
        // Show Button 1 and hide Clear Button
        UIView.animate(withDuration: 0.3) {
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
        let buttonAlpha = exponentialFactor // Alpha increases exponentially with height
        
        self.searchBar.alpha = buttonAlpha
        self.layoutIfNeeded()
    }
}


// MARK: -- Cosmetic List Cell and List

/*class TagIndividualCosmeticsRatingCell: UITableViewCell {
    
    // MARK: - Subviews
    private let containerView = UIView()
    private let productImageView = UIImageView()
    private let productNameLabel = UILabel()
    private let productBrandLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let sliderStackView = UIStackView()
    private let separator = UIView()
    
    private var containerBottomConstraint: NSLayoutConstraint?
    private var sliderBottomConstraint: NSLayoutConstraint?
    
    private var bottomHeight: CGFloat = 40
    private var topHeight: CGFloat = 90
    
    var isExpanded: Bool = false {
        didSet {
            updateCellExpansion()
        }
    }
    
    // Callback for toggle button
    var onToggleExpansion: (() -> Void)?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        selectionStyle = .none
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Product Image
        productImageView.layer.cornerRadius = 16
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
        
        // Toggle Button
        toggleButton.setTitle("^", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleExpansion), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toggleButton)
        
        // Slider Stack View
        sliderStackView.axis = .horizontal
        sliderStackView.distribution = .fillEqually
        sliderStackView.spacing = 10
        sliderStackView.isHidden = true // Hidden initially
        sliderStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add sliders to stack view
        for _ in 1...4 {
            let slider = UISlider()
            sliderStackView.addArrangedSubview(slider)
        }
        containerView.addSubview(sliderStackView)
    }
    
    private func setupConstraints() {
        
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerBottomConstraint?.isActive = true
        
        sliderBottomConstraint = sliderStackView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: topHeight)
        sliderBottomConstraint?.isActive = true
        

        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Product Image
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            productImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            productImageView.widthAnchor.constraint(equalToConstant: 70),
            productImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Product Name Label
            productNameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            productNameLabel.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10),
            productNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            // Product Brand Label
            productBrandLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            productBrandLabel.trailingAnchor.constraint(equalTo: productNameLabel.trailingAnchor),
            productBrandLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            productBrandLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            // Toggle Button
            toggleButton.widthAnchor.constraint(equalToConstant: 25),
            toggleButton.heightAnchor.constraint(equalToConstant: 25),
            toggleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            toggleButton.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),
            
            // Slider Stack View
            sliderStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            sliderStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            sliderStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topHeight + 20),
        ])
    }
    
    // MARK: - Toggle Expansion
    @objc private func toggleExpansion() {
        isExpanded.toggle()
        onToggleExpansion?()
    }
    
    private func updateCellExpansion() {
        sliderStackView.isHidden = !isExpanded
        
        // Adjust the bottom constraint for animation
        containerBottomConstraint?.constant = isExpanded ?  -(bottomHeight + 10) : 0
        sliderBottomConstraint?.constant = isExpanded ? topHeight : 0 // Adjust height when expanded or collapsed
        
        // Update toggle button title
        toggleButton.setTitle(isExpanded ? "v" : "^", for: .normal)
        
        // Animate layout changes
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    
    // MARK: - Configure Cell
    func configure(
        productImage: UIImage?,
        productName: String,
        productBrand: String
    ) {
        productImageView.image = productImage ?? UIImage(systemName: "cross.vial")
        productNameLabel.text = productName
        productBrandLabel.text = productBrand
    }
}*/

class TagIndividualCosmeticsRatingCell: UITableViewCell {
    
    // MARK: - Subviews
    private let containerView = UIView()
    private let productImageView = UIImageView()
    private let productNameLabel = UILabel()
    private let productBrandLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let sliderStackView = UIStackView()
    private let separator = UIView()
    
    private var containerBottomConstraint: NSLayoutConstraint?
    private var sliderBottomConstraint: NSLayoutConstraint?
    
    private var bottomHeight: CGFloat = 90
    private var topHeight: CGFloat = 90
    
    var isExpanded: Bool = false {
        didSet {
            updateCellExpansion()
        }
    }
    
    // Callback for toggle button
    var onToggleExpansion: (() -> Void)?
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        selectionStyle = .none
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Product Image
        productImageView.layer.cornerRadius = 16
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
        
        // Toggle Button
        toggleButton.setTitle("^", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleExpansion), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toggleButton)
        
        // Slider Stack View
        sliderStackView.axis = .vertical
        sliderStackView.distribution = .fill
        sliderStackView.spacing = 15
        sliderStackView.isHidden = true // Hidden initially
        sliderStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sliderStackView)
    }
    
    private func setupConstraints() {
        
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        containerBottomConstraint?.isActive = true
        
        sliderBottomConstraint = sliderStackView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: topHeight)
        sliderBottomConstraint?.isActive = true
        

        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Product Image
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            productImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            productImageView.widthAnchor.constraint(equalToConstant: 70),
            productImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Product Name Label
            productNameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            productNameLabel.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10),
            productNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            
            // Product Brand Label
            productBrandLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            productBrandLabel.trailingAnchor.constraint(equalTo: productNameLabel.trailingAnchor),
            productBrandLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            productBrandLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10),
            
            // Toggle Button
            toggleButton.widthAnchor.constraint(equalToConstant: 25),
            toggleButton.heightAnchor.constraint(equalToConstant: 25),
            toggleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            toggleButton.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),
            
            // Slider Stack View
            sliderStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            sliderStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            sliderStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topHeight + 20),
        ])
    }
    
    @objc private func toggleExpansion() {
        isExpanded.toggle()
        onToggleExpansion?()
    }
    
    private func updateCellExpansion() {
        sliderStackView.isHidden = !isExpanded
        
        // Adjust the bottom constraint for animation
        containerBottomConstraint?.constant = isExpanded ? -(bottomHeight + 10) : 0
        
        // Update toggle button title
        toggleButton.setTitle(isExpanded ? "v" : "^", for: .normal)
        
        // Animate layout changes
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Configure Cell
    func configure(
        productImage: UIImage?,
        productName: String,
        productBrand: String,
        ratingSliders: [RatingSliderView3]
    ) {
        productImageView.image = productImage ?? UIImage(systemName: "cross.vial")
        productNameLabel.text = productName
        productBrandLabel.text = productBrand
        
        // Clear existing sliders
        sliderStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new sliders
        for slider in ratingSliders {
            sliderStackView.addArrangedSubview(slider)
        }
    }
} 



protocol RatingListViewDelegate: AnyObject {
    func listViewDidScroll(to yOffset: CGFloat)
}

class RatingListView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    
    var exposedTableView: UITableView {
        return tableView
    }
    
    private var data: [(productImage: UIImage?, productName: String, productBrand: String, sliders: [RatingSliderView3])] = []
    
    weak var delegate: RatingListViewDelegate?
    
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
        tableView.register(TagIndividualCosmeticsRatingCell.self, forCellReuseIdentifier: "TagIndividualCosmeticsRatingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = UITableView.automaticDimension
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

    func updateData(_ newData: [(productImage: UIImage?, productName: String, productBrand: String, sliders: [RatingSliderView3])]) {
        data = newData
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagIndividualCosmeticsRatingCell", for: indexPath) as? TagIndividualCosmeticsRatingCell else {
            return UITableViewCell()
        }
        
        let item = data[indexPath.row]
        cell.configure(
            productImage: item.productImage,
            productName: item.productName,
            productBrand: item.productBrand,
            ratingSliders: item.sliders
        )
        
        cell.onToggleExpansion = { [weak tableView] in
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.listViewDidScroll(to: scrollView.contentOffset.y)
    }
}
