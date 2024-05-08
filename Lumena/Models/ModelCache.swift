//
//  ModelCache.swift
//  MyPalette
//
//  Created by 島田晃 on 2024/04/21.
//

import Foundation
import UIKit


class AnyCacheBox {
    // Base type to enable non-generic handling
    func clear() {}
}

class CacheBox<T: Codable>: AnyCacheBox {
    let cache = NSCache<NSString, CachedItem<T>>()

    override func clear() {
        cache.removeAllObjects()
    }
}

class CachedItem<T: Codable>: NSObject {
    let model: T

    init(model: T) {
        self.model = model
    }
}

class CacheManager {
    static let shared = CacheManager()

    private var caches = [String: AnyCacheBox]()

    private init() {}

    func cache<T: Codable>(for type: T.Type) -> NSCache<NSString, CachedItem<T>> {
        let typeName = String(describing: type)
        if let cacheBox = caches[typeName] as? CacheBox<T> {
            return cacheBox.cache
        }

        let newCacheBox = CacheBox<T>()
        caches[typeName] = newCacheBox
        return newCacheBox.cache
    }

    func clearAllCaches() {
        caches.values.forEach { $0.clear() }
    }
}


class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}  // Ensures singleton usage and prevents external initialization

    // Stores the image in the cache with the given identifier.
    func store(image: UIImage, forId identifier: String) {
        cache.setObject(image, forKey: identifier as NSString)
    }

    // Retrieves an image from the cache if available.
    func image(forId identifier: String) -> UIImage? {
        return cache.object(forKey: identifier as NSString)
    }

    // Removes an image from the cache with the given identifier.
    func removeImage(forId identifier: String) {
        cache.removeObject(forKey: identifier as NSString)
    }

    // Clears the entire image cache.
    func clearCache() {
        cache.removeAllObjects()
    }
}
