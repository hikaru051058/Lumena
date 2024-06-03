//
//  ImageExtractor.swift
//  MyPalette
//
//  Created by 島田晃 on 2024/01/30.
//

import SwiftUI
import Photos
import AVKit

class ImageExtractorViewModel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    @Published var showImagePicker = false
    
    @Published var library_status = LibraryStatus.denied
    
    // List Of Fetched Photos...
    
    @Published var fetchedPhotos : [ImageExtractorAsset] = []
    
    // To Get Updates....
    @Published var allPhotos : PHFetchResult<PHAsset>!
    
    // Preview...
    @Published var showPreview = false
    @Published var selectedImagePreview: UIImage!
    @Published var selectedVideoPreview: AVAsset!
    
    @Published var selectedPhotos: [ImageExtractorAsset] = []
    
    @Published var allAssets: [PHAsset] = []
    private let fetchLimit = 50
    private var lastFetchedIndex = 0
    
    func openImagePicker(fullRes: Bool = false){
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if fetchedPhotos.isEmpty{
            
            fetchPhotos(fullRes: fullRes)
        }
        
        
        withAnimation{showImagePicker.toggle()}
    }
    
    func setUp(){
        
        // requesting Permission...
        PHPhotoLibrary.requestAuthorization(for: .readWrite) {[self] (status) in
            
            DispatchQueue.main.async { [self] in
                
                switch status{
                    
                case .denied: library_status = .denied
                case .authorized: library_status = .approved
                case .limited: library_status = .limited
                default : library_status = .denied
                }
            }
        }
        
        // Registering Observer...
        PHPhotoLibrary.shared().register(self)
        
        loadAllAssets()
    }
    
    // Listeneing To Changes...
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let _ = allPhotos else{return}
        
        if let updates = changeInstance.changeDetails(for: allPhotos){
            
            // Getting Updated List...
            let updatedPhotos = updates.fetchResultAfterChanges

            updatedPhotos.enumerateObjects {[self] (asset, index, _) in
                
                if !allPhotos.contains(asset){
                    
                    // If its not There...
                    // getting Image And Appending it to array...
                    
                    getImageFromAsset(asset: asset, size: CGSize(width: 150, height: 150)) { (image) in
                        DispatchQueue.main.async { [self] in
                            fetchedPhotos.append(ImageExtractorAsset(asset: asset, image: image))
                        }
                    }
                }
            }
            
            // To Remove If Image is removed...
            allPhotos.enumerateObjects { (asset, index, _) in
                
                if !updatedPhotos.contains(asset){
                    
                    // removing it...
                    DispatchQueue.main.async {
                        
                        self.fetchedPhotos.removeAll { (result) -> Bool in
                            return result.asset == asset
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.allPhotos = updatedPhotos
            }
        }
    }
    
    func fetchPhotos(fullRes: Bool = false) {
        guard lastFetchedIndex < allAssets.count else { return }

        let endIndex = min(lastFetchedIndex + fetchLimit, allAssets.count)
        let assetsToFetch = Array(allAssets[lastFetchedIndex..<endIndex])

        for asset in assetsToFetch {
            getImageFromAsset(asset: asset, size: CGSize(width: (fullRes ? asset.self.pixelWidth : 150), height: (fullRes ? asset.self.pixelHeight : 150))) { [weak self] (image) in
                DispatchQueue.main.async {
                    // Check if this asset's localIdentifier is already in fetchedPhotos
                    if !(self?.fetchedPhotos.contains(where: { $0.asset.localIdentifier == asset.localIdentifier }) ?? false) {
                        self?.fetchedPhotos.append(ImageExtractorAsset(asset: asset, image: image))
                    }
                }
            }
        }

        lastFetchedIndex = endIndex
    }
    
    func loadAllAssets() {
        let allOptions = PHFetchOptions()
        allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allFetchResults = PHAsset.fetchAssets(with: allOptions)
        
        allFetchResults.enumerateObjects { (asset, _, _) in
            self.allAssets.append(asset)
        }
    }
    
    func getImageFromAsset(asset: PHAsset,size: CGSize,completion: @escaping (UIImage)->()){
        
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        
        // Your Own Properties For Images...
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        imageOptions.isSynchronous = false
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: imageOptions) { (image, _) in
            
            guard let resizedImage = image else{return}
            
            completion(resizedImage)
        }
    }
    
    
    func toggleImageSelection(asset: PHAsset) {
        if let index = selectedPhotos.firstIndex(where: { $0.asset == asset }) {
            // Image already selected, remove it
            selectedPhotos.remove(at: index)
        } else {
            // Handle video assets
            if asset.mediaType == .video {
                getVideoFromAsset(asset: asset) { [weak self] (url) in
                    self?.generateThumbnailForVideoAsset(asset) { thumbnail in
                        self?.selectedPhotos.append(ImageExtractorAsset(asset: asset, image: thumbnail, videoURL: url, isVideo: true))
                    }
                }
            } else if asset.mediaType == .image {
                // Handle image assets as before
                getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { [weak self] (image) in
                    self?.selectedPhotos.append(ImageExtractorAsset(asset: asset, image: image, videoURL: nil, isVideo: false))
                }
            }
        }
    }

    
    func extractPreviewData(asset: PHAsset){
        
        let manager = PHCachingImageManager()
        
        if asset.mediaType == .image{
            
            // Extract Image..
            
            getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { (image) in
                
                DispatchQueue.main.async {
                    self.selectedImagePreview = image
                }
            }
        }
        
        if asset.mediaType == .video{
            
            // Extract Video...
            
            let videoManager = PHVideoRequestOptions()
            videoManager.deliveryMode = .highQualityFormat
            
            manager.requestAVAsset(forVideo: asset, options: videoManager) { (videoAsset, _, _) in
                
                guard let videoUrl = videoAsset else{return}
                
                DispatchQueue.main.async {
                    
                    self.selectedVideoPreview = videoUrl
                }
            }
        }
    }
    
    func getVideoFromAsset(asset: PHAsset, completion: @escaping (URL?)->()) {
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, audioMix, info) in
            guard let urlAsset = avAsset as? AVURLAsset else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(urlAsset.url)
            }
        }
    }
    
    func fetchInitialPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 100
        
        let fetchResults = PHAsset.fetchAssets(with: options)
        allPhotos = fetchResults
        
        fetchResults.enumerateObjects { (asset, _, _) in
            self.fetchedPhotos.append(ImageExtractorAsset(asset: asset))
        }
    }
    
    func generateThumbnailForVideoAsset(_ asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, audioMix, info) in
            guard let avAsset = avAsset else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let assetImgGenerate = AVAssetImageGenerator(asset: avAsset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 600)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
    func loadThumbnailForAsset(_ asset: PHAsset, completion: @escaping (UIImage) -> Void) {
        let size = CGSize(width: 150, height: 150)
        getImageFromAsset(asset: asset, size: size, completion: completion)
    }
}


