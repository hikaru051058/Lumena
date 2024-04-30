import SwiftUI
import AVKit

struct ReelsView: View {
    
    @State var currentReel: UUID = (UUID(uuidString: "") ?? UUID())
    @State var offsetY: CGFloat = 0.0  // To store the drag offset
    @State var isRefreshing: Bool = false // To check if it's in refreshing state
    
    @State var pageTag: Int
    @Binding var selectedTab: Int
    @State private var atTop: Bool = false
    
    // Extracting Avplayer from media File...
    @Binding var reels: [Lume]
    @State var reelLocation: UUID = (UUID(uuidString: "") ?? UUID())
    @State private var result_conv: Lume?
    
    @GestureState private var translation: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var updating: Bool = false
    
    @State var mute: Bool = false
    
    @Binding var videoPlaybackSliderProgress: CGFloat
    @Binding var videoPlaybackSliderDragged:  Bool
    
    var body: some View {
        
        // Setting Width and height for rotated view....
        GeometryReader{proxy in
            
            ZStack{
                
                Color.black.ignoresSafeArea()
                
                // Vertical Page Tab VIew....
                TabView(selection: $currentReel){
                    
                    ForEach($reels){$reel in
                        
                        ReelsPlayer(reel: $reel, reels: $reels, reelLocation: $reelLocation, currentReel: $currentReel, mute: $mute, pageTag: pageTag, selectedTab: $selectedTab, videoPlaybackSliderProgress: $videoPlaybackSliderProgress, videoPlaybackSliderDragged: $videoPlaybackSliderDragged)
                        // setting width...
                            .frame(width: UIScreen.main.bounds.width)
                        // Rotating Content...
                            .rotationEffect(.init(degrees: -90))
                        //.ignoresSafeArea(.all, edges: .top)
                            .ignoresSafeArea()
                            .tag(reel.id)
                    }
                    .onChange(of: currentReel) { newValue in
                        if reels.contains(where: { $0.id == newValue }) {
                            if newValue == reels.first?.id {
                                atTop = true
                            } else if newValue == reels.last?.id || (reels.dropLast().last?.id == newValue) {
                                Task {
                                    do {
                                        var reelsToAppend: [Lume] = []
                                        if pageTag == 0 {
                                            reelsToAppend = try await GraphQL.shared.fetchRandomLumes()
                                        } else if pageTag == 1 {
                                            reelsToAppend = try await GraphQL.shared.fetchUserFollowingLumes()
                                        }
                                        reels.append(contentsOf: reelsToAppend)
                                    } catch {
                                        print(error)
                                    }
                                }
                            } else {
                                atTop = false
                            }
                        }
                    }
                    .onChange(of: currentReel) { change in
                        if change == UUID(uuidString: "Loading") {
                            DispatchQueue.main.async {
                                Task {
                                    do {
                                        var reelsToAppend: [Lume] = []
                                        if pageTag == 0 {
                                            reelsToAppend = try await GraphQL.shared.fetchRandomLumes()
                                        } else if pageTag == 1 {
                                            reelsToAppend = try await GraphQL.shared.fetchUserFollowingLumes()
                                        }
                                        reels.append(contentsOf: reelsToAppend)
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                    
                    ZStack{
                        LoadingSpinner()
                            .padding(.bottom, 30)
                            .tag(UUID(uuidString: "Loading"))
                    }
                }
                // Rotating View....
                .rotationEffect(.init(degrees: 90))
                // Since view is rotated setting height as width...
                .frame(width: UIScreen.main.bounds.height)
                .tabViewStyle(.page(indexDisplayMode: .never))
                // setting max width...
                .frame(width: UIScreen.main.bounds.width)
                .ignoresSafeArea()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            Task {
                do {
                    var reelsToAppend: [Lume] = []
                    if pageTag == 0 {
                        reelsToAppend = try await GraphQL.shared.fetchRandomLumes()
                    } else if pageTag == 1 {
                        reelsToAppend = try await GraphQL.shared.fetchUserFollowingLumes()
                    }
                    reels.append(contentsOf: reelsToAppend)
                } catch {
                    print(error)
                }
            }
            if let firstReel = reels.first?.id {
                currentReel = firstReel
            }
        }
        .ignoresSafeArea()
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0.1).updating($translation) { value, state, _ in
            let accumulatedTranslation = value.translation.height + dragOffset
            state = accumulatedTranslation // Set the translation including the accumulated offset
        }
        .onEnded { value in
            let gestureThreshold = UIScreen.main.bounds.height * 0.1
            dragOffset = value.translation.height.truncatingRemainder(dividingBy: UIScreen.main.bounds.height)
            withAnimation(.easeOut) {
                if value.translation.height > gestureThreshold {
                    print("refreshing...")
                    updating = true
                }
                dragOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
                
                updating = false
            }
        }
    }
}

extension View {
    @ViewBuilder
    func applyGesture(if condition: Bool, gesture: some Gesture) -> some View {
        if condition {
            self.gesture(gesture)
        } else {
            self
        }
    }
}


struct ReelsPlayer: View {
    
    @Binding var reel: Lume
    @Binding var reels: [Lume]
    
    @Binding var reelLocation: UUID
    @Binding var currentReel: UUID
    
    @Binding var mute: Bool
    @State private var lastTapTime: Date? = nil
    @State private var muteAnimation = false
    @State private var showLove: Bool = false
    @State private var userLiked: Bool = false
    @State private var isAnimating: Bool = false
    
    @State private var longHold: Bool = false
    
    @State private var singleTapWorkItem: DispatchWorkItem?
    
    @State var pageTag: Int
    @Binding var selectedTab: Int
    
    // Computed property
    @State private var currentMinY: CGFloat = 0
    @State private var currentSize: CGSize = .zero
    
    @State private var userName: String = ""
    @State private var musicName: String = ""
    
    @Binding var videoPlaybackSliderProgress: CGFloat
    @Binding var videoPlaybackSliderDragged:  Bool
    
    @State private var imageLoading: Bool = true
    @State private var imageDownload: Image? = nil
    @State private var imageReelImageid: UUID? = nil
    
    var body: some View{
        
        ZStack{
            
            if !reel.contents.isEmpty {
                
                TabView(selection: $reel.currentContent) {
                    ForEach(reel.contents) { content in
                        switch content {
                        case Content.video(let reelVideo):
                            CustomVideoPlayer(player: reelVideo.player!)
                                .tag(reelVideo.id)
                                .onChange(of: reel.currentContent) { change in
                                    videoPlaybackSliderProgress = CGFloat(0)
                                    setupVideoPlaybackObserver()
                                    reel.playVideo(mute: mute)
                                }
                                .onChange(of: videoPlaybackSliderDragged) { change in
                                    if currentReel == reel.id {
                                        if change {
                                            reelVideo.player?.pause()
                                        } else {
                                            reelVideo.player?.play()
                                        }
                                    }
                                }
                                .onChange(of: videoPlaybackSliderProgress) { change in
                                    if currentReel == reel.id {
                                        if videoPlaybackSliderDragged {
                                            reelVideo.player?.pause()
                                            if reelVideo.id == reel.currentContent {
                                                let duration = reelVideo.player?.currentItem?.duration.seconds ?? 0
                                                let newTime = duration * Double(change)
                                                reelVideo.player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 100))
                                            }
                                        }
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
                                }
                            }
                        }
                    }
                }
                //.tabViewStyle(PageTabViewStyle())
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .onDisappear{
                    reelLocation = reel.id
                    reel.stopVideos()
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .gesture(
                    TapGesture(count: 2)
                        .onEnded { _ in
                            // Cancel the single-tap action
                            singleTapWorkItem?.cancel()
                            
                            withAnimation {
                                userLiked.toggle()
                                reel.likedLume(userLikeInput: userLiked)
                            }
                            
                            showLove = true

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showLove = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    // Schedule the single-tap action with a delay
                    singleTapWorkItem = DispatchWorkItem {
                        
                        lastTapTime = Date()
                        mute.toggle()
                        
                        reel.muteVideos(mute: mute)
                                        
                        withAnimation(.easeIn(duration: 0.1)) {
                            muteAnimation.toggle()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation {
                                muteAnimation.toggle()
                            }
                        }
                    }
                                    
                    // Delay the single-tap action by 0.25 seconds to give double tap a chance to be recognized
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: singleTapWorkItem!)
                }
                
                
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ViewPositionKey.self, value: proxy.frame(in: .global))
                }
                .onPreferenceChange(ViewPositionKey.self) { frame in
                    let minY = frame.minY
                    let size = frame.size
                    manageVideoPlayback(minY: minY, size: size, reel: reel)
                }
                
                Image(systemName: mute ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(.secondary)
                    .clipShape(Circle())
                    .foregroundStyle(.black)
                    .opacity(muteAnimation ? 1 : 0)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .foregroundColor(Color(red: 0.919, green: 0.767, blue: 0.834))
                    .shadow(radius: 1)
                    .opacity(showLove ? 1 : 0)
                    .font(.largeTitle)
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                
                
                VStack{
                    
                    // Invisible box
                    
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.001))
                        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height*(3/9)))
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(Color.white.opacity(0.001))
                        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height*(3/9)))
                }
                .ignoresSafeArea()
                
