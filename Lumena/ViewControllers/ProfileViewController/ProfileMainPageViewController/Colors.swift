//
//  Colors.swift
//  TwitterProfile_Example
//
//  Created by ugur on 25.08.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    static var customGray: UIColor {
        return UIColor(white: 0.9, alpha: 1.0)
    }
    
    static var arinBlue: UIColor    {
        return UIColor(red: 0.552, green: 0.724, blue: 0.831, alpha: 1)
    }
    
    static var arinGreen: UIColor   {
        return UIColor(red: 0.723, green: 0.88, blue: 0.825, alpha: 1)
    }
    
    static var arinPink: UIColor    {
        return UIColor(red: 0.946, green: 0.76, blue: 0.839, alpha: 1)
    }
    
    static var arinDarkGreen: UIColor   {
        return UIColor(red: 0.452, green: 0.634, blue: 0.521, alpha: 1)
    }
    
    static var twitterGray: UIColor {
        return UIColor.gray
    }
    
    // Dynamic colors for light and dark mode
    static var primary: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    static var secondary: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .lightGray : .darkGray
        }
    }
}
