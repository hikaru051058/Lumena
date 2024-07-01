//
//  CosmeticModel.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/09/27.
//

import Foundation
import UIKit
import SwiftUI
import Zip
import Photos

struct SliderConfiguration {
    var title: String
    var minRating: String
    var maxRating: String
}

class TagCosmetic: Identifiable, ObservableObject {
    
    let id = UUID()
    
    var cosmeticID: String
    var cosmeticItem: Cosmetic?
    
    var recommendRating: Double
    var effectRating: Double
    var fadingRating: Double
    var feelingRating: Double
    
    var attachedURL: String?
    
    var authProduct: Bool
    
    init(cosmeticID: String, cosmeticItem: Cosmetic = Cosmetic(),
         recommendRating: Double = 0.0, effectRating: Double = 0.0, fadingRating: Double = 0.0, feelingRating: Double = 0.0, attachedURL: String = "", authProduct: Bool = false
    ) {
        
        self.cosmeticID = cosmeticID
        self.cosmeticItem = cosmeticItem
        self.recommendRating = recommendRating
        self.effectRating = effectRating
        self.fadingRating = fadingRating
        self.feelingRating = feelingRating
        self.attachedURL = attachedURL
        self.authProduct = authProduct
    }
    
    init(from tagCosmetic: TagCosmetic) {
        
        self.cosmeticID = tagCosmetic.cosmeticID
        self.cosmeticItem = tagCosmetic.cosmeticItem
        self.recommendRating = tagCosmetic.recommendRating
        self.effectRating = tagCosmetic.effectRating
        self.fadingRating = tagCosmetic.fadingRating
        self.feelingRating = tagCosmetic.feelingRating
        self.attachedURL = tagCosmetic.attachedURL
        self.authProduct = tagCosmetic.authProduct
    }
    
    init(ql: TagCosmeticQL) {
        
        self.cosmeticID = ql.cosmeticID
        self.authProduct = ql.authProduct
        self.recommendRating = ql.recommend ?? 0
        self.effectRating = ql.effect ?? 0
        self.fadingRating = ql.fading ?? 0
        self.feelingRating = ql.feeling ?? 0
        self.attachedURL = ql.attachedURL
        self.cosmeticItem = Cosmetic(id: ql.cosmeticID)
    }
    
    func toTagCosmeticQL() -> TagCosmeticQL {
        return TagCosmeticQL(
            cosmeticID: self.cosmeticID,
            authProduct: self.authProduct,
            recommend: self.recommendRating, 
            effect: self.effectRating,
            fading: self.fadingRating,
            feeling: self.feelingRating, 
            attachedURL: self.attachedURL
        )
    }
}




class CosmeticsWrapper: ObservableObject {
    
    @Published var cosmetics: [Cosmetic] = []
    
    func fetchRandomCosmetics() async throws {
        do {
            let returnedCosmetics = try await GraphQL.shared.fetchRandomCosmetic()
            DispatchQueue.main.async {
                self.cosmetics = returnedCosmetics
            }
            print("cosmetics created in fetchrandomcosmetics")
        } catch {
            
            print(error)
        }
    }
}

class Cosmetic: Identifiable, ObservableObject {
    let id: UUID
    let cosmeticID: String
    var barcode: String
    
    var productName: String
    var companyID: String
    var price: String
    var amount: String
    @Published var productImages: [ImageExtractorAsset]?
    var totTagCount: Int
    var authenticated: Bool
    var url: [String?]
    var type: String
    var zipURL: String
    
    init(id: String = "", cosmeticID: String = "",  barcode: String = "", productName: String = "null", companyID: String = "null", price: String = "0", amount: String = "null", productImages: [ImageExtractorAsset] = [], totTagCount: Int = 0, authenticated: Bool = false, url: [String?] = [], type: String = "", zipURL: String = "") {
        
        self.id = UUID(uuidString: id) ?? UUID(uuidString: barcode) ?? UUID()
        self.cosmeticID = cosmeticID
        self.barcode = barcode
        self.productName = productName
        self.companyID = companyID
        self.price = price
        self.amount = amount
        self.productImages = productImages
        self.totTagCount = totTagCount
        self.authenticated = authenticated
        self.url = url
        self.type = type
        self.zipURL = zipURL
    }
    
