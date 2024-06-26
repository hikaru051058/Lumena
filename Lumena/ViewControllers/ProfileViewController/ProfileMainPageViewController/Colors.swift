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
    
    static var arinLightGreen: UIColor   {
        return UIColor(red: 0.863, green: 0.948, blue: 0.92, alpha: 1)
    }
    
    static var aginGreenColorScheme: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .arinDarkGreen : .arinLightGreen
        }
    }
    
    static var twitterGray: UIColor {
        return UIColor.gray
    }
}

extension UIColor {
    static var primary: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }
    }

    static var secondary: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.lightGray : UIColor.darkGray
        }
    }
}

extension UIColor{
    static let background: UIColor  = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()
}
