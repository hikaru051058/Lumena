//
//  ContentCreationViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import Foundation
import UIKit
import Photos

class ContentCreationViewController: UIViewController {
    
    /// Text Based Content
    private var textBasedContentVC: TextBasedContentViewController!
    private var isTextBasedContentViewVisible = false
    
    /// Main Camera Feed
    private var cameraViewController: CameraViewController!
    private var countDownLabel: UILabel!
    
    /// Camera Capture Button
    private var cameraRecordButton: CameraRecordButtonUIView!
    private var cameraRecordButtonBottomConstraint: NSLayoutConstraint!
    private var undoButton: UIButton!
    private var saveButton: UIButton!
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var recordingIsInProgress: Bool = false {
        didSet {
            hideNonVideoRelatedButtons()
        }
    }
    
    /// Bottom Horizontal Section Buttons
    private var horizontalButtonsStackView: UIStackView!
    private var cameraToggleUIView: CameraToggleButtonUIButton!
    private var imagePickerButton: UIButton!
    private var previewButton: UIButton!
    
    /// Right Side Vertical Section Buttons
    private var verticalButtonsStackView: UIStackView!
    private var verticalButtonsStackViewBottomConstraint: NSLayoutConstraint!
    private var showSongButton: UIButton!
    private var flashButton: UIButton!
    private var timerButton: UIButton!
    private var textBaseButton: UIButton!
    
    private var sideButtonColor: UIColor = .background
    private var currentTimerState: TimerState = .noTimer
    
    /// Image Selector
    private var imageSelectorSheetVC: ImageSelectorSheetViewController!
    
    /// Left Side Buttons
    private var backButton: UIButton!
    
    /// Flash Light Slider
    private var flashlightSlider: FlashLightCustomSliderView?
    private var sliderIsVisible = false
    private var lastFlashLevel: CGFloat = 0.0
    
    /// Variables
    private var postLume: Lume = Lume()
    private var audioPlayer: LumeAudioPlayer = LumeAudioPlayer()
    private var musicListVC: MusicListViewController!
    private var isMusicTagged: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.cameraViewController.startCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.cameraViewController.stopCamera()
        pauseTaggedMusic()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        setupCameraViewController()
        
        setupTextBaseContentViewController()
        
        setupBackButton()
        
        setupCameraRecordButton()
        
        setupBottomHorizontalButtonStackUI()
        
        setupSideVerticalButtonStackUI()
        
    }
}


// MARK: - Camera Feed View
extension ContentCreationViewController: CameraViewControllerDelegate {
    
    private func setupCameraViewController() {
        cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        addChild(cameraViewController)
        view.addSubview(cameraViewController.view)
        cameraViewController.didMove(toParent: self)
        
        cameraViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            cameraViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.84),
            cameraViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        cameraViewController.view.layer.cornerRadius = 40
        cameraViewController.view.clipsToBounds = true
        
        setupTimerView()
        
        setupVideoEditHorizontalStack()
        
        UIView.animate(withDuration: 0, animations: {
            self.cameraViewController.view.transform = .identity
        })
    }
    
    func didToggleCameraMode(_ cameraMode: CameraMode) {
        guard cameraRecordButton != nil else { return }
        cameraRecordButton.cameraMode = cameraMode
    }
    
    func didToggleCameraPosition(_ cameraPosition: CameraPosition) {
        guard cameraRecordButton != nil else { return }
        resetFlashLight()
    }
    
    func didUpdateDuration(_ duration: CGFloat) {
        guard cameraRecordButton != nil else { return }
        cameraRecordButton.setProgress(Double(duration))
    }
    
    func didUpdateCameraStatus(_ cameraStatus: CameraProcessStatus) {
        guard cameraRecordButton != nil else { return }
        DispatchQueue.main.async {
            self.cameraRecordButton.currentCameraProcessStatus = cameraStatus

            if cameraStatus == .processing {
                self.toggleSaveButton(isProcessing: true)
            } else if cameraStatus == .ready {
                self.toggleSaveButton(isProcessing: false)
            }
        }
    }
    
    func didAddLumeContent(_ lumeContent: LumeContent) {
        postLume.contents.append(lumeContent)
        updatePreviewButtonVisibility()
    }
    
    func didRemoveLumeContent(_ lumeContent: LumeContent) {
        if let index = postLume.contents.firstIndex(where: { $0.id == lumeContent.id }) {
            postLume.contents.remove(at: index)
        }
        updatePreviewButtonVisibility()
    }
}

