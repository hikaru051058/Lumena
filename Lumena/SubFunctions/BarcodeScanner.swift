//
//  BarcodeScanner.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/18.
//

import SwiftUI
import AVFoundation


//struct ScannerView: UIViewControllerRepresentable {
//    @Binding var scannedCode: String
//    @Binding var isShowingScanner: Bool
//    
//    func makeUIViewController(context: Context) -> ScannerViewController {
//        let scannerViewController = ScannerViewController()
//        scannerViewController.delegate = context.coordinator
//        return scannerViewController
//    }
//    
//    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
//        // Update any parameters or settings on the scanner view controller if needed
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
//    }
//    
//    class Coordinator: NSObject, ScannerViewControllerDelegate {
//        @Binding var scannedCode: String
//        @Binding var isShowingScanner: Bool
//        
//        init(scannedCode: Binding<String>, isShowingScanner: Binding<Bool>) {
//            _scannedCode = scannedCode
//            _isShowingScanner = isShowingScanner
//        }
//        
//        func didScanBarcode(withCode code: String) {
//            scannedCode = code
//            isShowingScanner = false
//        }
//    }
//}
//
//protocol ScannerViewControllerDelegate: AnyObject {
//    func didScanBarcode(withCode code: String)
//}
//
//class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
//    weak var delegate: ScannerViewControllerDelegate?
//    
//    private let captureSession = AVCaptureSession()
//    private var previewLayer: AVCaptureVideoPreviewLayer!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
//            print("Failed to get the camera device")
//            return
//        }
//        
//        do {
//            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
//            if captureSession.canAddInput(videoInput) {
//                captureSession.addInput(videoInput)
//            } else {
//                print("Failed to add video input to the capture session")
//                return
//            }
//            
//            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
//                try videoCaptureDevice.lockForConfiguration()
//                videoCaptureDevice.focusMode = .continuousAutoFocus
//                videoCaptureDevice.unlockForConfiguration()
//            }
//            
//        } catch {
//            print("Failed to create video input: \(error.localizedDescription)")
//            return
//        }
//        
//        let metadataOutput = AVCaptureMetadataOutput()
//        if captureSession.canAddOutput(metadataOutput) {
//            captureSession.addOutput(metadataOutput)
//            
//            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
//        } else {
//            print("Failed to add metadata output to the capture session")
//            return
//        }
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.frame = view.layer.bounds
//        view.layer.addSublayer(previewLayer)
//        
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            self?.captureSession.startRunning()
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        requestCameraPermission()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        captureSession.stopRunning()
//    }
//    
//    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        if let metadataObject = metadataObjects.first {
//            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
//            
//            guard let stringValue = readableObject.stringValue else { return }
//            delegate?.didScanBarcode(withCode: stringValue)
//        }
//    }
//    
//    private func requestCameraPermission() {
//        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//            DispatchQueue.main.async {
//                if !granted {
//                    self?.showCameraPermissionAlert()
//                }
//            }
//        }
//    }
//    
//    private func showCameraPermissionAlert() {
//        let alert = UIAlertController(
//            title: "Camera Permission Required",
//            message: "Please grant permission to use the camera.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
//            self.dismiss(animated: true, completion: nil)
//        }))
//        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//            }
//        }))
//        
//        present(alert, animated: true, completion: nil)
//    }
//}
//
//
//struct ScanOverlayView: View {
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                Rectangle()
//                    .fill(Color.black.opacity(0.5))
//                    
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.black)
//                    .frame(width: CGFloat(150), height: CGFloat(50), alignment: .center)
//                    .blendMode(.destinationOut)
//                
//            }.compositingGroup()
//        }
//    }
//}


/*
 
 struct BarcodeScannerView: View {
     @State private var isShowingScanner = false
     @State private var scannedCode: String = ""
     
     @State private var showSheet: Bool = false
     
     var body: some View {
         
         
         ZStack{
             Rectangle()
                 .foregroundColor(Color.orange)
                 .ignoresSafeArea()
             
             Button("Barcode"){
                 
                 showSheet = true
             }
             .sheet(isPresented: $showSheet) {
                 
                 VStack {
                     if isShowingScanner {
                         
                         
                         ZStack {
                             // ScannerView
                             ScannerView(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
                                 .aspectRatio(contentMode: .fill)
                                 .padding(.bottom, UIScreen.main.bounds.height/2)
                                 .frame(width: UIScreen.main.bounds.width)
                                 .clipped()
                                 .cornerRadius(25)
                             
                             RoundedRectangle(cornerRadius: 10)
                                 .fill(Color.clear)
                                 .frame(width: 150, height: 50)
                                 .overlay(
                                     RoundedRectangle(cornerRadius: 10)
                                         .stroke(Color.white, lineWidth: 4)
                                 )
                                 .cornerRadius(10)
                         }
                         .padding(.horizontal)
                         
                         
                     } else {
                         Text("Scanned Code: \(scannedCode)")
                             .font(.title)
                             .padding()
                         
                         Button("Scan Barcode") {
                             isShowingScanner = true
                         }
                         .font(.headline)
                         .padding()
                         .background(Color.blue)
                         .foregroundColor(.white)
                         .cornerRadius(10)
                     }
                 }
                 
                 .foregroundColor(Color.primary)
                 .presentationDetents(
                     [
                         .height(UIScreen.main.bounds.height * 0.25)
                     ]
                 )
                 //.presentationBackground(.regularMaterial)
             }
         }
         .ignoresSafeArea()
     }
 }

 */