    convenience init(id: String) {
        
        self.init(cosmeticID: id)
        
        Task {
            do {
                let newCosmetic = try await Self.getCachedOrNew(cosmeticID: id)
                CosmeticManager.shared.updateCosmetic(newCosmetic!)
            } catch {
                print(error)
            }
        }
    }
    
    convenience init(ql: CosmeticQL) {
        
        self.init(
            id: ql.id,
            cosmeticID: ql.id,
            barcode: ql.id,
            productName: ql.productName,
            companyID: ql.companyID,
            price: ql.price ?? "",
            amount: ql.amount ?? "",
            productImages: [],
            totTagCount: ql.totTagCount ?? 0,
            authenticated: ql.authenticated,
            url: ql.link ?? [],
            type: ql.type ?? "",
            zipURL: ql.zipURL ?? ""
        )
        
        if self.zipURL == "" {
            self.zipURL = "https://d2jkiteuyn8e9n.cloudfront.net/public/cosmetics/\(self.cosmeticID).zip"
        }
        
        Task {
            do {
                let _ = try await self.downloadAndExtractImages()
                CosmeticManager.shared.updateCosmetic(self)
            } catch {
                print("Error in init using ql for cosmetics: ", error)
            }
        }
    }
    
    func toCosmeticQL() -> CosmeticQL {
        
        return CosmeticQL(
            id: self.cosmeticID,
            productName: self.productName,
            companyID: self.companyID,
            price: self.price,
            amount: self.amount,
            totTagCount: self.totTagCount,
            authenticated: self.authenticated,
            link: self.url,
            type: self.type
        )
    }
}


class CosmeticManager: ObservableObject {
    
    static let shared = CosmeticManager()
    
    @Published var cosmetics: [String: Cosmetic] = [:]
    
    var downloadedImagesCache: Set<String> = []
    
    private var currentlyDownloading = Set<String>()
    private let downloadQueue = DispatchQueue(label: "com.nucr.gotdns.org.Lumena.cosmeticManager.downloading")
    
    private init() {}
    
    func getCosmetic(withID id: String) async throws -> Cosmetic {
        if let existing = cosmetics[id] {
            return existing
        } else {
            do {
                // Check if it's currently downloading to avoid simultaneous downloads
                if !isCurrentlyDownloading(id) {
                    markAsDownloading(id)
                    let cosmeticFetched = try await getCosmeticAPI(with: id)
                    if let cosmeticFetched = cosmeticFetched {
                        DispatchQueue.main.async {
                            self.cosmetics[id] = cosmeticFetched
                            self.markDownloadComplete(id)
                        }
                        print("CosmeticManager: has downloaded: \(id)")
                        return cosmeticFetched
                    }
                }
            } catch {
                print("Failed to fetch cosmetic with ID \(id): \(error)")
            }
            return Cosmetic(id: id) // Return a placeholder if not found
        }
    }
    
    func getCosmetic(withID id: String) -> Cosmetic {
        if let existing = cosmetics[id] {
            return existing
        } else {
            return Cosmetic(id: id)
        }
    }
    
    func getCosmeticQueue(withID id: String) async throws {
        let cosmetic = Cosmetic(id: id)
        CosmeticManager.shared.updateCosmetic(cosmetic)
        DispatchQueue.main.async {
            self.cosmetics[id] = cosmetic
        }
    }
    
    func getCosmeticAPI(with cosmeticID: String) async throws -> Cosmetic? {
        do {
            if cosmeticID != "" {
                let arrCosmetic = try await GraphQL.shared.fetchCosmetic(cosmeticID: [cosmeticID])
                guard let cosmetic = arrCosmetic.first else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: No Cosmetic has been returned when called fetchCosmetic for \(cosmeticID)"])
                }
                return cosmetic
            } else {
                return nil
            }
        } catch {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error: Unknown error occured while fetching cosmetic: \(error)"])
        }
    }
    
    func updateCosmetic(_ cosmetic: Cosmetic) {
        DispatchQueue.main.async { [self] in
            cosmetics[cosmetic.cosmeticID] = cosmetic
            objectWillChange.send()
        }
    }
    
    private func isCurrentlyDownloading(_ id: String) -> Bool {
        downloadQueue.sync {
            return currentlyDownloading.contains(id)
        }
    }
    
    private func markAsDownloading(_ id: String) {
        let _ = downloadQueue.sync {
            currentlyDownloading.insert(id)
        }
    }
    
    private func markDownloadComplete(_ id: String) {
        let _ = downloadQueue.sync {
            currentlyDownloading.remove(id)
        }
    }
}


