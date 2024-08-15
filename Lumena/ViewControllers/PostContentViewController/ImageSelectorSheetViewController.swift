//
//  ImageSelectorSheetViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import UIKit
import Photos

class ImageSelectorSheetViewController: UIViewController {
    
    private var verticalImageScrollView: VerticalScrollPhotoLibraryViewController!
    private var horizontalImageScrollView: HorizontalScrollPhotoLibraryViewController!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupHorizontalImageScrollView()
        setupVerticalImageScrollView()
    }
}

extension ImageSelectorSheetViewController {
    
    private func setupHorizontalImageScrollView() {
        horizontalImageScrollView = HorizontalScrollPhotoLibraryViewController()
        addChild(horizontalImageScrollView)
        view.addSubview(horizontalImageScrollView.view)
        horizontalImageScrollView.didMove(toParent: self)
        
        horizontalImageScrollView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            horizontalImageScrollView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            horizontalImageScrollView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            horizontalImageScrollView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (view.frame.height * 0.025)),
            horizontalImageScrollView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (view.frame.height * 0.3)),
        ])
    }
}

extension ImageSelectorSheetViewController: ImageSelectionDelegate {
    
    private func setupVerticalImageScrollView() {
        verticalImageScrollView = VerticalScrollPhotoLibraryViewController()
        verticalImageScrollView.delegate = self
        addChild(verticalImageScrollView)
        view.addSubview(verticalImageScrollView.view)
        verticalImageScrollView.didMove(toParent: self)
        verticalImageScrollView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalImageScrollView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            verticalImageScrollView.view.topAnchor.constraint(equalTo: horizontalImageScrollView.view.bottomAnchor, constant: (view.frame.height * 0.025)),
            verticalImageScrollView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            verticalImageScrollView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func didSelectImages(_ assets: [PHAsset]) {
        // Update the horizontal scroll view to display all selected images
        horizontalImageScrollView.updateWithSelectedImages(assets)
    }
}


// MARK: - VerticalScrollPhotoLibraryViewController

protocol ImageSelectionDelegate: AnyObject {
    func didSelectImages(_ assets: [PHAsset])
}

class VerticalScrollPhotoLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var collectionView: UICollectionView!
    var assets: [PHAsset] = []
    var selectedAssets: Set<PHAsset> = []
    var fetchResult: PHFetchResult<PHAsset>?
    var isLoading = false

    // Configurable properties
    var numberOfItemsPerRow: CGFloat = 3
    var cellSpacing: CGFloat = 2
    var cellHeightRatio: CGFloat = 1.0 // Ratio of height to width for cells
    var cornerRadius: CGFloat = 0.0
    
    weak var delegate: ImageSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        
        // Configure the layout based on the properties
        let layout = UICollectionViewFlowLayout()
        let totalSpacing = (numberOfItemsPerRow - 1) * cellSpacing
        let itemWidth = (view.frame.width - totalSpacing) / numberOfItemsPerRow
        let itemHeight = itemWidth * cellHeightRatio
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        
        // Initialize collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VerticalPhotoLibraryCell.self, forCellWithReuseIdentifier: "PhotoLibraryCell")
        
        // Add collection view to the view controller's view
        view.addSubview(collectionView)
        
        // Request authorization and fetch the first batch of assets
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.initializeFetchResult()
                    self.fetchMoreAssets()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // Initialize the fetch result with all the assets, but do not fetch them all at once
    func initializeFetchResult() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: fetchOptions)
    }

    func fetchMoreAssets() {
        guard let fetchResult = fetchResult else { return }
        guard !isLoading else { return }
        isLoading = true

        let startIndex = assets.count
        let endIndex = min(startIndex + 20, fetchResult.count)
        
        if startIndex < endIndex {
            for i in startIndex..<endIndex {
                assets.append(fetchResult.object(at: i))
            }
            collectionView.reloadData()
        }
        
        isLoading = false
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoLibraryCell", for: indexPath) as! VerticalPhotoLibraryCell
        let asset = assets[indexPath.item]
        cell.configure(with: asset)
        cell.setSelected(selectedAssets.contains(asset))
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
        } else {
            selectedAssets.insert(asset)
        }
        
        collectionView.reloadItems(at: [indexPath])
        delegate?.didSelectImages(Array(selectedAssets))
        
        // Present the full-size image viewer
//        let fullSizeVC = FullSizePhotoViewController()
//        fullSizeVC.assets = assets
//        fullSizeVC.initialIndex = indexPath.item
//        fullSizeVC.modalPresentationStyle = .fullScreen
//        present(fullSizeVC, animated: true, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleHeight = scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        let yOffset = scrollView.contentOffset.y
        
        let threshold = contentHeight - visibleHeight - visibleHeight / 3
        
        if yOffset > threshold && !isLoading {
            fetchMoreAssets()
        }
    }
}

// MARK: - PhotoLibraryCell

class VerticalPhotoLibraryCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let selectionIndicator = UILabel() // A label to show the selection indicator
    
    var cornerRadius: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        
        // Add selection indicator
        selectionIndicator.text = "✓"
        selectionIndicator.textColor = .white
        selectionIndicator.font = UIFont.boldSystemFont(ofSize: 18)
        selectionIndicator.isHidden = true // Initially hidden
        contentView.addSubview(selectionIndicator)
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            selectionIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        let targetSize = CGSize(width: self.bounds.width * 3, height: self.bounds.height * 3)
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, _) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    func setSelected(_ selected: Bool) {
        selectionIndicator.isHidden = !selected
    }
}

// MARK: - FullSizePhotoViewController

class FullSizePhotoViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var assets: [PHAsset] = []
    var initialIndex: Int = 0
    
    var pageViewController: UIPageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        if let initialViewController = viewControllerAtIndex(index: initialIndex) {
            pageViewController.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        // Set constraints to fit the entire screen
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func viewControllerAtIndex(index: Int) -> ImageViewController? {
        if index < 0 || index >= assets.count {
            return nil
        }
        
        let imageViewController = ImageViewController()
        imageViewController.asset = assets[index]
        imageViewController.index = index
        return imageViewController
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? ImageViewController else { return nil }
        var index = viewController.index
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? ImageViewController else { return nil }
        var index = viewController.index
        index += 1
        return viewControllerAtIndex(index: index)
    }
}

// MARK: - ImageViewController

class ImageViewController: UIViewController {

    var asset: PHAsset!
    var index: Int = 0
    
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        displayImage()
    }
    
    func displayImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        let targetSize = UIScreen.main.bounds.size
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}




// MARK: - HorizontalPhotoScrollViewController

class HorizontalScrollPhotoLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var assets: [PHAsset] = []
    var fetchResult: PHFetchResult<PHAsset>?
    var isLoading = false

    // Configurable properties
    var cornerRadius: CGFloat = 24.0 // Corner radius for the images
    var imageSpacing: CGFloat = 12.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background

        // Configure the layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = imageSpacing
        layout.minimumLineSpacing = imageSpacing

        // Initialize collection view without a frame
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HorizontalPhotoLibraryCell.self, forCellWithReuseIdentifier: "PhotoLibraryCell")
        collectionView.backgroundColor = .background
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false // Disable paging
        collectionView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout

        // Add collection view to the view controller's view
        view.addSubview(collectionView)

        // Set constraints for the collection view
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Request authorization and fetch the first batch of assets
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                DispatchQueue.main.async {
//                    self.initializeFetchResult()
//                    self.fetchMoreAssets()
//                }
//            }
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // Initialize the fetch result with all the assets, but do not fetch them all at once
    func initializeFetchResult() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: fetchOptions)
    }

    func fetchMoreAssets() {
        guard let fetchResult = fetchResult else { return }
        guard !isLoading else { return }
        isLoading = true

        let startIndex = assets.count
        let endIndex = min(startIndex + 20, fetchResult.count)

        if startIndex < endIndex {
            for i in startIndex..<endIndex {
                assets.append(fetchResult.object(at: i))
            }
            collectionView.reloadData()
        }

        isLoading = false
    }
    
    func updateWithSelectedImages(_ assets: [PHAsset]) {
        // Update the assets array with the selected images and reload the collection view
        self.assets = assets
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoLibraryCell", for: indexPath) as! HorizontalPhotoLibraryCell
        let asset = assets[indexPath.item]
        cell.configure(with: asset, cornerRadius: cornerRadius)
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight = collectionView.frame.height // Fixed height of the collection view
        let asset = assets[indexPath.item]
        let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let itemWidth = itemHeight * aspectRatio // Calculate width based on aspect ratio
        
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleWidth = scrollView.frame.width
        let contentWidth = scrollView.contentSize.width
        let xOffset = scrollView.contentOffset.x

        let threshold = contentWidth - visibleWidth - visibleWidth / 3

        if xOffset > threshold && !isLoading {
            fetchMoreAssets()
        }
    }
}

class HorizontalPhotoLibraryCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var isImageLoaded: Bool = false // Track if image was successfully loaded
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Scale to fit within the bounds, keeping the aspect ratio
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        // Enable Auto Layout for the imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the imageView within the contentView
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    func configure(with asset: PHAsset, cornerRadius: CGFloat) {
        imageView.layer.cornerRadius = cornerRadius
        loadImage(asset: asset)
    }
    
    private func loadImage(asset: PHAsset) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        let targetSize = CGSize(width: contentView.frame.width * 3, height: contentView.frame.height * 3)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, _) in
            DispatchQueue.main.async {
                if let loadedImage = image {
                    self.imageView.image = loadedImage
                    self.isImageLoaded = true
                } else {
                    self.isImageLoaded = false
                }
            }
        }
    }
    
    func hasImageLoaded() -> Bool {
        return isImageLoaded
    }
}
