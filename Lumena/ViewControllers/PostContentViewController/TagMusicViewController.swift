//
//  TagMusicViewController.swift
//  Lumena
//
//  Created by 島田晃 on 2024/08/30.
//

import Foundation
import UIKit
import SwiftUI
import AVFAudio

protocol MusicListViewControllerDelegate: AnyObject {
    func musicListViewController(_ controller: MusicListViewController, didTagTrack track: Track)
    func musicListViewController(_ controller: MusicListViewController, didUntagTrack track: Track)
}

protocol SongDetailViewControllerDelegate: AnyObject {
    func songDetailViewController(_ controller: SongDetailViewController, didTagTrack track: Track)
    func songDetailViewController(_ controller: SongDetailViewController, didUntagTrack track: Track)
}

class MusicListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    weak var delegate: MusicListViewControllerDelegate?
    
    var tracks: [Track] = []
    var trendTracks: [Track] = []
    var audioPlayer: LumeAudioPlayer
    var searchText: String = ""
    var curPlayURI: String?
    var musicTag: Bool = false
    var loadingSheet: Bool = true
    var searchAction: Bool = false
    
    private var lastTaggedTrack: Track?
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let progressView = UIActivityIndicatorView(style: .medium)
    
    private var cachedPlaylist: [Track]?
    
    init(audioPlayer: LumeAudioPlayer) {
        self.audioPlayer = audioPlayer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupTableView()
        setupProgressView()
        
        if let cachedPlaylist = cachedPlaylist {
            self.tracks = cachedPlaylist
            self.trendTracks = cachedPlaylist
            self.loadingSheet = false
            self.tableView.reloadData()
        } else if loadingSheet {
            fetchPlaylist()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "音楽"
        
        let spotifyImageView = UIImageView(image: UIImage(named: "Spotify_Logo_RGB_Green"))
        spotifyImageView.contentMode = .scaleAspectFit
        // Create a container view to hold the image view
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 75, height: 36))
        
        // Set the image view's frame within the container view
        spotifyImageView.frame = CGRect(x: containerView.frame.width - 75, y: 0, width: 75, height: 36)
        
        containerView.addSubview(spotifyImageView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: containerView)
        
        searchBar.delegate = self
        searchBar.placeholder = "Search on Spotify"
        navigationItem.titleView = searchBar
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SongIndividualListCell.self, forCellReuseIdentifier: "SongCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchPlaylist() {
        progressView.startAnimating()
        audioPlayer.getPlaylist { result in
            DispatchQueue.main.async {
                self.progressView.stopAnimating()
                switch result {
                case .success(let tracks):
                    self.tracks = tracks
                    self.trendTracks = tracks
                    self.cachedPlaylist = tracks
                    self.loadingSheet = false
                    self.tableView.reloadData()
                case .failure(let error):
                    // Handle error
                    print("Error fetching playlist: \(error)")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            tracks = trendTracks
            tableView.reloadData()
            return
        }
        
        searchAction = true
        progressView.startAnimating()
        
        audioPlayer.getSearchResult(query: query, type: "track") { result in
            DispatchQueue.main.async {
                self.searchAction = false
                self.progressView.stopAnimating()
                self.tracks = result
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 // Set this value to something higher than the image height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongIndividualListCell
        let track = tracks[indexPath.row]
        
        // Determine if this track is the one tagged
        let isTagged = track.uri == lastTaggedTrack?.uri
        cell.configure(with: track, currentURI: curPlayURI ?? "", musicTag: isTagged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        let isTagged = track.uri == lastTaggedTrack?.uri
        let detailVC = SongDetailViewController(track: track, musicTag: isTagged)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MusicListViewController: SongDetailViewControllerDelegate {
    
    func songDetailViewController(_ controller: SongDetailViewController, didTagTrack track: Track) {
        lastTaggedTrack = track
        
        // Find the index of the tagged track
        if let index = tracks.firstIndex(where: { $0.uri == track.uri }) {
            let indexPath = IndexPath(row: index, section: 0)
            
            // Reload the specific row to update its appearance immediately
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        delegate?.musicListViewController(self, didTagTrack: track)
    }
    
    func songDetailViewController(_ controller: SongDetailViewController, didUntagTrack track: Track) {
        // Handle untagging similarly if needed
        if let index = tracks.firstIndex(where: { $0.uri == track.uri }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        delegate?.musicListViewController(self, didUntagTrack: track)
    }
}

class SongDetailViewController: UIViewController {
    
    weak var delegate: SongDetailViewControllerDelegate?

    private var track: Track
    var musicTag: Bool = false
    private var isPlaying: Bool = false

    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var trackNameMarquee: MarqueeTextViewController!
    private var artistNameMarquee: MarqueeTextViewController!
    
    private var tagButton: UIButton!
    private var playOrPauseButton: UIButton!

    init(track: Track, musicTag: Bool) {
        self.track = track
        self.musicTag = musicTag
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let sheet = self.sheetPresentationController {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard self != nil else { return }
                sheet.animateChanges {
                    sheet.detents = [.custom { context in
                        return context.maximumDetentValue * 0.35 // Locks the height at 40% of the screen
                    }]
                    sheet.prefersGrabberVisible = true
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        track.stopAudio()
        
        if let sheet = self.sheetPresentationController {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard self != nil else { return }
                sheet.animateChanges {
                    sheet.detents = [.medium(), .large()] // Restores the original medium or large size
                }
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        setupTagButton()
        setupPlayOrButton()
        
        view.addSubview(trackImageView)
        
//        view.addSubview(trackNameLabel)
//        view.addSubview(artistNameLabel)
        setupMarqueeLabels()
        
        view.addSubview(tagButton)
        
        setupConstraints()
        configureView()
    }
    
    private func setupMarqueeLabels() {
        // Setup for Track Name Marquee
        trackNameMarquee = MarqueeTextViewController(
            text: track.trackName,
            font: UIFont.systemFont(ofSize: 35, weight: .bold),
            textColor: .secondaryLabel,
            leftFade: 16,
            rightFade: 16,
            startDelay: 1,
            alignment: .leading
        )
        
        addChild(trackNameMarquee)
        view.addSubview(trackNameMarquee.view)
        trackNameMarquee.didMove(toParent: self)
        
        // Setup for Artist Name Marquee
        artistNameMarquee = MarqueeTextViewController(
            text: track.artistName,
            font: UIFont.systemFont(ofSize: 25),
            textColor: .secondaryLabel,
            leftFade: 16,
            rightFade: 16,
            startDelay: 1,
            alignment: .leading
        )
        
        addChild(artistNameMarquee)
        view.addSubview(artistNameMarquee.view)
        artistNameMarquee.didMove(toParent: self)
        
        // Set constraints
        trackNameMarquee.view.translatesAutoresizingMaskIntoConstraints = false
        artistNameMarquee.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Track Image
            trackImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            trackImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            trackImageView.widthAnchor.constraint(equalToConstant: 150),
            trackImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Track Name Marquee
            trackNameMarquee.view.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 16),
            trackNameMarquee.view.bottomAnchor.constraint(equalTo: trackImageView.centerYAnchor, constant: -2),
            trackNameMarquee.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackNameMarquee.view.heightAnchor.constraint(equalToConstant: 40),
            
            // Artist Name Marquee
            artistNameMarquee.view.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 16),
            artistNameMarquee.view.topAnchor.constraint(equalTo: trackImageView.centerYAnchor, constant: 2),
            artistNameMarquee.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            artistNameMarquee.view.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupConstraints() {
        let buttonStackView = UIStackView(arrangedSubviews: [tagButton, playOrPauseButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 32 // Space between the buttons
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStackView)

        NSLayoutConstraint.activate([
            // Track Image
            trackImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            trackImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            trackImageView.widthAnchor.constraint(equalToConstant: 150),
            trackImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Button Stack View
            buttonStackView.topAnchor.constraint(equalTo: trackImageView.bottomAnchor, constant: 30),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTagButton() {
        tagButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let imageName = musicTag ? "x.circle.fill" : "checkmark.circle.fill"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        tagButton.setImage(image, for: .normal)
        tagButton.tintColor = musicTag ? .arinPink : .arinBlue // Set the initial color based on the tag state
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        tagButton.addTarget(self, action: #selector(didTapTagButton), for: .touchUpInside)
    }
    
    private func setupPlayOrButton() {
        playOrPauseButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        playOrPauseButton.setImage(image, for: .normal)
        playOrPauseButton.tintColor = .arinBlue
        playOrPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playOrPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
    }
    
    private func configureView() {
        trackNameLabel.text = track.trackName
        artistNameLabel.text = track.artistName
        trackImageView.image = track.image
        
        updateTagButton()
        updatePlayPauseButton()
    }
    
    @objc private func didTapBackButton() {
        track.stopAudio()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapTagButton() {
        musicTag.toggle()
        
        if musicTag {
            delegate?.songDetailViewController(self, didTagTrack: track)
            self.dismiss(animated: true, completion: nil)
        } else {
            delegate?.songDetailViewController(self, didUntagTrack: track)
        }
        
        updateTagButton()
    }
    
    private func updateTagButton() {
        DispatchQueue.main.async { [self] in
            let imageName = musicTag ? "x.circle.fill" : "checkmark.circle.fill"
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
            let image = UIImage(systemName: imageName, withConfiguration: config)
            tagButton.setImage(image, for: .normal)
            tagButton.tintColor = musicTag ? .arinPink : .arinBlue
        }
    }
    
    @objc private func didTapPlayPause() {
        isPlaying.toggle()
        
        if track.audioPlayer == nil {
            track.initializeAudioPlayer { [weak self] success in
                guard success else { return }
                if let isPlaying = self?.isPlaying, 
                    isPlaying
                {
                    self?.track.playAudio()
                } else {
                    self?.track.stopAudio()
                }
            }
        } else {
            if isPlaying {
                track.playAudio()
            } else {
                track.stopAudio()
            }
        }
        
        updatePlayPauseButton()
    }
    
    private func updatePlayPauseButton() {
        DispatchQueue.main.async { [self] in
            let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
            let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
            let image = UIImage(systemName: imageName, withConfiguration: config)
            playOrPauseButton.setImage(image, for: .normal)
        }
    }
}

class SongSelectedIndividualCell: UICollectionViewCell {
    
    var track: Track?
    var isMusicTagged: Bool = false
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tagButton: UIButton!
    
    private func setupTagButton() {
        tagButton = UIButton()
        tagButton.translatesAutoresizingMaskIntoConstraints = false
        tagButton.addTarget(self, action: #selector(didTapTagButton), for: .touchUpInside)
    }
    
    private var isPlaying: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTagButton()
        
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(tagButton)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            trackImageView.widthAnchor.constraint(equalToConstant: 150),
            trackImageView.heightAnchor.constraint(equalToConstant: 150),
            
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 16),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            artistNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 16),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tagButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tagButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            tagButton.widthAnchor.constraint(equalToConstant: 30),
            tagButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with track: Track, isTagged: Bool) {
        self.track = track
        self.isMusicTagged = isTagged
        
        trackNameLabel.text = track.trackName
        artistNameLabel.text = track.artistName
        trackImageView.image = track.image
        
        updateTagButton()
    }
    
    @objc private func didTapTagButton() {
        isMusicTagged.toggle()
        updateTagButton()
        // Handle tagging logic
    }
    
    private func updateTagButton() {
        let imageName = isMusicTagged ? "x.circle.fill" : "checkmark.circle.fill"
        tagButton.setImage(UIImage(systemName: imageName), for: .normal)
        tagButton.tintColor = isMusicTagged ? .red : .yellow
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        track = nil
        isMusicTagged = false
    }
}

class SongIndividualListCell: UITableViewCell {
    
    var track: Track?
    var curPlayURI: String?
    var audioPlayer: AVAudioPlayer?
    var musicTag: Bool = false
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.shadowRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var playPauseButton: UIButton!
    
    private func setupPlayPauseButton() {
        playPauseButton = UIButton()
        playPauseButton.tintColor = .secondaryLabel
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
    }
    
    private var isPlaying: Bool = false {
        didSet {
            DispatchQueue.main.async { [self] in
                let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
                playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
                self.layoutIfNeeded()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupPlayPauseButton()
        
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(playPauseButton)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackImageView.widthAnchor.constraint(equalToConstant: 50),
            trackImageView.heightAnchor.constraint(equalToConstant: 50),
            
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 16),
            trackNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            trackNameLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -16),
            
            artistNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 16),
            artistNameLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            artistNameLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -16),
            
            playPauseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playPauseButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 30),
            playPauseButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Add bottom constraint to the contentView to increase the cell height
            contentView.bottomAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 20)
        ])
    }

    func configure(with track: Track, currentURI: String, musicTag: Bool) {
        self.track = track
        self.curPlayURI = currentURI
        self.musicTag = musicTag
        
        trackNameLabel.text = track.trackName
        artistNameLabel.text = track.artistName
        trackImageView.image = track.image
        
        // Set the background color based on whether the track is tagged
        contentView.backgroundColor = musicTag ? .arinYellow : .clear
        
        isPlaying = (track.uri == curPlayURI)
        playPauseButton.isEnabled = track.previewUrl != nil
    }
    
    @objc private func didTapPlayPause() {
        guard let track = track else { return }
        
        if track.audioPlayer == nil {
            track.initializeAudioPlayer { [weak self] success in
                guard success else { return }
                self?.isPlaying = true
                track.playAudio()
                self?.curPlayURI = track.uri
            }
        } else {
            isPlaying.toggle()
            if isPlaying {
                track.playAudio()
                curPlayURI = track.uri
            } else {
                track.stopAudio()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        track?.stopAudio()
        track = nil
        isPlaying = false
        contentView.backgroundColor = .clear // Reset background color for reuse
    }
}