// MARK: - Timer View
extension ContentCreationViewController {
    
    private func setupTimerView() {
        countDownLabel = UILabel()
        countDownLabel.font = UIFont.systemFont(ofSize: 80, weight: .bold)
        countDownLabel.textColor = .white
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(countDownLabel)
        
        NSLayoutConstraint.activate([
            countDownLabel.centerXAnchor.constraint(equalTo: cameraViewController.view.centerXAnchor),
            countDownLabel.centerYAnchor.constraint(equalTo: cameraViewController.view.centerYAnchor),
        ])
    }
    
    private func startCountDown(forTakingPicture: Bool = false) {
        guard currentTimerState != .noTimer else {
            if forTakingPicture {
                cameraViewController.capturePhoto()
                addCaptureImageFeedback()
            } else {
                playTaggedMusic()
                cameraViewController.startRecording()
                recordingIsInProgress = true
            }
            return
        }

        var secondsRemaining = currentTimerState.rawValue
        countDownLabel.text = "\(secondsRemaining)"
        countDownLabel.isHidden = false

        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if secondsRemaining > 0 {
                secondsRemaining -= 1
                self.countDownLabel.text = "\(secondsRemaining)"
            } else {
                timer.invalidate()
                self.countDownLabel.isHidden = true
                if forTakingPicture {
                    self.cameraViewController.capturePhoto()
                    addCaptureImageFeedback()
                } else {
                    playTaggedMusic()
                    self.cameraViewController.startRecording()
                    recordingIsInProgress = true
                }
            }
        }

        RunLoop.current.add(timer, forMode: .common)
    }
}

// MARK: - Text Based View
extension ContentCreationViewController: TextBasedContentViewControllerDelegate {
    
    private func setupTextBaseContentViewController() {
        if textBasedContentVC == nil {
            textBasedContentVC = TextBasedContentViewController(text: postLume.textBaseContent)
            textBasedContentVC.delegate = self
        }
        addChild(textBasedContentVC)
        view.addSubview(textBasedContentVC.view)
        textBasedContentVC.didMove(toParent: self)
        
        textBasedContentVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textBasedContentVC.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            textBasedContentVC.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.84),
            textBasedContentVC.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textBasedContentVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        textBasedContentVC.view.layer.cornerRadius = 40
        textBasedContentVC.view.clipsToBounds = true
        
        textBasedContentVC.view.alpha = isTextBasedContentViewVisible ? 1 : 0
    }
    
    func didUpdateText(_ newText: String) {
        postLume.textBaseContent = newText
    }
    
    private func calculateBottomOffset() -> CGFloat {
        let textBaseViewBottomY = textBasedContentVC.view.frame.maxY
        let viewBottomY = view.frame.maxY
        let heightDifference = viewBottomY - textBaseViewBottomY
        
        return heightDifference
    }
}

// MARK: - Record Button
extension ContentCreationViewController: CameraRecordButtonUIViewDelegate {
    
    private func setupCameraRecordButton() {
        cameraRecordButton = CameraRecordButtonUIView()
        cameraRecordButton.delegate = self
        cameraRecordButton.minDimension = 70
        cameraRecordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraRecordButton)
        
