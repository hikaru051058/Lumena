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
    
    static var arinPink: UIColor    {
        return UIColor(red: 0.946, green: 0.76, blue: 0.839, alpha: 1)
    }
    
    static var twitterGray: UIColor {
        return UIColor.gray
    }
}

extension UIColor {
    static var arinDarkPink: UIColor    {
        return UIColor(red: 0.867, green: 0.773, blue: 0.843, alpha: 1)
    }
    
    static var arinYellow: UIColor {
        return UIColor(red: 1, green: 0.859, blue: 0.651, alpha: 1)
    }
    
    
}

extension UIColor {
    static var arinGreen: UIColor   {
        return UIColor(red: 0.723, green: 0.88, blue: 0.825, alpha: 1)
    }
    
    static var arinLightGreen: UIColor   {
        return UIColor(red: 0.863, green: 0.948, blue: 0.92, alpha: 1)
    }
    
    static var arinDarkGreen: UIColor   {
        return UIColor(red: 0.452, green: 0.634, blue: 0.521, alpha: 1)
    }
    
    static var arinDarkestGreen: UIColor   {
        return UIColor(red: 50/255, green: 60/255, blue: 57/255, alpha: 1)
    }
    
    static var arinMatGreen: UIColor {
        return UIColor(red: 0.49, green: 0.629, blue: 0.53, alpha: 1)
    }
    
    static var aginGreenColorScheme: UIColor {
        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? .arinDarkGreen : .arinLightGreen
        }
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


extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        
        return nil
    }
    
    static func color(from description: String?) -> UIColor {
        guard let description = description, !description.isEmpty else {
            return .clear
        }
        
        return UIColor(hex: description) ?? .clear
    }
}

extension UIColor {
    func saturated(by factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            saturation = min(saturation * factor, 1.0)
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        
        return self
    }
}
