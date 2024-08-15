//
//  Profile.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/18.
//


private func setupDefaultImageAppearance(imageView: UIImageView, text: String, icon: String) {
        imageView.subviews.forEach { $0.removeFromSuperview() } // Always clear previous subviews first

        if imageView.image == nil {
            imageView.backgroundColor = .lightGray
            let iconImage = UIImage(systemName: icon)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            let iconImageView = UIImageView(image: iconImage)
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let stackView = UIStackView(arrangedSubviews: [iconImageView, label])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        } else {
            imageView.backgroundColor = .clear // Optionally clear the background color if not needed
        }
    }


import SwiftUI
import _PhotosUI_SwiftUI
import Amplify
import AWSS3
import CoreImage
import ColorKit

extension UIImage {
    func convertToRGBColorspace() -> UIImage? {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: UInt32(bitmapInfo.rawValue)
        )
        guard let context = context, let cgImage = cgImage else { return nil }
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: size))
        guard let convertedImage = context.makeImage() else { return nil }
        return UIImage(cgImage: convertedImage)
    }
}

struct profilereelpage: View {
    
    @Binding var reels: [Lume]
    
    @State var reelLocation: UUID
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View{
        
        ZStack{
            
            ProfileReelsView(currentReel: reelLocation, reels: $reels)
                .navigationBarHidden(true)
            
            
            VStack{
                HStack{
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                            .padding(.leading)
                        
                    })
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
                
            
        }
        .navigationBarHidden(true)
    }
}

struct TopRoundedRectangle: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(to: CGPoint(x: radius, y: 0), control: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: radius), control: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct TabBarPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}


private struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


//MARK: -- Profile page content view

struct ProfileReelsView: View {
    
    @State var currentReel: UUID = (UUID(uuidString: "") ?? UUID())
    @State var offsetY: CGFloat = 0.0  // To store the drag offset
    @State var isRefreshing: Bool = false // To check if it's in refreshing state
    
    @State private var atTop: Bool = false
    
    // Extracting Avplayer from media File...
    @Binding var reels: [Lume]
    @State var reelLocation: UUID = (UUID(uuidString: "") ?? UUID())
    
    @GestureState private var translation: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var updating: Bool = false
    
    @State var mute: Bool = false
    
