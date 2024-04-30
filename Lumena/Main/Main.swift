//
//  Main.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/13.
//

import SwiftUI
import AVKit
import Amplify


struct Main: View {
    
    @State var selectedTab: Int = 0
    
    let tabs: [Tab] = [
        //.init(title: "トレンド"),
        .init(title: "おすすめ"),
        .init(title: "フォロー")
    ]
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.white)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    @State private var result_conv: Lume? = nil
    
    @State var reelsSuggestion: [Lume] = []

    @State var reelsFollowing: [Lume] = []
    
    @State var videoPlaybackSliderProgress: CGFloat = CGFloat(0)
    @State var videoPlaybackSliderDragged:  Bool = false
    
    
    @State private var LumeUploadProgress: Double = 0.0
    @State private var LumeUploadStatus: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var onNavigate: () -> Void = {}
    
    var body: some View {
        
        ZStack{
            
            Color.black
                .ignoresSafeArea()
            
            // Views
            TabView(selection: $selectedTab,
                    content: {
                //                ReelsViewTest(pageTag: 0, selectedTab: $selectedTab, reels: $reels3, videoPlaybackSliderProgress: $videoPlaybackSliderProgress, videoPlaybackSliderDragged: $videoPlaybackSliderDragged)
                //                    .tag(0)
                //ReelsView(pageTag: 1, selectedTab: $selectedTab, reels: $reels2)
                ReelsView(pageTag: 0, selectedTab: $selectedTab, reels: $reelsSuggestion, videoPlaybackSliderProgress: $videoPlaybackSliderProgress, videoPlaybackSliderDragged: $videoPlaybackSliderDragged)
                    .tag(0)
                //ReelsView(pageTag: 2, selectedTab: $selectedTab, reels: $reels3)
                ReelsView(pageTag: 1, selectedTab: $selectedTab, reels: $reelsFollowing, videoPlaybackSliderProgress: $videoPlaybackSliderProgress, videoPlaybackSliderDragged: $videoPlaybackSliderDragged)
                    .tag(1)
            })
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            .onDisappear{
                
                //muteCurrentlyPlayingVideo(in: &reels3)
                reelsSuggestion = reelsSuggestion.map { reel in
                    let mutableReel = reel
                    mutableReel.muteVideos()
                    return mutableReel
                }
                
                reelsFollowing = reelsFollowing.map { reel in
                    let mutableReel = reel
                    mutableReel.muteVideos()
                    return mutableReel
                }
            }
            VStack{
                Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, useWhite: true, selectedTab: $selectedTab)
                    .padding(.horizontal, 45)
                
                Spacer()
            }
            
            VStack{
                if LumeUploadStatus {
                    SimpleProgressBarView(progress: $LumeUploadProgress)
                }
                Spacer()
            }
            .onReceive(timer) { _ in
                
                withAnimation {
                    LumeUploadStatus = GI.shared.postUploading
                    LumeUploadProgress = GI.shared.postUploadProgress
                    if !GI.shared.postUploading {
                        timer.upstream.connect().cancel() // Stop the timer when not uploading
                    }
                }
            }
            
            //MARK: -- Search button
            //            VStack{
            //                HStack{
            //
            //                    Spacer()
            //
            //                    NavigationLink(destination: Search()) {
            //                        Image(systemName: "magnifyingglass")
            //                            .foregroundColor(.white)
            //                            .font(.title2)
            //                            .frame(width: 50, height: 50, alignment: .top)
            //                    }
            //                }
            //
            //                Spacer()
            //            }
            //            .padding()
            //MARK: ^-
            
            VStack{
                
                Spacer()
                
                ZStack {
                    
                    Color.clear
                        .background(.ultraThinMaterial)
                    VideoProgressSeekBar(maxWidth: 130,
                                         sliderProgress: $videoPlaybackSliderProgress,
                                         dragged: $videoPlaybackSliderDragged
                    )
                    .frame(width: 130, height: 40)
                    
                    HStack {
                        
                        Button(action: {onNavigate()}) {
                            Image(systemName: "person.fill")
                        }
                        .padding(.trailing, 10)
                        
                        NavigationLink(destination: VideoHome()){
                            Image(systemName: "plus")
                        }
                        .padding(.leading, 10)
                    }
                    .foregroundColor(.white)
                    .font(.title2)
                }
                .frame(width: 130, height: 40)
                .cornerRadius(30)
            }
            //MARK: ^-
        }
        .navigationBarHidden(true)
    }
}

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}


struct VideoProgressSeekBar: View {
    var maxWidth: CGFloat
    @Binding var sliderProgress: CGFloat  // Represents the video playback progress (0.0 to 1.0)
    @Binding var dragged: Bool
    @State var lastDragValue: CGFloat = 0

    var onSliderChanged: ((CGFloat) -> Void)?  // Closure to handle changes in slider

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: sliderProgress * maxWidth)
            }
            .frame(width: maxWidth)
            .cornerRadius(30)
            .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                updateSlider(with: value)
                dragged = true
            }).onEnded({ _ in
                lastDragValue = sliderProgress * maxWidth
                dragged = false
            }))
        }
    }

    private func updateSlider(with value: DragGesture.Value) {
        let translation = value.translation.width
        var newWidth = lastDragValue + translation
        newWidth = max(0, min(newWidth, maxWidth))

        let newProgress = newWidth / maxWidth
        sliderProgress = newProgress

        onSliderChanged?(newProgress)
    }
}


// MARK: ^-
// MARK: -- Keyboard size responder


class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    var notificationCenter: NotificationCenter
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            withAnimation {
               currentHeight = keyboardSize.height
            }
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        withAnimation {
            currentHeight = 0
        }
    }
}



// MARK: - Previews
//struct Main_Previews: PreviewProvider {
//    static var previews: some View {
//        Main()
//    }
//}