                sideButtons(reel: $reel, reels: $reels, userLiked: $userLiked)
                
                VStack{
                    
                    Spacer()
                    
                    ZStack {
                        
                        HStack {
                            
                            if isAnimating {
                                
                                Marquee(text: musicName + (reel.postDescription ?? ""), font: .systemFont(ofSize: 16, weight: .regular))
                                    .frame(width: (UIScreen.main.bounds.width/2)-65)
                            }
                            
                            Spacer()
                            
                            Text("@\(reel.returnPostUser().preferredUsername)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                //.opacity((reel.returnPostUser().preferredUsername == nil) ? 0 : 1)
                        }
                    }
                    .frame(height: 40)
                }
                .onAppear {
                    
                    reel.muteVideos(mute: mute)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        isAnimating = true
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Color.red.frame(height: 35).opacity(0)
                }
                
            } else {
                
                LoadingSpinner()
                
            }
        }
        .onAppear{
            
            let trackName = reel.tagMusic.trackName
            let artistName = reel.tagMusic.artistName

            if !trackName.isEmpty && !artistName.isEmpty {
                musicName = "\(trackName) by \(artistName)"
            } else if !trackName.isEmpty {
                musicName = trackName
            } else if !artistName.isEmpty {
                musicName = artistName
            }
            
            userLiked = reel.userLiked
            reel.playVideo(mute: mute)
        }
    }
    
    private func setupVideoPlaybackObserver() {
        // Assuming you have an AVPlayer instance for the current video
        if let content = reel.contents.first(where: {$0.id == reel.currentContent}) {
            switch content {
            case .video(let reelVideo):
                
                let player = reelVideo.player
                
                let interval = CMTimeMakeWithSeconds(0.3, preferredTimescale: Int32(NSEC_PER_SEC))
                player!.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                    guard let currentItem = player?.currentItem else { return }
                    let duration = CMTimeGetSeconds(currentItem.duration)
                    if duration > 0 {
                        let currentTime = CMTimeGetSeconds(time)
                        withAnimation{
                            self.videoPlaybackSliderProgress = CGFloat(currentTime / duration)
                        }
                    }
                }
                
            default:
                withAnimation{
                    self.videoPlaybackSliderProgress = CGFloat(0.0)
                }
            }
        } else { return }
    }
    
    
    func manageVideoPlayback(minY: CGFloat, size: CGSize, reel: Lume) {
        // Check if the current reel is the one being displayed and if it's the selected tab
        if -minY < (size.height / 2) && minY < (size.height / 2) && currentReel == reel.id && selectedTab == pageTag {
            reel.playVideo(mute: mute)
        } else {
            reel.stopVideos()
        }
    }
}