extension Cosmetic {
    
    static func getCachedOrNew(cosmeticID: String) async throws -> Cosmetic? {
        
        do {
            let result = try await CosmeticManager.shared.getCosmetic(withID: cosmeticID)
            return result
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func updateSelf(cosmetic: Cosmetic) async {
        DispatchQueue.main.async {
            self.barcode = cosmetic.barcode
            self.productName = cosmetic.productName
            self.companyID = cosmetic.companyID
            self.price = cosmetic.price
            self.amount = cosmetic.amount
            self.productImages = cosmetic.productImages
            self.totTagCount = cosmetic.totTagCount
            self.authenticated = cosmetic.authenticated
            self.url = cosmetic.url
            self.type = cosmetic.type
            self.zipURL = cosmetic.zipURL
        }
    }
}


extension Cosmetic {
    
    func uploadCosmeticQL(progressHandler: @escaping (Double) -> Void) async throws -> String {
        
        guard let productImages = self.productImages, !productImages.isEmpty else {
            throw NSError(domain: "com.nucr.gotdns.Lumena.cosmeticUploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No product images to upload."])
        }
        
        // Try creating a CosmeticQL model asynchronously
        _ = try await GraphQL.shared.createModel(self.toCosmeticQL())
        print("CosmeticQL model created successfully.")
        
        let fileManager = FileManager.default
        let tempDirectory = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: NSTemporaryDirectory()), create: true)
        try saveProductImagesToDirectory(directory: tempDirectory, productImages: productImages)
        
        let zipFilePath = try zipDirectory(at: tempDirectory, zipFileName: "cosmetics.zip")
        let zipData = try Data(contentsOf: zipFilePath)
        let zipFileName = "\(self.cosmeticID).zip"
        let zipFileLocation = "cosmetics/\(zipFileName)"
        
        // Store data asynchronously and await the result
        _ = try await S3.shared.storeDataAsync(name: zipFileLocation, data: zipData, accessLevel: "public", progressHandler: { progress in
            progressHandler(progress)  // Call the closure passed by the caller
            print("Upload Progress: \(progress * 100)%")
        })
        print("Successfully uploaded cosmetic data.")
        
        // Clean up the temporary directory and zip file
        try? fileManager.removeItem(at: tempDirectory)
        try? fileManager.removeItem(at: zipFilePath)
        
        return "Upload successful"
        
    }
    
