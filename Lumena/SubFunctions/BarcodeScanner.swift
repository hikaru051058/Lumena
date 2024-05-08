//
//  BarcodeScanner.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/18.
//

import SwiftUI
import AVFoundation


struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isShowingScanner: Bool
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // Update any parameters or settings on the scanner view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        @Binding var scannedCode: String
        @Binding var isShowingScanner: Bool
        
        init(scannedCode: Binding<String>, isShowingScanner: Binding<Bool>) {
            _scannedCode = scannedCode
            _isShowingScanner = isShowingScanner
        }
        
        func didScanBarcode(withCode code: String) {
            scannedCode = code
            isShowingScanner = false
        }
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
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Failed to add video input to the capture session")
                return
            }
            
            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
                try videoCaptureDevice.lockForConfiguration()
                videoCaptureDevice.focusMode = .continuousAutoFocus
                videoCaptureDevice.unlockForConfiguration()
            }
            
        } catch {
            print("Failed to create video input: \(error.localizedDescription)")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        } else {
            print("Failed to add metadata output to the capture session")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestCameraPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            guard let stringValue = readableObject.stringValue else { return }
            delegate?.didScanBarcode(withCode: stringValue)
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.showCameraPermissionAlert()
                }
            }
        }
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Please grant permission to use the camera.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}


struct ScanOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .frame(width: CGFloat(150), height: CGFloat(50), alignment: .center)
                    .blendMode(.destinationOut)
                
            }.compositingGroup()
        }
    }
}


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
