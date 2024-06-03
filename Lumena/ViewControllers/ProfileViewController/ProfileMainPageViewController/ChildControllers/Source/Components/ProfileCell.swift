//
//  ProfileCell.swift
//  InstagramTransition
//
//  Created by Kolos Foltanyi on 2023. 07. 22..
//

import UIKit

class ProfileCell: UICollectionViewCell {

    // MARK: UI Properties

    private let imageView = ImageView()

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
                if let tempURL = saveImageToTemporaryDirectory(image: thumbnail) {
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
