//
//  GI.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/12.
//

// Global Index for constants

import Foundation
import Amplify

class GI: ObservableObject {
    static let shared = GI()
    
    var tracks: [Track] = []
    
    // MARK: -- User Attributes
    var identityID: String?
    var profileSettings: ProfileSettings?
    var userProfileQL: UserProfileQL?
    var userPosts: [String]?
    
    var cosmeticSubmission: Cosmetic?
    
    var postUploadProgress: Double = 0.0
    var postUploading: Bool = false
    
}