struct ViewPositionKey: PreferenceKey {
    typealias Value = CGRect
    
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}


// MARK: -- Post side buttons
struct sideButtons: View {
    
    @Binding var reel: Lume
    @Binding var reels: [Lume]
    
    @State private var commentShow: Bool = false
    @State private var cosmeticsShow: Bool = false
    
    @State private var totLikeCount: String = ""
    
    @State private var followButton: Bool = false
    @State private var followAnimation: Bool = false
    @State private var followFinish: Bool = false
    
    @State private var furtherAction: Bool = false
    
    @Binding var userLiked: Bool
    
    var body: some View{
        
        VStack{
            
            Spacer()
            
            HStack(){
                
                Spacer()
                
                VStack {
                    
                    ZStack{
                        if reel.returnPostUser().identityID != AuthenticationManager.shared.identityID {
                            
                            NavigationLink(destination: OtherUserProfile(profile: reel.returnPostUser(), followState: $followButton)){
                                
                                if let userUiProfile = reel.returnPostUser().profileImage?.image {
                                    Image(uiImage: userUiProfile)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 45, height: 45)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                } else {
                                    
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 45, height: 45)
                                        .foregroundColor(.white) // This makes the person icon white
                                        .background(Color.gray) // This sets the background to gray
                                        .clipShape(Circle()) // This clips the image and background into a circle
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                        .onAppear{
                                            reel.returnPostUser().profileImage?.loadAgain()
                                        }
                                }
                            }
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: (followButton ? 20 : 40), height: 20)
                                    .padding(.top, 55)
                                    .foregroundColor(followButton ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 0.946, green: 0.76, blue: 0.839))
                                
                                Group{
                                    Text("フォロー")
                                        .font(.system(size: 9))
                                        .fontWeight(.semibold)
                                        .padding(.top, 55)
                                        .foregroundColor(.white)
                                        .opacity(followButton ? 0 : 1)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9))
                                        .font(.system(size: 9))
                                        .fontWeight(.semibold)
                                        .padding(.top, 55)
                                        .foregroundColor(.white)
                                        .opacity(followButton ? 1 : 0)
                                }
                            }
                            .onTapGesture {
                                
                                withAnimation{
                                    followButton.toggle()
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.8){
                                    withAnimation(.easeOut(duration: 0.2)){
                                        followAnimation.toggle()
                                    }
                                }
                                
                                ProfileManager.shared.updateFollowingStatus(fromUserID: GI.shared.identityID!, toUserID: reel.returnPostUser().identityID, follow: followButton)
                            }
                            .opacity(followAnimation ? 0 : 1)
                        }
                    }
                    .padding(.bottom)
                    .onAppear{
                        Task {
                            
                            //logic to identify if the user is being followed or not
                            let followState = await ProfileManager.shared.getRelationshipStat(fromUserID: GI.shared.identityID!, toUserID: reel.postUserIID)
                            if followState == .following {
                                followButton = true
                                followAnimation = true
                            }
                        }
                    }
                    
                    
                    
                    Button(action: {
                        
                        userLiked.toggle()
                        reel.likedLume(userLikeInput: userLiked)
                        
                    }) {
                        VStack{
                            
                            Image(systemName: "heart.fill")
                                .font(.largeTitle)
                                .foregroundColor(userLiked ? Color(red: 0.919, green: 0.767, blue: 0.834) : .white)
                            
                            Text("\(formatNumber(reel.likeCnt))")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(userLiked ? Color(red: 0.919, green: 0.767, blue: 0.834) : .white)
                            
                        }
                    }
                    .padding(.bottom)
                    .onAppear {
                        userLiked = reel.userLiked
                    }
                    
                    
