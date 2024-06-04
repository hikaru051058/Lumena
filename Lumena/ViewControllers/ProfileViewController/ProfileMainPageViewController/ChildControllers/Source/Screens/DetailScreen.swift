import UIKit


class DetailScreen: UIViewController {

    // MARK: Private properties

    private var lumes: [Lume]
    private var currentLumePostID: String = ""
    var selectedIndexPath: IndexPath?

    // MARK: UI Properties

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = ImageView()
    
    var lumeVerticalScroll: LumeVerticalInfiniteScrollViewController!
    private lazy var recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    var transitionAnimator = SharedTransitionAnimator()
    private var interactionController: SharedTransitionInteractionController?
    
    var thumbnailURL: URL?
    var fitOrFill: UIView.ContentMode

    // MARK: Init

    init(lumes: [Lume], currentLumePostID: String, thumbnailURL: URL, fitOrFill: UIView.ContentMode) { // Updated
        self.lumes = lumes
        self.currentLumePostID = currentLumePostID
        self.thumbnailURL = thumbnailURL // Updated
        self.fitOrFill = fitOrFill // Updated
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DetailScreen - viewDidLoad")
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .background
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("DetailScreen - viewDidAppear")
        navigationController?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            if let bottomVC = navigationController?.viewControllers.last as? BottomViewController {
                let currentVisibleIndexPath = lumeVerticalScroll.getCurrentVisibleIndexPath()
                bottomVC.selectedIndexPath = currentVisibleIndexPath
            }
        }
    }
}

// MARK: - Setup

extension DetailScreen {
    private func setupUI() {
        print("DetailScreen - setupUI")
        setupView()
        setupImageView()
//        setupLumeVerticalSrollViewController()
    }

    private func setupView() {
        print("DetailScreen - setupView")
        view.backgroundColor = .background
        view.addGestureRecognizer(recognizer)
        recognizer.delegate = self
    }
    
    private func setupLumeVerticalSrollViewController() {
        lumeVerticalScroll = LumeVerticalInfiniteScrollViewController(lumes: lumes, loadAutomatically: false, currentLumePostID: currentLumePostID)
        lumeVerticalScroll.view.then {
            view.addSubview($0)
        }.layout {
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
        }
    }
    
    private func setupImageView() {
        if let thumbnailURL = thumbnailURL {
            imageView.then {
                view.addSubview($0)
                $0.contentMode = fitOrFill
                $0.layer.masksToBounds = true
                $0.setImage(from: thumbnailURL)
            }.layout {
                $0.leading == view.leadingAnchor
                $0.trailing == view.trailingAnchor
                if fitOrFill == .scaleAspectFill {
                    $0.top == view.topAnchor
                    $0.bottom == view.bottomAnchor
                }
                $0.centerX == view.centerXAnchor
                $0.centerY == view.centerYAnchor
            }
            
            imageView.heightAnchor.constraint(
                equalTo: imageView.widthAnchor,
                multiplier: 1.25
            ).isActive = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.5) {
                    self.imageView.alpha = 0.0
                }
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension DetailScreen: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return scrollView.isBouncing
    }
}

// MARK: - UINavigationControllerDelegate

extension DetailScreen: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("DetailScreen - navigationController animationControllerFor operation: \(operation.rawValue)")
        if fromVC is Self || toVC is Self {
            transitionAnimator.transition = (operation == .push) ? .push : .pop
            return transitionAnimator
        }
        return nil
    }

    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        print("DetailScreen - navigationController interactionControllerFor")
        return interactionController
    }
}

// MARK: UIPanGestureRecognizer

extension DetailScreen {
    @objc
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let window = UIApplication.keyWindow!
        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: window)
            guard abs(velocity.x) > abs(velocity.y) else { return }
            interactionController = SharedTransitionInteractionController()
            navigationController?.popViewController(animated: true)
        case .changed:
            interactionController?.update(recognizer)
        case .ended:
            if recognizer.velocity(in: window).x > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default:
            interactionController?.cancel()
            interactionController = nil
        }
    }
}

// MARK: SharedTransitioning

extension DetailScreen: SharedTransitioning {
    var sharedFrame: CGRect {
        return imageView.frameInWindow ?? .zero
    }
}
