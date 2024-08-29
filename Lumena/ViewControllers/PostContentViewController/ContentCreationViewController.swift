//
//  ContentCreationViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import Foundation
import UIKit

class ContentCreationViewController: UIViewController {
    
    private var textBasedContentVC: TextBasedContentViewController!
    private var isTextBasedContentViewVisible = false
    
    private var cameraViewController: CameraViewController!
    private var cameraRecordButton: CameraRecordButtonUIView!
    private var cameraRecordButtonBottomConstraint: NSLayoutConstraint!
    
    private var horizontalButtonsStackView: UIStackView!
    private var cameraToggleUIView: CameraToggleButtonUIButton!
    private var imagePickerButton: UIButton!
    private var previewButton: UIButton!
    
    private var verticalButtonsStackView: UIStackView!
    private var verticalButtonsStackViewBottomConstraint: NSLayoutConstraint!
    private var showSongButton: UIButton!
    private var flashButton: UIButton!
    private var timerButton: UIButton!
    private var textBaseButton: UIButton!
    
    private var flashlightSlider: FlashLightCustomSliderView?
    private var sliderIsVisible = false
    
    private var postLume: Lume = Lume()
    private var audioPlayer: LumeAudioPlayer = LumeAudioPlayer()
    private var musicListVC: MusicListViewController!
    
    private var sideButtonColor: UIColor = .background
    
    private var lastFlashLevel: CGFloat = 0.0
    
    // Maintain the current timer state
    var currentTimerState: TimerState = .noTimer {
        didSet {
            updateTimerButtonIcon()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        setupCameraViewController()
        
        setupTextBaseContentViewController()
        
        setupCameraRecordButton()
        
        setupBottomHorizontalButtonStackUI()
        
        setupSideVerticalButtonStackUI()
    }
}

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
    }
    
    func didToggleCameraMode(_ cameraMode: CameraMode) {
        guard cameraRecordButton != nil else { return }
        cameraRecordButton.cameraMode = cameraMode
    }
    
    func didUpdateDuration(_ duration: CGFloat) {
        guard cameraRecordButton != nil else { return }
        cameraRecordButton.setProgress(Double(duration))
    }
    
    func didUpdateCameraStatus(_ cameraStatus: CameraProcessStatus) {
        guard cameraRecordButton != nil else { return }
        cameraRecordButton.currentCameraProcessStatus = cameraStatus
    }
    
    func didUpdateLumeContent(_ lumeContent: [LumeContent]) {
    }
}

extension ContentCreationViewController {
    
    private func setupTextBaseContentViewController() {
        textBasedContentVC = TextBasedContentViewController(text: "")//postLume.textContent
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
}

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
        cameraViewController.captureAction()
    }
    
    func didTakePicture() {
        cameraViewController.captureAction()
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
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
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
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.withTintColor(.arinYellow, renderingMode: .alwaysOriginal)
        
        previewButton.setImage(image, for: .normal)
        previewButton.tintColor = .primary
//        previewButton.isHidden = postLume.contents.isEmpty
        previewButton.addTarget(self, action: #selector(navigateToPrepPost), for: .touchUpInside)
    }

    func setupBottomHorizontalButtonStackUI() {
        setupPhotoSelectorButton()
        setupCameraToggleView()
        setupPreviewButton()
        setupHorizontalButtonsStackView()
    }
}

extension ContentCreationViewController: CameraToggleButtonUIButtonDelegate {
    
    @objc private func photoSelectorButtonTapped() {
        let imageSelectorSheetVC = ImageSelectorSheetViewController()
        imageSelectorSheetVC.modalPresentationStyle = .pageSheet
        imageSelectorSheetVC.modalTransitionStyle = .coverVertical
        imageSelectorSheetVC.sheetPresentationController?.prefersGrabberVisible = true
        self.present(imageSelectorSheetVC, animated: true, completion: nil)
    }
    
    func didToggleCameraModeToggleButton(_ mode: CameraMode) {
        cameraViewController.setCameraMode(mode)
    }
    
    @objc func navigateToPrepPost() {
        DispatchQueue.main.async {
            let prepPostVC =  PrepPostViewController(postLume: self.postLume)
            self.navigationController?.pushViewController(prepPostVC, animated: true)
        }
    }
}


// MARK: - Top Side Control Buttons

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
        
        guard isTextBasedContentViewVisible else { return }
        
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
        
        guard isTextBasedContentViewVisible else { return }
        
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
        
        guard isTextBasedContentViewVisible else { return }
        
        // Toggle the timer state
        switch currentTimerState {
        case .noTimer:
            currentTimerState = .threeSeconds
        case .threeSeconds:
            currentTimerState = .tenSeconds
        case .tenSeconds:
            currentTimerState = .noTimer
        }
    }
    
    @objc private func textBaseButtonTapped() {
        isTextBasedContentViewVisible.toggle()
        
            textBasedContentVC.view.endEditing(true)
        
        if isTextBasedContentViewVisible {
            // Hide the camera elements and stop the camera
            cameraViewController.stopCamera()
            hideFlashlightSlider()
            sideButtonColor = .secondaryLabel
            updateButtonImages()
        } else {
            // Reset flashlight level
            didUpdateFlashLevel(0)
        }
        
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
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Start the camera session only after the animation and configuration are complete
            if !self.isTextBasedContentViewVisible {
                self.cameraViewController.startCamera()
            }
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
}

extension ContentCreationViewController: MusicListViewControllerDelegate {
    func musicListViewController(_ controller: MusicListViewController, didTagTrack track: Track) {
        postLume.tagMusic = track
    }
    
    func musicListViewController(_ controller: MusicListViewController, didUntagTrack track: Track) {
        postLume.tagMusic = Track()
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