    var body: some View {
        
        // Setting Width and height for rotated view....
        GeometryReader{proxy in
            
            ZStack{
                
                // Vertical Page Tab VIew....
                TabView(selection: $currentReel){
                    
                    ForEach($reels){$reel in
                        
                        ProfileReelsPlayer(reel: $reel, reels: $reels, reelLocation: $reelLocation, currentReel: $currentReel, mute: $mute)
                        // setting width...
                            .frame(width: UIScreen.main.bounds.width)
                        // Rotating Content...
                            .rotationEffect(.init(degrees: -90))
                        //.ignoresSafeArea(.all, edges: .top)
                            .ignoresSafeArea()
                            .tag(reel.id)
                    }
                    .onAppear{
                        currentReel = reelLocation
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
        .navigationBarHidden(true)
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
        }
    }
}


struct ProfileReelsPlayer: View {
    
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
    
    // Computed property
    @State private var currentMinY: CGFloat = 0
    @State private var currentSize: CGSize = .zero
    
    @State private var userName: String = ""
    @State private var musicName: String = ""
    
    @State private var imageLoading: Bool = true
    @State private var imageDownload: Image? = nil
    @State private var imageReelImageid: UUID? = nil
    
    var body: some View{
        
        ZStack{
            
            Color.black
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            if !reel.contents.isEmpty {
                
                TabView(selection: $reel.currentContent) {
                    ForEach(reel.contents) { content in
                        switch content {
                        case LumeContent.video(let reelVideo):
                            CustomVideoPlayer(player: reelVideo.player!)
                                .tag(reelVideo.id)
                            
                        case LumeContent.image(let reelImage):
                            ZStack {
                                if let index = reel.contents.firstIndex(where: { $0.id == reelImage.id }),
                                   case .image(let reelImageContent) = reel.contents[index],
                                   let uiImage = reelImageContent.image {
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
                            
                            withAnimation{
                                reel.userLiked = true
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
                
                Color(red: 0.919, green: 0.767, blue: 0.834)
                    .ignoresSafeArea()
                
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
            
            reel.playVideo(mute: mute)
        }
        .navigationBarHidden(true)
    }
    
    private func downloadImage(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                // Handle HTTP error here
                print("HTTP Error: Status code is not 200")
                return nil
            }

            guard let image = UIImage(data: data) else {
                // Handle case where the data is not an image
                print("Error: Data is not an image")
                return nil
            }

            return image
        } catch {
            // Handle networking error here
            print("Network Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func manageVideoPlayback(minY: CGFloat, size: CGSize, reel: Lume) {
        if -minY < (size.height / 2) && minY < (size.height / 2) && currentReel == reel.id {
            reel.playVideo(mute: mute)
        } else {
            reel.stopVideos()
        }
    }
}

// MARK: Profile page content view ^-


struct userFollowList: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @State var selectedTab: Int = 0
    
    @Binding var profile: ProfileSettings
    
    @State private var followerUsers: [ProfileSettings] = []
    @State private var followingUsers: [ProfileSettings] = []
    
    let tabs: [Tab] = [
        .init(title: "フォロワー"),
        .init(title: "フォロー")
    ]

    init(selectedTab: Int, _ profile: Binding<ProfileSettings>) {
        _selectedTab = State(initialValue: selectedTab)
        _profile = profile
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.white)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    var body: some View {
        
        VStack {
            
            ZStack{
                
                HStack{
                    
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                            .padding(.leading)
                        
                    })
                    
                    Spacer()
                }
                
                
                Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $selectedTab)
                    .padding(.horizontal, 50)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
            }
            .foregroundColor(colorScheme == .dark ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 128/255, green: 155/255, blue: 206/255))
            
            
            TabView(selection: $selectedTab, content: {
                userList(profile: $profile, users: $followerUsers)
                    .tag(0)
                userList(profile: $profile, users: $followingUsers)
                    .tag(1)
            })
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
        }
        .navigationBarHidden(true)
        .onAppear{
            loadUsers()
        }
    }
    
    private func loadUsers() {
        guard let followManager = profile.followManager else { return }
        Task {
            do {
                self.followerUsers = try await followManager.returnUsers(relationship: .follower)
                self.followerUsers = try await followManager.returnUsers(relationship: .follower)
            } catch {
                print(error)
            }
        }
    }
}

struct userList: View {
    
    @State private var searchText = ""
    
    @Binding var profile: ProfileSettings
    
    @Binding var users: [ProfileSettings]
    
    @FocusState var searchBarKeyboard: Bool
    
    var filteredUsers: [ProfileSettings] {
        if searchText.isEmpty {
            return users
        } else {
            let lowercaseSearchText = searchText.lowercased()
            return users.filter {
                $0.preferredUsername.lowercased().contains(lowercaseSearchText) || $0.givenName.lowercased().contains(lowercaseSearchText)
            }
        }
    }
    
    var body: some View{
        
        VStack{
            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollView in
                    TextField("Search", text: $searchText)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .focused($searchBarKeyboard)
                        .cornerRadius(10)
                        .frame(height: 10)
                        .padding(.all)
                        .id("SearchBar")
                    
                    ForEach(filteredUsers.indices, id: \.self) { index in
                        IndividualUserListView(user: filteredUsers[index], profile: $profile)
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
            .onDisappear{
                searchBarKeyboard = false
            }
            .onTapGesture {
                if(searchBarKeyboard) {
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            
            Spacer()
        }
        .onAppear{
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}


struct IndividualUserListView: View {
    let user: ProfileSettings
    @Binding var profile: ProfileSettings

    @State private var isFollowing: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProfileImageView(image: user.profileImage?.image)

                VStack(alignment: .leading) {
                    Text(user.givenName)
                        .font(.callout)
                        .foregroundColor(Color.primary)

                    Text(user.preferredUsername)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()

                FollowButton(isFollowing: isFollowing) {
                    toggleFollowing()
                }
            }
            .padding(.horizontal)
            .onAppear {
                checkFollowingStatus()
            }
        }
    }

    private func checkFollowingStatus() {
        Task {
            let relationship = await ProfileManager.shared.getRelationshipStat(fromUserID: profile.identityID, toUserID: user.identityID)
            isFollowing = (relationship == .following || relationship == .mutual)
        }
    }

    private func toggleFollowing() {
        let newFollowingStatus = !isFollowing
        ProfileManager.shared.updateFollowingStatus(fromUserID: profile.identityID, toUserID: user.identityID, follow: newFollowingStatus)
        isFollowing = newFollowingStatus
    }
}


struct ProfileImageView: View {
    var image: UIImage?

    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
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
    }
}

struct FollowButton: View {
    var isFollowing: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .fill(isFollowing ? Color.gray.opacity(0.4) : Color.blue)

                Text(isFollowing ? "フォロー中" : "フォロー")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(isFollowing ? Color.primary : Color.white)
            }
            .frame(width: 130, height: 38)
        }
    }
}




struct FollowRequest: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var requestUsers: [UserProfileQL] = []
    
    var body: some View{
        
        VStack{
            
            HStack{
                
                Button(action: {
                    
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    
                    Image(systemName: "chevron.backward")
                        .font(Font.system(size: 25).weight(.bold))
                        .foregroundColor(Color.primary)
                        .padding(.leading)
                })
                
                Text("フォローリクエスト")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.top, 60)
            .padding(.horizontal)
            
            
            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollView in
                    
                    ForEach(requestUsers.indices, id: \.self) { index in
                        IndividualFollowRequestView(requestUser: requestUsers[index])
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
            Spacer()
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct IndividualFollowRequestView: View {
    
    let requestUser: UserProfileQL
    
    var body: some View {
        
        
        VStack(alignment: .leading) {
            
            HStack {
                
                if let profileImageURL = requestUser.profileImage {
                    
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
                    
                    Text(requestUser.firstName ?? "")
                        .font(.callout)
                        .foregroundColor(Color.primary)
                    
                    Text(requestUser.username)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                
                Spacer()
                
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(.blue)
                    .frame(width: 100, height: 30)
                
                Image(systemName: "x.circle")
                    .font(.body)
            }
            .padding(.horizontal)
        }
    }
}


//struct UserSetting_Previews: PreviewProvider {
//    static var previews: some View {
//        UserSetting()
//    }
//}

//struct Profile_Previews: PreviewProvider {
//    static var previews: some View {
//        Profile()
//    }
//}



// MARK: -- Other user profile


struct OtherUserProfile: View {
    
    @State var identityID: String
    
    @State var profile: ProfileSettings = ProfileSettings()
    @State private var userPrivate: Bool = false
    @State private var showingDialog: Bool = false
    @Binding var followState: Bool
    
    
    @State private var headerHeight: CGFloat = 60
    @State private var tabBarHeight: CGFloat = 50
    
    let toolBarButtonsHeight: CGFloat = 50
    
    
    @State var tabIndex = 0
    
    @State var userLuma: [Lume] = []
    @State var reelThumbnails: [UUID: UIImage] = [:]
    @State private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    
    let tabs: [Tab] = [
        .init(title: "投稿"),
        //.init(title: "保存"),
        .init(title: "ポーチ"),
    ]
    
    @State private var tabBarY: CGFloat = 62
    @State private var tabButtonOpacity: Float = 1.0
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            
            Color.clear
                .onAppear{
                    Task {
                        do {
                            profile = try await ProfileManager.shared.getProfile(withID: identityID)
                        } catch {
                            print(error)
                        }
                    }
                }
            
            backgroundView()
                .opacity((tabBarY-headerHeight) <= 1 ? 0 : 1)
            
            
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    bottom
                }
            }
            .animation(.easeOut(duration: 1), value: tabIndex)
            .onPreferenceChange(TabBarPreferenceKey.self) { y in
                guard let y = y, y > 0 else { return }
                
                self.tabBarY = y
                
                if (tabBarY-headerHeight) < ((UIScreen.main.bounds.height/2)-headerHeight) {
                    
                    let scrollFraction = CGFloat((tabBarY-headerHeight)/((UIScreen.main.bounds.height/2)-headerHeight))
                    
                    tabButtonOpacity = Float(scrollFraction)
                    
                    //tabBarHeight = 50 + ((1-scrollFraction) * 50)
                    
                } else {
                    tabButtonOpacity = 1.0
                    
                    tabBarHeight = 50
                }
            }
            .ignoresSafeArea()
            
            
            VStack{
                toolBarButtons
                Spacer()
            }
            
        }
        .navigationBarHidden(true)
    }
    
    private var header: some View {
    
        VStack {
            
            Spacer()
            
            userStats
        }
        .frame(height: UIScreen.main.bounds.height)
    }
    
    private var bottom: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                pager
            } header: {
                tabBar
            }
        }
    }
    
    private var tabBar: some View {
        GeometryReader { geometry in
            ZStack {
                
                HStack(alignment: .bottom, spacing: 0) {
                 
                }
                .frame(maxWidth: .infinity)
                .frame(height: tabBarHeight)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .onAppear {
                    self.tabBarY = geometry.frame(in: .global).minY
                }
                .preference(key: TabBarPreferenceKey.self,value: geometry.frame(in: .global).minY)
                
            }
        }
        .frame(height: tabBarHeight)
    }

    private func tab(title: String, at index: Int) -> some View {
        Button {
            withAnimation {
                tabIndex = index
            }
        } label: {
            
            VStack{
                
                Spacer()
                
                Text(title)
                    .foregroundColor(Color.primary)
                    .frame(width: UIScreen.main.bounds.width / 2)
            }
            .padding(.bottom)
        }
    }

    private var toolBarButtons: some View {

        HStack{
            
            Button(action: {
                
                presentationMode.wrappedValue.dismiss()
            }, label: {
                
                Image(systemName: "chevron.backward")
                    .font(Font.system(size: 25).weight(.bold))
                    .foregroundColor(interpolatedColor(opacity: colorScheme == .dark ? 1 : tabButtonOpacity))
                    .padding(.leading)
                
            })
            
            Spacer(minLength: 0)
            
            Button(action: {
                
                self.showingDialog = true
            }){
                
                Image(systemName: "ellipsis")
                    .font(Font.system(size: 25).weight(.bold))
                    .foregroundColor(interpolatedColor(opacity: colorScheme == .dark ? 1 : tabButtonOpacity))
                    .padding(.trailing)
            }
            .confirmationDialog("",isPresented: $showingDialog, titleVisibility: .hidden) {
                Button("ブロック", role: .destructive) {
                    // 選択肢1ボタンが押された時の処理
                }
                Button("報告", role: .destructive) {
                    // 選択肢2ボタンが押された時の処理
                }
            }
            .opacity(Double(tabButtonOpacity))
        }
        .padding()
        .frame(height: toolBarButtonsHeight)
        .background(colorScheme == .dark ? Color.black.opacity(Double(1 - tabButtonOpacity)) : Color.white.opacity(Double(1 - tabButtonOpacity)))

    }
    
    func interpolatedColor(opacity: Float) -> Color {
        // Interpolating between white and black based on opacity
        //let whiteIntensity = 1 - opacity
        let blackIntensity = opacity
        return Color(red: Double(blackIntensity), green: Double(blackIntensity), blue: Double(blackIntensity))
    }
    

    private var pager: some View {
        ZStack(alignment: .top) {
            
            if !userPrivate {
                
                if userLuma.isEmpty {
                    
                    Text("No Luma Available")
                        .padding(.vertical, 150)
                    
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(userLuma, id: \.id) { reel in
                            NavigationLink(destination: profilereelpage(reels: $userLuma, reelLocation: reel.id)) {
                                if let thumbnail = reel.thumbnail {
                                    Image(uiImage: thumbnail)
                                        .centerCropped()
                                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
                                } else {
                                    ShimmerEffectBox()
                                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
                                }
                            }
                        }
                    }
                }
                
            } else {
                
                VStack{
                    
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 100)
                }
            }
        }
        .onAppear{
            Task {
                userLuma = await profile.returnUserLumes()
            }
        }
        .animation(.easeOut, value: tabIndex)
        .frame(width: UIScreen.main.bounds.width)
        .frame(minHeight: UIScreen.main.bounds.height - (tabBarHeight + headerHeight), alignment: .top)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
    
    
    