//                    Button(action: {
//                        
//                        commentShow = true
//                        
//                    }) {
//                        ZStack{
//                            
//                            Image(systemName: "bubble.fill")
//                                .font(.largeTitle)
//                                .foregroundColor(Color.white)
//                        }
//                    }
//                    .sheet(isPresented: $commentShow) {
//                        
//                        
//                        CommentSlideView(reel: $reel)
//                            .presentationDetents(
//                                [
//                                    .height(UIScreen.main.bounds.height * 0.65),
//                                    .height(UIScreen.main.bounds.height * 0.85)
//                                ]
//                            )
//                        //.presentationBackground(.regularMaterial)
//                    }
//                    .padding(.bottom)
                    
                    
                    Button(action: {
                        
                        cosmeticsShow = true
                    }) {
                        Image(systemName: "cross.vial")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
                    .sheet(isPresented: $cosmeticsShow) {
                        CosmeticsTagView(TagCosmetics: $reel.tagProducts)
                            .foregroundColor(Color.primary)
                            .presentationDetents(
                                [
                                    .height(UIScreen.main.bounds.height * 0.25),
                                    .height(UIScreen.main.bounds.height * 0.85)
                                ]
                            )
                        //.presentationBackground(.regularMaterial)
                    }
                    .disabled(reel.tagProducts.isEmpty)
                    .opacity(reel.tagProducts.isEmpty ? 0.4 : 1)
                    .padding(.bottom)
                    
                    Button(action: {
                        
                        furtherAction.toggle()
                        
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .confirmationDialog("",isPresented: $furtherAction, titleVisibility: .hidden) {
                        Button("報告", role: .destructive) {
                            // 選択肢2ボタンが押された時の処理
                        }
                        Button("remove current reel", role: .destructive) {
                            reels.removeAll { $0.id == reel.id }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.trailing, 10)
                .frame(height: UIScreen.main.bounds.height/2)
            }
        }
    }
    
    func formatNumber(_ num: Int) -> String {
        let thousand = 1_000
        let million = 1_000_000
        
        if num < thousand {
            return "\(num)"
        } else if num < million {
            return String(format: "%.1fk", Double(num) / Double(thousand))
        } else {
            return String(format: "%.1fm", Double(num) / Double(million))
        }
    }
}


