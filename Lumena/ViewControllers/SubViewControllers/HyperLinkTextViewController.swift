//
//  HyperLinkTextViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/07/07.
//

import Foundation
import UIKit
import SwiftUI

enum hyperLinkContent {
    case text(String)
    case link(text: String, url: String)
}

struct HyperLinkTextView: UIViewControllerRepresentable {
    var text: String
    var hyperlinks: [String: String]
    
    func makeUIViewController(context: Context) -> HyperLinkTextViewController {
        let viewController = HyperLinkTextViewController()
        viewController.inputText = text
        viewController.hyperlinks = hyperlinks
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: HyperLinkTextViewController, context: Context) {
        // Any update logic can go here
    }
}

class HyperLinkTextViewController: UIViewController {
    
    lazy var label: ABTappableLabel = self.makeLabel()
    var inputText: String = ""
    var hyperlinks: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedText = NSMutableAttributedString(string: inputText, attributes: [
            .foregroundColor: UIColor.gray,
            .font: UIFont.preferredFont(forTextStyle: .caption2)
        ])
        
        for (hyperlink, url) in hyperlinks {
            if let range = attributedText.string.ranges(of: hyperlink).first {
                attributedText.addAttributes([
                    .font: UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize),
                    .foregroundColor: UIColor.gray
                ], range: range)
                
                _ = label.makeTappable(string: hyperlink, tapHandler: {
                    if let linkURL = URL(string: url) {
                        UIApplication.shared.open(linkURL)
                    }
                })
            }
        }
        
        label.attributedText = attributedText
    }
    
    func makeLabel() -> ABTappableLabel {
        let label = ABTappableLabel(text: inputText)
        label.numberOfLines = 0
        label.textAlignment = .center
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Adjust these constants to control padding
        let verticalPadding: CGFloat = 20
        let horizontalPadding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -horizontalPadding),
            label.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -verticalPadding)
        ])
        
        return label
    }

}

typealias ABLabelTapHandler = (() -> Void)

class ABTappableLabel: UILabel {
    
    private var tapHandlerDetails: [String: ABLabelTapHandler] = [:]
    
    //MARK: - Initialiizer methods
    
    init(text: String) {
        super.init(frame: CGRect.zero)
        self.text = text
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    //MARK: - Private methods
    
    private func setup() {
        self.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func tappedOnLabel(_ gesture: RangeGestureRecognizer) {
        guard let text = self.text else { return }
        for (key, value) in tapHandlerDetails {
            let stringRange = (text as NSString).range(of: key)
            if gesture.didTapAttributedTextInLabel(label: self, inRange: stringRange) {
                value()
            }
        }
    }
        
    //MARK: - Public methods
    
    func makeTappable(string: String,
                      hyperlinkAttributes: [NSAttributedString.Key: Any] = NSAttributedString.linkAppearanceAttributes,
                      tapHandler: @escaping ABLabelTapHandler) -> Self {
        
        // Setup gesture recognizer
        var tapGesture: RangeGestureRecognizer
        if let rangeTapGesture = gestureRecognizers?.first as? RangeGestureRecognizer {
            tapGesture = rangeTapGesture
        } else {
            tapGesture = RangeGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:)))
            tapGesture.numberOfTapsRequired = 1
            self.addGestureRecognizer(tapGesture)
        }
        
        // Add appearance
        var attributedString: NSMutableAttributedString!
        if let attributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: attributedText)
        } else if let normalText = self.text {
            attributedString = NSMutableAttributedString(string: normalText)
        }
        if let range = attributedString.string.ranges(of: string).first {
            attributedString.addAttributes(hyperlinkAttributes, range: range)
        }
        self.attributedText = attributedString
        
        tapHandlerDetails[string] = tapHandler

        return self
    }

   
}

fileprivate extension ABTappableLabel {
    
    class RangeGestureRecognizer: UITapGestureRecognizer {
              
        func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
            // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: CGSize.zero)
            let textStorage = NSTextStorage(attributedString: label.attributedText!)
          
            // Configure layoutManager and textStorage
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
          
            // Configure textContainer
            textContainer.lineFragmentPadding = 0.0
            textContainer.lineBreakMode = label.lineBreakMode
            textContainer.maximumNumberOfLines = label.numberOfLines
            let labelSize = label.bounds.size
            textContainer.size = labelSize
            
            // Find the tapped character location and compare it to the specified range
            let locationOfTouchInLabel = self.location(in: label)
            let textBoundingBox = layoutManager.usedRect(for: textContainer)
            let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
            let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                         y: locationOfTouchInLabel.y - textContainerOffset.y);
            let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

            return NSLocationInRange(indexOfCharacter, targetRange)
        }
    }
    
}


extension NSAttributedString {
    static var linkAppearanceAttributes: [NSAttributedString.Key: Any] {
        [
            .foregroundColor: UIColor.gray,
            .underlineStyle: 1,
            .font: UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption2).pointSize)
        ]
    }
}

extension String {
    public func ranges(of string: String) -> Array<NSRange> {
        var searchRange = NSMakeRange(0, self.count)
        var ranges : Array<NSRange> = []
        
        while searchRange.location < self.count {
            searchRange.length = self.count - searchRange.location
            let foundRange = (self as NSString).range(of: string, options: .caseInsensitive, range: searchRange)
            if foundRange.location != NSNotFound {
                ranges.append(foundRange)
                searchRange.location = foundRange.location + foundRange.length
            } else {
                break
            }
        }
        return ranges
    }
}
