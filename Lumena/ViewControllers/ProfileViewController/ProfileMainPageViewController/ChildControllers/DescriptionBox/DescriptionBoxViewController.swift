//
//  DescriptionBoxViewController.swift
//  test
//
//  Created by 島田晃 on 2024/05/20.
//

import UIKit
import SwiftUI

protocol ExpandableTextViewControllerDelegate: AnyObject {
    func didUpdateHeight(_ height: CGFloat)
}

class ExpandableTextViewController: UIView {
    
    private let scrollView = UIScrollView()
    private let descriptionLabel = UILabel()
    private var expanded = false
    private var maximumExpandedHeight: CGFloat = 100 // Renamed for clarity
    var text: String = String().loresIpsum {
        didSet {
            descriptionLabel.text = text
            updateDescriptionHeight()
        }
    }
    
    private var scrollViewTopConstraint: NSLayoutConstraint!
    
    weak var delegate: ExpandableTextViewControllerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure the scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.primary.withAlphaComponent(0.1)
        scrollView.layer.cornerRadius = 16
        scrollView.showsVerticalScrollIndicator = false
        //        scrollView.backgroundColor = .gray
        addSubview(scrollView)
        
        // Configure the label
        descriptionLabel.text = text
        descriptionLabel.textColor = .primary
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .left
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(descriptionLabel)
        
        // Set constraints for the label
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            descriptionLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            descriptionLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            descriptionLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Calculate the required height for the label after the layout has been applied
        DispatchQueue.main.async {
            let requiredHeight = self.descriptionLabel.requiredHeight(for: self.bounds.width)
            self.scrollViewTopConstraint = self.scrollView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -requiredHeight)
            self.scrollViewTopConstraint.isActive = true
            self.updateDescriptionHeight()
            // Animate the layout change
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescription))
        descriptionLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func toggleDescription() {
        expanded.toggle()
        updateDescriptionHeight()
    }
    
    private func updateDescriptionHeight() {
        self.descriptionLabel.numberOfLines = self.expanded ? 0 : 2
        
        // Calculate the required height for the expanded label content
        var requiredHeight: CGFloat = 0.0
        if !text.isEmpty {
            requiredHeight = min(maximumExpandedHeight, descriptionLabel.requiredHeight(for: bounds.width)) + 32
        }
        scrollView.isScrollEnabled = expanded
        
        delegate?.didUpdateHeight(requiredHeight)
        
        // Animate the height change
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.scrollViewTopConstraint?.constant = -requiredHeight
            self.layoutIfNeeded()
        }
    }
    
    func getCurrentHeight() -> CGFloat {
        var heightReturn: CGFloat = 0.0
        if !text.isEmpty {
            heightReturn = min(maximumExpandedHeight, descriptionLabel.requiredHeight(for: bounds.width)) + 32
        }
        
        print(heightReturn)
        return heightReturn
    }
}

struct textAlternateTestView: View {
    @State private var text: String = ""
    var body: some View {
        VStack {
            Button("Toggle") {
                if text == "" {
                    text = String().loresIpsumShort
                } else if text == String().loresIpsumShort {
                    text = String().loresIpsum
                } else {
                    text = ""
                }
            }
            
            ExpandableTextViewControllerRepresentable()
                .padding(.trailing, 50)
        }
    }
}

#Preview("ExpandableTextViewControllerPreview") {
    
    textAlternateTestView()
}

struct ExpandableTextViewControllerRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ExpandableTextViewController {
        return ExpandableTextViewController()
    }
    
    func updateUIView(_ uiView: ExpandableTextViewController, context: Context) {
        // Update the view if needed
    }
}
