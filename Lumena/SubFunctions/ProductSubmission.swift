//
//  productSubmission.swift
//  MyPalette
//
//  Created by 島田晃 on 2024/02/29.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation
import Photos


enum Field: Hashable {
    case productName
    case companyName
    case barcode
    case type
}

struct ProductSubmission: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var cameraModel = CameraViewModel(session: AVCaptureSession())
    @State var selectedImage: [ImageExtractorAsset]? = nil
    
    @StateObject var imagePicker = ImageExtractorViewModel()
    
    
    @State var showImagePicker: Bool = false
    @State private var showCamera: Bool = false
    
    
    @State private var cosmeticModel: Cosmetic?
    
    @State private var productName: String = ""
    @State private var companyName: String = ""
    @State private var Barcode: String = ""
    @State private var type: String = ""
    
    @FocusState var focusedField: Field?

    
    @State var selectedImageItems: [ImageExtractorAsset] = []
    @State var selectedImageItemsForShow: [ImageExtractorAsset] = []
    
    @State var maxImageCnt: Int = 3
    
    @State private var errorRetryUpload: Bool = false
    
    @State private var uploadProgress: Double = 0.0
    @State private var uploading: Bool = false
    
    var dropDownList = ["マスカラ", "シャドー", "チーク", "リップ", "アイライナー", "ファンデーション", "コンシーラー", "化粧水・乳液", "香水"]
    
    var body: some View {
        
        NavigationView{
            
            VStack(alignment: .leading){
                
                HStack{
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                    })
                    .disabled(uploading)
                    
                    Text("コスメ登録")
                    
                    Image(systemName: "text.badge.plus")
                    
                    Spacer()
                }
                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)
                
                
                ZStack{
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                        .shadow(radius: 5)
                    
                    
                    VStack{
                        
                        HStack{
                            
                            if selectedImageItems.isEmpty {
                                
                                Menu{
                                    if selectedImageItems.count < maxImageCnt{
                                        Button("Camera", action: {showCamera.toggle()})
                                    }
                                    Button("Photo Library", action: {showImagePicker.toggle()})
                                } label: {
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .frame(width: 120, height: 120)
                                            .foregroundColor(Color.secondary)
                                        
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color.white)
                                    }
                                    .shadow(radius: 5)
                                }
                                .disabled(uploading)
                                
                            } else {
                                
                                CardStack(selectedImageItemsForShow) { item in
                                    
                                    // Subsequent items - Show the image
                                    if let uiItemImage = item.image, uiItemImage != UIImage() {
                                        
                                        Image(uiImage: uiItemImage)
                                            .resizable()
                                            .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
                                            .shadow(radius: 5)
                                            .overlay(
                                                Button(action: {
                                                    
                                                    if let index = selectedImageItemsForShow.firstIndex(where: {$0.id == item.id}) {
                                                        selectedImageItemsForShow.remove(at: index) // Remove the item at the found index
                                                    }
                                                    
                                                    if let index = selectedImageItems.firstIndex(where: {$0.id == item.id}) {
                                                        selectedImageItems.remove(at: index) // Remove the item at the found index
                                                        imagePicker.selectedPhotos = selectedImageItems
                                                    }
                                                    
                                                    if selectedImageItems.count < 5 {
                                                        selectedImageItemsForShow.insert(contentsOf: [ImageExtractorAsset(asset: PHAsset(), image: UIImage())], at: 0)
                                                    }
                                                
                                                }) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.red)
                                                            .frame(width: 20, height: 20)
                                                        
                                                        Image(systemName: "xmark")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                    }
                                                    .padding(5)
                                                }
                                                    .disabled(uploading)
                                                ,
                                                alignment: .topTrailing
                                            )
                                        
                                    } else {
                                        
                                        Menu{
                                            Button("Camera", action: {showCamera.toggle()})
                                            Button("Photo Library", action: {showImagePicker.toggle()})
                                        } label: {
                                            
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .frame(width: 120, height: 120)
                                                    .foregroundColor(Color.secondary)
                                                
                                                Image(systemName: "plus")
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(Color.white)
                                            }
                                            .shadow(radius: 5)
                                        }
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(16)
                                        .disabled(uploading)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack{
                                
                                Spacer()
                                
                                Text("\(selectedImageItems.count)/5 selected")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(Color.secondary)
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 40)
                        
                        Group{
                            CustomTextField(text: $productName, placeholder: "商品名", focused: $focusedField, thisField: .productName, nextField: .companyName)
                            CustomTextField(text: $companyName, placeholder: "会社名", focused: $focusedField, thisField: .companyName, nextField: .barcode)
                            CustomBarCodeField(text: $Barcode, placeholder: "バーコード", focused: $focusedField, thisField: .barcode)
                            CustomDropDownField(text: $type, options: dropDownList, placeholder: "種類")
                        }
                        .disabled(uploading)
                    }
                    .padding(.vertical)
                }
                
                Button(action: {
                    uploadCosmetic()
                }){
                    
                    HStack{
                        
                        Spacer()
                        
                        ZStack{
                            
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53).opacity((
                                    selectedImageItems.isEmpty ||
                                     productName == "" ||
                                     companyName == "" ||
                                     Barcode == "" ||
                                      type == "") ? 0.3 : 1)
                                )
                            
                           
                            if uploading {
                                
                                CircularProgressView(progress: $uploadProgress, baseColor: .white, progressColor: .white)
                                    .frame(width: 40, height: 40)
                                
                            } else {
                                Image(systemName: errorRetryUpload ? "arrow.counterclockwise" : "arrow.up")
                                    .foregroundColor(errorRetryUpload ? Color.red : Color.white )
                                    .fontWeight(.bold)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.top, 80)
                .disabled(
                    selectedImageItems.isEmpty ||
                    productName == "" ||
                    companyName == "" ||
                    Barcode == "" ||
                    type.isEmpty ||
                    uploading
                )
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicView(cameraModel: cameraModel, selectedImageItems: $selectedImageItems, maxCnt: maxImageCnt)
                .onDisappear{

                    imagePicker.selectedPhotos = selectedImageItems
                    
                    if selectedImageItems.count < 5 {
                        selectedImageItemsForShow = [ImageExtractorAsset(asset: PHAsset(), image: UIImage())]
                    } else {
                        selectedImageItemsForShow = []
                    }
                    selectedImageItemsForShow.append(contentsOf: selectedImageItems)
                }
        }
        .sheet(isPresented: $showImagePicker) {
            
            NavigationStack {
                
                ImageSelectorSheetView(imagePicker: imagePicker, isFocused: $showImagePicker, maxCnt: maxImageCnt, imageOnly: true)
            }
            .onDisappear{
                
                selectedImageItems = imagePicker.selectedPhotos
                
                if selectedImageItems.count < 5 {
                    selectedImageItemsForShow = [ImageExtractorAsset(asset: PHAsset(), image: UIImage())]
                } else {
                    selectedImageItemsForShow = []
                }
                selectedImageItemsForShow.append(contentsOf: selectedImageItems)
            }
        }
        .onAppear{
            imagePicker.setUp()
        }
        .navigationBarHidden(true)
    }
    
    func uploadCosmetic() {
        uploading = true
        errorRetryUpload = false
        
        cosmeticModel = Cosmetic(id: Barcode, cosmeticID: Barcode, barcode: Barcode, productName: productName, companyID: companyName, productImages: selectedImageItems, type: type)
        
        Task {
            do {
                let _ = try await cosmeticModel?.uploadCosmeticQL(progressHandler: { progress in
                    DispatchQueue.main.async {
                        withAnimation {
                            uploadProgress = progress
                        }
                    }
                })
                GI.shared.cosmeticSubmission = cosmeticModel
                uploading = false
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error during upload: \(error)")
                DispatchQueue.main.async {
                    uploading = false
                    errorRetryUpload = true
                }
            }
        }
    }

}

