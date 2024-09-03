//
//  ImageSelectorSheetViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import UIKit
import Photos

protocol ImageSelectorSheetViewControllerDelegate: AnyObject {
    func didAddSelectedAsset(_ asset: LumeContent)
    func didRemoveSelectedAsset(_ asset: LumeContent)
}

class ImageSelectorSheetViewController: UIViewController {
    
    weak var delegate: ImageSelectorSheetViewControllerDelegate?
    
    private var verticalImageScrollView: VerticalScrollPhotoLibraryViewController!
    private var horizontalImageScrollView: HorizontalScrollPhotoLibraryViewController!
    
    private var horizontalScrollViewHeightConstraint: NSLayoutConstraint!
    private var horizontalScrollViewInitialHeight: CGFloat = 0.0
    
    private var doneButton: UIBarButtonItem!
    
    // Array to hold selected PHAssets
    private var selectedAssets: [PHAsset] = [] {
        didSet {
            updateNavigationBarButtonLabel()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
        setupNavigationBar()
    }
    
    private func setupUI() {
        setupHorizontalImageScrollView()
        setupVerticalImageScrollView()
    }
}

extension ImageSelectorSheetViewController {
    
    private func setupNavigationBar() {
        doneButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.tintColor = .arinBlue
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func doneButtonTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func updateNavigationBarButtonLabel() {
        let buttonTitle = selectedAssets.isEmpty ? "Close" : "Done"
        doneButton.title = buttonTitle
    }
}

extension ImageSelectorSheetViewController {
    
