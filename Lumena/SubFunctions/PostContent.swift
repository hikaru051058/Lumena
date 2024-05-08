//
//  Film.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/24.
//

import Foundation
import SwiftUI
import AVKit
import PhotosUI
import Photos



struct VideoHome: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @StateObject var cameraModel = CameraViewModel(session: AVCaptureSession())
    
    @State private var recording: Bool = false
    
    @State private var showLight: Bool = false
    @State private var lightRadius: CGFloat = 0
    @State private var lightTemperature: CGFloat = 0
    
    
    @State var sliderMaxHeight: CGFloat = UIScreen.main.bounds.height / 6
    @State var sliderProgress: CGFloat = 0
    @State var sliderHeight: CGFloat = 0
    @State var sliderLastDragValue: CGFloat = 0
    
    
    @State var sliderMaxWidth: CGFloat = UIScreen.main.bounds.height / 6
    @State var sliderWidthProgress: CGFloat = 0
    @State var sliderWidth: CGFloat = 0
    @State var sliderWidthLastDragValue: CGFloat = 0
    
    
    @State var audioPlayer = AudioPlayer()
    @State private var showingSheet = false
    @State private var loadingSheet = true
    @State private var searchText = ""
    @FocusState var searchBarKeyboard: Bool
    
    @State private var CamVid: Bool = false // false = cam
    
    @State private var musicTag: Bool = false
    
    @State private var timerCountDown: Int = 4
    @State private var timerCountingRN: Bool = false
    @State private var timerActivated: Bool = false
    @State private var timerAborted: Bool = false
    
    @State public var tracks: [Track] = []
    @State public var trendTracks: [Track] = []
    
    @State public var searchAction: Bool = false
    
    @State public var curPlayURI: String = ""
    
    @StateObject var imagePicker = ImageExtractorViewModel()
    @State var showImagePicker: Bool = false
    
    @State private var savedVideo: Bool = true
    
    @StateObject var postLume: Lume = Lume()
    @State private var contentsCount: Int = 0
    
    @State private var colorTemperature: CGFloat = 2700
    
    private func colorForTemperature(_ temperature: CGFloat) -> Color {
        // Normalize temperature range to [0, 1]
        let normalizedTemperature = (temperature - 2700) / (7000 - 2700)
        
        // Define warm and cool colors
        let warmColor = Color(red: 255/255, green: 138/255, blue: 18/255) // Warm light
        let coolColor = Color(red: 155/255, green: 176/255, blue: 255/255) // Cool light
        
        // Interpolate between warm and cool colors
        let red = warmColor.components.red + (coolColor.components.red - warmColor.components.red) * normalizedTemperature
        let green = warmColor.components.green + (coolColor.components.green - warmColor.components.green) * normalizedTemperature
        let blue = warmColor.components.blue + (coolColor.components.blue - warmColor.components.blue) * normalizedTemperature
        
        return Color(red: red, green: green, blue: blue)
    }
    
    
    var body: some View {
        
        ZStack{
            
            if showLight {
                Color.white
                    .ignoresSafeArea()
            } else {
                Color.black
                    .ignoresSafeArea()
            }
            
            // MARK: Camera View
            CameraView(musicPlaying: $musicTag)
                .environmentObject(cameraModel)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    ZStack{
                        if(showLight){
                            
                            RadialGradient(gradient: Gradient(colors: [.clear, colorForTemperature(colorTemperature).opacity(lightRadius/100)]), center: .center, startRadius: lightRadius, endRadius: lightRadius + 200 )
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                            
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(showLight ? colorForTemperature(colorTemperature).opacity(lightRadius/100) : Color.clear, lineWidth: 40)
                        }
                    }
                )
                .ignoresSafeArea()
                .padding(.bottom,50)
            
            
            // MARK: Controls
            ZStack{
                
                let audioPlaybackQueue = DispatchQueue(label: "com.nucr.gotdns.org.Lumena", qos: .userInitiated)
                
                Button(action: {
                    
                    
                    if !timerCountingRN {
                        
                        if CamVid {
                            
                            if cameraModel.isRecording {
                                
                                cameraModel.stopRecording()
                                postLume.tagMusic.stopAudio()
                                
                                recording = false
                                timerCountDown = 4
                                
                            } else {
                                
                                recording = true
                                savedVideo = false
                                
                                timerCountingRN = timerActivated
                                
                                DispatchQueue.main.asyncAfter(deadline: timerActivated ? .now()+5 : .now()){
                                    
                                    if !timerAborted {
                                        
                                        postLume.tagMusic.stopAudio()
                                        cameraModel.startRecording()
                                        
                                        if(postLume.tagMusic.uri != "") {
                                            
                                            audioPlaybackQueue.async {
                                                
                                                if cameraModel.recordedURLs.count > 0 {
                                                    postLume.tagMusic.playAudio(from: Float(cameraModel.recordedDuration), to: Float(postLume.tagMusic.tagMusicRange.upperBound))
                                                } else {
                                                    postLume.tagMusic.playAudio(from: Float(postLume.tagMusic.tagMusicRange.lowerBound), to: Float(postLume.tagMusic.tagMusicRange.upperBound))
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                }
                            }
                        } else {
                            
                            if cameraModel.previewURL != nil {
                                cameraModel.resetCameraViewModel()
                                timerCountDown = 4
                            }
                            
                            recording = true
                            
                            timerCountingRN = timerActivated
                            
                            DispatchQueue.main.asyncAfter(deadline: timerActivated ? .now()+5 : .now()){
                                
                                if !timerAborted {
                                    
                                    
                                    // Setup after action of capturedImage saved
                                    cameraModel.onImageCaptured = { capturedImage in
                                        let imageToAppend = LumeImage(image: capturedImage)
                                        postLume.contents.append(.image(imageToAppend))
                                        contentsCount+=1
                                        cameraModel.resetCameraViewModel()
                                    }

                                    // Now, when you call takePhoto, the onImageCaptured closure will handle appending the image
                                    cameraModel.takePhoto()
                                    
                                    recording = false
                                }
                            }
                        }
                        
                    } else {
                        //stop timer before recording or pic
                        timerAborted = true
                        timerCountingRN = false
                    }
                    
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(cameraModel.isRecording ? .red : (showLight ? Color.black : Color.white), lineWidth: 3))
                        .frame(width: 70, height: 70)
                        .padding(.bottom, 25)
                }
                
                
                // Preview Button
                if contentsCount > 0 {
                    
                    if !cameraModel.isRecording && savedVideo {
                        
                        HStack{
                            
                            NavigationLink(destination: PrepPost(postLume: postLume)) {
                                Group {
                                    if cameraModel.previewURL == nil && !cameraModel.recordedURLs.isEmpty {
                                        // Merging Videos
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Text("Preview \(contentsCount)")
                                            .foregroundColor(showLight ? .white : .black)
                                    }
                                }
                                .padding(.horizontal,20)
                                .padding(.vertical,8)
                                .background{
                                    Capsule()
                                        .fill(showLight ? .black : .white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing)
                        }
                    }
                }
                
                if (!(cameraModel.previewURL == nil && cameraModel.recordedURLs.isEmpty) && CamVid && !savedVideo) {
                    
                    HStack{
                        
                        
                        Button(action: {
                            
                            if !(cameraModel.previewURL == nil), let contentsToAppend = cameraModel.getContentFromPreview(){
                                postLume.contents.append(contentsToAppend)
                                savedVideo = true
                                contentsCount+=1
                            }
                            
                        }) {
                            
                            Image(systemName: "video.fill.badge.checkmark")
                                .foregroundColor(showLight ? .white : .black)
                                .padding(8)
                                .background{
                                    Capsule()
                                        .fill(showLight ? .black : .white)
                                }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                }
            }
            .frame(maxHeight: .infinity,alignment: .bottom)
            .padding(.bottom,50)
            
            
            
            
            
            
            
            HStack{
                
                VStack{
                    
                    Button(action: {
                        
                        if cameraModel.previewURL != nil{
                            cameraModel.resetCameraViewModel()
                            
                            postLume.tagMusic.stopAudio()
                            
                            recording = false
                        } else {
                            
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                    }){
                        Image(systemName: (cameraModel.previewURL != nil) ? "xmark" : "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                            .foregroundColor((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                            .shadow(radius: 5)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                if(showLight){
                    
                    VStack{
                        ZStack(alignment: .trailing, content: {
                            
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                            
                            Rectangle()
                                .fill(Color(red: 0.552, green: 0.724, blue: 0.831))
                                .frame(width: sliderWidth)
                        })
                        .frame(width: sliderMaxWidth, height: 30)
                        .cornerRadius(35)
                        .gesture(DragGesture(minimumDistance: 0).onChanged({ (value) in
                            
                            let translation = value.translation
                            sliderWidth = -translation.width + sliderWidthLastDragValue
                            
                            sliderWidth = sliderWidth > sliderMaxWidth ? sliderMaxWidth : sliderWidth
                            sliderWidth = sliderWidth >= 0 ? sliderWidth : 0
                            
                            let progress = sliderWidth / sliderMaxWidth
                            sliderWidthProgress = progress <= 1.0 ? progress : 1
                            
                            lightTemperature = sliderWidthProgress * 100
                            colorTemperature = 2700 + (lightTemperature * 43)
                        }).onEnded({ (value) in
                            sliderWidth = sliderWidth > sliderMaxWidth ? sliderMaxWidth : sliderWidth
                            sliderWidth = sliderWidth >= 0 ? sliderWidth : 0
                            sliderWidthLastDragValue = sliderWidth
                        }))
                        
                        Spacer()
                        
                    }
                }
                
                VStack{
                    
                    Button(action: {
                        withAnimation{
                            cameraModel.showLight.toggle()
                            showLight.toggle()
                            
                            if !showLight {
                                
                                lightRadius = 0
                                sliderLastDragValue = 0
                                sliderProgress = 0
                            }
                        }
                        
                        if cameraModel.currentCameraPosition == .back {
                            if(cameraModel.showLight){
                                
                                cameraModel.setUp(type: .wide)
                            } else {
                                
                                cameraModel.setFlashlight(level: Float(0.0))
                            }
                        }
                        
                    }){
                        Image(systemName: "lightbulb.fill")
                            .padding(.bottom, showLight ? 0 : 30)
                            .foregroundColor((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                    }
                    
                    if(showLight){
                        
                        
                        ZStack(alignment: .bottom, content: {
                            
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                            
                            Rectangle()
                                .fill(Color(red: 0.552, green: 0.724, blue: 0.831))
                                .frame(height: sliderHeight)
                        })
                        .frame(width: 30, height: sliderMaxHeight)
                        .cornerRadius(35)
                        .gesture(DragGesture(minimumDistance: 0).onChanged({ (value) in
                            
                            let translation = value.translation
                            sliderHeight = -translation.height + sliderLastDragValue
                            
                            sliderHeight = sliderHeight > sliderMaxHeight ? sliderMaxHeight : sliderHeight
                            sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                            
                            let progress = sliderHeight / sliderMaxHeight
                            sliderProgress = progress <= 1.0 ? progress : 1
                            
                            if let currentCameraInput = cameraModel.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first(where: { $0.device.hasMediaType(.video) }) {
                                if currentCameraInput.device.position == .back {
                                    cameraModel.setFlashlight(level: Float(sliderProgress))
                                } else {
                                    lightRadius = sliderProgress * 100
                                }
                            }
                        }).onEnded({ (value) in
                            sliderHeight = sliderHeight > sliderMaxHeight ? sliderMaxHeight : sliderHeight
                            sliderHeight = sliderHeight >= 0 ? sliderHeight : 0
                            sliderLastDragValue = sliderHeight
                        }))
                    }
                    
                    
                    Button(action: {
                        loadingSheet = true
                        showingSheet = true
                    }){
                        
                        Image(systemName: (postLume.tagMusic.uri == "") ? "music.note" : "music.quarternote.3")
                            .foregroundColor((postLume.tagMusic.uri == "") ? ((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white) : Color(red: 0.946, green: 0.76, blue: 0.839))
                    }
                    .padding(.bottom, 30)
                    
                    Button(action: {
                        
                        timerActivated.toggle()
                        timerCountDown = 4
                    }){
                        
                        Image(systemName: timerActivated ? "timer.circle.fill" : "timer")
                            .foregroundColor(timerActivated ? Color(red: 0.946, green: 0.76, blue: 0.839) : (cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                    }
                    .padding(.bottom, 30)
                    
                    
                    Button(action: {
                        
                        if cameraModel.currentCameraType == .wide {
                            cameraModel.switchCameraType(to: .ultraWide)
                        } else if cameraModel.currentCameraType == .ultraWide {
                            cameraModel.switchCameraType(to: .telephoto)
                        } else {
                            cameraModel.switchCameraType(to: .wide)
                        }
                    }){
                        
                        Image(systemName: cameraModel.currentCameraType == .ultraWide ? "arrow.down.left.and.arrow.up.right.square.fill" : "arrow.down.forward.and.arrow.up.backward.square.fill")
                            .foregroundColor((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                    }
                    .padding(.bottom, 30)
                    .opacity(cameraModel.currentCameraPosition == .back ? 1 : 0)
                    
                    if cameraModel.recordedURLs.count > 0 {
                        
                        if !cameraModel.isRecording {
                            Button(action: {
                                if cameraModel.recordedURLs.count > 1{
                                    cameraModel.removeLastVideo()
                                } else {
                                    cameraModel.recordedDuration = 0
                                    cameraModel.previewURL = nil
                                    cameraModel.recordedURLs.removeAll()
                                }
                            }) {
                                ZStack {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                        .foregroundColor((cameraModel.currentCameraPosition == .front) ? (showLight ? .black : .white) : .white)
                                    
                                    
                                    if cameraModel.recordedURLs.count > 0 {
                                        Text("\(cameraModel.recordedURLs.count)")
                                            .foregroundColor(.white)
                                            .font(.caption2)
                                            .frame(width: 20, height: 20)
                                            .background(Color.red)
                                            .clipShape(Circle())
                                            .offset(x: 10, y: -10)
                                    }
                                }
                            }
                            .padding(.bottom, 30)
                        }
                    }
                    
                    Spacer()
                }
                .foregroundColor(showLight ? .black : .white)
                .font(.title)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .opacity(recording ? 0 : 1)
            
            VStack{
                Spacer()
                
                HStack(alignment: .center){
                    
                    if !musicTag {
                        Button(action: {
                            cameraModel.switchCamera()
                            
                            withAnimation{
                                lightRadius = 0
                                sliderLastDragValue = 0
                                sliderProgress = 0
                                sliderWidthLastDragValue = 0
                                sliderWidthProgress = 0
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(showLight ? .black : .white)
                                .font(.title3)
                        }
                    } else {
                        // Empty frame with clear background color
                        Color.clear
                            .frame(width: 40, height: 40)
                            .hidden()
                    }
                    
                    Spacer()
                    
                    HStack{
                        Button(action: {
                            cameraModel.resetCameraViewModel()
                            timerCountDown = 4
                            savedVideo = true
                            withAnimation(.easeInOut(duration: 0.15)) {
                                CamVid.toggle()
                            }
                        }){
                            Image(systemName: "camera.fill")
                                .font(CamVid ? .caption : .body)
                                .foregroundColor(CamVid ? Color.secondary : (showLight ? Color.primary : Color.white))
                        }
                        .padding(.trailing, 5)
                        
                        Button(action: {
                            cameraModel.resetCameraViewModel()
                            timerCountDown = 4
                            savedVideo = true
                            withAnimation(.easeInOut(duration: 0.15)) {
                                CamVid.toggle()
                            }
                        }){
                            Image(systemName: "video.fill")
                                .font(CamVid ? .body : .caption)
                                .foregroundColor(CamVid ? (showLight ? Color.primary : Color.white) : Color.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {showImagePicker = true}){
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundColor(showLight ? .black : .white)
                    }
                }
                .padding(.horizontal, 30)
            }
            .opacity(recording ? 0 : 1)
            .sheet(isPresented: $showingSheet) {
                
                Group {
                    NavigationView {
                        VStack {
                            HStack {
                                Text("音楽")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                HStack {
                                    Spacer()
                                    
                                    let scaleFactor = UIScreen.main.scale
                                    let pixelHeight: CGFloat = 70
                                    let pointHeight = pixelHeight / scaleFactor
                                    
                                    Image("Spotify_Logo_RGB_Green")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: pointHeight)
                                    
                                }
                                .ignoresSafeArea()
                                .padding(.top)
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                            
                            
                            if searchAction || loadingSheet {
                                
                                Spacer()
                                
                                ProgressView()
                                    .onAppear {
                                        
                                        if loadingSheet {
                                            
                                            audioPlayer.getPlaylist { result in
                                                DispatchQueue.main.async {  // Ensure UI updates are on the main thread
                                                    switch result {
                                                    case .success(let tracks):
                                                        self.tracks = tracks
                                                        self.trendTracks = tracks
                                                        loadingSheet = false
                                                    case .failure(let error):
                                                        // Handle error, e.g., show an alert to the user
                                                        print("Error fetching playlist: \(error)")
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                
                                Spacer()
                                
                            } else {
                                
                                if !musicTag {
                                    
                                    TextField("Search", text: $searchText, onCommit: {
                                        
                                        if searchText == "" {
                                            
                                            withAnimation{
                                                tracks = trendTracks
                                            }
                                        } else {
                                            
                                            withAnimation{
                                                searchAction = true
                                                audioPlayer.getSearchResult(query: searchText, type: "track"){ result in
                                                    
                                                    tracks = result
                                                    searchAction = false
                                                }
                                            }
                                        }
                                    })
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(10)
                                    .frame(height: 10)
                                    .id("SearchBar")
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                    
                                    List {
                                        ForEach($tracks) { track in
                                            NavigationLink(destination: SongSelectedIndividualView(postLume: postLume, track: track, showingSheet: $showingSheet, musicTag: $musicTag)) {
                                                SongIndividualListView(track: track, curPlayURI: $curPlayURI, audioPlayer: $audioPlayer, showingSheet: $showingSheet)
                                            }
                                        }
                                    }
                                    .listStyle(.inset)
                                    
                                } else {
                                    
                                    SongSelectedIndividualView(postLume: postLume, track: $postLume.tagMusic, showingSheet: $showingSheet, musicTag: $musicTag)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .onDisappear {
                            searchBarKeyboard = false
                        }
                        .onAppear {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .presentationDetents(
                    [
                        .height(UIScreen.main.bounds.height * 0.7),
                        //.height(UIScreen.main.bounds.height)
                    ]
                )
            }
            .sheet(isPresented: $showImagePicker) {
                NavigationStack {
                    ImageSelectorSheetView(imagePicker: imagePicker, isFocused: $showImagePicker, maxCnt: 8)
                }
                .onDisappear{
                    imagePicker.fetchContents { fetchedContents in
                        postLume.contents.append(contentsOf: fetchedContents)
                        contentsCount = postLume.contents.count
                    }
                }
            }
            
            
            
            if timerActivated && recording && timerCountDown > 0 && timerCountingRN {
                ZStack {
                    Text("\(timerCountDown)")
                        .font(.system(size: 100))
                        .fontWeight(.bold)
                }
                .onAppear {
                    
                    timerCountDown = 4
                    
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                        withAnimation {
                            
                            if timerCountDown > 0 && timerCountingRN {
                                
                                // Turn flashlight level to 0.5
                                cameraModel.setFlashlight(level: 0.5)
                                
                                // After 0.5 seconds, turn off flashlight
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    cameraModel.setFlashlight(level: 0.0) // Assuming that setting level to 0 turns the flashlight off
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                                    timerCountDown -= 1
                                }
                            } else {
                                timerCountingRN = false
                                timer.invalidate()
                            }
                        }
                    }
                }
                .onDisappear{
                    recording = false
                    timerCountingRN = false
                    cameraModel.setFlashlight(level: 0.0)
                    timerCountDown = 4
                }
            }
        }
        .animation(.easeInOut, value: cameraModel.showPreview)
        .onAppear{
            imagePicker.setUp()
        }
        .navigationBarHidden(true)
    }
    
    
    struct SongIndividualListView: View {
        
        @Binding var track: Track
        @Binding var curPlayURI: String //UID of the music that is playing currently -> to monitor when to stop
        
        @Binding var audioPlayer: AudioPlayer  // Use @Binding here
        @Binding var showingSheet: Bool
        
        @State private var PlayOrPause: Bool = false
        
        var body: some View {
            
            HStack{
                
                if let image = track.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .shadow(radius: 5)
                } else {
                    
                    EmptyView()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading){
                    
                    Text(track.trackName)
                        .font(.body)
                        .fontWeight(.bold)
                    
                    Text(track.artistName)
                        .font(.caption2)
                }
                .foregroundColor(Color.secondary)
                
                Spacer()
                
                Image(systemName: PlayOrPause ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title3)
                    .foregroundColor(Color.secondary)
                    .opacity(track.previewUrl == nil ? 0 : 1)
                    .onTapGesture {
                        
                        if track.audioPlayer == nil {
                            
                            track.initializeAudioPlayer() { _ in
                                
                                PlayOrPause = true
                                track.playAudio()
                                curPlayURI = track.uri
                            }
                            
                        } else {
                            
                            PlayOrPause.toggle()
                            
                            withAnimation{
                                
                                if(PlayOrPause) {
                                    track.playAudio()
                                    curPlayURI = track.uri
                                } else {
                                    track.stopAudio()
                                }
                            }
                        }
                    }
                
            }
            .onDisappear{
                track.stopAudio()
                track.resetAudioPlayer()
                PlayOrPause = false
            }
            .onChange(of: curPlayURI){ change in
                if change != track.uri {
                    track.stopAudio()
                    PlayOrPause = false
                }
            }
        }
    }
        
    struct SongSelectedIndividualView: View {
        
        @ObservedObject var postLume: Lume
        
        @Binding var track: Track
        
        @Binding var showingSheet: Bool
        
        @State private var PlayOrPause: Bool = false
        
        @State private var lowerValue: Double = 50
        @State private var upperValue: Double = 250
        
        @Binding var musicTag: Bool
        
        @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            
            
            VStack{
                
                if !musicTag {
                    
                    HStack{
                        
                        Button(action: {
                            
                            track.stopAudio()
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                                .foregroundColor(Color.secondary)
                                .padding(.leading)
                            
                        })
                        
                        Spacer()
                    }
                }
                
                HStack{
                    
                    if let image = track.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                        //.cornerRadius(10)
                    } else {
                        EmptyView()
                            .frame(width: 150, height: 150)
                    }
                    
                    VStack(alignment: .leading){
                        
                        Text(track.trackName)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text(track.artistName)
                            .font(.body)
                    }
                    .foregroundColor(Color.secondary)
                    
                    Spacer()
                }
                .padding(.vertical)
                
                HStack{
                    
                    AudioVisualizer(track: $track)
                    
                    Button(action: {
                        if postLume.tagMusic == track {
                            
                            withAnimation{
                                postLume.tagMusic = Track()
                                musicTag = false
                            }
                        } else {
                            withAnimation{
                                postLume.tagMusic = track
                                musicTag = true
                            }
                        }
                        
                        
                    }) {
                        Image(systemName: musicTag ? "x.circle.fill" : "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(musicTag ? Color.red : Color.yellow)
                    }
                    .onAppear{
                        
                        if postLume.tagMusic == track {
                            withAnimation{
                                musicTag = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationBarHidden(true)
            .onDisappear{
                track.stopAudio()
            }
        }
    }
}

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}



struct PrepPost: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var postLume: Lume
    
    @State private var selectedOption: String = "撮影"
    @State private var barLength: Double = 0.0
    
    @State private var description: String = ""
    @State private var completePage: String = "撮影"
    
    
    @StateObject private var cosmeticsWrapper = CosmeticsWrapper()
    @StateObject private var taggedProducts = CosmeticsWrapper()
    
    var body: some View {
        
        NavigationView{
        
            ZStack{
                
                VStack{
                    
                    VStack{
                        
                        ZStack{
                            
                            HStack{
                                
                                TextOptionView(text: "撮影", selectedOption: $selectedOption, completePage: $completePage)
                                
                                Spacer()
                                
                                TextOptionView(text: "概要", selectedOption: $selectedOption, completePage: $completePage)
                                
                                Spacer()
                                
                                TextOptionView(text: "商品", selectedOption: $selectedOption, completePage: $completePage)
                                
                                Spacer()
                                
                                TextOptionView(text: "評価", selectedOption: $selectedOption, completePage: $completePage)
                            }
                        }
                        
                        GeometryReader { geometry in
                            
                            ZStack {
                                /*Divider()
                                 .frame(minHeight: 1)
                                 .overlay(Color(red: 0.686, green: 0.817, blue: 0.724))
                                 */
                                
                                HStack{
                                    Divider()
                                        .frame(width:
                                                selectedOption == "撮影" ? geometry.size.width/6 : //0.0 :
                                                selectedOption == "概要" ? geometry.size.width/3 :
                                                selectedOption == "商品" ? (geometry.size.width*2)/3 :
                                                selectedOption == "評価" ? geometry.size.width-10 : geometry.size.width/6 // 0.0
                                               , height: 3)
                                        .overlay(Color(red: 0.486, green: 0.629, blue: 0.53))
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    CircleOptionView(selectedOption: $selectedOption, completePage: $completePage, option: "撮影")
                                    Spacer()
                                    CircleOptionView(selectedOption: $selectedOption, completePage: $completePage, option: "概要")
                                    Spacer()
                                    CircleOptionView(selectedOption: $selectedOption, completePage: $completePage, option: "商品")
                                    Spacer()
                                    CircleOptionView(selectedOption: $selectedOption, completePage: $completePage, option: "評価")
                                }
                            }
                        }
                        .frame(height: 20)
                    }
                    .padding(.horizontal, 15)
                    .padding(.leading, 30)
                    .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                    
                    Spacer()
                }
                
                
                VStack{
                    HStack{
                        
                        Button(action: {
                            
                            if selectedOption == "撮影"{
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                
                                withAnimation{
                                    if selectedOption == "概要" {
                                        selectedOption = "撮影"
                                    } else if selectedOption == "商品" {
                                        selectedOption = "概要"
                                    } else {
                                        selectedOption = "商品"
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                                .padding(.top, 35)
                                .padding(.leading, 15)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                
                if selectedOption == "撮影" {
                    PostPreview(postLume: postLume, selectedOption: $selectedOption, completePage: $completePage, cosmeticsWrapper: cosmeticsWrapper)
                } else if selectedOption == "概要" {
                    PostDescription(postLume: postLume, description: $description, selectedOption: $selectedOption, completePage: $completePage)
                } else if selectedOption == "商品" {
                    PostTag(postLume: postLume, selectedOption: $selectedOption, cosmeticsWrapper: cosmeticsWrapper, completePage: $completePage)
                } else {
                    RatingAction(postLume: postLume, selectedOption: $selectedOption, cosmeticsWrapper: cosmeticsWrapper, completePage: $completePage)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    
    struct TextOptionView: View {
        
        let text: String
        
        @Binding var selectedOption: String
        @Binding var completePage: String

        let pages = ["撮影", "概要", "商品", "評価"]

        var body: some View {
            Text(NSLocalizedString(text, comment: "PostContent TabBar Option"))
                .font(text == selectedOption ? .title2 : .callout)
                .fontWeight(text == selectedOption ? .bold: .regular)
                .onTapGesture {
                    withAnimation {
                        // Check if the desired page is within the range of completed pages
                        if let desiredPageIndex = pages.firstIndex(of: text),
                           let completedPageIndex = pages.firstIndex(of: completePage),
                           desiredPageIndex <= completedPageIndex {
                            selectedOption = text
                        }
                        // else, do nothing
                    }
                }
        }
    }
    
    struct CircleOptionView: View {
        
        @Binding var selectedOption: String
        @Binding var completePage: String
        
        let option: String

        let pages = ["撮影", "概要", "商品", "評価"]

        var body: some View {
            Circle()
                .frame(width: 15, height: 15)
                .onTapGesture {
                    withAnimation {
                        // Check if the desired page is within the range of completed pages
                        if let desiredPageIndex = pages.firstIndex(of: option),
                           let completedPageIndex = pages.firstIndex(of: completePage),
                           desiredPageIndex <= completedPageIndex {
                            selectedOption = option
                        }
                        // else, do nothing
                    }
                }
        }
    }

    /*struct PostPreview_Previews: PreviewProvider {
        
        @State static var postLume = Reel()
        
        @State static var selectedOption: String = "撮影"
        @State static var completePage: String = "撮影"
        
        static var previews: some View {
            PostPreview(postLume: $postLume, selectedOption: $selectedOption, completePage: $completePage)
        }
    }*/
    
    struct PostPreview: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        @ObservedObject var postLume: Lume
        
        @Binding var selectedOption: String
        @Binding var completePage: String
        
        @ObservedObject var cosmeticsWrapper: CosmeticsWrapper
        
        var body: some View {
            
            ZStack{
                
                postLumesPlayer(postLume: postLume)
                    .frame(width: UIScreen.main.bounds.width * 0.85, height:UIScreen.main.bounds.height * 0.8)
                    .cornerRadius(34)
                    .padding(.top, 60)
                
                VStack{
                    
                    Spacer()
                    
                    HStack{
                        
                        Spacer()
                        
                        Button {
                            withAnimation{
                                selectedOption = "概要"
                                completePage = "概要"
                            }
                        } label: {
                            ZStack {
                                Rectangle()
                                    .frame(width: 100, height: 40)
                                    .cornerRadius(50)
                                    .foregroundColor(Color.primary)
                                
                                Text("次へ")
                                    .fontWeight(.bold)
                                    .font(.callout)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }
                        }
                    }
                }
                .padding()
                .padding(.horizontal, 25)
            }
            .onAppear {
                Task {
                    do {
                        try await cosmeticsWrapper.fetchRandomCosmetics()
                    } catch {
                        print(error)
                    }
                }
            }

        }
    }
    
    struct PostDescription: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        @ObservedObject var postLume: Lume
        
        @Binding var description: String
        @Binding var selectedOption: String
        @Binding var completePage: String
        
        var body: some View {
            
            ZStack{
                
                HStack{
                    
                    VStack(alignment: .leading) {
                        Text("投稿の概要欄")
                            .font(.callout)
                            .fontWeight(.bold)
                            .padding(.top, 100)
                        
                        Rectangle()
                            .foregroundColor(Color.gray)
                            .frame(width: 100, height: 1)
                            .padding(.bottom, 10)
                        
                        TextField("ここから始める", text: $description, axis: .vertical)
                            .lineLimit(10)
                            .onReceive(description.publisher.collect()) {
                                description = String($0.prefix(300))
                                postLume.postDescription = description
                            }
                        
                        HStack{
                            
                            Spacer()
                            
                            Text("\(description.count) / 300")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                        }
                        
                        
                        HStack{
                            
                            Spacer()
                            
                            Button(action: {
                                
                                withAnimation {
                                    selectedOption = "商品"
                                    completePage = "商品"
                                }
                                
                            }){
                                ZStack {
                                    Rectangle()
                                        .frame(width: 100, height: 40)
                                        .cornerRadius(50)
                                        //.foregroundColor(Color.primary.opacity((description.count == 0) ? 0.2 : 1))
                                        .foregroundColor(Color.primary)
                                    
                                    Text("次へ")
                                        .fontWeight(.bold)
                                        .font(.body)
                                        .foregroundColor(colorScheme == .dark ? .black : .white)
                                }
                            }
                            //.disabled(description.count == 0)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    struct PostTag: View {
        
        @ObservedObject var postLume: Lume
        
        @Binding var selectedOption: String
        @ObservedObject var cosmeticsWrapper: CosmeticsWrapper
        @Binding var completePage: String
        
        @Environment(\.colorScheme) var colorScheme
        
        // Barcode Scanner
        @State private var isShowingScanner = false
        @State private var SearchOutputShow: Bool = false
        @State private var scannedCode: String = ""
        @State var searchTerm: String = ""
        
        @State var tagAny: Bool = false
        
        @State var filterTag: Bool = false
        
        var body: some View {
                
            ZStack{
                
                VStack{
                    
                    HStack{
                        ZStack{
                            TextField("", text: $searchTerm, onCommit: {
                                
                                withAnimation {
                                    SearchOutputShow = true
                                }
                            })
                            .placeholder(when: searchTerm.isEmpty) {
                                Text("検索").foregroundColor(.gray)
                            }
                            .padding(.all, 8)
                            .background(Color.primary.opacity(0.1))
                            .autocapitalization(.none)
                            .cornerRadius(10)
                            
                            if(SearchOutputShow) {
                                
                                HStack{
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        searchTerm = ""
                                        
                                        withAnimation {
                                            SearchOutputShow = false
                                        }
                                        
                                    }) {
                                        Image(systemName: "x.circle.fill")
                                            .foregroundColor(Color.secondary)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        NavigationLink(destination: ProductSubmission()){
                            
                            Image(systemName: "vial.viewfinder")
                                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                                .font(.largeTitle)
                        }
                        .onAppear{
                            
                            if let cosmeticToAppend = GI.shared.cosmeticSubmission {
                                self.cosmeticsWrapper.cosmetics.append(cosmeticToAppend)
                                GI.shared.cosmeticSubmission = nil
                            }
                        }
                        
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                            
                                .font(.largeTitle)
                        }
                        .sheet(isPresented: $isShowingScanner) {
                            VStack {
                                ZStack {
                                    ScannerView(scannedCode: $scannedCode, isShowingScanner: $isShowingScanner)
                                        .aspectRatio(contentMode: .fill)
                                        .padding(.bottom, UIScreen.main.bounds.height/2)
                                        .frame(width: UIScreen.main.bounds.width)
                                        .clipped()
                                        .cornerRadius(25)
                                    
                                    ScanOverlayView() // Add ScanOverlayView here
                                    
                                    VStack {
                                        Text("バーコードをスキャン")
                                            .foregroundColor(.white)
                                            .shadow(radius: 5)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .padding(.bottom, 70)
                                        
                                        Text("枠内にバーコードを収めてください")
                                            .foregroundColor(.white)
                                            .shadow(radius: 5)
                                            .font(.body)
                                            .padding(.bottom)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .foregroundColor(Color.primary)
                            .presentationDetents(
                                [
                                    .height(UIScreen.main.bounds.height * 0.25)
                                ]
                            )
                        }
                        .onChange(of: isShowingScanner) { change in
                            
                            if !change {
                                if(scannedCode != ""){
                                    searchTerm = scannedCode
                                    scannedCode = ""
                                    withAnimation {
                                        SearchOutputShow = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 80)
                    .padding(.horizontal)
                    .opacity(filterTag ? 0 : 1)
                    
                    
                    ZStack{
                        
                        ProductView(postLume: postLume, tagAny: $tagAny, filterTag: $filterTag, cosmeticsWrapper: cosmeticsWrapper)
                        
                        VStack{
                            
                            Spacer()
                            
                            HStack (alignment: .top){
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    withAnimation{
                                        filterTag.toggle()
                                    }
                                    
                                }){
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(50)
                                            .foregroundColor(.primary)
                                        
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(colorScheme == .dark ? .black : .white)
                                    }
                                }
                                
                                Button(action: {
                                    
                                    withAnimation{
                                        selectedOption = "評価"
                                        completePage = "評価"
                                    }
                                    
                                }){
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 140, height: 50)
                                            .cornerRadius(50)
                                            .foregroundColor(.primary)
                                        
                                        HStack{
                                            Text("次へ")
                                                .fontWeight(.bold)
                                                .font(.body)
                                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .opacity((tagAny || !postLume.tagProducts.isEmpty) ? 1 : 0)
                    }
                    .ignoresSafeArea()
                }
            }
        }
    }
    
    
    struct RatingAction: View {
        
        @ObservedObject var postLume: Lume
        
        @Binding var selectedOption: String
        
        @ObservedObject var cosmeticsWrapper: CosmeticsWrapper
        
        @Binding var completePage: String
        
        @Environment(\.colorScheme) var colorScheme
        
        // Barcode Scanner
        @State private var isShowingScanner = false
        @State private var SearchOutputShow: Bool = false
        @State private var scannedCode: String = ""
        @State var searchTerm: String = ""
        
        @State var tagAny: Bool = false
        
        @State var filterTag: Bool = false
        
        @State private var isPresented: Bool = false
        
        var body: some View {
            
            ZStack{
                
                VStack{
                    
                    ZStack{
                        
                        RatingView(postLume: postLume)
                        
                        VStack{
                            
                            Spacer()
                            
                            HStack (alignment: .top){
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    withAnimation{
                                        selectedOption = "評価"
                                        completePage = "評価"
                                    }
                                    DispatchQueue.main.async {
                                        postLume.uploadLumeQL() { result in
                                            switch result {
                                                
                                            case .success:
                                                
                                                GI.shared.profileSettings?.postContents.append(postLume.postID)
                                                
                                            case .failure:
                                                
                                                print("Error uploading in PostContent")
                                            }
                                        }
                                    }
                                    
                                    isPresented.toggle()
                                     
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first {
                                        // Initialize the main view controller you want to display
                                        let mainViewController = LumeHorizontalTabViewController()  // Replace MainViewController with your main view controller

                                        // Wrap the main view controller in your custom navigation controller
                                        let navigationController = FakeModalNavigationController(rootViewController: mainViewController)

                                        // Perform the custom animation transition
                                        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                                            window.rootViewController = navigationController
                                        }, completion: { _ in
                                            window.makeKeyAndVisible()
                                        })
                                    }

                                }){
                                    ZStack {
                                        Rectangle()
                                            .frame(width: 100, height: 50)
                                            .cornerRadius(50)
                                            .foregroundColor(.primary)
                                        
                                        HStack{
                                            Text("投稿")
                                                .fontWeight(.bold)
                                                .font(.body)
                                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                            
                                            Image(systemName: "arrow.up.circle")
                                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                            
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .opacity((tagAny || !postLume.tagProducts.isEmpty) ? 1 : 0)
                    }
                    .ignoresSafeArea()
                }
                .padding(.top, 80)
            }
        }
    }
    
    struct RatingView: View {
        
        @ObservedObject var postLume: Lume
        
        var body: some View {
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(postLume.tagProducts , id: \.id) { tagCosmetic in
                        RatingIndividualListView(postLume: postLume, tagCosmetic: tagCosmetic)
                            .padding(.bottom)
                            .padding(.top, 10)
                    }
                    .padding(.top, 25)
                }
                
                Spacer()
                    .padding(.vertical, 100)
            }
        }
    }
    
    
    struct postLumesPlayer: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        @ObservedObject var postLume: Lume
        
        @State var currentReel: UUID = UUID(uuidString: "") ?? UUID()
        
        @State private var mute: Bool = false
        @State private var lastTapTime: Date? = nil
        
        @State private var userName: String = ""
        @State private var musicName: String = ""
        
        @State private var currentContent: UUID = UUID(uuidString: "") ?? UUID()
        
        var body: some View{
            
            ZStack{
                
                if colorScheme == .dark {
                    Color.white.ignoresSafeArea()
                } else {
                    Color.black.ignoresSafeArea()
                }
                
                if !postLume.contents.isEmpty {
                    
                    TabView(selection: $currentContent) {
                        ForEach(postLume.contents) { content in
                            
                            switch content {
                            case Content.video(let reelVideo):
                                // Assuming reelVideo.player is an AVPlayer
                                
                                CustomVideoPlayer(player: reelVideo.player!)
                                    .tag(reelVideo.id)
                                    .onChange(of: currentContent) { change in
                                        
                                        postLume.currentContent = change
     
                                        if change != reelVideo.id {
                                            
                                            reelVideo.player?.pause()
                                            reelVideo.player?.isMuted = mute
                                        } else {
                                            
                                            reelVideo.player?.isMuted = mute
                                            reelVideo.player?.play()
                                        }
                                    }
                                
                                
                            case Content.image(let reelImage):
                                ZStack {
                                    if let uiImage = reelImage.image {
                                        // If a UIImage is already loaded, display it
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    } else {
                                        LoadingSpinner()
                                            .task(id: reelImage.url) {
                                                do {
                                                    let (data, _) = try await URLSession.shared.data(from: reelImage.url!)
                                                    if let fetchedImage = UIImage(data: data) {
                                                        // Update the reelImage with the fetched UIImage
                                                        DispatchQueue.main.async {
                                                            // Update the image in ReelImage
                                                            if let index = postLume.contents.firstIndex(where: { $0.id == reelImage.id }) {
                                                                switch postLume.contents[index] {
                                                                case .image(let updatedReelImage):
                                                                    updatedReelImage.image = fetchedImage
                                                                    postLume.contents[index] = .image(updatedReelImage)
                                                                default:
                                                                    break
                                                                }
                                                            }
                                                        }
                                                    }
                                                } catch {
                                                    print("Error fetching image: \(error)")
                                                }
                                            }
                                    }
                                }

                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .onDisappear{
                        postLume.stopVideos()
                    }
                    
                    
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: ViewPositionKey.self, value: proxy.frame(in: .global))
                    }
                    .onPreferenceChange(ViewPositionKey.self) { frame in
                        let minY = frame.minY
                        let size = frame.size
                        manageVideoPlayback(minY: minY, size: size, reel: postLume)
                    }
                    
                } else {
                    
                    Color(red: 0.919, green: 0.767, blue: 0.834)
                        .ignoresSafeArea()
                    
                    LoadingSpinner()
                    
                }
            }
            .onAppear{
                
                let trackName = postLume.tagMusic.trackName
                let artistName = postLume.tagMusic.artistName

                if !trackName.isEmpty && !artistName.isEmpty {
                    musicName = "\(trackName) by \(artistName)"
                } else if !trackName.isEmpty {
                    musicName = trackName
                } else if !artistName.isEmpty {
                    musicName = artistName
                }
                
                if let firstContent = postLume.contents.first {
                    switch firstContent {
                    case .video(let reelVideo):
                        
                        // only play when the current tab is at the first video
                        
                        
                        if currentContent == UUID(uuidString: "") {
                            currentContent = reelVideo.id
                            postLume.currentContent = reelVideo.id
                        }
                        
                        if currentReel == postLume.id {
                            reelVideo.player?.play()
                            reelVideo.player?.seek(to: CMTime.zero)
                        }
                        
                    default:
                        // Handle other types or do nothing
                        break
                    }
                }

            }
            .navigationBarHidden(true)
        }
        
        
        func manageVideoPlayback(minY: CGFloat, size: CGSize, reel: Lume) {
            // Check if the current reel is the one being displayed and if it's the selected tab
            if -minY < (size.height / 2) && minY < (size.height / 2) && currentReel == reel.id {
                // Find the current content by matching the currentContent UUID
                if let currentContent = reel.contents.first(where: {$0.id == reel.currentContent}) {
                    // Play the video if the current content is a video
                    if case .video(let reelVideo) = currentContent {
                        reelVideo.player?.play()
                    }
                }
            } else {
                // Find the current content by matching the currentContent UUID
                if let currentContent = reel.contents.first(where: { $0.id == reel.currentContent }) {
                    // Pause the video if the current content is a video
                    if case .video(let reelVideo) = currentContent {
                        reelVideo.player?.pause()
                    }
                }
            }
        }
    }
}


class FakeModalNavigationController: UINavigationController {

    fileprivate static let unwindToBubblegumScreenSegueID = "unwindToBubblegumScreenSegueID"

    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        if unwindSegue.identifier == type(of: self).unwindToBubblegumScreenSegueID {
            popViewControllerAnimatedFromBottom(subsequentVC)
        }
    }

    fileprivate func popViewControllerAnimatedFromBottom(_ viewControllerToPop: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromBottom
        view.layer.add(transition, forKey: nil)
        popViewController(animated: false)
    }
}