// MARK: -- Comment View

struct CommentSlideView: View {
    
    @Binding var reel: Lume
//    @State private var selectedTab: Int = 0
    
    @State private var loading: Bool = false
    @State private var likers: Bool = false

//    let tabs: [Tab] = [
//        .init(title: "コメント"),
//        .init(title: "ライク")
//    ]

    init(reel: Binding<Lume>) {
        self._reel = reel
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.white)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    var body: some View {
        
        ZStack{
            
            if loading {
                
                ProgressView()
                    .font(.title)
                    .foregroundColor(Color.secondary)
                
            } else {
                
                VStack{
                    
                    ZStack{
                        Text("コメント")
                            .font(.title3)
                            .fontWeight(.bold)
                        
//                        HStack{
//                            
//                            Spacer()
//                            
//                            
//                            Button(action:{
//                                withAnimation{
//                                    likers.toggle()
//                                }
//                            }){
//                                Image(systemName: likers ? "heart.fill" : "heart")
//                                    .font(.title3)
//                                    .fontWeight(.bold)
//                            }
//                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.top, 10)
                    
                    ZStack{
                        
                        VStack{
                            Divider()
                            
                            Spacer()
                        }
                        
                        ZStack{
                            
//                            if likers {
//                                LikeView(reel: $reel)
//                            } else {
                                CommentView(reel: $reel)
//                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.container)
        .onAppear{
            
            loading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                withAnimation{
                    loading = false
                }
            }
        }
    }
}

struct CommentView: View {
    
    @Binding var reel: Lume
    
    @State private var writeComment: String = ""
    @State private var scrollToCommentId: UUID?
    
    @FocusState private var keyboardFocus: Bool
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        ZStack {
            
            VStack {
                
                Group{
                    ScrollView(showsIndicators: false) {
                        ScrollViewReader { scrollView in
                            VStack {
                                
                                // Poster's description
                                if let postDescription = reel.postDescription,
                                   postDescription != ""
                                {
                                    Rectangle()
                                        .frame(height: 16)
                                        .foregroundColor(Color.clear)
                                    
                                    Text(postDescription)
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                    
                                    Divider()
                                        .padding(.top)
                                }
                                
                                if !reel.userComments.isEmpty {
                                    ForEach(reel.userComments.indices, id: \.self) { index in
                                        let comment = reel.userComments[index]
                                        IndividualCommentView(comment: comment)
                                            .id(comment.id)
                                            .onAppear {
                                                if index == reel.userComments.count - 2 {
                                                    reel.fetchComment()
                                                }
                                            }
                                    }
                                    .padding(.vertical, 5)
                                    .onChange(of: scrollToCommentId) { value in
                                        if let value = value {
                                            withAnimation {
                                                scrollView.scrollTo(value, anchor: .bottom)
                                            }
                                        }
                                    }
                                    
                                } else {
                                    
                                    Spacer()
                                    
                                    Text("まだ誰もコメントしてません")
                                        .font(.title2)
                                        .foregroundColor(Color.primary)
                                        .fontWeight(.heavy)
                                    Text("コメントを追加してみよう！")
                                        .font(.callout)
                                        .foregroundColor(Color.secondary)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                }
                            }
                            .onTapGesture {
                                if(keyboardFocus) {
                                    
                                    keyboardFocus = false
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                HStack(alignment: .bottom) {
                    
                    TextField("コメントを書く", text: $writeComment, onCommit: {
                        if !writeComment.isEmpty {
                            
                            if let userProfile = GI.shared.profileSettings {
                                
                                let commentID = reel.postID + ":\(userProfile.identityID):\(Int(Date.now.timeIntervalSince1970))"
                                
                                let newComment = Comment(commentID: commentID, userProfile: userProfile, content: writeComment, lumeQLID: reel.postID)
                                
                                Task {
                                    do {
                                        let message = try await newComment.postComment()
                                        print(message)
                                    } catch {
                                        print(error)
                                    }
                                }
                                
                                reel.userComments.append(newComment)
                                scrollToCommentId = newComment.id
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                writeComment = ""
                            }
                        }
                    })
                    .focused($keyboardFocus)
                    .padding(.all, 20)
                    .frame(height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.gray, lineWidth: 0.5)  // This adds a border
                            .background(Color.clear)  // This makes the fill color clear
                    )
                    .foregroundColor(Color.primary)
                    .keyboardType(.twitter)
                    
                    
                    if writeComment.isEmpty {
                        Button(action: {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }) {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.primary)
                        }
                    } else {
                        Button(action: {
                            
                            if let userProfile = GI.shared.profileSettings {
                                
                                let commentID = reel.postID + ":\(userProfile.identityID):\(Int(Date.now.timeIntervalSince1970))"
                                
                                let newComment = Comment(commentID: commentID, userProfile: userProfile, content: writeComment, lumeQLID: reel.postID)
                                
                                Task {
                                    do {
                                        let message = try await newComment.postComment()
                                        print(message)
                                    } catch {
                                        print(error)
                                    }
                                }
                                
                                reel.userComments.append(newComment)
                                scrollToCommentId = newComment.id
                            }
                            
                            writeComment = ""
                            
                            keyboardFocus = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, keyboardFocus ? 0 : 25)
                .padding(.bottom, keyboardFocus ? keyboardResponder.currentHeight : 0)
            }
            .onAppear{
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .ignoresSafeArea(.container)
    }
}

struct IndividualCommentView: View {
    
    let comment: Comment
    
    var body: some View {
        
        HStack(alignment: .top) {
            
            
            if let userProfileImage = comment.userProfile.profileImage?.image {
                Image(uiImage: userProfileImage)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.gray)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(comment.userProfile.preferredUsername)
                    Text(comment.timestampString)
                    Spacer()
                }
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 3)
                
                Text(comment.content)
                    .font(.footnote)
                    .foregroundColor(.primary)
            }
            .padding(.leading, 6)
            .multilineTextAlignment(.leading)
        }
    }
}



// MARK: -- Like View

struct IndividualLikeView: View {
    
    @Binding var like: ProfileSettings
    
    @State private var following: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack {
                
                if let profileImageURL = like.profileImage?.url {
                    
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    
                } else {
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                }
                
                VStack{
                    
                    Text(like.givenName)
                        .font(.callout)
                        .foregroundColor(Color.primary)
                    
                    Text(like.preferredUsername)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                
                Spacer()
                
                ZStack{
                    
                    RoundedRectangle(cornerRadius: 11)
                        .fill(following ? Color.gray.opacity(0.4) : Color.blue)
                    
                    Text("フォロー")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .opacity(following ? 0 : 1)
                    
                    Text("フォロー中")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                        .opacity(following ? 1 : 0)
                }
                .frame(width: 130, height: 38)
                .onTapGesture {
                    //withAnimation(.easeInOut(duration: 0.2)){
                        following.toggle()
                    //}
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LikeView: View {
    
    @Binding var reel: Lume
    
    @State private var searchText = ""
    
    @FocusState var searchBarKeyboard: Bool
    
    @State var likedUsers: [ProfileSettings] = []
    @State private var allLikedUsers: [ProfileSettings] = []
    
    var body: some View {
        
        ZStack {
            
            if reel.likedUsers.isEmpty {
                
                VStack{
                    Text("まだ誰もライクしてません")
                        .font(.title2)
                        .foregroundColor(Color.primary)
                        .fontWeight(.heavy)
                    Text("ライクみよう！")
                        .font(.callout)
                        .foregroundColor(Color.secondary)
                        .fontWeight(.medium)
                }
                .padding(.bottom)
                
            } else {
                
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { scrollView in
                        TextField("Search", text: $searchText)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .focused($searchBarKeyboard)
                            .cornerRadius(10)
                            .frame(height: 10)
                            .padding(.all)
                            .padding(.top)
                            .id("SearchBar")
                            .onSubmit {
                                if !searchText.isEmpty {
                                    let lowercaseSearchText = searchText.lowercased()
                                    likedUsers = likedUsers.filter {
                                        $0.preferredUsername.lowercased().contains(lowercaseSearchText) || $0.givenName.lowercased().contains(lowercaseSearchText)
                                    }
                                } else {
                                    likedUsers = allLikedUsers
                                }
                            }
                        
                        ForEach(likedUsers.indices, id: \.self) { index in
                            IndividualLikeView(like: $likedUsers[index])
                                .id(index == 0 ? "FirstLikeView" : nil)
                                .padding(.top)
                        }
                        
                        Spacer()
                            .padding(.vertical)
                            .onAppear {
                                scrollView.scrollTo("FirstLikeView", anchor: .top)
                            }
                    }
                }
                .padding(.horizontal)
                .ignoresSafeArea()
                .onDisappear{
                    searchBarKeyboard = false
                }
                .onTapGesture {
                    if(searchBarKeyboard) {
                        
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .onAppear{
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            let profiles = ProfileManager.shared.getArrayProfiles(ids: reel.likedUsers)
            allLikedUsers = profiles
            likedUsers = profiles
            
        }
    }
}