    func addSelectedAsset(_ asset: PHAsset) {
        if !selectedAssets.contains(asset) {
            selectedAssets.append(asset)
            horizontalImageScrollView.updateWithSelectedImages(selectedAssets)
            
//            verticalImageScrollView.updateCellForAsset(asset, setSelected: true)
            
            // Notify the delegate that an asset was added
            if let lumeContent = convertPHAssetToLumeContent(asset) {
                delegate?.didAddSelectedAsset(lumeContent)
            }
            
            // If there are selected assets, set the height to full and hide the label
            horizontalScrollViewHeightConstraint.constant = view.frame.height * 0.3
            horizontalScrollViewInitialHeight = view.frame.height * 0.3
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func removeSelectedAsset(_ asset: PHAsset) {
        if let index = selectedAssets.firstIndex(of: asset) {
            selectedAssets.remove(at: index)
            horizontalImageScrollView.updateWithSelectedImages(selectedAssets)
            
            verticalImageScrollView.updateCellForAsset(asset, setSelected: false)
            
            // Notify the delegate that an asset was removed
            if let lumeContent = convertPHAssetToLumeContent(asset) {
                delegate?.didRemoveSelectedAsset(lumeContent)
            }
            
            // If there are no selected assets, shrink the height and show the label
            if selectedAssets.isEmpty {
                horizontalScrollViewHeightConstraint.constant = view.frame.height * 0.15
                horizontalScrollViewInitialHeight = view.frame.height * 0.15
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

extension ImageSelectorSheetViewController {
    
    private func convertPHAssetToLumeContent(_ asset: PHAsset) -> LumeContent? {
        let localIdentifier = asset.localIdentifier
        
        if asset.mediaType == .video {
            guard let url = getVideoUrl(from: asset) else { return nil }
            let player = AVPlayer(url: url)
            let lumeVideo = LumeVideo(localIdentifier: localIdentifier, player: player)
            lumeVideo.lumeVideoAuth = false
            return .video(lumeVideo)
        } else {
            guard let image = getImage(from: asset) else { return nil }
            let lumeImage = LumeImage(localIdentifier: localIdentifier, image: image)
            lumeImage.lumeImageAuth = false
            return .image(lumeImage)
        }
    }
    
    private func getVideoUrl(from asset: PHAsset) -> URL? {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        var videoUrl: URL?
        let semaphore = DispatchSemaphore(value: 0)
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
            if let urlAsset = avAsset as? AVURLAsset {
                videoUrl = urlAsset.url
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return videoUrl
    }
    
    private func getImage(from asset: PHAsset) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        
        var image: UIImage?
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { result, _ in
            image = result
        }
        
        return image
    }
}

extension ImageSelectorSheetViewController {
    
    private func setupHorizontalImageScrollView() {
        horizontalImageScrollView = HorizontalScrollPhotoLibraryViewController()
        horizontalImageScrollView.delegate = self
        addChild(horizontalImageScrollView)
        view.addSubview(horizontalImageScrollView.view)
        horizontalImageScrollView.didMove(toParent: self)
        
        horizontalImageScrollView.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the height constraint with an initial height
        horizontalScrollViewHeightConstraint = horizontalImageScrollView.view.heightAnchor.constraint(equalToConstant: view.frame.height * 0.15)
        
        NSLayoutConstraint.activate([
            horizontalImageScrollView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            horizontalImageScrollView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            horizontalImageScrollView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),//, constant: (view.frame.height * 0.025)),
            horizontalScrollViewHeightConstraint // Activate the height constraint
        ])
        
        horizontalScrollViewInitialHeight = view.frame.height * 0.15
    }
}

extension ImageSelectorSheetViewController: ImageSelectionDelegate {
    
    func didSelectImage(_ asset: PHAsset) {
        addSelectedAsset(asset)
    }
    
    func didUnselectImage(_ asset: PHAsset) {
        removeSelectedAsset(asset)
    }
    
    func didVerticallyScroll(_ yOffset: CGFloat) {
        DispatchQueue.main.async {
            if self.selectedAssets.isEmpty {
                self.horizontalScrollViewHeightConstraint.constant = (self.horizontalScrollViewInitialHeight - min(yOffset, self.horizontalScrollViewInitialHeight))
            } else {
                self.horizontalScrollViewHeightConstraint.constant = self.view.frame.height * 0.3
            }
        }
    }
    
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
}

// MARK: - VerticalScrollPhotoLibraryViewController

protocol ImageSelectionDelegate: AnyObject {
    func didSelectImage(_ asset: PHAsset)
    func didUnselectImage(_ asset: PHAsset)
    func didVerticallyScroll(_ yOffset: CGFloat)
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
        layout.footerReferenceSize = CGSize(width: view.frame.width, height: UIScreen.main.bounds.height * 0.4)
        
        // Initialize collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VerticalPhotoLibraryCell.self, forCellWithReuseIdentifier: "PhotoLibraryCell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
        
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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }

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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
            footerView.backgroundColor = .clear // You can customize this view as needed
            return footerView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50) // Adjust height as needed
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
            delegate?.didUnselectImage(asset)
        } else {
            selectedAssets.insert(asset)
            delegate?.didSelectImage(asset)
        }
        
        collectionView.reloadItems(at: [indexPath])
        
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
        
        delegate?.didVerticallyScroll(yOffset)
        
        let threshold = contentHeight - visibleHeight - visibleHeight / 3
        
        if yOffset > threshold && !isLoading {
            fetchMoreAssets()
        }
    }
    
    func updateCellForAsset(_ asset: PHAsset, setSelected: Bool) {
        if let index = assets.firstIndex(of: asset) {
            let indexPath = IndexPath(item: index, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? VerticalPhotoLibraryCell {
                cell.setSelected(setSelected)
            }
            
            if setSelected {
                selectedAssets.insert(asset)
            } else {
                selectedAssets.remove(asset)
            }
            
            // Optionally, you can reload the cell to ensure proper UI update
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - PhotoLibraryCell

class VerticalPhotoLibraryCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let selectionIndicator = UILabel() // A label to show the selection indicator
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var cornerRadius: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup imageView
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        
        // Setup blur effect view
        blurEffectView.frame = contentView.bounds
        blurEffectView.layer.cornerRadius = cornerRadius
        blurEffectView.clipsToBounds = true
        blurEffectView.isHidden = true // Initially hidden
        contentView.addSubview(blurEffectView)
        
        // Setup selection indicator
        selectionIndicator.text = "✓"
        selectionIndicator.textColor = .white
        selectionIndicator.font = UIFont.boldSystemFont(ofSize: 18)
        selectionIndicator.isHidden = true // Initially hidden
        contentView.addSubview(selectionIndicator)
        
        // Setup Auto Layout constraints for the selection indicator
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
        DispatchQueue.main.async { [self] in
            blurEffectView.isHidden = !selected
            selectionIndicator.isHidden = !selected
            self.layoutIfNeeded()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Adjust the frames of imageView and blurEffectView to match contentView
        imageView.frame = contentView.bounds
        blurEffectView.frame = contentView.bounds
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

class HorizontalScrollPhotoLibraryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HorizontalPhotoLibraryCellDelegate {

    var collectionView: UICollectionView!
    var assets: [PHAsset] = []
    var fetchResult: PHFetchResult<PHAsset>?
    var isLoading = false
    
    var noImageSelectedLabel: UILabel!

    // Configurable properties
    var cornerRadius: CGFloat = 12.0
    var imageSpacing: CGFloat = 12.0
    
    weak var delegate: ImageSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupNoImageSelectedLabel()
//        fetchInitialAssets()
    }
    
    private func setupCollectionView() {

        // Configure the layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = imageSpacing
        layout.minimumLineSpacing = imageSpacing
        
        // Add padding at the front and back
        let padding: CGFloat = 16.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)

        // Initialize collection view without a frame
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HorizontalPhotoLibraryCell.self, forCellWithReuseIdentifier: "PhotoLibraryCell")
//        collectionView.backgroundColor = .background
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
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
    
    private func setupNoImageSelectedLabel() {
        noImageSelectedLabel = UILabel()
        noImageSelectedLabel.text = "No image has been selected"
        noImageSelectedLabel.textColor = .gray
        noImageSelectedLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noImageSelectedLabel.textAlignment = .center
        noImageSelectedLabel.isHidden = false
        noImageSelectedLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(noImageSelectedLabel)
        
        NSLayoutConstraint.activate([
            noImageSelectedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noImageSelectedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Initialize the fetch result with all the assets, but do not fetch them all at once
    func initializeFetchResult() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: fetchOptions)
    }
    
    func fetchInitialAssets() {
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
        DispatchQueue.main.async {
            self.assets = assets
            self.noImageSelectedLabel.isHidden = !assets.isEmpty
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoLibraryCell", for: indexPath) as! HorizontalPhotoLibraryCell
        let asset = assets[indexPath.item]
        cell.delegate = self
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

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let visibleWidth = scrollView.frame.width
//        let contentWidth = scrollView.contentSize.width
//        let xOffset = scrollView.contentOffset.x
//
//        let threshold = contentWidth - visibleWidth - visibleWidth / 3
//
//        if xOffset > threshold && !isLoading {
//            fetchMoreAssets()
//        }
//    }
    
    func didUnselectAsset(asset: PHAsset) {
        delegate?.didUnselectImage(asset)
    }
}

protocol HorizontalPhotoLibraryCellDelegate: AnyObject {
    func didUnselectAsset(asset: PHAsset)
}

class HorizontalPhotoLibraryCell: UICollectionViewCell {

    private var imageView: UIImageView!
    private var closeButton: UIButton!
    private var asset: PHAsset?
    private var cornerRadius: CGFloat = 24.0
    
    weak var delegate: HorizontalPhotoLibraryCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupCloseButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupCloseButton() {
        closeButton = UIButton(type: .custom)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 12
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        contentView.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with asset: PHAsset, cornerRadius: CGFloat) {
        self.asset = asset
        self.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        setNeedsLayout()  // Trigger layout update to load the image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let asset = asset {
            loadImage(asset: asset)
        }
    }
    
    @objc private func closeButtonTapped() {
        if let asset = self.asset {
            delegate?.didUnselectAsset(asset: asset)
        } else {
            print("No PHAsset to remove from the Horizontal Scroll")
        }
    }
    
    private func loadImage(asset: PHAsset, targetSize: CGSize? = nil) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .opportunistic // Allows the system to provide the image in stages, if necessary

        // Set the initial target size if not provided
        let initialTargetSize = CGSize(width: self.contentView.frame.width * 2, height: self.contentView.frame.height * 2)
        let currentTargetSize = targetSize ?? initialTargetSize

        imageManager.requestImage(for: asset, targetSize: currentTargetSize, contentMode: .aspectFill, options: options) { [weak self] (image, _) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let loadedImage = image {
                    self.imageView.image = loadedImage
                    self.imageView.layer.cornerRadius = self.cornerRadius
                    self.imageView.clipsToBounds = true
                    self.imageView.isHidden = false
                } else {
                    if currentTargetSize.width > 100 && currentTargetSize.height > 100 {
                        // Retry with a smaller target size
                        let smallerTargetSize = CGSize(width: currentTargetSize.width / 2, height: currentTargetSize.height / 2)
                        print("Retrying with smaller target size: \(smallerTargetSize)")
                        self.loadImage(asset: asset, targetSize: smallerTargetSize)
                    } else {
                        // Final fallback if the image still fails to load
                        self.imageView.isHidden = true
                        print("Could not show image for asset \(asset.localIdentifier) even after resizing.")
                    }
                }
            }
        }
    }
}
