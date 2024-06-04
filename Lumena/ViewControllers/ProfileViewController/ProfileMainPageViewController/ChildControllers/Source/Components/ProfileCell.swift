// ProfileCell.swift
// InstagramTransition
//
// Created by Kolos Foltanyi on 2023. 07. 22..
//

import UIKit

class ProfileCell: UICollectionViewCell {

    // MARK: UI Properties

    private let imageView = ImageView()
    
    var thumbnailURL: URL? // Add this property
    var fitOrFill: UIView.ContentMode = .scaleAspectFill

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
        Task {
            if let thumbnail = await lume.generateThumbnail() {
                
                var thumbnailAspectRatio: CGSize
                if thumbnail.size.width > thumbnail.size.height {
                    thumbnailAspectRatio = thumbnail.size
                    thumbnailAspectRatio.width = thumbnailAspectRatio.width * 0.5
                    thumbnailAspectRatio.height = thumbnailAspectRatio.height * 0.5
                } else {
                    thumbnailAspectRatio = UIScreen.main.bounds.size
                }
                
                let croppedThumbnail = cropImage(thumbnail, to: thumbnailAspectRatio)
                if let tempURL = saveImageToTemporaryDirectory(image: croppedThumbnail) {
                    thumbnailURL = tempURL
                    imageView.setImage(from: tempURL)
                }
            } else {
                // Handle case where thumbnail generation fails
                if let placeholderURL = Bundle.main.url(forResource: "placeholder", withExtension: "jpg") {
                    imageView.setImage(from: placeholderURL)
                }
            }
        }
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
