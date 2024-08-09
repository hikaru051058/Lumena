//
//  Extensions.swift
//  TwitterProfile_Example
//
//  Created by ugur on 10.09.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIView{
    func bordered(lineWidth: CGFloat, strokeColor: UIColor = UIColor.background){
        let path = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: self.frame.width/2)
        let borderLayer = CAShapeLayer()
        borderLayer.lineWidth = lineWidth
        borderLayer.strokeColor = strokeColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = self.bounds
        borderLayer.path = path.cgPath
        self.layer.addSublayer(borderLayer)
    }
    
    func rounded(insets: UIEdgeInsets = .zero){
        let path = UIBezierPath.init(roundedRect: self.bounds.inset(by: insets), cornerRadius: self.frame.width/2)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

protocol Reflectable {
    func printClassStructure()
}

extension Reflectable {
    func printClassStructure() {
        let mirror = Mirror(reflecting: self)
        printClassStructure(mirror)
    }
    
    private func printClassStructure(_ mirror: Mirror, indent: Int = 0) {
        let indentation = String(repeating: " ", count: indent)
        print("\(indentation)\(mirror.subjectType):")
        
        for (label, value) in mirror.children {
            if let label = label {
                let valueMirror = Mirror(reflecting: value)
                if valueMirror.children.isEmpty {
                    print("\(indentation)  \(label): \(type(of: value)) = \(value)")
                } else {
                    print("\(indentation)  \(label): \(type(of: value))")
                    printClassStructure(valueMirror, indent: indent + 4)
                }
            } else {
                print("\(indentation)  \(type(of: value)) = \(value)")
            }
        }
    }
}

extension Date {
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension DateComponentsFormatter {
    static let positional: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}
