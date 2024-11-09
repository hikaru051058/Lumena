//
//  PrepPostContentCheckViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/11/05.
//

import Foundation
import UIKit
import AVKit
import SwiftUI

#Preview("PrepPostContentCheckViewControllerRepresentablePreview") {
    PrepPostContentCheckViewControllerRepresentable()
}

struct PrepPostContentCheckViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> PrepPostContentCheckViewController {
        return PrepPostContentCheckViewController(postLume: Lume())
    }
    
    func updateUIViewController(_ uiViewController: PrepPostContentCheckViewController, context: Context) {
        // Update the view controller if needed
    }
}

class PrepPostContentCheckViewController: UIViewController {
    
    private var postLumesPlayerVC: PostLumesPlayerViewController?
    private var fallbackView: UIView! // Fallback view when no Lume is available
    
    init(postLume: Lume? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        if let postLume = postLume {
            // Initialize postLumesPlayerVC if a Lume is provided
            self.postLumesPlayerVC = PostLumesPlayerViewController(postLume: postLume)
        } else {
            // No Lume provided, initialize fallback view with arinGreen color
            setupFallbackView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add postLumesPlayerVC if it's initialized
        setupPostLumePlayer()
    }
    
    private func setupFallbackView() {
        fallbackView = UIView()
        fallbackView.backgroundColor = .arinGreen // Set fallback color
        fallbackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fallbackView)
        
        NSLayoutConstraint.activate([
            fallbackView.topAnchor.constraint(equalTo: view.topAnchor),
            fallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupPostLumePlayer() {
        if let postLumesPlayerVC = postLumesPlayerVC {
            // Remove the fallback view if postLumesPlayerVC is present
            fallbackView?.removeFromSuperview()
            
            addChild(postLumesPlayerVC)
            view.addSubview(postLumesPlayerVC.view)
            postLumesPlayerVC.didMove(toParent: self)
            
            // Set up constraints to make postLumesPlayerVC full screen without safe area
            postLumesPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                postLumesPlayerVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                postLumesPlayerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                postLumesPlayerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                postLumesPlayerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force the content to extend beyond the safe area
        view.insetsLayoutMarginsFromSafeArea = false
        additionalSafeAreaInsets = .zero
    }
}


class PostLumesPlayerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var postLume: Lume // The model to display
    private var collectionView: UICollectionView!
    private var pageControl: UIPageControl!
    private var mute = false
    private var currentContent: UUID?
    private var currentReel: UUID?
    
    init(postLume: Lume) {
        self.postLume = postLume
        super.init(nibName: nil, bundle: nil)
        self.currentReel = postLume.id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .arinPink
        
        setupCollectionView()
        setupPageControl()
        loadInitialContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mute = postLume.musicTag
        startAudio()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAudioAndVideo()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .arinBlue
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(LumeContentCell.self, forCellWithReuseIdentifier: "LumeContentCell")
    }
    
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        pageControl.numberOfPages = postLume.contents.count
        pageControl.hidesForSinglePage = true
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadInitialContent() {
        if let firstContent = postLume.contents.first {
            currentContent = firstContent.id
            if case .video(let reelVideo) = firstContent {
                reelVideo.player?.play()
            }
        }
    }
    
    private func startAudio() {
        postLume.playAudio(repeatAudio: true)
    }
    
    private func stopAudioAndVideo() {
        postLume.stopAudio()
        for cell in collectionView.visibleCells {
            if let lumeCell = cell as? LumeContentCell {
                lumeCell.pauseVideo()
            }
        }
    }
    
    // MARK: - CollectionView Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postLume.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LumeContentCell", for: indexPath) as! LumeContentCell
        let content = postLume.contents[indexPath.item]
        cell.configure(with: content, isMuted: mute)
        return cell
    }
    
    // MARK: - CollectionView Delegate FlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: - CollectionView Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentPage
        handleContentChange(at: currentPage)
    }
    
    private func handleContentChange(at index: Int) {
        guard postLume.contents.indices.contains(index) else { return }
        let content = postLume.contents[index]
        currentContent = content.id
        
        switch content {
        case .video(let reelVideo):
            reelVideo.player?.play()
            reelVideo.player?.isMuted = mute
        default:
            stopVideoPlayback()
        }
    }
    
    private func stopVideoPlayback() {
        for cell in collectionView.visibleCells {
            if let lumeCell = cell as? LumeContentCell {
                lumeCell.pauseVideo()
            }
        }
    }
}
