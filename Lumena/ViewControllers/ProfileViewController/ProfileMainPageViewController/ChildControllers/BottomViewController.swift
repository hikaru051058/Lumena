//
//  BottomViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/27.
//

import UIKit
import XLPagerTabStrip

class BottomViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: Constants

    private enum Constants {
        static let numberOfRows = 3
        static let sectionInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        static let interItemSpacing: CGFloat = 2
        static let lineSpacing: CGFloat = 2
    }
    
    private var headerSpace: Bool = false // for header to identify the space
    
    let refresh = UIRefreshControl()

    // MARK: Typealiases

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Lume>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Lume>

    // MARK: UI properties

    private let transitionAnimator = SharedTransitionAnimator()
    private lazy var dataSource = DataSource(collectionView: collectionView, cellProvider: cellProvider)
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private lazy var layout = UICollectionViewFlowLayout().then {
        $0.sectionInset = Constants.sectionInset
        $0.minimumLineSpacing = Constants.lineSpacing
        $0.minimumInteritemSpacing = Constants.interItemSpacing
    }
    
    private let noContentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Lume Yet!"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let noContentSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a Lume and share it with friends!"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: Private properties

    var selectedIndexPath: IndexPath? = nil
    private var lumes = [Lume]() {
        didSet {
            updateCollectionView()
            updateNoContentLabelsVisibility()
        }
    }

    var pageIndex: Int = 0
    var pageTitle: String?
    var currentTabIndex: Int = 0
    var profile: ProfileSettings!
    
    init(profile: ProfileSettings?, lumes: [Lume] = [], headerSpace: Bool = false) {
        self.profile = profile
        self.headerSpace = headerSpace
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .background
        setupUI()
        self.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func updateProfile(profile: ProfileSettings) {
        self.profile = profile
        collectionView.layoutIfNeeded()
        self.fetchData()
        view.layoutIfNeeded()
    }
}

// MARK: - Helpers

extension BottomViewController {
    private func setupUI() {
        setupView()
        setupCollectionView()
        setupNoContentLabels()
    }

    private func setupView() {
        view.backgroundColor = .background
    }

    private func setupCollectionView() {
        collectionView.then {
            view.addSubview($0)
            $0.register(ProfileCell.self)
            $0.dataSource = dataSource
            $0.delegate = self
            $0.delaysContentTouches = false
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }
        
        collectionView.layoutIfNeeded()
    }
    
    private func fetchData() {
        switch pageIndex {
        case 0:
            lumes = profile.returnUserLumes()
        case 1:
            lumes = profile.returnUserLikedLumes()
        default:
            break
        }
        updateCollectionView()
    }
}


// MARK: - RefreshDelegate

extension BottomViewController: RefreshDelegate {
    func didStartRefreshing() {
        print("Started refreshing in BottomViewController")
        DispatchQueue.main.async {
            self.fetchData()
        }
    }
    
    func didEndRefreshing() {
        print("Ended refreshing in BottomViewController")
    }
}

// MARK: - UICollectionView helpers

extension BottomViewController {
    private func updateCollectionView() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(lumes, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private var cellProvider: DataSource.CellProvider {
        { [unowned self] collectionView, indexPath, _ in
            let cell = collectionView.dequeuCellOfType(ProfileCell.self, for: indexPath)
            let lume = lumes[indexPath.row]
            cell.setup(with: lume)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension BottomViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let lume = lumes[indexPath.item]
        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileCell,
           let thumbnailURL = cell.thumbnailURL {
            let viewController = DetailScreen(lumes: lumes, currentLumePostID: lume.postID, thumbnailURL: thumbnailURL, fitOrFill: cell.fitOrFill, heightScale: cell.heightScale)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout methods

extension BottomViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacingWidth = CGFloat(Constants.numberOfRows - 1) * Constants.interItemSpacing
        let contentWidth = collectionView.frame.inset(by: Constants.sectionInset).width
        let availableWidth = contentWidth - spacingWidth
        let size = availableWidth / CGFloat(Constants.numberOfRows)
        return CGSize(width: size, height: size)
    }
}

// MARK: - UINavigationControllerDelegate

extension BottomViewController {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Return nil if the delegate is not BottomViewController
        if !(navigationController.delegate is BottomViewController) {
            return nil
        }

        if operation == .push || operation == .pop {
            return transitionAnimator
        }
        return nil
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // Return nil if the delegate is not BottomViewController
        if !(navigationController.delegate is BottomViewController) {
            return nil
        }

        return nil
    }
}

// MARK: - SharedTransitioning

extension BottomViewController: SharedTransitioning {
    var sharedFrame: CGRect {
        guard let selectedIndexPath = selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath),
              let frame = cell.frameInWindow else {
            return .zero
        }
        return frame
    }

    func prepare(for transition: SharedTransitionAnimator.Transition) {
        guard transition == .pop, let selectedIndexPath else { return }
        collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
        collectionView.layoutIfNeeded()
    }
}

extension BottomViewController {
    
    private func setupNoContentLabels() {
        guard !headerSpace else { return }
        view.addSubview(noContentTitleLabel)
        view.addSubview(noContentSubtitleLabel)
        NSLayoutConstraint.activate([
            noContentTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noContentTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            noContentSubtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noContentSubtitleLabel.topAnchor.constraint(equalTo: noContentTitleLabel.bottomAnchor, constant: 8)
        ])
        noContentTitleLabel.isHidden = true
        noContentSubtitleLabel.isHidden = true
        
        updateNoContentLabelsVisibility()
    }

    private func updateNoContentLabelsVisibility() {
        guard !headerSpace else { return }
        
        let isEmpty = lumes.isEmpty
        noContentTitleLabel.isHidden = !isEmpty
        noContentSubtitleLabel.isHidden = !isEmpty
    }
}


// MARK: - IndicatorInfoProvider

extension BottomViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: pageTitle ?? "Tab \(pageIndex)")
    }
}
