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
    @Published var cosmeticItem: Cosmetic?
    
    var recommendRating: Double
    var effectRating: Double
    var fadingRating: Double
    var feelingRating: Double
    
    var attachedURL: String?
    
    var authProduct: Bool
    
    init(cosmeticID: String, cosmeticItem: Cosmetic? = nil,
         recommendRating: Double = 0.0, effectRating: Double = 0.0, fadingRating: Double = 0.0, feelingRating: Double = 0.0, attachedURL: String = "", authProduct: Bool = false) {
        
        self.cosmeticID = cosmeticID
        self.cosmeticItem = cosmeticItem
        self.recommendRating = recommendRating
        self.effectRating = effectRating
        self.fadingRating = fadingRating
        self.feelingRating = feelingRating
        self.attachedURL = attachedURL
        self.authProduct = authProduct
        
        Task {
            await fetchAndAssignCosmetic()
        }
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
        self.recommendRating = ql.recommend ?? 0.0
        self.effectRating = ql.effect ?? 0.0
        self.fadingRating = ql.fading ?? 0.0
        self.feelingRating = ql.feeling ?? 0.0
        self.attachedURL = ql.attachedURL
        self.cosmeticItem = Cosmetic(id: ql.cosmeticID)
        
        Task {
            await fetchAndAssignCosmetic()
        }
    }
    
    @MainActor
    private func fetchAndAssignCosmetic() async {
        do {
            let fetchedCosmetic = try await CosmeticManager.shared.getCosmetic(withID: cosmeticID)
            self.cosmeticItem = fetchedCosmetic
        } catch {
            print("Failed to fetch cosmetic: \(error)")
        }
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
    var cosmeticID: String
    var productName: String
    var companyID: String
    
    @Published var productImages: [ImageExtractorAsset]?
    
    var totTagCount: Int?
    var authenticated: Bool?
    var description: String?
    var rating: Double?
    var category: String?
    var productType: String?
    var imageURL: [String]?
    var productUrl: String?
    
    var createdAt: Int?
    var updatedAt: Int?
    
    var variants: [CosmeticVariant]? = []
    var criteriaTags: [String]? = []
    var ingredients: [String]? = []
    
    var barcode: [String]? = []
    
    var cosmeticBrandQL: CosmeticBrandQL?
    
    init(id: String = "",
             cosmeticID: String = "",
             barcode: [String] = [],
             productName: String = "null",
             companyID: String = "null",
             productImages: [ImageExtractorAsset] = [],
             description: String = "null",
             category: String = "null",
             totTagCount: Int = 0,
             authenticated: Bool = false,
             productUrl: String = "",
             createdAt: Int = 0,
             updatedAt: Int = 0,
             productType: String = "",
             rating: Double = 0.0,
             criteriaTags: [String] = [],
             variants: [CosmeticVariant] = [],
             imageURL: [String] = [],
             cosmeticBrandQL: CosmeticBrandQL = CosmeticBrandQL()
    ) {
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.cosmeticID = cosmeticID
        self.barcode = barcode
        self.productName = productName
        self.companyID = companyID
        self.productImages = productImages
        self.description = description
        self.category = category
        self.totTagCount = totTagCount
        self.authenticated = authenticated
        self.productUrl = productUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.productType = productType
        self.rating = rating
        self.criteriaTags = criteriaTags
        self.variants = variants
        self.imageURL = imageURL
        self.cosmeticBrandQL = cosmeticBrandQL
    }
    
    convenience init(ql: CosmeticQL) {
        
        var newImageURL: [String] = []
        var newIngredients: [String] = []
        
        if let qlVariants = ql.variants {
            for variant in qlVariants {
                newImageURL.append(contentsOf: variant.imageURL ?? [])
                newIngredients.append(contentsOf: variant.ingredientIDs ?? [])
            }
        }
        
        self.init(
            id: ql.id,
            cosmeticID: ql.id,
            productName: ql.productName,
            companyID: ql.cosmeticbrandqlID,
            description: ql.description ?? "",
            category: ql.category ?? "",
            totTagCount: ql.totPostTagCount ?? 0,
            authenticated: ql.authenticated ?? false,
            createdAt: Int(ql.createdAt ?? 0),
            updatedAt: Int(ql.updatedAt ?? 0) ,
            productType: ql.productType ?? "",
            rating: ql.rating ?? 0.0,
            criteriaTags: ql.criteriaTags ?? [],
            variants: ql.variants ?? []
        )
        
        Task {
            await self.fetchCosmeticBrandQL()
            await self.downloadProductImages()
            CosmeticManager.shared.updateCosmetic(self)
        }
    }
    
    func toCosmeticQL() -> CosmeticQL {
        return CosmeticQL(
            id: self.cosmeticID,
            productName: self.productName,
//            totPostTagCount: self.totTagCount,
            authenticated: self.authenticated ?? false,
            cosmeticbrandqlID: self.companyID,
            description: self.description,
//            rating: self.rating,
            category: self.category,
            productType: self.productType,
            imageURL: self.imageURL,
            productURL: self.productUrl,
//            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            variants: self.variants
//            criteriaTags: self.criteriaTags
        )
    }
}

extension Cosmetic {
    
    func returnProductURL() -> URL? {
        guard let productURL = self.productUrl, !productURL.isEmpty else { return nil }
        return URL(string: productURL)
    }
    