extension ImageExtractorViewModel {
    
    // Function to convert selected photos to a Content array
    func fetchContents(completion: @escaping ([Content]) -> Void) {
        var contents: [Content] = []
        
        let dispatchGroup = DispatchGroup()
        
        for imageExtractorAsset in selectedPhotos {
            dispatchGroup.enter()
            let asset = imageExtractorAsset.asset
            
            if asset.mediaType == .image {
                // Assuming the image already loaded in ImageExtractorAsset
                if let image = imageExtractorAsset.image {
                    let reelImage = LumeImage(image: image, url: nil) // Assuming URL would be fetched or set differently
                    contents.append(.image(reelImage))
                    dispatchGroup.leave()
                } else {
                    // If image is not preloaded, load it
                    loadThumbnailForAsset(asset) { image in
                        let reelImage = LumeImage(image: image)
                        contents.append(.image(reelImage))
                        dispatchGroup.leave()
                    }
                }
            } else if asset.mediaType == .video {
                extractVideoData(asset: asset) { player in
                    var reelVideo = LumeVideo(player: player)
                    reelVideo.mute() // Mute by default, change as needed
                    contents.append(.video(reelVideo))
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(contents)
        }
    }
    
    func fetchLastImage(completion: @escaping (UIImage?) -> Void) {
        guard let lastAsset = selectedPhotos.last?.asset else {
            completion(nil)
            return
        }
        
        if lastAsset.mediaType == .image {
            if let preloadedImage = selectedPhotos.last?.image {
                completion(preloadedImage)
            } else {
                getImageFromAsset(asset: lastAsset, size: PHImageManagerMaximumSize) { image in
                    completion(image)
                }
            }
        } else {
            completion(nil)
        }
    }
   
    // Helper function for extracting video data remains the same
    private func extractVideoData(asset: PHAsset, completion: @escaping (AVPlayer?) -> Void) {
        let manager = PHCachingImageManager()
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        manager.requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            guard let avAsset = avAsset else {
                completion(nil)
                return
            }
            
            let playerItem = AVPlayerItem(asset: avAsset)
            let player = AVPlayer(playerItem: playerItem)
            
            completion(player)
        }
    }
}



enum LibraryStatus {

