//
//  ProfileBackgroundViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/05/28.
//

import Foundation
import UIKit
import SwiftUI
import ColorKit

class ProfileBackgroundViewController: UIViewController {
    var backgroundView: UIView!
    var imageView: UIImageView!
    var backgroundGradient: GradientEffectViewController?
    var profile: ProfileSettings!
    
    init(profile: ProfileSettings?) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .primary
        setupBackgroundGradientOrImage()
    }
    
    func updateProfile(profile: ProfileSettings) {
        DispatchQueue.main.async { [self] in
            self.profile = profile
            imageView.image = profile.backgroundImage?.image
            backgroundGradient?.updateColors(from: profile.backgroundImage?.image)
        }
    }

    private func setupBackgroundGradientOrImage() {
        backgroundView = UIView()
        backgroundView.clipsToBounds = true
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        if let backgroundImage = profile.backgroundImage?.image {
            imageView = UIImageView(image: backgroundImage)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = view.bounds
            imageView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
            ])
        } else if let profileImage = profile.profileImage?.image {
            updateColors(for: profileImage, colorScheme: traitCollection.userInterfaceStyle) { colors in
                self.setGradientBackground(colors: colors)
            }
        } else {
            setGradientBackground(colors: defaultColors(for: traitCollection.userInterfaceStyle).map { Color(uiColor: $0) })
        }
    }

    private func setGradientBackground(colors: [Color]) {
        backgroundGradient = GradientEffectViewController(colors: colors)
        
        addChild(backgroundGradient!)
        backgroundView.addSubview(backgroundGradient!.view)
        backgroundGradient!.didMove(toParent: self)
        
        backgroundGradient!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundGradient!.view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            backgroundGradient!.view.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            backgroundGradient!.view.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            backgroundGradient!.view.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor)
        ])
    }
    
    func updateColors(for image: UIImage?, colorScheme: UIUserInterfaceStyle, completion: @escaping ([Color]) -> Void) {
        var colors: [UIColor] = []

        if let validImage = image {
            guard let dominantColors = try? validImage.dominantColorFrequencies(with: .high) else {
                completion(defaultColors(for: colorScheme).map { Color(uiColor: $0) })
                return
            }

            colors = dominantColors.prefix(3).map { $0.color }
            
            let schemeColor = UIColor(colorScheme == .light ? .white : .black)
            colors.append(schemeColor)
            
        } else {
            colors = defaultColors(for: colorScheme)
        }
        
        let uiColors = colors.map { Color(uiColor: $0) }
        DispatchQueue.main.async {
            completion(uiColors)
        }
    }

    private func defaultColors(for colorScheme: UIUserInterfaceStyle) -> [UIColor] {
        return [
            UIColor(red: 0.723, green: 0.88, blue: 0.825, alpha: 1.0),
            UIColor(red: 0.552, green: 0.724, blue: 0.831, alpha: 1.0),
            UIColor(red: 0.946, green: 0.76, blue: 0.839, alpha: 1.0)
        ]
    }
}