    func returnImageURL() -> [URL]? {
        guard let imageURL = self.imageURL, !imageURL.isEmpty else { return nil }
        let newURLs = imageURL.compactMap { URL(string: $0) }
        return newURLs.isEmpty ? nil : newURLs
    }
    
    func isProductURLEmpty() -> Bool {
        guard let productURL = self.productUrl, !productURL.isEmpty else { return true }
        return false
    }
    
    func isImageURLEmpty() -> Bool {
        guard let imageURL = self.imageURL, !imageURL.isEmpty else { return true }
        return false
    }
    
    private func fetchCosmeticBrandQL() async {
        self.cosmeticBrandQL = await CosmeticBrandManager.shared.getCosmeticBrandQL(withID: companyID)
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
            // Check if it's currently downloading to avoid simultaneous downloads
            if !isCurrentlyDownloading(id) {
                markAsDownloading(id)
                defer {
                    markDownloadComplete(id)
                }
                do {
                    let cosmeticFetched = try await getCosmeticAPI(with: id)
                    if let cosmeticFetched = cosmeticFetched {
                        DispatchQueue.main.async {
                            self.cosmetics[id] = cosmeticFetched
                        }
                        print("CosmeticManager: has downloaded: \(id)")
                        return cosmeticFetched
                    }
                } catch {
                    print("Failed to fetch cosmetic with ID \(id): \(error)")
                }
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
                let arrCosmetic = try await GraphQL.shared.fetchCosmetic(cosmeticIDs: [cosmeticID])
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
    
    func updateSelf(cosmetic: Cosmetic) {
        DispatchQueue.main.async {
            self.barcode = cosmetic.barcode
            self.productName = cosmetic.productName
            self.companyID = cosmetic.companyID
            self.productImages = cosmetic.productImages
            self.description = cosmetic.description
            self.category = cosmetic.category
            self.totTagCount = cosmetic.totTagCount
            self.authenticated = cosmetic.authenticated
            self.productUrl = cosmetic.productUrl
            self.createdAt = cosmetic.createdAt
            self.updatedAt = cosmetic.updatedAt
            self.productType = cosmetic.productType
            self.rating = cosmetic.rating
            self.criteriaTags = cosmetic.criteriaTags
            self.imageURL = cosmetic.imageURL
        }
    }
}

// upload
extension Cosmetic {
    
    func uploadCosmeticQL(progressHandler: @escaping (Double) -> Void) async throws -> String {
        
        guard let productImages = self.productImages, !productImages.isEmpty else {
            throw NSError(domain: "com.nucr.gotdns.Lumena.cosmeticUploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No product images to upload."])
        }
        
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
        
        // Try creating a CosmeticQL model asynchronously
        _ = try await GraphQL.shared.createModel(self.toCosmeticQL())
        print("CosmeticQL model created successfully.")
        
        GraphQL.shared.postCosmeticQLUploadProcess(cosmeticID: self.cosmeticID)
        
        return "Upload successful"
    }
    
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
    
    func downloadProductImages() async {
        
        guard let imageURL = self.returnImageURL() else { return }
        
        let downloader = ImageDownloader()
        
        await withTaskGroup(of: ImageExtractorAsset?.self) { group in
            for url in imageURL {
                group.addTask {
                    return try? await ImageExtractorAsset.create(from: url)
                }
            }
            
            for await asset in group {
                if let asset = asset {
                    await downloader.addAsset(asset)
                }
            }
        }
        
        let assets = await downloader.getAssets()
        
        DispatchQueue.main.async {
            self.productImages = assets
        }
    }
    
    func generateCosmeticQLID() -> String {
        // Sanitize and replace spaces with underscores
        let sanitizedProductName = self.productName.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
        let sanitizedCompanyName = self.companyID.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
        
        // Use fallback values if necessary
        let finalProductName = sanitizedProductName.isEmpty ? "Unknown_Product" : sanitizedProductName
        let finalCompanyName = sanitizedCompanyName.isEmpty ? "Unknown_Brand" : sanitizedCompanyName
        
        // Concatenate the sanitized strings
        let cosmeticQLID = "\(finalProductName)-\(finalCompanyName)"
        self.cosmeticID = cosmeticQLID
        
        return cosmeticQLID
    }

}

extension Cosmetic: Equatable {
    static func == (lhs: Cosmetic, rhs: Cosmetic) -> Bool {
        return lhs.id == rhs.id
    }
}


class CosmeticBrandManager: ObservableObject {
    
    static let shared = CosmeticBrandManager()
    
    @Published var cosmeticBrands: [String: CosmeticBrandQL] = [:]
    
    // Ensure that updates to `cosmeticBrands` happen on the main thread
    @MainActor
    func getCosmeticBrandQL(withID id: String) async -> CosmeticBrandQL? {
        if let existingCosmeticBrandQL = cosmeticBrands[id] {
            return existingCosmeticBrandQL
        } else {
            if id.isEmpty {
                print("NULL id detected in getCosmeticBrandQL async")
                return nil
            }
            do {
                let returnedModel = try await GraphQL.shared.queryAmplify(for: CosmeticBrandQL.self, modelID: id)
                // Ensure this operation happens on the main thread
                cosmeticBrands[id] = returnedModel
                return returnedModel
            } catch {
                print(error)
            }
            return nil
        }
    }
}