import UIKit
import AVFoundation

protocol BarcodeScannerProtocol: AnyObject {
    func didScanBarcode(withCode code: String)
}

class BarcodeScannerViewController: UIViewController, ScannerViewControllerDelegate {
    
    private var overlayView: ScanOverlayView!
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let scannerContainerView = UIView()
    private let scannerViewController = ScannerViewController()
    
    weak var delegate: BarcodeScannerProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupScanner()
        setupLabels()
    }

    private func setupViews() {
        view.backgroundColor = .black

        // Scanner container view
        scannerContainerView.backgroundColor = .clear
//        scannerContainerView.layer.cornerRadius = 25
        scannerContainerView.clipsToBounds = true
        scannerContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scannerContainerView)

        // Overlay view
        overlayView = ScanOverlayView(frame: .zero) // Set frame to zero initially
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        scannerContainerView.addSubview(overlayView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scanner container view
            scannerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            scannerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scannerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Overlay view
            overlayView.topAnchor.constraint(equalTo: scannerContainerView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: scannerContainerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: scannerContainerView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: scannerContainerView.bottomAnchor),
        ])
    }
    
    private func setupLabels(){
        
        // Title label
        titleLabel.text = "バーコードをスキャン"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scannerContainerView.addSubview(titleLabel)

        // Subtitle label
        subtitleLabel.text = "枠内にバーコードを収めてください"
        subtitleLabel.textColor = .white
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.shadowOffset = CGSize(width: 0, height: 2)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scannerContainerView.addSubview(subtitleLabel)
        
        scannerContainerView.bringSubviewToFront(titleLabel)
        scannerContainerView.bringSubviewToFront(subtitleLabel)
        
        NSLayoutConstraint.activate([
            // Title label (centered within the container)
            titleLabel.centerXAnchor.constraint(equalTo: scannerContainerView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: scannerContainerView.topAnchor, constant: 20),

            // Subtitle label
            subtitleLabel.centerXAnchor.constraint(equalTo: scannerContainerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }

    private func setupScanner() {
        // Add the ScannerViewController as a child view controller
        scannerViewController.delegate = self
        addChild(scannerViewController)
        scannerContainerView.addSubview(scannerViewController.view)
        scannerViewController.view.frame = scannerContainerView.bounds
        scannerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scannerViewController.didMove(toParent: self)

        scannerContainerView.bringSubviewToFront(overlayView)
    }
    
    func didScanBarcode(withCode code: String) {
        delegate?.didScanBarcode(withCode: code)
    }
}

class ScanOverlayView: UIView {
    private let cornerRadius: CGFloat = 24
    private let cutoutWidth: CGFloat = 300
    private let cutoutHeight: CGFloat = 175
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }

    private func setupOverlay() {
        backgroundColor = .clear

        // Configure the blur effect view
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        blurEffectView.isUserInteractionEnabled = false // Ensure it doesn't block touches
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blurEffectView.frame = bounds
        drawCutout()
    }

    private func drawCutout() {
        // Create the full screen path
        let fullScreenPath = UIBezierPath(rect: bounds)

        // Calculate the center rectangle frame
        let cutoutRect = CGRect(
            x: (bounds.width - cutoutWidth) / 2,
            y: (bounds.height - cutoutHeight) / 2,
            width: cutoutWidth,
            height: cutoutHeight
        )

        // Create the cutout path with rounded corners
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: cornerRadius)

        // Append the cutout path to the full screen path
        fullScreenPath.append(cutoutPath)
        fullScreenPath.usesEvenOddFillRule = true

        // Configure the mask layer for the blur effect view
        let maskLayer = CAShapeLayer()
        maskLayer.path = fullScreenPath.cgPath
        maskLayer.fillRule = .evenOdd

        // Apply the mask to the blur effect view
        blurEffectView.layer.mask = maskLayer
    }
}


protocol ScannerViewControllerDelegate: AnyObject {
    func didScanBarcode(withCode code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        // Select the ultra-wide camera (0.5x)
        guard let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {
            print("Ultra-wide camera is not available on this device.")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: ultraWideCamera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Failed to add ultra-wide camera input to the capture session.")
                return
            }
        } catch {
            print("Failed to create video input for ultra-wide camera: \(error.localizedDescription)")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        } else {
            print("Failed to add metadata output to the capture session.")
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            delegate?.didScanBarcode(withCode: stringValue)
        }
    }
}