    @State private var followingCount: Int = 0
    @State private var followerCount: Int = 0
    
    private var userStats: some View {
        
        
        ZStack{
            
            VStack{
                
                TopRoundedRectangle(radius: 40)
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()
            }
            .padding(.top, 80)
            
            
            VStack{
                
                profileImageView()
                
                Group {
                    
                    Text(profile.preferredUsername.isEmpty ? " " : "@\(profile.preferredUsername )")
                        .font(.title2)
                    
                    Text(profile.givenName.isEmpty ?  " " : "\(profile.givenName)")
                        .font(.footnote)
                }
                .fontWeight(.bold)
                .background(colorScheme == .dark ? Color.black : Color.white)
                
                
                Spacer()
                
                VStack{
                    
                    ZStack{
                        
                        HStack{
                            //NavigationLink(destination: userFollowList(selectedTab: 0, $profile)){
                                VStack{
                                    Text("\(formatNumber(followerCount))")
                                        .foregroundColor(Color(red: 0.723, green: 0.88, blue: 0.825))
                                        .font(.title2)
                                    Text("フォロワー")
                                        .font(.footnote)
                                        .foregroundColor(Color.primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4)
                                .onAppear{
                                    if followerCount < 0 {
                                        followerCount = 0
                                    }
                                    followerCount = profile.followerCount
                                }
                            //}
                            
                            Spacer()
                            
                            //NavigationLink(destination: userFollowList(selectedTab: 1, $profile)){
                                VStack{
                                    Text("\(formatNumber(followingCount))")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                        .font(.title2)
                                    
                                    Text("フォロー中")
                                        .font(.footnote)
                                        .foregroundColor(Color.primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4)
                                .onAppear{
                                    followingCount = profile.followingCount
                                }
                            //}
                            
                            Spacer()
                            
                            VStack{
                                Text("\(userLuma.count)")
                                    .foregroundColor(Color(red: 0.946, green: 0.76, blue: 0.839))
                                    .font(.title2)
                                
                                Text("投稿数")
                                    .font(.footnote)
                            }
                            .frame(width: UIScreen.main.bounds.width/4)
                        }
                        .fontWeight(.bold)
                        .padding(.horizontal, 30)
                        .padding(.bottom)
                        
                    }
                    
                    Text(profile.bio.isEmpty ? " " : "\(profile.bio)")
                    
                    Button(action: {
                        
                        withAnimation{
                            followState.toggle()
                        }
                        
                        let loggedInUser = ProfileManager.shared.getProfile(withID: GI.shared.identityID!)
                        
                        if followState {
                            loggedInUser.followUser(userID: profile.identityID)
                            followerCount += 1
                        } else {
                            loggedInUser.unfollowUser(userID: profile.identityID)
                            followerCount -= 1
                        }
                        
                        if followerCount < 0 {
                            followerCount = 0
                        }

                        
                    }) {
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 100, height: 30)
                                .cornerRadius(50)
                                .foregroundColor(followState ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 0.946, green: 0.76, blue: 0.839))
                            
                            Text(followState ? "フォロー中" : "フォロー")
                                .fontWeight(.bold)
                                .font(.callout)
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            .frame(height: 272)
            
        }
        .ignoresSafeArea()
        .padding(.top, UIScreen.main.bounds.height*0.57)
    }
    
    @State var BackgroundBlurImages: [UIImage] = []
    @State var BackgroundBlurPage: Int = 0
    
    @State var colors: [(id: Int, color: UIColor, frequency: CGFloat)] = []
    @State var gradientModel = AnimatedGradient.Model(colors: [])
    
    func profileImageView() -> some View {
        
        ZStack{
            
            if let profileImage = profile.profileImage?.image {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100) // Adjust the size as needed
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 4) // Adjust the border width as needed
                    )
                    .onAppear{
                        BackgroundBlurImages.append(profileImage)
                        BackgroundBlurPage = BackgroundBlurImages.count
                    }
                    .onDisappear{
                        if !BackgroundBlurImages.isEmpty {
                            BackgroundBlurImages.removeAll()
                            BackgroundBlurPage = BackgroundBlurImages.count
                        }
                    }
                
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 100, height: 100) // Adjust the size as needed
                    .clipShape(Circle())
                    .foregroundColor(Color.secondary)
                    .background(
                        Circle()
                            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    )
                    .onAppear{
                        profile.profileImage?.loadAgain()
                    }
            }
        }
    }
    
    func backgroundView() -> some View {
        
        ZStack{
            if let backgroundImage = profile.backgroundImage?.image {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
            }
        }
        .background(GradientEffectView($gradientModel).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        .onAppear{
            updateColors()
            profile.backgroundImage?.loadAgain()
        }
        .ignoresSafeArea()
        .onChange(of: BackgroundBlurPage) { _ in
            updateColors()
        }
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
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

private extension OtherUserProfile {
    
    var image: UIImage? {
        if !BackgroundBlurImages.isEmpty {
            return BackgroundBlurImages[BackgroundBlurPage % BackgroundBlurImages.count].convertToRGBColorspace()
        } else {
            return nil
        }
    }
    
    func updateColors() {
        if let validImage = image {
            guard let dominantColors = try? validImage.dominantColorFrequencies(with: .high) else { return }
            
            colors = dominantColors.prefix(3).enumerated().map { ($0.offset, $0.element.color, $0.element.frequency) }
            
            let schemeColor = UIColor(colorScheme == .light ? .white : .black)
            colors.append((id: 3, color: schemeColor, frequency: 1.0))
            
        } else {
            // Default colors when there are no valid images
            let defaultColors = [
                UIColor(red: 0.723, green: 0.88, blue: 0.825, alpha: 1.0),
                UIColor(red: 0.552, green: 0.724, blue: 0.831, alpha: 1.0),
                UIColor(red: 0.946, green: 0.76, blue: 0.839, alpha: 1.0),
                UIColor(colorScheme == .dark ? .black : .white)
            ]
            
            colors = defaultColors.enumerated().map { (id: $0.offset, color: $0.element, frequency: 1.0) }
        }
        
        DispatchQueue.main.async {
            withAnimation(.linear.speed(0.7)) {
                gradientModel.colors = colors.map { Color(uiColor: $0.color) }
            }
        }
    }
}
