//
//  Reel.swift
//  Reels (iOS)
//
//  Created by Balaji on 29/06/21.
//

import SwiftUI
import AVKit
import Amplify
import Foundation
import UIKit

class ReelClass {
    
    static let shared = ReelClass()

    func saveToTemporaryLocation(data: Data, fileExtension: String) -> URL? {
        let tempDirectory = NSTemporaryDirectory()
        let fileName = UUID().uuidString
        let fileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving data to temporary location:", error)
            return nil
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
