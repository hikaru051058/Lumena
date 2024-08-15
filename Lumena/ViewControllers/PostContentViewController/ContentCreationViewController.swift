//
//  ContentCreationViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/13.
//

import Foundation
import UIKit


class ContentCreationViewController: UIViewController {
    
    private var cameraViewController: CameraViewController!
    private var cameraRecordButton: CameraRecordButtonUIView!
    private var cameraToggleUIView: CameraToggleButtonUIButton!
    
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
        setupCameraRecordButton()
        setupCameraToggleView()
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
            cameraViewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.85),
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

extension ContentCreationViewController: CameraRecordButtonUIViewDelegate {
    
    private func setupCameraRecordButton() {
        cameraRecordButton = CameraRecordButtonUIView()
        cameraRecordButton.delegate = self
        cameraRecordButton.minDimension = 70
        cameraRecordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraRecordButton)
        NSLayoutConstraint.activate([
            cameraRecordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraRecordButton.bottomAnchor.constraint(equalTo: cameraViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
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

extension ContentCreationViewController: CameraToggleButtonUIButtonDelegate {
    
    private func setupCameraToggleView() {
        cameraToggleUIView = CameraToggleButtonUIButton()
        cameraToggleUIView.delegate = self
        view.addSubview(cameraToggleUIView)
        
        cameraToggleUIView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraToggleUIView.widthAnchor.constraint(equalToConstant: 150),
            cameraToggleUIView.topAnchor.constraint(equalTo: cameraViewController.view.bottomAnchor),
            cameraToggleUIView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraToggleUIView.centerXAnchor.constraint(equalTo: cameraViewController.view.centerXAnchor),
        ])
    }
    
    func didToggleCameraModeToggleButton(_ mode: CameraMode) {
        cameraViewController.setCameraMode(mode)
    }
}