//    private func uploadCosmeticQLZip(progressHandler: @escaping (Double) -> Void) async throws -> String {
//        guard let productImages = self.productImages, !productImages.isEmpty else {
//            throw NSError(domain: "com.nucr.gotdns.Lumena.cosmeticUploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No product images to upload."])
//        }
//        
//        // Try creating a CosmeticQL model asynchronously
//        _ = try await GraphQL.shared.createModel(self.toCosmeticQL())
//        print("CosmeticQL model created successfully.")
//        
//        let fileManager = FileManager.default
//        let tempDirectory = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: NSTemporaryDirectory()), create: true)
//        try saveProductImagesToDirectory(directory: tempDirectory, productImages: productImages)
//        
//        let zipFilePath = try zipDirectory(at: tempDirectory, zipFileName: "cosmetics.zip")
//        let zipData = try Data(contentsOf: zipFilePath)
//        let zipFileName = "\(self.cosmeticID).zip"
//        let zipFileLocation = "cosmetics/\(zipFileName)"
//        
//        // Store data asynchronously and await the result
//        _ = try await S3.shared.storeDataAsync(name: zipFileLocation, data: zipData, accessLevel: "public", progressHandler: { progress in
//            progressHandler(progress)  // Call the closure passed by the caller
//            print("Upload Progress: \(progress * 100)%")
//        })
//        print("Successfully uploaded cosmetic data.")
//        
//        // Clean up the temporary directory and zip file
//        try? fileManager.removeItem(at: tempDirectory)
//        try? fileManager.removeItem(at: zipFilePath)
//        
//        return "Upload successful"
//    }
//
//    private func generateCompressedImage() {
//        
//        
//    }

    private func saveProductImagesToDirectory(directory: URL, productImages: [ImageExtractorAsset]) throws {
        for (index, imageAsset) in productImages.enumerated() {
            guard let image = imageAsset.image else { continue }
            let imagePath = directory.appendingPathComponent("image\(index).jpg")
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            try imageData.write(to: imagePath)
        }
    }
    
    private func zipDirectory(at directory: URL, zipFileName: String) throws -> URL {
        let zipFilePath = directory.appendingPathComponent(zipFileName)
        try Zip.zipFiles(paths: [directory], zipFilePath: zipFilePath, password: nil, progress: nil)
        return zipFilePath
    }
    
    
    func downloadAndExtractImages() async throws -> String {
        // Create a key prefix for caching images
        let cacheKeyPrefix = "\(self.cosmeticID)_image"
        
        // Check for images in cache first
        var cachedImages = [ImageExtractorAsset]()
        var index = 0
        while let image = ImageCache.shared.image(forId: "\(cacheKeyPrefix)\(index)") {
            cachedImages.append(ImageExtractorAsset(asset: PHAsset(), image: image))
            index += 1
        }
        
        if !cachedImages.isEmpty {
            self.productImages = cachedImages
            return "Images loaded from cache for \(self.cosmeticID)"
        }
        
        // Download and extract images if not in cache
        guard self.zipURL != "", let zipURL = URL(string: self.zipURL) else {
            throw NSError(domain: "ExtractionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No zipURL provided for \(self.cosmeticID) image"])
        }
        
        let zipFileUrl = try await downloadZipFile(from: zipURL)
        let destinationUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("extractedImages")
        try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
        try extractZipFile(at: zipFileUrl, to: destinationUrl)
        
        guard let extractedImages = convertImagesToImageExtractorAssets(from: destinationUrl) else {
            throw NSError(domain: "ExtractionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Images to extract from zip file"])
        }
        
        // Store each extracted image in the cache with a unique key
        for (i, asset) in extractedImages.enumerated() {
            if let image = asset.image {
                ImageCache.shared.store(image: image, forId: "\(cacheKeyPrefix)\(i)")
            }
        }
        
        // Clean up the zip file and extracted contents
        try FileManager.default.removeItem(at: zipFileUrl)
        try FileManager.default.removeItem(at: destinationUrl)
        
        self.productImages = extractedImages
        return "Successfully fetched and cached images for \(self.cosmeticID)"
    }
    
    private func downloadZipFile(from url: URL) async throws -> URL {
        let (tempFileUrl, response) = try await URLSession.shared.download(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "DownloadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to download zip file"])
        }
        
        let fileManager = FileManager.default
        let uniqueFileName = UUID().uuidString + "_" + url.lastPathComponent
        let permanentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(uniqueFileName)
        
        if fileManager.fileExists(atPath: permanentUrl.path) {
            try fileManager.removeItem(at: permanentUrl)
        }
        
        try fileManager.moveItem(at: tempFileUrl, to: permanentUrl)
        return permanentUrl
    }
    
    private func extractZipFile(at sourceUrl: URL, to destinationUrl: URL) throws {
        let fileManager = FileManager.default
        // Ensure the destination directory exists
        if !fileManager.fileExists(atPath: destinationUrl.path) {
            try fileManager.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        try Zip.unzipFile(sourceUrl, destination: destinationUrl, overwrite: true, password: nil)
    }
    
    private func convertImagesToImageExtractorAssets(from directory: URL) -> [ImageExtractorAsset]? {
        let fileManager = FileManager.default
        var returnAssets: [ImageExtractorAsset] = []
        
        // Use enumerator to recursively iterate through the directory and its subdirectories
        if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles], errorHandler: nil) {
            for case let fileUrl as URL in enumerator {
                do {
                    let fileAttributes = try fileUrl.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        guard let image = UIImage(contentsOfFile: fileUrl.path) else {
                            print("Failed to load image from path: \(fileUrl.path)")
                            continue // Skip to the next file
                        }
                        let imageAsset = ImageExtractorAsset(asset: PHAsset(), image: image)
                        returnAssets.append(imageAsset)
                    }
                } catch {
                    print("Error accessing file \(fileUrl.path): \(error)")
                    continue // Skip to the next file
                }
            }
        }
        
        return returnAssets.isEmpty ? nil : returnAssets
    }
}

extension Cosmetic: Equatable {
    static func == (lhs: Cosmetic, rhs: Cosmetic) -> Bool {
        return lhs.id == rhs.id
    }
}