struct CircularProgressView: View {
    @Binding var progress: Double
    var baseColor: Color  // Color for the background circle
    var progressColor: Color  // Color for the progress circle

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    baseColor.opacity(0.5),
                    lineWidth: 5
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}



struct CameraPicView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var cameraModel: CameraViewModel
    @Binding var selectedImageItems: [ImageExtractorAsset]
    var maxCnt: Int
    
    @State private var showLight: Bool = false
    @State private var lightRadius: CGFloat = 0
    
    @State var sliderMaxHeight: CGFloat = UIScreen.main.bounds.height / 6
    @State var sliderProgress: CGFloat = 0
    @State var sliderHeight: CGFloat = 0
    @State var sliderLastDragValue: CGFloat = 0
    
    @State private var CamVid: Bool = false // false = cam
    
    @State private var musicTag: Bool = false
    
    
    
    @State private var colorTemperature: CGFloat = 2700
    
    private func colorForTemperature(_ temperature: CGFloat) -> Color {
        // Normalize temperature range to [0, 1]
        let normalizedTemperature = (temperature - 2700) / (7000 - 2700)
        
        // Define warm and cool colors
        let warmColor = Color(red: 255/255, green: 138/255, blue: 18/255) // Warm light
        let coolColor = Color(red: 155/255, green: 176/255, blue: 255/255) // Cool light
        
        // Interpolate between warm and cool colors
        let red = warmColor.components.red + (coolColor.components.red - warmColor.components.red) * normalizedTemperature
        let green = warmColor.components.green + (coolColor.components.green - warmColor.components.green) * normalizedTemperature
        let blue = warmColor.components.blue + (coolColor.components.blue - warmColor.components.blue) * normalizedTemperature
        
        return Color(red: red, green: green, blue: blue)
    }
    
    
    var body: some View {
        
        ZStack{
            
            if showLight {
                Color.white
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
            // MARK: Camera View
            CameraView(musicPlaying: $musicTag)
                .environmentObject(cameraModel)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .ignoresSafeArea()
                .overlay(
                    ZStack{
                        if(showLight){
                            
                            RadialGradient(gradient: Gradient(colors: [.clear, .white.opacity(lightRadius/100)]), center: .center, startRadius: lightRadius, endRadius: lightRadius + 200 )
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(showLight ? .white.opacity(lightRadius/100) : Color.clear, lineWidth: 40)
                        }
                    }
                )
                .padding(.bottom,50)
            
            
            // MARK: Controls
            ZStack{
                
                Button(action: {
                    
                    // Setup after action of capturedImage saved
                    cameraModel.onImageCaptured = { capturedImage in
                        let capturedImageItem = ImageExtractorAsset(asset: PHAsset(), image: capturedImage)
                        selectedImageItems.append(capturedImageItem)
                    }

                    // Now, when you call takePhoto, the onImageCaptured closure will handle appending the image
                    cameraModel.takePhoto()
                    
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(cameraModel.isRecording ? .red : (showLight ? Color.black : Color.white), lineWidth: 3))
                        .frame(width: 70, height: 70)
                        .padding(.bottom, 25)
                }
                .disabled(selectedImageItems.count > 5)
            }
            .frame(maxHeight: .infinity,alignment: .bottom)
            .padding(.bottom,50)
            
            
            HStack{
                
                VStack{
                    
                    Button(action: {
                        
                        if cameraModel.previewURL != nil{
                            cameraModel.resetCameraViewModel()
                            
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                        
                    }){
                        Image(systemName: (cameraModel.previewURL != nil) ? "checkmark.circle.fill" : "xmark")
                            .font(Font.system(size: 25).weight(.bold))
                            .foregroundColor((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack{
                    
                    Button(action: {
                        withAnimation{
                            cameraModel.showLight.toggle()
                            showLight.toggle()
                            
                            if !showLight {
                                
                                lightRadius = 0
                                sliderLastDragValue = 0
                                sliderProgress = 0
                            }
                        }
                        
                        if cameraModel.currentCameraPosition == .back {
                            if(cameraModel.showLight){
                                
                                cameraModel.setUp(type: .wide)
                            } else {
                                
                                cameraModel.setFlashlight(level: Float(0.0))
                            }
                        }
                        
                    }){
                        Image(systemName: "lightbulb.fill")
                            .padding(.bottom, showLight ? 0 : 30)
                            .foregroundColor((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                    }
                    
                    if(showLight){
                        
                        ZStack(alignment: .bottom, content: {
                            
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                            
                            Rectangle()
                                .fill(Color(red: 0.552, green: 0.724, blue: 0.831))
                                .frame(height: sliderHeight)
                        })
                        .frame(width: 30, height: sliderMaxHeight)
                        .cornerRadius(35)
                        .gesture(DragGesture(minimumDistance: 0).onChanged({ (value) in
                            
                            let translation = value.translation
                            sliderHeight = -translation.height + sliderLastDragValue
                            
                            sliderHeight = sliderHeight > sliderMaxHeight ? sliderMaxHeight : sliderHeight
                            sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                            
                            let progress = sliderHeight / sliderMaxHeight
                            sliderProgress = progress <= 1.0 ? progress : 1
                            
                            if let currentCameraInput = cameraModel.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) {
                                if currentCameraInput.device.position == .back {
                                    cameraModel.setFlashlight(level: Float(sliderProgress))
                                } else {
                                    lightRadius = sliderProgress * 100
                                }
                            }
                        }).onEnded({ (value) in
                            sliderHeight = sliderHeight > sliderMaxHeight ? sliderMaxHeight : sliderHeight
                            sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                            sliderLastDragValue = sliderHeight
                        }))
                    }
                    
                    Spacer()
                }
                .foregroundColor(showLight ? .black : .white)
                .font(.title)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            VStack{
                Spacer()
                
                HStack(alignment: .center){
                    
                    if !musicTag {
                        Button(action: {
                            cameraModel.switchCamera()
                            withAnimation{
                                lightRadius = 0
                                sliderLastDragValue = 0
                                sliderProgress = 0
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(showLight ? .black : .white)
                                .font(.title3)
                        }
                    } else {
                        // Empty frame with clear background color
                        Color.clear
                            .frame(width: 40, height: 40)
                            .hidden()
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarHidden(true)
    }
}


struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    
    @FocusState.Binding var focused: Field?
    var thisField: Field?
    var nextField: Field?

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(NSLocalizedString(placeholder, comment: "Field name for product submission"))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    .focused($focused, equals: thisField)
                    .submitLabel(.next)
                    .onSubmit {
                        if let nextField = nextField {
                            focused = nextField // Corrected assignment
                        }
                    }
                    .padding(.horizontal, 5)

                Spacer()
            }
            Divider()
                .frame(minHeight: 1)
                .overlay(Color.secondary)

            Spacer()
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 50)
    }
}

struct CustomBarCodeField: View {
    @Binding var text: String
    var placeholder: String
    
    @FocusState.Binding var focused: Field?
    var thisField: Field?

    
    @State private var isShowingScanner = false
    @State private var SearchOutputShow: Bool = false
    @State private var scannedCode: String = ""

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(NSLocalizedString(placeholder, comment: "Field name for product submission"))
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    .focused($focused, equals: thisField)
                    .submitLabel(.next)
                    .padding(.horizontal, 5)

                Spacer()
                
                Button(action: {
                    isShowingScanner = true
                }) {
                    
                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(Color.secondary)
                        .font(Font.system(size: 16, weight: .bold))
                }
                .padding(.horizontal, 5)
                
                Spacer()
            }
            
            Divider()
                .frame(minHeight: 1)
                .overlay(Color.secondary)

            Spacer()
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 50)
        .sheet(isPresented: $isShowingScanner) {
            VStack {
                ZStack {
                    ScannerView(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
                        .aspectRatio(contentMode: .fill)
                        .padding(.bottom, UIScreen.main.bounds.height/2)
                        .frame(width: UIScreen.main.bounds.width)
                        .clipped()
                        .cornerRadius(25)
                    
                    ScanOverlayView() // Add ScanOverlayView here
                    
                    VStack {
                        Text("バーコードをスキャン")
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 70)
                        
                        Text("枠内にバーコードを収めてください")
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .font(.body)
                            .padding(.bottom)
                    }
                }
                .padding(.horizontal)
            }
            .foregroundColor(Color.primary)
            .presentationDetents(
                [
                    .height(UIScreen.main.bounds.height * 0.25)
                ]
            )
        }
        .onChange(of: isShowingScanner) { change in
            if !change {
                if(scannedCode != ""){
                    text = scannedCode
                    scannedCode = ""
                    withAnimation {
                        SearchOutputShow = true
                    }
                }
            }
        }
    }
}

struct CustomDropDownField: View {
    @Binding var text: String
    var options: [String]
    var placeholder: String

    var body: some View {
        VStack {
            HStack {
                Menu {
                    ForEach(options, id: \.self){ client in
                        Button(NSLocalizedString(client, comment: "DropDown list option for product submission")) {
                            self.text = client
                        }
                    }
                } label: {
                    VStack{
                        HStack{
                            Text(NSLocalizedString(text.isEmpty ? placeholder : text, comment: "DropDown list option for product submission"))
                                .foregroundColor(text.isEmpty ? .gray : .primary)
                                .font(text.isEmpty ? .footnote : .callout)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.secondary)
                                .font(Font.system(size: 16, weight: .bold))
                        }
                    }
                }
                .padding(.horizontal, 5)

                Spacer()
            }
            Divider()
                .frame(minHeight: 1)
                .overlay(Color.secondary)

            Spacer()
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 20)
        .frame(minHeight: 50)
    }
}
