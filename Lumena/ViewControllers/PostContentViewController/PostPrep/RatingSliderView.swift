//
//  RatingSliderView.swift
//  Lumena
//
//  Created by 島田晃 on 2024/12/03.
//

import Foundation
import UIKit
//import SwiftUI
//
//struct RatingSliderViewPreview: UIViewRepresentable {
//    class PreviewDataSource: RatingSliderViewDataSource {
//        func currentRating(for tagCosmeticID: String, title: String) -> Double {
//            return 0.5 // Example initial rating
//        }
//    }
//    
//    class PreviewDelegate: RatingSliderViewDelegate {
//        func ratingSliderView(_ sliderView: RatingSliderView3, didUpdateRating rating: Double, for tagCosmeticID: String, title: String) {
//            print("Rating updated to \(rating) for \(title) with ID \(tagCosmeticID)")
//        }
//    }
//
//    func makeUIView(context: Context) -> RatingSliderView3 {
//        let configuration = RatingSliderConfiguration(
//            tagCosmeticID: "exampleID",
//            title: "Example Slider",
//            maxWidth: 300,
//            minRatingText: "Min",
//            maxRatingText: "Max"
//        )
//        let sliderView = RatingSliderView3(frame: .zero, configuration: configuration)
//        sliderView.dataSource = PreviewDataSource()
//        sliderView.delegate = PreviewDelegate()
//        return sliderView
//    }
//
//    func updateUIView(_ uiView: RatingSliderView3, context: Context) {
//        // Update logic if needed
//    }
//}
//
//struct RatingSliderViewPreview_Previews: PreviewProvider {
//    static var previews: some View {
//        RatingSliderViewPreview()
//            .frame(width: 320, height: 100) // Adjust frame size as needed
//            .previewLayout(.sizeThatFits)
//    }
//}


protocol RatingSliderViewDataSource: AnyObject {
    func currentRating(for tagCosmeticID: String, title: String) -> Double
}

protocol RatingSliderViewDelegate: AnyObject {
    func ratingSliderView(_ sliderView: RatingSliderView3, didUpdateRating rating: Double, for tagCosmeticID: String, title: String)
}

struct RatingSliderConfiguration {
    var tagCosmeticID: String
    var title: String
    var maxWidth: CGFloat
    var minRatingText: String
    var maxRatingText: String
}

class RatingSliderView3: UIView {
    
    weak var dataSource: RatingSliderViewDataSource?
    weak var delegate: RatingSliderViewDelegate?
    
    var configuration: RatingSliderConfiguration
    
    private var tempWidth: CGFloat = 0
    
    // UI elements
    private let backgroundRectangle = UIView()
    private let foregroundRectangle = UIView()
    private let titleLabel = UILabel()
    private let minLabel = UILabel()
    private let maxLabel = UILabel()
    
    init(frame: CGRect, configuration: RatingSliderConfiguration) {
        self.configuration = configuration
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup the view hierarchy and initial configurations
    private func setupView() {
        // Configure title label
        titleLabel.text = configuration.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        // Configure background rectangle
        backgroundRectangle.backgroundColor = UIColor(red: 0.486, green: 0.629, blue: 0.53, alpha: 0.2)
        backgroundRectangle.layer.cornerRadius = 5
        backgroundRectangle.clipsToBounds = true
        
        // Configure foreground rectangle
        foregroundRectangle.backgroundColor = UIColor(red: 0.486, green: 0.629, blue: 0.53, alpha: 1.0)
        foregroundRectangle.layer.cornerRadius = 5
        foregroundRectangle.clipsToBounds = true
        
        // Configure min and max labels
        minLabel.text = configuration.minRatingText
        minLabel.font = UIFont.boldSystemFont(ofSize: 12)
        maxLabel.text = configuration.maxRatingText
        maxLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(backgroundRectangle)
        backgroundRectangle.addSubview(foregroundRectangle)
        addSubview(minLabel)
        addSubview(maxLabel)
        
        // Add gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        backgroundRectangle.addGestureRecognizer(panGesture)
        
        // Set initial width based on current rating
        if let currentRating = dataSource?.currentRating(for: configuration.tagCosmeticID, title: configuration.title) {
            tempWidth = CGFloat(currentRating) * configuration.maxWidth
        } else {
            tempWidth = 0
        }
        
        // Trigger layout
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 10
        
        // Layout title label
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: 20)
        
        // Layout background rectangle
        backgroundRectangle.frame = CGRect(x: 0, y: titleLabel.frame.maxY + padding, width: configuration.maxWidth, height: 10)
        
        // Layout foreground rectangle
        foregroundRectangle.frame = CGRect(x: 0, y: 0, width: tempWidth, height: 10)
        
        // Layout min and max labels
        minLabel.frame = CGRect(x: 0, y: backgroundRectangle.frame.maxY + padding, width: 50, height: 15)
        maxLabel.frame = CGRect(x: backgroundRectangle.frame.maxX - 50, y: backgroundRectangle.frame.maxY + padding, width: 50, height: 15)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: backgroundRectangle)
        switch gesture.state {
        case .began, .changed:
            let newWidth = max(0, min(location.x, configuration.maxWidth))
            tempWidth = newWidth
            foregroundRectangle.frame.size.width = tempWidth
        case .ended:
            let rating = Double(tempWidth / configuration.maxWidth)
            delegate?.ratingSliderView(self, didUpdateRating: rating, for: configuration.tagCosmeticID, title: configuration.title)
        default:
            break
        }
    }
}
