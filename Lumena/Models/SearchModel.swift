//
//  SearchModel.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/09/27.
//

import Foundation
import UIKit
import SwiftUI

struct SearchCategory: Identifiable {
    
    let id = UUID()
    var category: String
    var icon: Image
    var products: [Cosmetic]
    
    init(category: String = "null", icon: Image = Image(systemName: "cross.vial.fill"), products: [Cosmetic]) {
        self.category = category
        self.icon = icon
        self.products = products
    }
}
