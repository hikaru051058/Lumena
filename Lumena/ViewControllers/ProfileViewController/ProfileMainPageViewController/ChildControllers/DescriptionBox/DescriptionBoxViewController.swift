//
//  DescriptionBoxViewController.swift
//  test
//
//  Created by 島田晃 on 2024/05/20.
//

import UIKit

class ExpandableTextViewController: UIViewController {
    
    let yourLabel = UILabel()
    var text: String {
        didSet {
            yourLabel.layoutIfNeeded()
            view.layoutIfNeeded()
        }
    }
    var isExpanded = false
    
    init(text: String) {
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !text.isEmpty {
            setupLabel()
            yourLabel.text = text
            
            // Check if the text spans more than 2 lines
            let readmoreFont = UIFont.systemFont(ofSize: 16, weight: .thin)
            let readmoreFontColor = UIColor.secondaryLabel
            DispatchQueue.main.async {
                let labelHeight = self.yourLabel.sizeThatFits(CGSize(width: self.yourLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
                let lineHeight = self.yourLabel.font.lineHeight
                if labelHeight > lineHeight * 2 {
                    self.yourLabel.addTrailing(with: "... ", moreText: "more", moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                    
                    // Add tap gesture recognizer
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapLabel))
                    self.yourLabel.isUserInteractionEnabled = true
                    self.yourLabel.addGestureRecognizer(tapGesture)
                } else {
                    self.yourLabel.numberOfLines = 0
                }
            }
        }
    }
    
    private func setupLabel() {
        yourLabel.translatesAutoresizingMaskIntoConstraints = false
        yourLabel.numberOfLines = 2
        yourLabel.lineBreakMode = .byTruncatingTail
        yourLabel.textAlignment = .center
        view.addSubview(yourLabel)
        
        NSLayoutConstraint.activate([
            yourLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            yourLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            yourLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            yourLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func tapLabel() {
        if isExpanded {
            UIView.animate(withDuration: 0.3) {
                self.yourLabel.numberOfLines = 2
                self.yourLabel.text = self.text
                DispatchQueue.main.async {
                    let readmoreFont = UIFont.systemFont(ofSize: 16, weight: .thin)
                    let readmoreFontColor = UIColor.secondaryLabel
                    self.yourLabel.addTrailing(with: "... ", moreText: "more", moreTextFont: readmoreFont, moreTextColor: readmoreFontColor)
                }
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.yourLabel.numberOfLines = 0
                self.yourLabel.text = self.text
                self.view.layoutIfNeeded()
            }
        }
        isExpanded.toggle()
    }
}

extension UILabel {
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            let mutableString: String = myText
            
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
            let trimmedForReadMore: String = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "") + trailingText
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font as Any])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }
    
    var visibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        if let myText = self.text {
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: myText, attributes: attributes as? [NSAttributedString.Key : Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
}