        cameraRecordButtonBottomConstraint = cameraRecordButton.bottomAnchor.constraint(equalTo: cameraViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        NSLayoutConstraint.activate([
            cameraRecordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraRecordButtonBottomConstraint,
            cameraRecordButton.widthAnchor.constraint(equalToConstant: 70),
            cameraRecordButton.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    func didChangeRecordStatus(_ isRecording: Bool) {
        pauseTaggedMusic()
        if isRecording {
            startCountDown()  // Start the countdown before recording
        } else {
            cameraViewController.stopRecording()
        }
        updateVideoEditButtonVisibility()
    }
    
    func didTakePicture() {
        startCountDown(forTakingPicture: true)  // Start the countdown before taking a picture
        updateVideoEditButtonVisibility()
    }
}

extension ContentCreationViewController {
    
    private func addCaptureImageFeedback() {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0, animations: {
            self.cameraViewController.view.alpha = 0.3
            self.cameraViewController.view.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.cameraViewController.view.alpha = 1.0
                self.cameraViewController.view.transform = .identity
            }
        }
    }
}

// MARK: - Horizontal Video Editing Button
extension ContentCreationViewController {

    private func setupVideoEditHorizontalStack() {
        let horizontalStack = UIView()
        horizontalStack.backgroundColor = .clear
        
        undoButton = setupUndoVideoButton()
        saveButton = setupSaveVideoButton()
        progressView.isHidden = true
        progressView.backgroundColor = .background
        activityIndicator.isHidden = true
        saveButton.isHidden = true
        
        let saveContainerView = UIView()
        saveContainerView.backgroundColor = .clear // Make sure background is clear
        saveContainerView.layer.cornerRadius = saveButton.layer.cornerRadius
        saveContainerView.layer.masksToBounds = true
        
        // Add the save button, progress view, and activity indicator to the container view
        saveContainerView.addSubview(saveButton)
        saveContainerView.addSubview(progressView)
        saveContainerView.addSubview(activityIndicator)
        
        horizontalStack.addSubview(undoButton)
        horizontalStack.addSubview(saveContainerView)
        
        view.addSubview(horizontalStack)
        
        // Set up constraints for the horizontalStack
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: cameraViewController.view.leadingAnchor, constant: 40),
            horizontalStack.trailingAnchor.constraint(equalTo: cameraViewController.view.trailingAnchor, constant: -40),
            horizontalStack.bottomAnchor.constraint(equalTo: cameraViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            horizontalStack.heightAnchor.constraint(equalToConstant: 40)  // Ensure the stack has a defined height
        ])
        
        // Set up constraints for the undo button
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            undoButton.leadingAnchor.constraint(equalTo: horizontalStack.leadingAnchor),
            undoButton.centerYAnchor.constraint(equalTo: horizontalStack.centerYAnchor),
            undoButton.widthAnchor.constraint(equalToConstant: 50),  // Define button size
            undoButton.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // Set up constraints for the save container view
        saveContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveContainerView.trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor),
            saveContainerView.centerYAnchor.constraint(equalTo: horizontalStack.centerYAnchor),
            saveContainerView.widthAnchor.constraint(equalToConstant: 50),  // Define size
            saveContainerView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // Set up constraints for the save button within the container
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.centerXAnchor.constraint(equalTo: saveContainerView.centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: saveContainerView.centerYAnchor),
            saveButton.widthAnchor.constraint(equalTo: saveContainerView.widthAnchor),
            saveButton.heightAnchor.constraint(equalTo: saveContainerView.heightAnchor)
        ])
        
        // Set up constraints for the progress view within the container
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: saveContainerView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: saveContainerView.trailingAnchor),
            progressView.centerYAnchor.constraint(equalTo: saveContainerView.centerYAnchor),
            progressView.heightAnchor.constraint(equalTo: horizontalStack.heightAnchor),
        ])
        
        // Set up constraints for the activity indicator within the container
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: saveContainerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: saveContainerView.centerYAnchor)
        ])
        
        updateVideoEditButtonVisibility()
    }
    
    private func setupButton(withImageName imageName: String, pointSize: CGFloat, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)  // Set the button type to custom
        
        // Setup the icon
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: config)?.withTintColor(.background, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        // Prevent the image from distorting
        button.imageView?.contentMode = .scaleAspectFit
        
        // Setup the button background
        button.backgroundColor = .black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 35/2.0  // Height / 2
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Ensure the button is tappable
        button.isUserInteractionEnabled = true
        
        // Bring the button to the front
        button.layer.zPosition = 1
        
        // Set button action
        button.addTarget(target, action: action, for: .touchUpInside)
        
        // Add constraints for width and height
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        return button
    }

    // Usage for Undo Button
    private func setupUndoVideoButton() -> UIButton {
        return setupButton(withImageName: "arrow.uturn.backward.fill", pointSize: 25, target: self, action: #selector(undoVideoButtonTapped))
    }

    // Usage for Save Button
    private func setupSaveVideoButton() -> UIButton {
        return setupButton(withImageName: "video.fill.badge.checkmark", pointSize: 25, target: self, action: #selector(saveVideoButtonTapped))
    }
    
    private func toggleSaveButton(isProcessing: Bool) {
        DispatchQueue.main.async {
            self.saveButton.isHidden = isProcessing
            self.progressView.isHidden = !isProcessing
            self.activityIndicator.isHidden = !isProcessing
            
            if isProcessing {
                self.progressView.progress = 0.0
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc private func saveVideoButtonTapped() {
        toggleSaveButton(isProcessing: true) // Show progress indicator
        
        Task.init {
            if let _ = cameraViewController.saveVideo() {
                toggleSaveButton(isProcessing: false) // Hide progress indicator
                recordingIsInProgress = false
            } else {
                print("Error in appending saved video in ContentCreationViewController: No Video (LumeContent) returned from CameraViewController")
                toggleSaveButton(isProcessing: false) // Hide progress indicator
            }
            updateVideoEditButtonVisibility()
            updatePreviewButtonVisibility()
        }
    }
    
    @objc private func undoVideoButtonTapped() {
        cameraViewController.removeLastVideo()
        updateVideoEditButtonVisibility()
    }
    
    private func updateVideoEditButtonVisibility() {
        let hasMultipleVideos = cameraViewController.recordedVideoCount() > 1
        let hasVideosToSave = cameraViewController.recordedVideoCount() != 0
        
        // Set alpha based on conditions
        undoButton.alpha = hasMultipleVideos ? 1 : 0
        saveButton.alpha = hasVideosToSave ? 1 : 0
        recordingIsInProgress = hasVideosToSave
        
        view.layoutIfNeeded()
    }
    
    private func hideNonVideoRelatedButtons() {
        // Define the buttons that should be hidden during recording
        let buttonsToHideDuringRecording: [UIView?] = [
            showSongButton,    // Button to show music selection
            textBaseButton,    // Button for text-based content
            backButton,        // Back button
            imagePickerButton, // Button for image selector
            cameraToggleUIView, // Button for toggling the camera
            saveButton        // Button to save the video
        ]
        
        if recordingIsInProgress {
            // Hide all non-video-related buttons during recording
            buttonsToHideDuringRecording.forEach { button in
                button?.isHidden = true
            }
        } else {
            // Show all buttons when not recording
            buttonsToHideDuringRecording.forEach { button in
                button?.isHidden = false
            }
        }
        view.layoutIfNeeded()
    }
}

// MARK: - Bottom Control Buttons
extension ContentCreationViewController {

    private func setupHorizontalButtonsStackView() {
        // Create the stack view
        horizontalButtonsStackView = UIStackView()
        horizontalButtonsStackView.axis = .horizontal
        horizontalButtonsStackView.alignment = .center
        horizontalButtonsStackView.distribution = .equalSpacing
        horizontalButtonsStackView.spacing = 20 // Adjust the spacing as needed

        // Add the stack view to the view hierarchy
        view.addSubview(horizontalButtonsStackView)
        
        // Add the buttons to the stack view
        horizontalButtonsStackView.addArrangedSubview(imagePickerButton)
        horizontalButtonsStackView.addArrangedSubview(cameraToggleUIView)
        horizontalButtonsStackView.addArrangedSubview(previewButton)
        
        // Set up constraints for the stack view
        horizontalButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalButtonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            horizontalButtonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            horizontalButtonsStackView.topAnchor.constraint(equalTo: cameraViewController.view.bottomAnchor),
            horizontalButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        cameraToggleUIView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraToggleUIView.widthAnchor.constraint(equalToConstant: 150) // Adjust this width as needed
        ])
    }

    private func setupPhotoSelectorButton() {
        imagePickerButton = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let image = UIImage(systemName: "photo.on.rectangle", withConfiguration: config)?.withTintColor(.arinBlue, renderingMode: .alwaysOriginal)
        
        imagePickerButton.setImage(image, for: .normal)
        imagePickerButton.tintColor = .primary
        imagePickerButton.addTarget(self, action: #selector(photoSelectorButtonTapped), for: .touchUpInside)
    }

    private func setupCameraToggleView() {
        cameraToggleUIView = CameraToggleButtonUIButton()
        cameraToggleUIView.delegate = self
    }

    private func setupPreviewButton() {
        previewButton = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withTintColor(.arinYellow, renderingMode: .alwaysOriginal)
        
        previewButton.setImage(image, for: .normal)
        previewButton.tintColor = .primary
        previewButton.alpha = postLume.contents.isEmpty ? 0 : 1
        previewButton.addTarget(self, action: #selector(navigateToPrepPost), for: .touchUpInside)
    }

    func setupBottomHorizontalButtonStackUI() {
        setupPhotoSelectorButton()
        setupCameraToggleView()
        setupPreviewButton()
        setupHorizontalButtonsStackView()
    }
}

extension ContentCreationViewController: CameraToggleButtonUIButtonDelegate, ImageSelectorSheetViewControllerDelegate {
    
    @objc private func photoSelectorButtonTapped() {
        if imageSelectorSheetVC == nil {
            imageSelectorSheetVC = ImageSelectorSheetViewController()
            imageSelectorSheetVC.delegate = self
        }
        let navigationController = UINavigationController(rootViewController: imageSelectorSheetVC)
        navigationController.modalPresentationStyle = .pageSheet
        navigationController.modalTransitionStyle = .coverVertical
        navigationController.sheetPresentationController?.prefersGrabberVisible = true
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func didToggleCameraModeToggleButton(_ mode: CameraMode) {
        cameraViewController.setCameraMode(mode)
    }
    
    @objc func navigateToPrepPost() {
        DispatchQueue.main.async { [self] in
            
            if isMusicTagged {
                muteAllVideos()
            } else {
                unmuteAllVideos()
            }
            
            if postLume.contents.contains(where: { $0.isAuthentic == false }) {
                postLume.lumeAuth = false
            } else {
                postLume.lumeAuth = true
            }
            
            print("Lume Authenticity: \(postLume.lumeAuth)")
            
            let prepPostVC =  PrepPostViewController(postLume: self.postLume)
            self.navigationController?.pushViewController(prepPostVC, animated: true)
        }
    }
    
    func didAddSelectedAsset(_ asset: LumeContent) {
        // Add the new asset to postLume.contents
        postLume.contents.append(asset)
        updatePreviewButtonVisibility()
    }
    
    func didRemoveSelectedAsset(_ asset: LumeContent) {
        if let index = postLume.contents.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            postLume.contents.remove(at: index)
        }
        updatePreviewButtonVisibility()
    }

    private func updatePreviewButtonVisibility() {
        // Update the preview button's visibility based on the content count
        previewButton.alpha = postLume.contents.isEmpty ? 0 : 1
        view.layoutIfNeeded()
    }
}

// MARK: - Top Right Side Control Buttons
extension ContentCreationViewController {
    
    private func setupVerticalSideButtonsStackView() {
        // Create the stack view
        verticalButtonsStackView = UIStackView()
        verticalButtonsStackView.axis = .vertical
        verticalButtonsStackView.alignment = .center
        verticalButtonsStackView.distribution = .equalSpacing
        verticalButtonsStackView.spacing = 20 // Adjust the spacing as needed
        
        // Add the stack view to the view hierarchy
        view.addSubview(verticalButtonsStackView)
        
        // Add the buttons to the stack view
        verticalButtonsStackView.addArrangedSubview(flashButton)
        verticalButtonsStackView.addArrangedSubview(showSongButton)
        verticalButtonsStackView.addArrangedSubview(timerButton)
        verticalButtonsStackView.addArrangedSubview(textBaseButton)
        
        // Set up constraints for the stack view
        verticalButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        verticalButtonsStackViewBottomConstraint = verticalButtonsStackView.bottomAnchor.constraint(equalTo: cameraViewController.view.topAnchor, constant: returnSideButtonOriginalHeight())
        
        NSLayoutConstraint.activate([
            verticalButtonsStackView.trailingAnchor.constraint(equalTo: cameraViewController.view.trailingAnchor, constant: -10),
            verticalButtonsStackView.topAnchor.constraint(equalTo: cameraViewController.view.topAnchor, constant: 24),
            verticalButtonsStackViewBottomConstraint,
        ])
    }
    
    private func returnSideButtonOriginalHeight() -> CGFloat {
        // Calculate the height of the stack view dynamically
        let totalButtonHeight: CGFloat = 50 * 4 // 4 buttons with 50 height each
        let totalSpacing: CGFloat = 20 * 3 // 3 spaces between the buttons with 20 spacing each
        return totalButtonHeight + totalSpacing
    }

    private func setupFlashButton() {
        flashButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "lightbulb.led.fill", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        flashButton.setImage(image, for: .normal)
        flashButton.tintColor = sideButtonColor
        flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
    }

    private func setupShowSongButton() {
        showSongButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "music.note", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        showSongButton.setImage(image, for: .normal)
        showSongButton.tintColor = sideButtonColor
        showSongButton.addTarget(self, action: #selector(showSongsButtonTapped), for: .touchUpInside)
    }

    private func setupTimerButton() {
        timerButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "timer.circle.fill", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        timerButton.setImage(image, for: .normal)
        timerButton.tintColor = sideButtonColor
        timerButton.addTarget(self, action: #selector(timerButtonTapped), for: .touchUpInside)
    }

    private func setupTextBaseContentButton() {
        textBaseButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "doc.text.fill", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        textBaseButton.setImage(image, for: .normal)
        textBaseButton.tintColor = sideButtonColor
        textBaseButton.addTarget(self, action: #selector(textBaseButtonTapped), for: .touchUpInside)
    }
    
    private func updateButtonImages() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        
        // Update the flashButton image
        let flashImage = UIImage(systemName: "lightbulb.led.fill", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        flashButton.setImage(flashImage, for: .normal)
        
        // Update the showSongButton image
        let songImage = UIImage(systemName: "music.note", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        showSongButton.setImage(songImage, for: .normal)
        
        // Update the timerButton image
        let timerImage = UIImage(systemName: "timer.circle.fill", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        timerButton.setImage(timerImage, for: .normal)
        
        // Update the textBaseButton image
        let textBaseImage = UIImage(systemName: "doc.text.fill", withConfiguration: config)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        textBaseButton.setImage(textBaseImage, for: .normal)
        
        // Update the backButton image
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
        let backButtonImage = UIImage(systemName: "chevron.backward", withConfiguration: buttonImageConfig)?.withTintColor(sideButtonColor, renderingMode: .alwaysOriginal)
        backButton.setImage(backButtonImage, for: .normal)
    }

    func setupSideVerticalButtonStackUI() {
        setupFlashButton()
        setupShowSongButton()
        setupTimerButton()
        setupTextBaseContentButton()
        setupVerticalSideButtonsStackView()
    }
}

extension ContentCreationViewController {
    
    @objc private func flashButtonTapped() {
        
        guard !isTextBasedContentViewVisible else { return }
        
        if sliderIsVisible {
            hideFlashlightSlider()
        } else {
            showFlashlightSlider()
        }
        
        if cameraViewController.currentCameraPosition == .back {
            cameraViewController.setFlashlight(level: 0)
        } else {
            if sliderIsVisible {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0.5,
                               options: [.curveEaseInOut],
                               animations: {
                    self.cameraViewController.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.textBasedContentVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.cameraRecordButtonBottomConstraint.constant -= (self.cameraViewController.view.frame.height * 0.1) // Adjust based on scaling
                    self.view.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               options: [.curveEaseInOut],
                               animations: {
                    self.cameraViewController.view.transform = .identity
                    self.textBasedContentVC.view.transform = .identity
                    self.cameraRecordButtonBottomConstraint.constant = -16
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc private func showSongsButtonTapped() {
        
        guard !isTextBasedContentViewVisible else { return }
        
        if musicListVC == nil {
            musicListVC = MusicListViewController(audioPlayer: self.audioPlayer)
            musicListVC.delegate = self
        }
        let navController = UINavigationController(rootViewController: musicListVC)
        navController.modalPresentationStyle = .pageSheet
        navController.sheetPresentationController?.detents = [.medium(), .large()]
        //        navController.sheetPresentationController?.prefersGrabberVisible = true
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func timerButtonTapped() {
        
        guard !isTextBasedContentViewVisible else { return }
        
        // Toggle the timer state
        switch currentTimerState {
        case .noTimer:
            currentTimerState = .threeSeconds
        case .threeSeconds:
            currentTimerState = .tenSeconds
        case .tenSeconds:
            currentTimerState = .noTimer
        }
        
        updateTimerButtonIcon()
    }
    
    @objc private func textBaseButtonTapped() {
        isTextBasedContentViewVisible.toggle()
        
        textBasedContentVC.view.endEditing(true)
        
        textBasedContentVC.bottomInsetHeight = calculateBottomOffset()
        
        if isTextBasedContentViewVisible {
            // Hide the camera elements and stop the camera
//            cameraViewController.stopCamera()
            hideFlashlightSlider()
            sideButtonColor = .secondaryLabel
            updateButtonImages()
        } else {
            sideButtonColor = .background
            updateButtonImages()
            didUpdateFlashLevel(0)
        }
        
        updateTextBaseButtonIcon()
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut],
                       animations: {
            // Toggle visibility with alpha animation
            self.textBasedContentVC.view.alpha = self.isTextBasedContentViewVisible ? 1 : 0
            self.cameraViewController.view.alpha = self.isTextBasedContentViewVisible ? 0 : 1
            self.cameraRecordButton.alpha = self.isTextBasedContentViewVisible ? 0 : 1
            self.cameraToggleUIView.alpha = self.isTextBasedContentViewVisible ? 0 : 1
            self.imagePickerButton.alpha = self.isTextBasedContentViewVisible ? 0 : 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Start the camera session only after the animation and configuration are complete
//            if !self.isTextBasedContens
        })
    }
}

extension ContentCreationViewController {
    
    private func updateTimerButtonIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image: UIImage?
        let tintColor: UIColor?
        
        switch currentTimerState {
        case .noTimer:
            image = UIImage(systemName: "timer.circle.fill", withConfiguration: config)
            tintColor = sideButtonColor
        case .threeSeconds:
            image = UIImage(systemName: "3.circle.fill", withConfiguration: config)
            tintColor = UIColor.arinYellow
        case .tenSeconds:
            image = UIImage(systemName: "10.circle.fill", withConfiguration: config)
            tintColor = UIColor.arinPink
        }
        
        timerButton.setImage(image, for: .normal)
        timerButton.tintColor = tintColor
    }
    
    private func updateTextBaseButtonIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "doc.text.fill", withConfiguration: config)
        let tintColor = isTextBasedContentViewVisible ? UIColor.arinPink : (postLume.textBaseContent.isEmpty ? sideButtonColor : .arinBlue)
        textBaseButton.setImage(image, for: .normal)
        textBaseButton.tintColor = tintColor
    }
}

extension ContentCreationViewController: MusicListViewControllerDelegate {
    func musicListViewController(_ controller: MusicListViewController, didTagTrack track: Track) {
        postLume.tagMusic = track
        postLume.tagMusic.initializeAudioPlayer { _ in}
        isMusicTagged = true
        muteAllVideos()
    }
    
    func musicListViewController(_ controller: MusicListViewController, didUntagTrack track: Track) {
        postLume.tagMusic = Track()  // Reset to an empty Track
        isMusicTagged = false
        unmuteAllVideos()
    }
    
    private func playTaggedMusic() {
        let taggedMusic = postLume.tagMusic
        if !taggedMusic.uri.isEmpty {
            if !taggedMusic.isPlaying {
                taggedMusic.playAudio()
            }
        }
    }
    
    private func pauseTaggedMusic() {
        let taggedMusic = postLume.tagMusic
        if taggedMusic.isPlaying {
            taggedMusic.stopAudio()
        }
    }
    
    private func muteAllVideos() {
        for content in postLume.contents {
            switch content {
            case .video(let lumeVideo):
                lumeVideo.mute(muteBool: true)
            case .image(_):
                continue
            case .text(_):
                continue
            }
        }
    }
    
    private func unmuteAllVideos() {
        for content in postLume.contents {
            switch content {
            case .video(let lumeVideo):
                lumeVideo.mute(muteBool: false)
            case .image(_):
                continue
            case .text(_):
                continue
            }
        }
    }
}

extension ContentCreationViewController: FlashLightCustomSliderViewDelegate {
    
    private func showFlashlightSlider() {
        
        guard flashlightSlider == nil else { return }
        
        // Create the slider view
        if flashlightSlider == nil {
            flashlightSlider = FlashLightCustomSliderView(frame: .zero)
            flashlightSlider?.delegate = self
        }
        
        if let flashSlider = flashlightSlider
        {
            if lastFlashLevel < 0.1 {
                flashSlider.setSlideValue(to: 0.1)
            } else {
                flashSlider.setSlideValue(to: lastFlashLevel)
            }
        }
        
        // Add to the view hierarchy
        view.addSubview(flashlightSlider!)
        flashlightSlider?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flashlightSlider!.topAnchor.constraint(equalTo: verticalButtonsStackView.bottomAnchor, constant: 16),
            flashlightSlider!.leadingAnchor.constraint(equalTo: flashButton.leadingAnchor),
            flashlightSlider!.trailingAnchor.constraint(equalTo: flashButton.trailingAnchor),
            flashlightSlider!.heightAnchor.constraint(equalToConstant: 150)
        ])
        self.view.layoutIfNeeded()
        
        // Adjust the constraints to make room for the slider
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        sliderIsVisible = true
    }
    
    private func hideFlashlightSlider() {
        guard let flashlightSlider = flashlightSlider else { return }
        
        // Remove the slider and move buttons back to their original position
        UIView.animate(withDuration: 0.3, animations: {
            flashlightSlider.removeFromSuperview()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.flashlightSlider = nil
        })
        
        sliderIsVisible = false
    }
    
    private func resetFlashLight() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut],
                       animations: {
            self.hideFlashlightSlider()
            self.cameraViewController.view.transform = .identity
            self.textBasedContentVC.view.transform = .identity
            self.cameraRecordButtonBottomConstraint.constant = -16
            self.view.backgroundColor = .primary
            self.cameraViewController.setFlashlight(level: 0)
            
            self.view.layoutIfNeeded()
        })
    }
    
    func didUpdateFlashLevel(_ level: CGFloat) {
        
        lastFlashLevel = level
        
        if cameraViewController.currentCameraPosition == .back {
            cameraViewController.setFlashlight(level: level)
        } else {
            view.backgroundColor = .white.withAlphaComponent(CGFloat(level))
            sideButtonColor = UIColor(white: 1 - CGFloat(max(0, min(1, level))), alpha: 1)
            cameraToggleUIView.buttonColor = sideButtonColor
            updateButtonImages()
        }
    }
}


// MARK: - Top Left Side Exit Button
extension ContentCreationViewController {
    
    private func setupBackButton() {
        let buttonImageConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .default)
        backButton = UIButton()
        if let image = UIImage(systemName: "chevron.backward", withConfiguration: buttonImageConfig) {
            backButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        backButton.contentMode = .scaleAspectFit
        backButton.tintColor = sideButtonColor
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: cameraViewController.view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: cameraViewController.view.topAnchor, constant: 30),
        ])
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