    case denied
    case approved
    case limited
}

struct ImageExtractorAsset: Identifiable {
    var id = UUID()
    var asset: PHAsset
    var image: UIImage? // Used for both image assets and video thumbnails
    var videoURL: URL?
    var isVideo: Bool = false // Indicates if the asset is a video
}



struct ImageSelectorSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var imagePicker: ImageExtractorViewModel
    
    @Binding var isFocused: Bool
    
    var maxCnt: Int
    
    var imageOnly: Bool = false
    
    
    var body: some View {
        
        ZStack{
            
            VStack {
                
                ScrollView(showsIndicators: false) {
                    // Embedding LazyVGrid inside List
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(imagePicker.fetchedPhotos.filter { photo in
                            // If imageOnly is true, filter out videos. Otherwise, include all assets.
                            return !imageOnly || photo.asset.mediaType == .image
                        }) { photo in
                            Button(action: {
                                let isCurrentlySelected = imagePicker.selectedPhotos.contains(where: { $0.asset == photo.asset })
                                
                                // Toggle selection only if not exceeding maxCnt or if deselecting
                                if !isCurrentlySelected {
                                    if imagePicker.selectedPhotos.count < maxCnt {
                                        imagePicker.toggleImageSelection(asset: photo.asset)
                                    }
                                } else {
                                    // Always allow deselection
                                    imagePicker.toggleImageSelection(asset: photo.asset)
                                }
                                
                            }) {
                                ThumbnailView(imagePicker: imagePicker, photo: photo)
                                    .frame(width: (UIScreen.main.bounds.width - 50) / 3, height: (UIScreen.main.bounds.width - 50) / 3)
                            }
                            .onAppear {
                                if let fetchedPhotoAsset = imagePicker.fetchedPhotos.last?.asset,
                                   photo.asset == fetchedPhotoAsset {
                                    imagePicker.fetchPhotos()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            VStack {
                
                Spacer()
                
                ZStack {
                    
                    VStack {
                        
                        Text("Selected: \(imagePicker.selectedPhotos.count)/\(maxCnt)")
                            .font(.footnote)
                            .bold()
                            .foregroundColor(Color.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(imagePicker.selectedPhotos.enumerated()), id: \.element.id) { (index, photo) in
                                    
                                    Button(action: {
                                        
                                        imagePicker.toggleImageSelection(asset: photo.asset)
                                        
                                    }, label: {
                                        
                                        if let image = photo.image {
                                            
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(10)
                                                .overlay(
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.blue)
                                                            .frame(width: 16, height: 16)
                                                        
                                                        Text("\(index + 1)")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                    },
                                                    alignment: .topTrailing
                                                )
                                            
                                        } else {
                                            
                                            Color.gray
                                                .frame(width: 60, height: 60)
                                                .cornerRadius(10)
                                                .overlay(
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.blue)
                                                            .frame(width: 16, height: 16)
                                                        
                                                        Text("\(index + 1)")
                                                            .font(.caption)
                                                            .foregroundColor(.white)
                                                    },
                                                    alignment: .topTrailing
                                                )
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(32)
//                .frame(height: 75)
                .opacity(imagePicker.selectedPhotos.isEmpty ? 0 : 1)
                .padding(.horizontal)
            }
        }
        .onAppear{
            imagePicker.openImagePicker()
        }
        .toolbar {
            ToolbarItem {
                Button(imagePicker.selectedPhotos.isEmpty ? "Close": "Done") {
                    isFocused = false
                }
            }
        }
        .toolbarBackground(.hidden)
    }
    
    
    struct ThumbnailView: View {
        
        @ObservedObject var imagePicker: ImageExtractorViewModel
        var photo: ImageExtractorAsset
        var size: CGFloat = (UIScreen.main.bounds.width - 50) / 3
        
        var body: some View {
            let isSelected = imagePicker.selectedPhotos.contains(where: { $0.asset == photo.asset })
            let index = isSelected ? imagePicker.selectedPhotos.firstIndex(where: { $0.asset == photo.asset }) : nil

            ZStack(alignment: .bottomTrailing, content: {
                if let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .overlay(
                            Color.gray.opacity(isSelected ? 0.65 : 0)
                        )
                        .cornerRadius(10)

                    if isSelected, let index = index {
                        indexOverlay(index: index)
                    }
                    
                    if photo.asset.mediaType == .video {
                        Image(systemName: "video.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                    }
                } else {
                    Color.gray.frame(width: size, height: size)
                        .cornerRadius(10)
                        .onAppear {
                            imagePicker.loadThumbnailForAsset(photo.asset) { image in
                                if let index = imagePicker.fetchedPhotos.firstIndex(where: { $0.id == photo.id }) {
                                    imagePicker.fetchedPhotos[index].image = image
                                }
                            }
                        }
                        .overlay(
                            isSelected && index != nil ? indexOverlay(index: index!) : nil,
                            alignment: .topTrailing
                        )
                }
            })
        }

        @ViewBuilder
        private func indexOverlay(index: Int) -> some View {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 22, height: 22)
                
                Text("\(index + 1)")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}



public struct CardStack<Data, Content>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Content: View {
    @State private var currentIndex: Double = 0.0
    @State private var previousIndex: Double = 0.0
    
    private let data: Data
    @ViewBuilder private let content: (Data.Element) -> Content
    @Binding var finalCurrentIndex: Int
    
    /// Creates a stack with the given content
    /// - Parameters:
    ///   - data: The identifiable data for computing the list.
    ///   - currentIndex: The index of the topmost card in the stack
    ///   - content: A view builder that creates the view for a single card
    public init(_ data: Data, currentIndex: Binding<Int> = .constant(0), @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        _finalCurrentIndex = currentIndex
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.element.id) { (index, element) in
                content(element)
                    .zIndex(zIndex(for: index))
                    .offset(x: xOffset(for: index), y: 0)
                    .scaleEffect(scale(for: index), anchor: .center)
                    .rotationEffect(.degrees(rotationDegrees(for: index)))
            }
        }
        .highPriorityGesture(dragGesture)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring()) {
                    let x = (value.translation.width / 300) - previousIndex
                    self.currentIndex = -x
                }
            }
            .onEnded { value in
                self.snapToNearestAbsoluteIndex(value.predictedEndTranslation)
                self.previousIndex = self.currentIndex
            }
    }
    
    private func snapToNearestAbsoluteIndex(_ predictedEndTranslation: CGSize) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 40)) {
            let translation = predictedEndTranslation.width
            if abs(translation) > 200 {
                if translation > 0 {
                    self.goTo(round(self.previousIndex) - 1)
                } else {
                    self.goTo(round(self.previousIndex) + 1)
                }
            } else {
                self.currentIndex = round(currentIndex)
            }
        }
    }
    
    private func goTo(_ index: Double) {
        let maxIndex = Double(data.count - 1)
        if index < 0 {
            self.currentIndex = 0
        } else if index > maxIndex {
            self.currentIndex = maxIndex
        } else {
            self.currentIndex = index
        }
        self.finalCurrentIndex = Int(self.currentIndex)
    }
    
    private func zIndex(for index: Int) -> Double {
        if (Double(index) + 0.5) < currentIndex {
            return -Double(data.count - index)
        } else {
            return Double(data.count - index)
        }
    }
    
    private func xOffset(for index: Int) -> CGFloat {
        let topCardProgress = currentPosition(for: index)
        let padding = 35.0
        let x = ((CGFloat(index) - currentIndex) * padding)
        if topCardProgress > 0 && topCardProgress < 0.99 && index < (data.count - 1) {
            return x * swingOutMultiplier(topCardProgress)
        }
        return x
    }
    
    private func scale(for index: Int) -> CGFloat {
        return 1.0 - (0.1 * abs(currentPosition(for: index)))
    }
    
    private func rotationDegrees(for index: Int) -> Double {
        return -currentPosition(for: index) * 2
    }
    
    private func currentPosition(for index: Int) -> Double {
        currentIndex - Double(index)
    }
    
    private func swingOutMultiplier(_ progress: Double) -> Double {
        return sin(Double.pi * progress) * 15
    }
}
