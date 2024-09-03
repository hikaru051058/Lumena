// ProfileCell.swift
// InstagramTransition
//
// Created by Kolos Foltanyi on 2023. 07. 22..
//

import UIKit
import AVKit

class ProfileCell: UICollectionViewCell {

    // MARK: UI Properties

    private let imageView = ImageView()
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    var thumbnailURL: URL?
    var fitOrFill: UIView.ContentMode = .scaleAspectFill
    var heightScale: CGFloat = 0.0

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Data

    func setup(with lume: Lume) {
        // Stop any previous video playback
        stopVideoPlayback()
        
        DispatchQueue.main.async { [self] in
            if let firstContent = lume.contents.first {
                switch firstContent {
                case .image(let lumeImage):
                    // Fetch and display the image thumbnail
                    Task {
                        if let thumbnail = await lume.getThumbnailImage() {
                            
                            var thumbnailAspectRatio: CGSize
                            if thumbnail.size.width > thumbnail.size.height {
                                thumbnailAspectRatio = thumbnail.size
                                thumbnailAspectRatio.width = thumbnailAspectRatio.width
                                thumbnailAspectRatio.height = thumbnailAspectRatio.height
                            } else {
                                thumbnailAspectRatio = UIScreen.main.bounds.size
                            }
                            
                            let croppedThumbnail = cropImage(thumbnail, to: thumbnailAspectRatio)
                            if let tempURL = saveImageToTemporaryDirectory(image: croppedThumbnail) {
                                thumbnailURL = tempURL
                                imageView.setImage(from: tempURL)
                            }
                        }
                    }
                    
                case .video(let lumeVideo):
                    // Setup and play the video in the cell
                    if let videoURL = lumeVideo.getVideoURL() {
                        setupVideoPlayer(with: videoURL)
                    } else {
                        print("Failed to retrieve video URL.")
                    }
                    
                    var thumbnail: UIImage = UIImage()
                    
                    if let asset = player?.currentItem,
                        let newThumbnail = generateThumbnail(asset: asset.asset) {
                        thumbnail = newThumbnail
                    }
                    
                    var thumbnailAspectRatio: CGSize
                    if thumbnail.size.width > thumbnail.size.height {
                        thumbnailAspectRatio = thumbnail.size
                        thumbnailAspectRatio.width = thumbnailAspectRatio.width
                        thumbnailAspectRatio.height = thumbnailAspectRatio.height
                    } else {
                        thumbnailAspectRatio = UIScreen.main.bounds.size
                    }
                    
                    let croppedThumbnail = cropImage(thumbnail, to: thumbnailAspectRatio)
                    if let tempURL = saveImageToTemporaryDirectory(image: croppedThumbnail) {
                        thumbnailURL = tempURL
                        imageView.setImage(from: tempURL)
                    }
                    
                case .text(let lumeText):
                    // Generate and display a text thumbnail
                    imageView.image = generateTextThumbnail(from: lumeText)
                    
                }
            } else {
                // Handle case where there's no content
                if let placeholderURL = Bundle.main.url(forResource: "placeholder", withExtension: "jpg") {
                    imageView.setImage(from: placeholderURL)
                }
            }
        }
    }
    
    private func generateThumbnail(asset: AVAsset) -> UIImage? {
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }

    private func setupVideoPlayer(with url: URL) {
        // Setup the video player
        player = AVPlayer(url: url)
        player?.isMuted = true
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = imageView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        imageView.layer.addSublayer(playerLayer!)
        
        // Play the video after a brief delay to ensure the UI is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.player?.play()
            
            var thumbnail: UIImage = UIImage()
            
            if let asset = player?.currentItem,
                let newThumbnail = generateThumbnail(asset: asset.asset) {
                thumbnail = newThumbnail
            }
            
            var thumbnailAspectRatio: CGSize
            if thumbnail.size.width > thumbnail.size.height {
                thumbnailAspectRatio = thumbnail.size
                thumbnailAspectRatio.width = thumbnailAspectRatio.width
                thumbnailAspectRatio.height = thumbnailAspectRatio.height
            } else {
                thumbnailAspectRatio = UIScreen.main.bounds.size
            }
            
            let croppedThumbnail = cropImage(thumbnail, to: thumbnailAspectRatio)
            if let tempURL = saveImageToTemporaryDirectory(image: croppedThumbnail) {
                thumbnailURL = tempURL
                imageView.setImage(from: tempURL)
            }
        }
    }

    private func stopVideoPlayback() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
    }

    private func generateTextThumbnail(from text: String) -> UIImage? {
        // Create a thumbnail image with the text content
        let size = CGSize(width: 300, height: 300)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        defer { UIGraphicsEndImageContext() }
        
        UIColor(named: "arinBlue")?.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = CGRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        attributedText.draw(in: textRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func cropImage(_ image: UIImage, to size: CGSize) -> UIImage {
        
        fitOrFill = (image.size.width > image.size.height) ? .scaleAspectFit : .scaleAspectFill
        
        let aspectRatio = image.size.width / image.size.height
        let targetAspectRatio = size.width / size.height
        
        let scale: CGFloat
        if aspectRatio > targetAspectRatio {
            scale = size.height / image.size.height
        } else {
            scale = size.width / image.size.width
            heightScale = UIScreen.main.bounds.size.height / size.height
        }
        
        let width = image.size.width * scale
        let height = image.size.height * scale
        let x = (size.width - width) / 2.0
        let y = (size.height - height) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: cropRect)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage ?? image
    }

    private func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
        let imageData = image.jpegData(compressionQuality: 1.0)
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        do {
            try imageData?.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image to temporary directory: \(error)")
            return nil
        }
    }
}

// MARK: - Reuse

extension ProfileCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        stopVideoPlayback() // Stop video playback and reset the player
        thumbnailURL = nil
    }
}

// MARK: - Setup

extension ProfileCell {
    private func setupUI() {
        setupImageView()
    }

    private func setupImageView() {
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.masksToBounds = true
            contentView.addSubview($0)
            contentView.fillWith($0)
        }
    }
}
