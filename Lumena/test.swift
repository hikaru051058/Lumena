//
//  test.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/13.
//

import Foundation
import SwiftUI
import AVFoundation
import _PhotosUI_SwiftUI
import Amplify
import _AVKit_SwiftUI



/*
struct cont: View {
    @State private var selectedTab: Int = 0

    let tabs: [Tab] = [
        .init(title: "Music"),
        .init(title: "Movies"),
        .init(title: "Books")
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

    var body: some View {
        
        ZStack{
            
            Color(.gray)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tabs
                ZStack{
                    // Views
                    TabView(selection: $selectedTab,
                            content: {
                        SwipeViewTest()
                            .tag(0)
                        Text("2")
                            .foregroundColor(.white)
                            .tag(1)
                        Text("3")
                            .foregroundColor(.white)
                            .tag(2)
                    })
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    
                    ZStack{
                        VStack{
                            Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $selectedTab)
                                .padding(.horizontal, 50)
                                .background(Color.blue)
                                
                            Spacer()
                        }
                        .padding(.top, 50)
                    }
                    
                    VStack{
                        HStack{
                        
                            Spacer()
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .padding(.top, 55)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .foregroundColor(.green)
            .ignoresSafeArea()
        }
    }
}


struct SwipeViewTest: View {
    @GestureState private var translation: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var currentViewIndex = 0
    
    @State private var previousCheckyOffset: CGFloat = 0
    
    @State private var updating: Bool = false
    
    private let views = [Color.red, Color.green, Color.blue] // Replace with your desired views
    
    var body: some View {
        
        ZStack{

            List{
                VStack(spacing: 0) {
                    ForEach(0..<views.count, id: \.self) { index in
                        views[index]
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .ignoresSafeArea()
                    }
                }
                .offset(y: getOffsetY()-11)
                .zIndex(1)
                .gesture(
                    DragGesture(minimumDistance: 0.1).updating($translation) { value, state, _ in
                        let accumulatedTranslation = value.translation.height + dragOffset
                        state = accumulatedTranslation // Set the translation including the accumulated offset
                    }
                        .onEnded { value in
                            
                            updating = false
                            
                            let gestureThreshold = UIScreen.main.bounds.height * 0.1
                            
                            dragOffset = value.translation.height.truncatingRemainder(dividingBy: UIScreen.main.bounds.height)
                            
                            withAnimation(.easeOut) {
                                if value.translation.height < -gestureThreshold && currentViewIndex < views.count - 1 {
                                    currentViewIndex += 1
                                } else if value.translation.height > gestureThreshold && currentViewIndex > 0 {
                                    currentViewIndex -= 1
                                } else if currentViewIndex == 0 && value.translation.height > gestureThreshold {
                                    performRefresh()
                                }
                                dragOffset = 0
                            }
                        }
                )
            }
            .listStyle(.inset)
            
            if(updating){
                VStack{
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .padding(.top, 50)
                        .scaleEffect(1.5)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func getOffsetY() -> CGFloat {
        let viewHeight = UIScreen.main.bounds.height
        let currentViewOffset = CGFloat(currentViewIndex) * -viewHeight
        
        let newOffset = currentViewOffset + translation + dragOffset
        
        return newOffset
    }
    
    private func performRefresh() {
        print("Refreshing...")
        updating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            
            updating = false
        }
    }
}


struct NavBar_ZStack: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                // NavigationView Background
                VStack {
                    SearchResultViews.AccountView()
                    
                    
                    RadialGradient(colors: [.green.opacity(0.3), .blue.opacity(0.5)],
                                   center: .bottomTrailing,
                                   startRadius: 0, endRadius: 300)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 0)
                    
                    Spacer()
                }
                
                VStack {
                    Text("Use a ZStack to put a background behind the Nav view.")
                        .padding()
                    Spacer()
                }
                .navigationTitle("Nav Bar Background")
                .font(.title2)
            }
        }
    }
}



struct NavBar_ZStack_Previews: PreviewProvider {
    static var previews: some View {
        NavBar_ZStack()
    }
}

 
 */


/*
 
 struct Profile: View {
     
     
     @State private var selectedTab: Int = 0

     let tabs: [Tab] = [
         .init(title: "投稿"),
         .init(title: "保存"),
         .init(title: "ライク"),
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
     
     
     // For Smooth Sliding Effect
     @Namespace var animation
     
     // For Dark Mode Adoption...
     @Environment(\.colorScheme) var colorScheme
     
     // Offset For Sticky Segmeted Picker...
     @State var topHeaderOffset: CGFloat = 0
     
     
     @State var topOut: Bool = true
     
     @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
     
     var body: some View {
         
         
         ZStack{
             
             VStack{
                 
                 ScrollView(.vertical, showsIndicators: false, content: {
                     
                     LazyVStack(pinnedViews: [.sectionHeaders]){
                         
                         // Stories Sections...
                         ScrollView(.horizontal, showsIndicators: false, content: {
                             
                             ZStack{
                                 
                                 Image("postcontentmock")
                                     .resizable()
                                     .scaledToFill()
                                     .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.95)
                                 
                                 VStack{
                                     
                                     Spacer()
                                     
                                     ZStack{
                                         
                                         Group {
                                             RoundedRectangle(cornerRadius: 25)
                                                 .foregroundColor(Color.white)
                                             
                                             Rectangle()
                                                 .foregroundColor(Color.white)
                                                 .padding(.top)
                                             
                                         }
                                         .frame(height: 120)
                                         
                                         
                                         VStack{
                                             
                                             Image("mock2")
                                                 .resizable()
                                                 .aspectRatio(contentMode: .fill)
                                                 .frame(width: 100, height: 100) // Adjust the size as needed
                                                 .clipShape(Circle())
                                                 .overlay(
                                                     Circle()
                                                         .stroke(Color.white, lineWidth: 4) // Adjust the border width as needed
                                                 )
                                             
                                             Group {
                                                 Text("藤澤隼")
                                                     .font(.title2)
                                                 Text("@shunfujisawa_")
                                                     .font(.footnote)
                                             }
                                             .fontWeight(.bold)
                                             
                                             
                                             Spacer()
                                             
                                             ZStack{
                                                 
                                                 Rectangle()
                                                     .foregroundColor(Color.white)
                                                 
                                                 HStack{
                                                     VStack{
                                                         Text("10K")
                                                             .foregroundColor(Color(red: 0.723, green: 0.88, blue: 0.825))
                                                             .font(.title2)
                                                         Text("フォロワー")
                                                             .font(.footnote)
                                                     }
                                                     .frame(width: UIScreen.main.bounds.width/4)
                                                     
                                                     Spacer()
                                                     
                                                     VStack{
                                                         Text("30")
                                                             .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                                             .font(.title2)
                                                         
                                                         Text("フォロー中")
                                                             .font(.footnote)
                                                     }
                                                     .frame(width: UIScreen.main.bounds.width/4)
                                                     
                                                     Spacer()
                                                     
                                                     VStack{
                                                         Text("30")
                                                             .foregroundColor(Color(red: 0.946, green: 0.76, blue: 0.839))
                                                             .font(.title2)
                                                         
                                                         Text("投稿数")
                                                             .font(.footnote)
                                                     }
                                                     .frame(width: UIScreen.main.bounds.width/4)
                                                 }
                                                 .fontWeight(.bold)
                                                 .padding(.horizontal, 30)
                                                 
                                             }
                                         }
                                         .frame(height: 200)
                                         
                                         
                                     }

                                 }
                                 
                             }
                             
                         })
                         .ignoresSafeArea()
     
                         
                         Section(header:
                                     
                                     
                             Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $selectedTab)
                                 .padding(.horizontal, 50)
                                 .frame(height: 120, alignment: .bottom)
                                 .background(colorScheme == .dark ? Color.black : Color.white)
                                 .ignoresSafeArea()
                                 
                         )
                         {
                             
                             TabView(selection: $selectedTab) {
                                 List(1...50, id: \.self) { index in
                                     HStack(spacing: 1) {
                                         ForEach(0..<3) { _ in
                                             Image("mock2")
                                                 .centerCropped()
                                                 .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                                         }
                                     }
                                     .listRowSeparator(.hidden)
                                     .listRowInsets(.init(top: 0, leading: 0, bottom: 1, trailing: 0))
                                 }
                                 .listStyle(.inset)
                                 .tag(0)
                                 
                                 
                                 List(1...2, id: \.self) { index in
                                     HStack(spacing: 1) {
                                         ForEach(0..<3) { _ in
                                             Image("mock2")
                                                 .centerCropped()
                                                 .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                                         }
                                     }
                                     .listRowSeparator(.hidden)
                                     .listRowInsets(.init(top: 0, leading: 0, bottom: 1, trailing: 0))
                                 }
                                 .listStyle(.inset)
                                     .tag(1)
                                 
                                 
                                 ScrollViewReader { proxy in
                                     List(1...50, id: \.self) { index in
                                         HStack(spacing: 1) {
                                             ForEach(0..<3) { _ in
                                                 Image("mock2")
                                                     .centerCropped()
                                                     .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                                                     .id(index)
                                             }
                                         }
                                         .listRowSeparator(.hidden)
                                         .listRowInsets(.init(top: 0, leading: 0, bottom: 1, trailing: 0))
                                     }
                                     .onAppear {
                                         
                                         if(topOut){
                                             proxy.scrollTo(1, anchor: .top)
                                         }
                                     }
                                     .listStyle(.inset)
                                 }
                                 .tag(2)
                             }
                             .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                             .frame(height: UIScreen.main.bounds.height)
                         }
                     }
                 })
             }
             
             VStack{
                 
                 HStack(spacing: 15){
                     
                     Button(action: {
                         
                         presentationMode.wrappedValue.dismiss()
                     }, label: {
                         
                         Image(systemName: "chevron.backward")
                             .font(Font.system(size: 25).weight(.bold))
                             .foregroundColor(colorScheme == .dark ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 128/255, green: 155/255, blue: 206/255))
                             .padding(.leading)
                         
                     })
                     
                     Spacer(minLength: 0)
                     
                     Button(action: {}, label: {
                         Image(systemName: "plus.app")
                             .font(.title)
                             .foregroundColor(.primary)
                     })
                     
                     Button(action: {}, label: {
                         Image(systemName: "line.horizontal.3")
                             .font(.title)
                             .foregroundColor(.primary)
                     })
                 }
                 .padding([.horizontal,.top])
                 
                 Spacer()
             }
             .padding(.top, 30)
         }
         .ignoresSafeArea()
     }
 }


struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LoadingSpinner()
        }
    }
}

*/

/*
struct TestView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var postReel: Reel = Reel()
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages: [Image] = []
    
    
    @State var ReelID: String = "1010101\(Int(Date.now.timeIntervalSince1970))"
    @State var ReelLocationS3: String = ""
    @State var s3Prefix: String = "s3://lumena225d91d9ee5c43d99341141978c6b54c25223-lumenaenv/public/"
    
    @State var description: PostDescriptionQL = PostDescriptionQL()
    @State var post: ReelQL? = nil
    
    var body: some View {
        
        VStack{
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 8, // Unlimited selections
                selectionBehavior: .ordered,
                matching: .images,
                preferredItemEncoding: .current,
                photoLibrary: .shared()
            ) {
                Image(systemName: "photo")
                    .font(.title3)
            }
            .onChange(of: selectedItems) { newPhotoPickerItems in
                Task {
                    do {
                        // Clear previous images
                        postReel.imageStruct.removeAll()
                        selectedImages.removeAll()
                        
                        for item in newPhotoPickerItems {
                            if let data = try await item.loadTransferable(type: Data.self) {
                                if let uiImage = UIImage(data: data) {
                                    let image = Image(uiImage: uiImage)
                                    postReel.imageStruct.append(uiImage)
                                    selectedImages.append(image)
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(action:{
                
                ReelLocationS3 = "\(GI.shared.profileSettings?.identityID ?? "null")/\(ReelID)"
                
                postReel.postURL.removeAll()

                if postReel.imageStruct.count > 0 {
                    for (index, image) in postReel.imageStruct.enumerated() {
                        let imageName = "\(ReelLocationS3)/\(index + 1)"
                        
                        let imageData = image.jpegData(compressionQuality: 1.0)
                        if let imageData = imageData {
                            S3.shared.storeImage(name: imageName, image: imageData, accessLevel: .guest)
                            postReel.postURL.append("\(s3Prefix)\(imageName)")
                        }
                    }
                }

                description = PostDescriptionQL(
                    id: "\(ReelID)postDescription",
                    timestamp: Int(Date.now.timeIntervalSince1970),
                    comment: "testestets"
                )

                post = ReelQL(id: ReelID,
                                  postURL: postReel.postURL,
                                  timestamp: Int(Date.now.timeIntervalSince1970),
                                  tagProducts: [TagCosmeticQL(tagCosmeticID: "101010", cosmeticID: "202020", authProduct: false, recommend: 0.2, effect: 0.4, fading: 0.6, feeling: 0.8)],
                                  tagMusic: TagTrackQL(trackID: "postReel.tagMusic.uri", tagMusicRange: [3.2, 10.8]),
                                  description: description,
                                  userprofile: GI.shared.userProfileQL
                )

                Task {
                    do {
                        let _: () = await GraphQL.shared.createModel(post!)
                    }
                }
                
            }) {
                
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
            
            
            Button(action:{
                
                
                print("now I liked this post!!")

                let likedPost = LikedPostQL(id: ReelID, timestamp: Int(Date.now.timeIntervalSince1970), reelQLID: ReelID, reel: post, userprofileqlID: GI.shared.profileSettings?.identityID ?? "null")
                
                Task {
                    do {
                        let _: () = await GraphQL.shared.createModel(likedPost)
                    }
                }
                
            }){
                
                ZStack {
                    Rectangle()
                        .frame(width: 100, height: 50)
                        .cornerRadius(50)
                        .foregroundColor(.primary)
                    
                    HStack{
                        Text("Like")
                            .fontWeight(.bold)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                    }
                }

            }
            
            
            
            Button(action:{
                
                print("now I added a comment to this post!!")

                let commentPost = CommentQL(id: ReelID, timestamp: Int(Date.now.timeIntervalSince1970), comment: "first comment!", reelQLID: ReelID, reel: post, userprofileqlID: GI.shared.profileSettings?.identityID ?? "null")
                
                Task {
                    do {
                        let _: () = await GraphQL.shared.createModel(commentPost)
                    }
                }
                
            }){
                
                ZStack {
                    Rectangle()
                        .frame(width: 100, height: 50)
                        .cornerRadius(50)
                        .foregroundColor(.primary)
                    
                    HStack{
                        Text("Comment")
                            .fontWeight(.bold)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                    }
                }

            }
            
            
            Button(action:{
                
                print("now I receive a comment to this post!!")
                
                Task {
                    do {
                        let returnCommentQL = await GraphQL.shared.queryAmplify(for: CommentQL.self, modelID: ReelID)
                    }
                }
                
            }){
                
                ZStack {
                    Rectangle()
                        .frame(width: 100, height: 50)
                        .cornerRadius(50)
                        .foregroundColor(.primary)
                    
                    HStack{
                        Text("Ret Comment")
                            .fontWeight(.bold)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                    }
                }

            }
            
            
            Button(action:{
                
                print("now I receive a like to this post!!")
                
                Task {
                    do {
                        let returnCommentQL = await GraphQL.shared.queryAmplify(for: LikedPostQL.self, modelID: ReelID)
                    }
                }
                
            }){
                
                ZStack {
                    Rectangle()
                        .frame(width: 100, height: 50)
                        .cornerRadius(50)
                        .foregroundColor(.primary)
                    
                    HStack{
                        Text("Ret Comment")
                            .fontWeight(.bold)
                            .font(.body)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                    }
                }

            }
            
            
            
        }
    }
}

struct TestProfileView: View {
    
    @State private var headerHeight: CGFloat = 60
    @State private var tabBarHeight: CGFloat = 50
    let toolBarButtonsHeight: CGFloat = 50
    
    @State private var tab1Height: CGFloat = UIScreen.main.bounds.height/4
    @State private var tab2Height: CGFloat = UIScreen.main.bounds.height/4
    
    @State var tabIndex = 0
    
    let tabs: [Tab] = [
        .init(title: "投稿"),
        //.init(title: "保存"),
        .init(title: "ライク"),
    ]
    
    @State private var scrollOffsets: [Int: CGFloat] = [:]
    @State private var scrollLock: Bool = true
    
    @State private var tabBarY: CGFloat = 62
    @State private var tabButtonOpacity: Float = 1.0
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            
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
                
                if tabBarY-headerHeight <= 0{
                    print("at top")
                    
                    scrollLock = false
                }
                
                self.tabBarY = y
                
                if (tabBarY-headerHeight) < ((UIScreen.main.bounds.height/2)-headerHeight) {
                    
                    let scrollFraction = CGFloat((tabBarY-headerHeight)/((UIScreen.main.bounds.height/2)-headerHeight))
                    
                    tabButtonOpacity = Float(scrollFraction)
                    
                    tabBarHeight = 50 + ((1-scrollFraction) * 90)
                    
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
                
                /*
                HStack(alignment: .bottom, spacing: 0) {
                    tab(title: "Tab 1", at: 0)
                    tab(title: "Tab 2", at: 1)
                }
                 */
                
                HStack(alignment: .bottom, spacing: 0) {
                 
                    VStack{
                        
                        Spacer()
                        
                        Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $tabIndex)
                            .padding(.horizontal, 50)
                    }
                 
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
                    .foregroundColor(Color.primary)
                    .padding(.leading)
                
            })
            
            Spacer(minLength: 0)
            
            NavigationLink(destination:
                FollowRequest()
            ) {
                Image(systemName: "person.fill.checkmark")
                    .font(Font.system(size: 25).weight(.bold))
                    .foregroundColor(Color.primary)
                    .padding(.leading)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(Double(tabButtonOpacity))
            
            
            NavigationLink(destination:
                UserSetting()
            ) {
                Image(systemName: "gear")
                    .font(Font.system(size: 25).weight(.bold))
                    .foregroundColor(Color.primary)
                    //.padding(.trailing)
                
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(Double(tabButtonOpacity))
        }
        .padding()
        .frame(height: toolBarButtonsHeight)
        //.background(Color.white.opacity(Double(1 - tabButtonOpacity)))// < 0.5 ? Double(1 - (tabButtonOpacity) ) : 0))
        //.background(VisualEffectBlur(blurStyle: .systemMaterialDark))

    }

    private var pager: some View {
        
        /// TabView needs to be in a fixed height -> UIScreen.height - tabBar height -> cuz tabBar height is the other part of the height that is visible on the view, and the rest should be the list
        /// Inside TabView should be the Scrollview -> each scroll view shoudl be locked until the main page is scrolled down fully
        ///  And should be locked when the total number of Lumes are less than the offset.
        
        
        
        ZStack(alignment: .top) {
            
            
            TabView(selection: $tabIndex) {
                
                
                
                /*
                
                //VStack{
                    // First Tab
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(1...50, id: \.self) { index in
                                HStack(spacing: 1) {
                                    ForEach(0..<3) { _ in
                                        Image("postcontentmock")
                                            .centerCropped()
                                            .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            if let offset = scrollOffsets[0] {
                                // Restore scroll position for the first tab
                            }
                        }
                    }
                    .onAppear{
                        
                        var listSize = (50 * (UIScreen.main.bounds.height/5))
                        
                        if listSize > (4 * (UIScreen.main.bounds.height/5)) {
                            
                            listSize = listSize + (UIScreen.main.bounds.height/3)
                        }
                        self.tab1Height = listSize
                    }
                    .scrollDisabled(scrollLock)
                    .tag(0)
                    //.frame(height: tab1Height)
                //}
                
                //VStack{
                    
                    // Second Tab
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(1...2, id: \.self) { index in
                                HStack(spacing: 1) {
                                    ForEach(0..<3) { _ in
                                        Image("postcontentmock")
                                            .centerCropped()
                                            .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            if let offset = scrollOffsets[1] {
                                // Restore scroll position for the second tab
                            }
                        }
                    }
                    .onAppear{
                        
                        var listSize = (2 * (UIScreen.main.bounds.height/5))
                        
                        if listSize > (4 * (UIScreen.main.bounds.height/5)) {
                            
                            listSize = listSize + (UIScreen.main.bounds.height/3)
                        }
                        self.tab2Height = listSize
                    }
                    .tag(1)
                    .frame(minHeight: UIScreen.main.bounds.height - tabBarHeight, alignment: .top)
                //}
                //.frame(height: tab2Height)
                 
                 */
                
                
                ZStack{
                    Text("Content 1")
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabBarHeight)
                        .background(Color.yellow)
                }
                .tag(0)
                
                
                ZStack{
                    Text("Content 2")
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - tabBarHeight)
                        .background(Color.green)
                }
                .tag(1)
            }
            //.frame(height: tabIndex == 0 ? tab1Height : tab2Height)
            .frame(minHeight: UIScreen.main.bounds.height - tabBarHeight, alignment: .top)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            //.animation(.default, value: tabIndex)
        }
        //.animation(.easeOut, value: tabIndex)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .frame(height: UIScreen.main.bounds.height - tabBarHeight, alignment: .top)
        //.frame(minHeight: UIScreen.main.bounds.height - tabBarHeight, alignment: .top)
    }
    
    private var userStats: some View {
        
        ZStack{
            VStack{
                
                TopRoundedRectangle(radius: 40)
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()
            }
            .padding(.top, 70)
            
            
            VStack{
                
                if let profileImage = GI.shared.profileSettings?.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100) // Adjust the size as needed
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 4) // Adjust the border width as needed
                        )
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
                }
                
                Group {
                    Text((GI.shared.profileSettings?.preferredUsername.isEmpty ?? true) ? " " : "@\(GI.shared.profileSettings?.preferredUsername ?? " ")")
                        .font(.title2)
                    
                    Text((GI.shared.profileSettings?.givenName.isEmpty ?? true) ?  " " : "\(GI.shared.profileSettings!.givenName)")
                        .font(.footnote)
                }
                .fontWeight(.bold)
                .background(colorScheme == .dark ? Color.black : Color.white)
                
                
                Spacer()
                
                VStack{
                    
                    ZStack{
                        
                        HStack{
                            NavigationLink(destination: userFollowList(selectedTab: 0)){
                                VStack{
                                    Text("10K") //Text("\(formatNumber(profile.followerUsers.count))")
                                        .foregroundColor(Color(red: 0.723, green: 0.88, blue: 0.825))
                                        .font(.title2)
                                    
                                    
                                    Text("フォロワー")
                                        .font(.footnote)
                                        .foregroundColor(Color.primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4)
                            }
                            
                            Spacer()
                            
                            
                            NavigationLink(destination: userFollowList(selectedTab: 1)){
                                VStack{
                                    Text("30")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                        .font(.title2)
                                    
                                    Text("フォロー中")
                                        .font(.footnote)
                                        .foregroundColor(Color.primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4)
                            }
                            
                            Spacer()
                            
                            VStack{
                                Text("30")
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
                    
                    Text((GI.shared.profileSettings?.bio.isEmpty ?? true) ? " " : "\(GI.shared.profileSettings!.bio)")
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
            }
            .frame(height: 227)
            
        }
        .ignoresSafeArea()
        .padding(.top, UIScreen.main.bounds.height*0.65)
    }
    
    @ViewBuilder
    private func backgroundView() -> some View {
        
        Group {
            if let backgroundImage = GI.shared.profileSettings?.backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                GradientEffectView(
                    .constant(
                        AnimatedGradient.Model(
                            colors: [
                                Color(red: 0.723, green: 0.88, blue: 0.825),
                                Color(red: 0.552, green: 0.724, blue: 0.831),
                                Color(red: 0.946, green: 0.76, blue: 0.839),
                                (colorScheme == .dark ? Color.black : Color.white)
                            ]
                        )
                    )
                )
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
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

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

*/


/*
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

 */
/*

struct TestProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TestProfileView3()
            //testProfileView()
            //TestProfileView333()
            //TestProfileView2
        }
    }
}



struct TestProfileView333: View {
    let headerHeight: CGFloat = 300
    let tabBarHeight: CGFloat = 50

    static let tab1Height: CGFloat = 100
    static let tab2Height: CGFloat = 2800

    @State var tabIndex = 0
    @GestureState var dragOffset = CGSize.zero

    var body: some View {

        // The GeometryReader must contain the ScrollReader, not
        // the other way around, otherwise scrolling doesn't work
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 0) {
                        header.id(0)
                        bottom(viewWidth: geometryProxy.size.width)
                    }
                }
                // Scroll back to the header when the tab changes
                .onChange(of: tabIndex) { newValue in
                    withAnimation(.easeInOut(duration: 1)) {
                        scrollViewProxy.scrollTo(0)
                    }
                }
            }
        }
    }

    private var header: some View {
        Text("Header")
            .frame(maxWidth: .infinity)
            .frame(height: headerHeight)
            .background(Color.green)
    }

    private func bottom(viewWidth: CGFloat) -> some View {
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                pager(viewWidth: viewWidth)
            } header: {
                tabBar(viewWidth: viewWidth)
            }
        }
    }

    private func tabBar(viewWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            tab(title: "Tab 1", at: 0, viewWidth: viewWidth)
            tab(title: "Tab 2", at: 1, viewWidth: viewWidth)
        }
        .frame(maxWidth: .infinity)
        .frame(height: tabBarHeight)
        .background(Color.gray)
    }

    private func tab(title: String, at index: Int, viewWidth: CGFloat) -> some View {
        Button {
            withAnimation {
                tabIndex = index
            }
        } label: {
            Text(title)
                .foregroundColor(.black)
                .frame(width: viewWidth / 2)
        }
    }

    func selectByDrag(viewWidth: CGFloat) -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, transaction in
                let translation = value.translation

                // Only interested in horizontal drag
                if abs(translation.width) > abs(translation.height) {
                    state = translation
                }
            }
            .onEnded { value in
                let translation = value.translation

                // Switch view if the translation is more than a
                // threshold (half the view width)
                if abs(translation.width) > abs(translation.height) &&
                    abs(translation.width) > viewWidth / 2 {
                    tabIndex = translation.width > 0 ? 0 : 1
                }
            }
    }

    private func pager(viewWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text("Content 1")
                .frame(width: viewWidth, height: Self.tab1Height)
                .background(Color.yellow)
            Text("Content 2")
                .frame(width: viewWidth, height: Self.tab2Height)
                .background(Color.orange)
        }
        .fixedSize()
        .offset(x: (CGFloat(-tabIndex) * viewWidth) + dragOffset.width)
        .animation(.easeInOut, value: tabIndex)
        .animation(.easeInOut, value: dragOffset)
        .gesture(selectByDrag(viewWidth: viewWidth))
    }
}



struct testProfileView: View {
    
    @State private var scrollOffset: CGFloat = 0
    
    var headerHeight: CGFloat {
        let height = 350 + scrollOffset
        return max(50, height)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            
            /*
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    
                    TabView{
                        
                        Text("Content 1")
                            .frame(width: UIScreen.main.bounds.width, height: 800)
                            .background(Color.yellow)
                        Text("Content 2")
                            .frame(width: UIScreen.main.bounds.width, height: 200)
                            .background(Color.orange)

                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: UIScreen.main.bounds.height - headerHeight, alignment: .top)
                    
                    /*
                    ZStack(alignment: .top) {
                        ScrollView{
                            Text("body")
                                .frame(width: UIScreen.main.bounds.width, height: 2000)
                                .background(Color.green)
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - headerHeight)
                    }
                     */
                    
                } header: {
                    Text("header info")
                        .frame(width: UIScreen.main.bounds.width, height: headerHeight)
                        .background(Color.orange)
                }
            }
            .frame(height: UIScreen.main.bounds.height)
             
             */
            
            GeometryReader { geometryProxy in
                LazyVStack {
                    
                    Text("header info")
                        .frame(width: UIScreen.main.bounds.width, height: headerHeight, alignment: .top)
                        .background(Color.orange)
                    
                    TabView{
                        
                        LazyVStack{
                            Text("Content 1")
                                .frame(width: UIScreen.main.bounds.width, height: 2000)
                                .background(Color.yellow)
                                .preference(key: ScrollOffsetKey.self, value: geometryProxy.frame(in: .named("scrollView")).minY)
                        }
                        
                        Text("Content 1")
                            .frame(width: UIScreen.main.bounds.width, height: 800)
                            .background(Color.yellow)
                        .preference(key: ScrollOffsetKey.self, value: geometryProxy.frame(in: .named("scrollView")).minY)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: UIScreen.main.bounds.height - headerHeight, alignment: .bottom)
                    
                }
            }
            .frame(height: UIScreen.main.bounds.height)
                
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            self.scrollOffset = offset
        }
        .refreshable {
            print("refreshing")
        }
        .ignoresSafeArea()
    }
}

struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}



 
struct TestProfileView3: View {
    
    @State private var headerHeight: CGFloat = 300
    @State private var tabBarHeight: CGFloat = 50
    let toolBarButtonsHeight: CGFloat = 50
    
    static let tab1Height: CGFloat = 100
    static let tab2Height: CGFloat = 800
    
    @State var tabIndex = 0
    
    @State private var tabBarY: CGFloat = 62
    @State private var tabButtonOpacity: Float = 1.0
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        ScrollView{
            VStack(spacing: 0) {
                //header
                bottom
            }
        }
        //.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .top)
    }
    
    private var header: some View {
        Text("Header")
            .frame(maxWidth: .infinity)
            .frame(height: headerHeight)
            .background(Color.green)
    }
    
    private var bottom: some View {
        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
            Section {
                pager
            } header: {
                //header
                tabBar
            }
        }
    }
    
    private var tabBar: some View {
        
        VStack{
            Text("Header")
                .frame(width: UIScreen.main.bounds.width, height: headerHeight)
                .background(Color.green)
            
            HStack(spacing: 0) {
                tab(title: "Tab 1", at: 0)
                tab(title: "Tab 2", at: 1)
            }
        }
        .onPreferenceChange(TabBarPreferenceKey.self) { y in
            guard let y = y, y > 0 else { return }
            
            if tabBarY-headerHeight <= 0{
                print("at top")
            }
            
            self.tabBarY = y
            
            if (tabBarY-headerHeight) < ((UIScreen.main.bounds.height/2)-headerHeight) {
                
                let scrollFraction = CGFloat((tabBarY-headerHeight)/((UIScreen.main.bounds.height/2)-headerHeight))
                
                tabButtonOpacity = Float(scrollFraction)
                
                tabBarHeight = 50 + ((1-scrollFraction) * 90)
                
            } else {
                tabButtonOpacity = 1.0
                
                tabBarHeight = 50
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: tabBarHeight + headerHeight)
        .background(Color.gray)
    }
    
    private func tab(title: String, at index: Int) -> some View {
        Button {
            withAnimation {
                tabIndex = index
            }
        } label: {
            Text(title)
                .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width / 2)
        }
    }
    
    private var pager: some View {
        
        TabView {
            ScrollView{
                Text("Content 1")
                    .frame(height: Self.tab1Height)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
            }
                .tag(0)
            
            ScrollView{
                Text("Content 2")
                    .frame(height: Self.tab2Height)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
            }
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: UIScreen.main.bounds.height - (tabBarHeight + headerHeight), alignment: .top)
    }
}

struct TestProfileView2: View {
    
    @State var profile: ProfileSettings = ProfileSettings()
    @State private var userPrivate: Bool = false
    @State private var showingDialog: Bool = false
    @State var followState: Bool
    
    
    @State private var headerHeight: CGFloat = 60
    @State private var tabBarHeight: CGFloat = 50
    
    let toolBarButtonsHeight: CGFloat = 50
    
    @State private var tab1Height: CGFloat = UIScreen.main.bounds.height/4
    @State private var tab2Height: CGFloat = UIScreen.main.bounds.height/4
    
    @State var tabIndex = 0
    
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
                    
                    tabBarHeight = 50 + ((1-scrollFraction) * 90)
                    
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
        .onAppear{
             
            profile.postContents = MediaFileJSON.map { item -> Reel in
                
                let url = Bundle.main.path(forResource: item.url, ofType: "mp4") ?? ""
                
                let player = AVPlayer(url: URL(fileURLWithPath: url))
                
                return Reel(videoStruct: ReelVideo(player: player, mediaFile: item))
            }
        }
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
                
                /*
                HStack(alignment: .bottom, spacing: 0) {
                    tab(title: "Tab 1", at: 0)
                    tab(title: "Tab 2", at: 1)
                }
                 */
                
                HStack(alignment: .bottom, spacing: 0) {
                 
                    VStack{
                        
                        Spacer()
                        
                        Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $tabIndex)
                            .padding(.horizontal, 50)
                    }
                 
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
                    .foregroundColor(Color.primary)
                    .padding(.leading)
                
            })
            
            Spacer(minLength: 0)
            
            Button(action: {
                
                self.showingDialog = true
            }){
                
                Image(systemName: "ellipsis")
                    .font(Font.system(size: 25).weight(.bold))
                    .foregroundColor(Color.primary)
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

    }

    private var pager: some View {
        ZStack(alignment: .top) {
            
            /*
            TabView(selection: $tabIndex) {
                Text("Content 1")
                    .frame(maxHeight: Self.tab1Height)
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .tag(0)
                
                Text("Content 2")
                    .frame(maxHeight: Self.tab2Height)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .tag(1)
            }
             */
            
            if !userPrivate {
                TabView(selection: $tabIndex) {
                    
                    List(1...50, id: \.self) { index in
                        HStack(spacing: 1) {
                            ForEach(0..<3) { _ in
                                Image("postcontentmock")
                                    .centerCropped()
                                    .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 1, trailing: 0))
                    }
                    .listStyle(.inset)
                    .tag(0)
                    .onAppear{
                        
                        var listSize = (50 * (UIScreen.main.bounds.height/5))
                        
                        if listSize < (4 * (UIScreen.main.bounds.height/5)) {
                            
                            listSize = (4 * (UIScreen.main.bounds.height/5))
                        } else {
                            
                            listSize = listSize + (UIScreen.main.bounds.height/3)
                        }
                        
                        self.tab1Height = listSize
                    }
                    
                    
                    List(1...2, id: \.self) { index in
                        HStack(spacing: 1) {
                            ForEach(0..<3) { _ in
                                Image("postcontentmock")
                                    .centerCropped()
                                    .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/5)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 1, trailing: 0))
                    }
                    .listStyle(.inset)
                    .tag(1)
                    .onAppear{
                        
                        var listSize = (2 * (UIScreen.main.bounds.height/5))
                        
                        if listSize < (4 * (UIScreen.main.bounds.height/5)) {
                            
                            listSize = (4 * (UIScreen.main.bounds.height/5))
                        } else {
                            
                            listSize = listSize + (UIScreen.main.bounds.height/3)
                        }
                        
                        self.tab2Height = listSize
                    }
                }
                .frame(height: tabIndex == 0 ? tab1Height : tab2Height)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.default, value: tabIndex)
            } else {
                
                VStack{
                    
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 100)
                }
            }
        }
        .animation(.easeOut, value: tabIndex)
        .background(Color.white)
    }
    
    private var userStats: some View {
        
        
        ZStack{
            
            VStack{
                
                TopRoundedRectangle(radius: 40)
                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()
            }
            .padding(.top, 80)
            
            
            VStack{
                
                
                if let profileImage = profile.profileImage {
                    
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100) // Adjust the size as needed
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 4) // Adjust the border width as needed
                        )
                    
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
                }
                
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
                            NavigationLink(destination: userFollowList(selectedTab: 0)){
                                VStack{
                                    Text("\(formatNumber(profile.followerUsers.count))")
                                        .foregroundColor(Color(red: 0.723, green: 0.88, blue: 0.825))
                                        .font(.title2)
                                    Text("フォロワー")
                                        .font(.footnote)
                                        .foregroundColor(Color.primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4)
                            }
                            
                            Spacer()
                            
                            
                            NavigationLink(destination: userFollowList(selectedTab: 1)){
                                VStack{
                                    Text("\(formatNumber(profile.followingUsers.count))")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                        .font(.title2)
                                    
                                    Text("フォロー中")
                                        .font(.footnote)
                                        .foregroundColor(Color.primary)
                                }
                                .frame(width: UIScreen.main.bounds.width/4)
                            }
                            
                            Spacer()
                            
                            VStack{
                                Text("\(profile.postContents.count)")
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
    
    @ViewBuilder
    private func backgroundView() -> some View {
        
        Group {
            if let backgroundImage = GI.shared.profileSettings?.backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                GradientEffectView(
                    .constant(
                        AnimatedGradient.Model(
                            colors: [
                                Color(red: 0.723, green: 0.88, blue: 0.825),
                                Color(red: 0.552, green: 0.724, blue: 0.831),
                                Color(red: 0.946, green: 0.76, blue: 0.839),
                                (colorScheme == .dark ? Color.black : Color.white)
                            ]
                        )
                    )
                )
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
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

*/
/*
 
 
 
 
 struct TestProfileView3: View {
     
     @State private var headerHeight: CGFloat = 300
     @State private var tabBarHeight: CGFloat = 50
     let toolBarButtonsHeight: CGFloat = 50
     
     static let tab1Height: CGFloat = 100
     static let tab2Height: CGFloat = 800
     
     @State var tabIndex = 0
     
     @State private var tabBarY: CGFloat = 62
     @State private var tabButtonOpacity: Float = 1.0
     
     @Environment(\.colorScheme) var colorScheme
     @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
     
     var body: some View {
         VStack(spacing: 0) {
             //header
             bottom
         }
         .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .top)
     }
     
     private var header: some View {
         Text("Header")
             .frame(maxWidth: .infinity)
             .frame(height: headerHeight)
             .background(Color.green)
     }
     
     private var bottom: some View {
         LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
             Section {
                 pager
             } header: {
                 //header
                 tabBar
             }
         }
     }
     
     private var tabBar: some View {
         
         VStack{
             Text("Header")
                 .frame(width: UIScreen.main.bounds.width, height: headerHeight)
                 .background(Color.green)
             
             HStack(spacing: 0) {
                 tab(title: "Tab 1", at: 0)
                 tab(title: "Tab 2", at: 1)
             }
         }
         .onPreferenceChange(TabBarPreferenceKey.self) { y in
             guard let y = y, y > 0 else { return }
             
             if tabBarY-headerHeight <= 0{
                 print("at top")
             }
             
             self.tabBarY = y
             
             if (tabBarY-headerHeight) < ((UIScreen.main.bounds.height/2)-headerHeight) {
                 
                 let scrollFraction = CGFloat((tabBarY-headerHeight)/((UIScreen.main.bounds.height/2)-headerHeight))
                 
                 tabButtonOpacity = Float(scrollFraction)
                 
                 tabBarHeight = 50 + ((1-scrollFraction) * 90)
                 
             } else {
                 tabButtonOpacity = 1.0
                 
                 tabBarHeight = 50
             }
         }
         .frame(maxWidth: .infinity)
         .frame(height: tabBarHeight + headerHeight)
         .background(Color.gray)
     }
     
     private func tab(title: String, at index: Int) -> some View {
         Button {
             withAnimation {
                 tabIndex = index
             }
         } label: {
             Text(title)
                 .foregroundColor(.black)
                 .frame(width: UIScreen.main.bounds.width / 2)
         }
     }
     
     private var pager: some View {
         
         TabView {
             ScrollView{
                 Text("Content 1")
                     .frame(height: Self.tab1Height)
                     .frame(maxWidth: .infinity)
                     .background(Color.yellow)
             }
                 .tag(0)
             
             ScrollView{
                 Text("Content 2")
                     .frame(height: Self.tab2Height)
                     .frame(maxWidth: .infinity)
                     .background(Color.orange)
             }
                 .tag(1)
         }
         .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
         .frame(height: UIScreen.main.bounds.height - (tabBarHeight + headerHeight), alignment: .top)
     }
 }
 
 */










//struct ReelsViewTest: View {
//    
//    @State var currentReel: UUID = (UUID(uuidString: "") ?? UUID())
//    @State var offsetY: CGFloat = 0.0  // To store the drag offset
//    @State var isRefreshing: Bool = false // To check if it's in refreshing state
//    
//    @State var pageTag: Int
//    @Binding var selectedTab: Int
//    @State private var atTop: Bool = false
//    
//    // Extracting Avplayer from media File...
//    @Binding var reels: [Lume]
//    @State var reelLocation: UUID = (UUID(uuidString: "") ?? UUID())
//    @State private var result_conv: Lume?
//    
//    @GestureState private var translation: CGFloat = 0
//    @State private var dragOffset: CGFloat = 0
//    @State private var updating: Bool = false
//    
//    @State var mute: Bool = false
//    
//    @Binding var videoPlaybackSliderProgress: CGFloat
//    @Binding var videoPlaybackSliderDragged:  Bool
//    
//    var body: some View {
//        
//        // Setting Width and height for rotated view....
//        GeometryReader{proxy in
//            
//            ZStack{
//                
//                Color.black.ignoresSafeArea()
//                
//                // Vertical Page Tab VIew....
//                TabView(selection: $currentReel){
//                    
//                    ForEach($reels){$reel in
//                        
//                        ReelsPlayerTest(reel: $reel, reels: $reels, reelLocation: $reelLocation, currentReel: $currentReel, mute: $mute, pageTag: pageTag, selectedTab: $selectedTab, videoPlaybackSliderProgress: $videoPlaybackSliderProgress, videoPlaybackSliderDragged: $videoPlaybackSliderDragged)
//                        // setting width...
//                            .frame(width: UIScreen.main.bounds.width)
//                        // Rotating Content...
//                            .rotationEffect(.init(degrees: -90))
//                        //.ignoresSafeArea(.all, edges: .top)
//                            .ignoresSafeArea()
//                            .tag(reel.id)
//                    }
//                    .onChange(of: selectedTab) { change in
//                        if change != pageTag {
//                            // Pause all the videos in reels
//                            for r in reels {
//                                r.videoStruct.player?.pause()
//                            }
//                        } else {
//                            currentReel = reelLocation
//                            if let matchingReel = reels.first(where: { $0.id == currentReel }) {
//                                matchingReel.videoStruct.player?.play()
//                                matchingReel.videoStruct.player?.isMuted = false
//                            }
//                        }
//                    }
//                    .onChange(of: currentReel) { newValue in
//                        // Check if newValue matches any id inside videoStruct of reels array
//                        
//                        if reels.contains(where: { $0.id == newValue }) {
//                            
//                            if newValue == reels.first?.id {
//                                atTop = true
//                                updating = true
//                                DispatchQueue.main.asyncAfter(deadline: .now()+3){
//                                    updating = false
//                                }
//                            } else if newValue == reels.last?.id || (reels.dropLast().last?.id == newValue) {
//                                
////                                GraphQL.shared.fetchSingleReelQL(reelQLId: "ap-northeast-1:fe0851e3-7778-4cec-a56a-1be377f25c9b:1703679266") { result in
////                                    switch result {
////                                    case .success(let reel):
////                                        
////                                        Task{
////                                            result_conv = reel
////                                            
////                                            await result_conv?.fetchAndProcessReel() { result in
////                                                switch result {
////                                                case .success(let reel):
////                                                    
////                                                    result_conv = reel
////                                                    reels.append(result_conv!)
////                                                    
////                                                case .failure(let error):
////                                                    print(error)
////                                                    // Handle error
////                                                }
////                                            }
////                                        }
////                                        // Use the fetched ReelQL data
////                                    case .failure(let error):
////                                        print("Error fetching ReelQL: \(error.localizedDescription)")
////                                    }
////                                }
//                            } else {
//                                atTop = false
//                            }
//                        }
//                    }
//                    
//                    
//                    ZStack{
//                        
//                        LoadingSpinner()
//                            .padding(.bottom, 30)
//                            .tag(UUID(uuidString: "Loading"))
////                            .onAppear{
////                                
////                                GraphQL.shared.fetchSingleReelQL(reelQLId: "ap-northeast-1:fe0851e3-7778-4cec-a56a-1be377f25c9b:1703679266") { result in
////                                    switch result {
////                                    case .success(let reel):
////                                        
////                                        Task{
////                                            result_conv = reel
////                                            
////                                            await result_conv?.fetchAndProcessReel() { result in
////                                                switch result {
////                                                case .success(let reel):
////                                                    
////                                                    result_conv = reel
////                                                    
////                                                    reels.append(result_conv!)
////                                                    
////                                                case .failure(let error):
////                                                    print(error)
////                                                    // Handle error
////                                                }
////                                            }
////                                        }
////                                        // Use the fetched ReelQL data
////                                    case .failure(let error):
////                                        print("Error fetching ReelQL: \(error.localizedDescription)")
////                                    }
////                                }
////                            }
//                    }
//                    .onChange(of: currentReel){ change in
//                        
//                      
//                        if change == UUID(uuidString: "Loading") {
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now()+2){
//                                print("Loading showing currently downloading")
////                                GraphQL.shared.fetchSingleReelQL(reelQLId: "ap-northeast-1:fe0851e3-7778-4cec-a56a-1be377f25c9b:1703679266") { result in
////                                    switch result {
////                                    case .success(let reel):
////                                        
////                                        Task{
////                                            result_conv = reel
////                                            
////                                            await result_conv?.fetchAndProcessReel() { result in
////                                                switch result {
////                                                case .success(let reel):
////                                                    
////                                                    result_conv = reel
////                                                    
////                                                    reels.append(result_conv!)
////                                                    
////                                                case .failure(let error):
////                                                    print(error)
////                                                    // Handle error
////                                                }
////                                            }
////                                        }
////                                        // Use the fetched ReelQL data
////                                    case .failure(let error):
////                                        print("Error fetching ReelQL: \(error.localizedDescription)")
////                                    }
////                                }
//                            }
//                            
//                        }
//                    }
//                }
//                // Rotating View....
//                .rotationEffect(.init(degrees: 90))
//                // Since view is rotated setting height as width...
//                .frame(width: UIScreen.main.bounds.height)
//                .tabViewStyle(.page(indexDisplayMode: .never))
//                // setting max width...
//                .frame(width: UIScreen.main.bounds.width)
//                .ignoresSafeArea()
//                
//                if updating {
//                    
//                    VStack{
//                        
//                        loadingProgressView()
//                        
//                        Spacer()
//                    }
//                }
//            }
//        }
//        .background(Color.black.ignoresSafeArea())
//        // setting intial reel...
//        .onAppear {
//            
//            if let firstReel = reels.first?.id {
//                
//                currentReel = firstReel
//            }
//        }
//        .ignoresSafeArea()
//    }
//    
//    var dragGesture: some Gesture {
//        DragGesture(minimumDistance: 0.1).updating($translation) { value, state, _ in
//            let accumulatedTranslation = value.translation.height + dragOffset
//            state = accumulatedTranslation // Set the translation including the accumulated offset
//        }
//        .onEnded { value in
//            let gestureThreshold = UIScreen.main.bounds.height * 0.1
//            dragOffset = value.translation.height.truncatingRemainder(dividingBy: UIScreen.main.bounds.height)
//            withAnimation(.easeOut) {
//                if value.translation.height > gestureThreshold {
//                    print("refreshing...")
//                    updating = true
//                }
//                dragOffset = 0
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now()+3){
//                
//                updating = false
//            }
//        }
//    }
//}
//
//struct ReelsPlayerTest: View{
//    
//    @Binding var reel: Lume
//    @Binding var reels: [Lume]
//    
//    @Binding var reelLocation: UUID
//    @Binding var currentReel: UUID
//    
//    @Binding var mute: Bool
//    @State private var lastTapTime: Date? = nil
//    @State private var muteAnimation = false
//    @State private var showLove: Bool = false
//    @State private var isAnimating: Bool = false
//    
//    @State private var longHold: Bool = false
//    
//    @State private var singleTapWorkItem: DispatchWorkItem?
//    
//    @State var pageTag: Int
//    @Binding var selectedTab: Int
//    
//    // Computed property
//    @State private var currentMinY: CGFloat = 0
//    @State private var currentSize: CGSize = .zero
//    
//    @State private var userName: String = ""
//    @State private var musicName: String = ""
//    
//    @State private var currentContent: UUID = UUID(uuidString: "") ?? UUID()
//    
//    @Binding var videoPlaybackSliderProgress: CGFloat
//    @Binding var videoPlaybackSliderDragged:  Bool
//    
//    @State private var imageLoading: Bool = true
//    @State private var imageDownload: Image? = nil
//    @State private var imageReelImageid: UUID? = nil
//    
//    var body: some View{
//        
//        ZStack{
//            
//            if !reel.contents.isEmpty {
//                
//                TabView(selection: $currentContent) {
//                    ForEach(reel.contents) { content in
//                        
//                        switch content {
//                        case Content.video(let reelVideo):
//                            // Assuming reelVideo.player is an AVPlayer
//                            
//                            CustomVideoPlayer(player: reelVideo.player!)
//                                .tag(reelVideo.id)
//                                .onChange(of: currentContent) { change in
//                                    
//                                    reel.currentContent = change
//                                    
//                                    withAnimation {
//                                        
//                                        videoPlaybackSliderProgress = CGFloat(0)
//                                    }
// 
//                                    if change != reelVideo.id {
//                                        
//                                        reelVideo.player?.pause()
//                                        reelVideo.player?.isMuted = mute
//                                    } else {
//                                        
//                                        reelVideo.player?.isMuted = mute
//                                        reelVideo.player?.play()
//                                    }
//                                    
//                                    setupVideoPlaybackObserver()
//                                }
//                                .onAppear{
//                                    setupVideoPlaybackObserver()
//                                }
//                                .onChange(of: videoPlaybackSliderDragged) { change in
//
//                                    if currentReel == reel.id {
//                                        
//                                        if change {
//                                            
//                                            reelVideo.player?.pause()
//                                            
//                                        } else {
//                                            
//                                            if currentReel == reel.id {
//                                                
//                                                reelVideo.player?.play()
//                                            }
//                                        }
//                                    }
//                                }
//                                .onChange(of: videoPlaybackSliderProgress) { change in
//                                    
//                                    if currentReel == reel.id {
//                                        
//                                        if videoPlaybackSliderDragged {
//                                            
//                                            reelVideo.player?.pause()
//                                            
//                                            if reelVideo.id == reel.currentContent {
//                                                
//                                                let duration = reelVideo.player?.currentItem?.duration.seconds ?? 0
//                                                let newTime = duration * Double(change)
//                                                reelVideo.player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 100))
//                                            }
//                                        }
//                                    }
//                                }
//                            
//                            
//                        case Content.image(let reelImage):
//                            ZStack {
//                                if let uiImage = reelImage.image {
//                                    // If a UIImage is already loaded, display it
//                                    Image(uiImage: uiImage)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                } else {
//                                    LoadingSpinner()
//                                        .task(id: reelImage.url) {
//                                            do {
//                                                let (data, _) = try await URLSession.shared.data(from: reelImage.url!)
//                                                if let fetchedImage = UIImage(data: data) {
//                                                    // Update the reelImage with the fetched UIImage
//                                                    DispatchQueue.main.async {
//                                                        // Update the image in ReelImage
//                                                        if let index = reel.contents.firstIndex(where: { $0.id == reelImage.id }) {
//                                                            switch reel.contents[index] {
//                                                            case .image(var updatedReelImage):
//                                                                updatedReelImage.image = fetchedImage
//                                                                reel.contents[index] = .image(updatedReelImage)
//                                                            default:
//                                                                break
//                                                            }
//                                                        }
//                                                    }
//                                                }
//                                            } catch {
//                                                print("Error fetching image: \(error)")
//                                            }
//                                        }
//                                }
//                            }
//                            .onChange(of: currentContent){ change in
//                                
//                                videoPlaybackSliderProgress = CGFloat(0)
//                                setupVideoPlaybackObserver()
//                            }
//                        }
//                    }
//                }
//                //.tabViewStyle(PageTabViewStyle())
//                .tabViewStyle(.page(indexDisplayMode: .automatic))
//                .onDisappear{
//                    reelLocation = reel.id
//                    reel.stopVideos()
//                }
//                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//                .gesture(
//                    TapGesture(count: 2)
//                        .onEnded { _ in
//                            // Cancel the single-tap action
//                            singleTapWorkItem?.cancel()
//                            
//                            withAnimation{
//                                reel.userLiked = true
//                            }
//                            
//                            showLove = true
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                withAnimation(.easeOut(duration: 0.5)) {
//                                    showLove = false
//                                }
//                            }
//                        }
//                )
//                .onTapGesture {
//                    // Schedule the single-tap action with a delay
//                    singleTapWorkItem = DispatchWorkItem {
//                        
//                        lastTapTime = Date()
//                        mute.toggle()
//                        
//                        reel.muteVideos(mute: mute)
//                                        
//                        withAnimation(.easeIn(duration: 0.1)) {
//                            muteAnimation.toggle()
//                        }
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
//                            withAnimation {
//                                muteAnimation.toggle()
//                            }
//                        }
//                    }
//                                    
//                    // Delay the single-tap action by 0.25 seconds to give double tap a chance to be recognized
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: singleTapWorkItem!)
//                }
//                
//                
//                GeometryReader { proxy in
//                    Color.clear
//                        .preference(key: ViewPositionKey.self, value: proxy.frame(in: .global))
//                }
//                .onPreferenceChange(ViewPositionKey.self) { frame in
//                    let minY = frame.minY
//                    let size = frame.size
//                    manageVideoPlayback(minY: minY, size: size, reel: reel)
//                }
//                
//                Image(systemName: mute ? "speaker.slash.fill" : "speaker.wave.2.fill")
//                    .font(.title)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(.secondary)
//                    .clipShape(Circle())
//                    .foregroundStyle(.black)
//                    .opacity(muteAnimation ? 1 : 0)
//                
//                Image(systemName: "heart.fill")
//                    .resizable()
//                    .foregroundColor(Color(red: 0.919, green: 0.767, blue: 0.834))
//                    .shadow(radius: 1)
//                    .opacity(showLove ? 1 : 0)
//                    .font(.largeTitle)
//                    .scaledToFit()
//                    .frame(width: 70, height: 70)
//                
//                
//                VStack{
//                    
//                    // Invisible box
//                    
//                    Rectangle()
//                        .foregroundColor(Color.white.opacity(0.001))
//                        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height*(3/9)))
//                    
//                    Spacer()
//                    
//                    Rectangle()
//                        .foregroundColor(Color.white.opacity(0.001))
//                        .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height*(3/9)))
//                }
//                .ignoresSafeArea()
//                
//                sideButtons(reel: $reel, reels: $reels)
//                
//                VStack{
//                    
//                    Spacer()
//                    
//                    ZStack {
//                        
//                        HStack {
//                            
//                            if isAnimating {
//                                
//                                Marquee(text: musicName, font: .systemFont(ofSize: 16, weight: .regular))
//                                    .frame(width: (UIScreen.main.bounds.width/2)-65)
//                            }
//                            
//                            Spacer()
//                            
//                            Text("@\(reel.postUser?.preferredUsername ?? " ")")
//                                .font(.subheadline)
//                                .foregroundColor(.white)
//                                .padding(.horizontal)
//                                .opacity((reel.postUser?.preferredUsername == nil) ? 0 : 1)
//                        }
//                    }
//                    .frame(height: 40)
//                }
//                .onAppear {
//                    
//                    reel.muteVideos(mute: mute)
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//                        isAnimating = true
//                    }
//                }
//                .safeAreaInset(edge: .bottom, spacing: 0) {
//                    Color.red.frame(height: 35).opacity(0)
//                }
//                
//            } else {
//                
//                LoadingSpinner()
//                
//            }
//        }
//        .onAppear{
//            
//            let trackName = reel.tagMusic.trackName
//            let artistName = reel.tagMusic.artistName
//
//            if !trackName.isEmpty && !artistName.isEmpty {
//                musicName = "\(trackName) by \(artistName)"
//            } else if !trackName.isEmpty {
//                musicName = trackName
//            } else if !artistName.isEmpty {
//                musicName = artistName
//            }
//            
//            if let firstContent = reel.contents.first {
//                switch firstContent {
//                case .video(let reelVideo):
//                    
//                    // only play when the current tab is at the first video
//                    
//                    
//                    if currentContent == UUID(uuidString: "") {
//                        currentContent = reelVideo.id
//                        reel.currentContent = reelVideo.id
//                    }
//                    
//                    if currentReel == reel.id {
//                        reelVideo.player?.play()
//                        reelVideo.player?.seek(to: CMTime.zero)
//                    }
//                    
//                default:
//                    // Handle other types or do nothing
//                    break
//                }
//            }
//
//        }
//    }
//    
//    private func setupVideoPlaybackObserver() {
//        // Assuming you have an AVPlayer instance for the current video
//        if let content = reel.contents.first(where: {$0.id == reel.currentContent}) {
//            switch content {
//            case .video(let reelVideo):
//                
//                let player = reelVideo.player
//                
//                let interval = CMTimeMakeWithSeconds(0.3, preferredTimescale: Int32(NSEC_PER_SEC))
//                player!.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
//                    guard let currentItem = player?.currentItem else { return }
//                    let duration = CMTimeGetSeconds(currentItem.duration)
//                    if duration > 0 {
//                        let currentTime = CMTimeGetSeconds(time)
//                        withAnimation{
//                            self.videoPlaybackSliderProgress = CGFloat(currentTime / duration)
//                        }
//                    }
//                }
//                
//            default:
//                withAnimation{
//                    self.videoPlaybackSliderProgress = CGFloat(0.0)
//                }
//            }
//        } else { return }
//    }
//    
//    
//    func manageVideoPlayback(minY: CGFloat, size: CGSize, reel: Lume) {
//        // Check if the current reel is the one being displayed and if it's the selected tab
//        if -minY < (size.height / 2) && minY < (size.height / 2) && currentReel == reel.id && selectedTab == pageTag {
//            // Find the current content by matching the currentContent UUID
//            if let currentContent = reel.contents.first(where: {$0.id == reel.currentContent}) {
//                // Play the video if the current content is a video
//                if case .video(let reelVideo) = currentContent {
//                    reelVideo.player?.play()
//                }
//            }
//        } else {
//            // Find the current content by matching the currentContent UUID
//            if let currentContent = reel.contents.first(where: { $0.id == reel.currentContent }) {
//                // Pause the video if the current content is a video
//                if case .video(let reelVideo) = currentContent {
//                    reelVideo.player?.pause()
//                }
//            }
//        }
//    }
//}



import SwiftUI
import UIKit
import AVKit

//struct VideoPicker: UIViewControllerRepresentable {
//    @Binding var selectedVideoURL: URL?
//    @Environment(\.presentationMode) var presentationMode
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.mediaTypes = ["public.movie"]
//        picker.videoQuality = .typeHigh
//        picker.sourceType = .photoLibrary
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        var parent: VideoPicker
//
//        init(_ parent: VideoPicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let url = info[.mediaURL] as? URL {
//                parent.selectedVideoURL = url
//            }
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
//
//
//
//
//struct Retrieve: View {
//    
//    @State private var textInput: String = "ap-northeast-1:be59e1d8-89b0-4171-9f2c-24c60b22800c:1701649501"
//    
//    @State private var result: ReelQL? = nil
//    @State private var result_conv: Reel? = nil
//    
//    
//    @State private var selectedVideoURL: URL?
//    @State private var showingVideoPicker = false
//    @State private var hasSelectedVideo: Bool = false
//    
//    
//    @State var reels5 = MediaFileJSON.map { item -> Reel in
//        
//        let url = Bundle.main.path(forResource: item.url, ofType: "mp4") ?? ""
//        
//        let player = AVPlayer(url: URL(fileURLWithPath: url))
//        
//        return Reel(
//            likedUsers: [
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Takeda Shinji", following: true)
//            ],
//            userPostDescription: Comment(profileImage: Image("postcontentmock"), username: "@GoPhoUrself", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！"),
//            userComments: [
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！も是非使ってみてください！"),
//                Comment(username: "@shunfujisawa_", content: "Love that, slay"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！も是非使ってみてください！"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Love that, slay"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！も是非使ってみてください！"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Love that, slay"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ")
//            ],
//            tagProducts: [
//                TagCosmetic(
//                    cosmeticID: "test1", cosmeticItem: cosmetic(
//                        productName: "Lip Gloss",
//                        companyID: "GlamUp",
//                        price: "1200",
//                        amount: "20 ml",
//                        productImage: Image("lipGlossImage"),
//                        totTagCount: 13
//                    ),
//                    recommendRating: 0.2,
//                    effectRating: 0.4,
//                    fadingRating: 0.8,
//                    feelingRating: 1,
//                    authProduct: true
//                ),
//                TagCosmetic(cosmeticID: "test3", cosmeticItem: cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml")),
//                TagCosmetic(
//                    cosmeticID: "test2", cosmeticItem: cosmetic(
//                        productName: "Mascara",
//                        companyID: "EyeCatcher",
//                        price: "1500",
//                        amount: "15 ml",
//                        productImage: Image("mascaraImage"),
//                        totTagCount: 20
//                    ),
//                    recommendRating: 0.1,
//                    effectRating: 0.1,
//                    fadingRating: 0.8,
//                    feelingRating: 0.2,
//                    authProduct: false
//                )
//            ],
//
//            userLiked: false,
//            contents: [.video(ReelVideo(player: player, mediaFile: item))
//                       ,.image(ReelImage(image: UIImage(named: "gayMan1")!, url: URL(string:"")!))
//                                   ,.image(ReelImage(image: UIImage(named: "gayMan2")!, url: URL(string:"")!))
//                                   //,.video(ReelVideo(player: AVPlayer(url: URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!)))
//                                    ,.video(ReelVideo(player: player, mediaFile: item))
//                                   ,.image(ReelImage(image: UIImage(named: "mock3")!, url: URL(string:"")!))
//                                   //,.video(ReelVideo(player: AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)))
//                                    ,.video(ReelVideo(player: player, mediaFile: item))
//                                   ,.image(ReelImage(image: UIImage(named: "gayMan3")!, url: URL(string:"")!))
//                                  ]
//        
//        )
//    }
//    @State var reels6: [Reel] = []
//    
//    
//    
//    /// for test
//    @State var selectedTab: Int = 0
//    @State var videoPlaybackSliderProgress: CGFloat = CGFloat(0.2)
//    @State var videoPlaybackSliderDragged:  Bool = false
//    
//    ///
//    
//    var body: some View {
//        
//        ZStack{
//            
//            TabView{
//                
//                
//                
//                VStack {
//                    
//                    Group {
//                        
//                        VStack{
//                            
//                            Text("Download reel Test")
//                            
//                            TextField("Input ReelQL ID", text: $textInput)
//                                .padding()
//                            
//                            Button("Fetch") {
//                                
//                                Task{
//                                    result_conv = Reel(postID: textInput)
//                                    
//                                    await result_conv?.fetchAndProcessReel() { result in
//                                        switch result {
//                                        case .success(let reel):
//                                            
//                                            result_conv = reel
//                                            
//                                            print("result_conv: \(result_conv!)")
//                                            reels6.append(result_conv!)
//                                            print("reels6: \(reels6)")
//                                            
//                                        case .failure(let error):
//                                            print(error)
//                                            // Handle error
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    
//                    Group {
//                        
//                        VStack{
//                            
//                            Text("Upload reel Test")
//                            
//                            
//                            Button("Upload"){
//                                
//                                print("uploading...")
//                                
//                                if var uploadingReel = reels5.first {
//                                    
//                                    uploadingReel.uploadReelQL() { result in
//                                        
//                                        switch result {
//                                            
//                                        case .success:
//                                            
//                                            print("Successfully uploaded Reel")
//                                            
//                                            self.textInput = reels5.first?.postID ?? ""
//                                            
//                                        case .failure:
//                                            
//                                            print("Error uploading")
//                                        }
//                                    }
//                                } else {
//                                    
//                                    print("no reel detected in reels5 array")
//                                }
//                                
//                                
//                                
//                            }
//                            
//                            Text("OR")
//                                .padding()
//                            
//                            
//                            
//                            
//                            
//                            
//                            Button("Select Video") {
//                                showingVideoPicker = true
//                                hasSelectedVideo = true
//                            }
//                            
//                            
//                            
//                            Button("upload video"){
//                                
//                                if let content = reels5.first?.contents.first {
//                                    
//                                    switch content{
//                                    case .video(let reelVideo):
//                                        
//                                        let s3Prefix = "s3://lumena225d91d9ee5c43d99341141978c6b54c25223-lumenaenv/public/"
//                                        
//                                        // Generate ReelID and ReelLocationS3
//                                        let ReelID = "\(GI.shared.profileSettings?.identityID ?? "null"):\(Int(Date.now.timeIntervalSince1970))"
//                                        let ReelLocationS3 = "\(GI.shared.profileSettings?.identityID ?? "null")/\(ReelID)"
//                                        
//                                        
//                                        if let videoURL = selectedVideoURL {
//                                            do {
//                                                let videoData = try Data(contentsOf: videoURL)
//                                                let videoName = "\(ReelLocationS3)/\(1).mp4"
//                                                S3.shared.storeData(name: videoName, data: videoData, accessLevel: .guest)
//                                                print("\(s3Prefix)\(videoName)")
//                                            } catch {
//                                                print("Error reading video data: \(error)")
//                                            }
//                                        }
//                                        
//                                        
//                                        
//                                        
//                                        if let asset = reelVideo.player?.currentItem?.asset {
//                                            let uniqueID = UUID().uuidString
//                                            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("exportedFile_\(uniqueID).mp4")
//                                            
//                                            if FileManager.default.fileExists(atPath: outputURL.path) {
//                                                try? FileManager.default.removeItem(at: outputURL)
//                                            }
//                                            
//                                            if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
//                                                exportSession.outputURL = outputURL
//                                                exportSession.outputFileType = .mp4
//                                                
//                                                exportSession.exportAsynchronously {
//                                                    DispatchQueue.main.async {
//                                                        switch exportSession.status {
//                                                        case .completed:
//                                                            print(outputURL)
//                                                            
//                                                            Task {
//                                                                let videoName = "\(ReelLocationS3)/\(2).mp4"
//                                                                let videoData = try Data(contentsOf: outputURL)
//                                                                S3.shared.storeData(name: videoName, data: videoData, accessLevel: .guest)
//                                                            }
//                                                            
//                                                        case .failed:
//                                                            print("Export failed: \(String(describing: exportSession.error))")
//                                                        default:
//                                                            print("Export session ended with \(exportSession.status)")
//                                                        }
//                                                    }
//                                                }
//                                            } else {
//                                                print("Could not create AVAssetExportSession")
//                                            }
//                                        } else {
//                                            print("Asset is not exportable")
//                                        }
//                                        
//                                        
//                                        
//                                        
//                                        
//                                    case .image:
//                                        break
//                                    }
//                                }
//                                
//                            }
//                            .disabled(!hasSelectedVideo)
//                            
//                        }
//                        .sheet(isPresented: $showingVideoPicker) {
//                            VideoPicker(selectedVideoURL: $selectedVideoURL)
//                        }
//                        
//                    }
//                    
//                }
//                .tag(0)
//                
//                VStack{
//                    ReelsViewTest(pageTag: 0, selectedTab: $selectedTab, reels: $reels6, videoPlaybackSliderProgress: $videoPlaybackSliderProgress, videoPlaybackSliderDragged: $videoPlaybackSliderDragged)
//                }
//                .tag(1)
//                
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        }
//        .ignoresSafeArea()
//    }
//}


//struct ReelsViewTest_Previews: PreviewProvider {
//    
//    @State static var selectedTab: Int = 0
//    
//    @State static var reels = MediaFileJSON.map { item -> Reel in
//        
//        let url = Bundle.main.path(forResource: item.url, ofType: "mp4") ?? ""
//        
//        let player = AVPlayer(url: URL(fileURLWithPath: url))
//        
//        return Reel(contents: [.video(ReelVideo(player: player, mediaFile: item))
//                               ,.image(ReelImage(image: UIImage(named: "gayMan1")!))
//                               ,.image(ReelImage(image: UIImage(named: "gayMan2")!))
//                               ,.video(ReelVideo(player: AVPlayer(url: URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!)))
//                               ,.image(ReelImage(image: UIImage(named: "mock3")!))
//                               ,.video(ReelVideo(player: AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)))
//                               ,.image(ReelImage(image: UIImage(named: "gayMan3")!))
//                              ])
//    }
//    
//    
//    static var previews: some View{
//        
//        ReelsViewTest(pageTag: 0, selectedTab: $selectedTab, reels: $reels)
//    }
//}

//struct imageLoadingTest: View {
//    // URLs for the compressed and uncompressed images
//    @State var compressedImageURL = URL(string: "https://lumena225d91d9ee5c43d99341141978c6b54c25223-lumenaenv.s3.ap-northeast-1.amazonaws.com/public/ap-northeast-1%3Abe59e1d8-89b0-4171-9f2c-24c60b22800c/ap-northeast-1%3Abe59e1d8-89b0-4171-9f2c-24c60b22800c%3A1701650188/2.jpg?AWSAccessKeyId=ASIA3RZTWI3LE7PLPSNN&Expires=1703168853&Signature=O85lVWZl0jE97jppY7cyUUsZbMU%3D&X-Amzn-Trace-Id=Root%3D1-65843d45-4f8861e32b051b203efd7199%3BParent%3D5939136e1c54794a%3BSampled%3D0%3BLineage%3D0f75f78b%3A0&x-amz-security-token=IQoJb3JpZ2luX2VjEI3%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDmFwLW5vcnRoZWFzdC0xIkcwRQIgf2wv8yT%2BAAJfyygqazLCBUD8BO1%2BBn%2F3Ci0a5peNwWoCIQCfkRbvNjJ94gfyVBoik2ZbBAL7hCJQ173mqXHobYl%2Bkyr7AggXEAAaDDc5NDE0MDQ5MzUyNiIMJunhXkvvmpsDd7%2FQKtgCnFgj0WqSoS7HwVBhLL8LqKfuQ1qMzO%2BNXrF5kVmrDrMJClBL1lTElnlPkTQxZHAzxWB9qZzJgeUOLYPNejPulvK2lx50GpeE7uYtQ6wzHQnPG2zpy%2FZhxNRWVzo792BBBz1N3NeM6jalxbaZKqshD4lIwD1Y5VjhqR%2BCcOLMtA4rNRSJSxS4B5GA4ZaB%2BCRKAK2GU%2B%2B8Oxc%2BmfN%2FnxYfr0%2FbxtkE8wH7xXLo5OBdkvry9Ysfs3dL6ZiXLmdwFgKzGzcup0yShkJohE2absO2IcQQz64wEU7QSeA43t1cvAg9%2BkE166Q%2BhmjB6BCLotG121J6XfbHOI5EbP6cuaaROqfu5DEEAu80VlbpMeFitW%2B1qXpSwjYub3OSMoxiT%2FoeboQNZRLkeSgjBBCtzv%2Btc1B1VDmC6vPp3x9VyAVtc1zfWZn3WPg1jF1GkVROKfie7qFnTPzw4I0w8vmQrAY6ngHsD706Dm5bkGaxn%2BdZqfJ46g4Rz%2B6JFSLmSD0KwdjbXjS4X%2FL30kKkeY%2FY4ppNeT8Rn%2BNzGEeBmX1B4%2BBQQFkSYUXeS1b1IrVnI2pCcxzSZVet3n4jvY%2FwPI4q%2B9FRe0C1A%2BkxdNna%2B0DbY4dd%2FQJzDZ16LGaJb41HARe%2BcfMCYTb9%2Bv%2FL8zc83pxJhdA2lUb8JReyLj0Gb9VEE990LA%3D%3D")!
//    @State var uncompressedImageURL = URL(string: "https://lumena225d91d9ee5c43d99341141978c6b54c25223-lumenaenv.s3.ap-northeast-1.amazonaws.com/public/ap-northeast-1%3Abe59e1d8-89b0-4171-9f2c-24c60b22800c/ap-northeast-1%3Abe59e1d8-89b0-4171-9f2c-24c60b22800c%3A1701649501/3.jpg?AWSAccessKeyId=ASIA3RZTWI3LKBBQNGNV&Expires=1702544308&Signature=sAAF1ZCscrJ7jNQO8uPY6DyZdm4%3D&X-Amzn-Trace-Id=Root%3D1-657ab5a4-6f4a923d332e5f862b7191cb%3BParent%3D448f76973b2f0fb7%3BSampled%3D0%3BLineage%3D0f75f78b%3A0&x-amz-security-token=IQoJb3JpZ2luX2VjEOD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDmFwLW5vcnRoZWFzdC0xIkgwRgIhAO6eMuju8GUz5fBpLmDDQy52ysLB%2FYlLhUcskYGSxZSdAiEAs1zV3K3O44G0YeEaXJshX8b7%2FgHS090rTLXbSYza8eoq%2BwIIWRAAGgw3OTQxNDA0OTM1MjYiDArDUmupjsWB%2FfYs6yrYApM901T0JsYJnHk0eG69FpoU%2BfWw6YHKmmztnHG4gZNx%2FOS6spbaD68Qyzmp6E2nVah4Yfwkovysl1d11WcVqjcvOaOZG9rRNPA%2F2xpcEADRgApRDbSxx5XwzjWqrU58CmToc9DOnmNoQwHokq1qXyaqDq78jumfgjlMYxcpoXZkmyzsEPr%2FD51aZoQ4tENBI6LHqjeZapjq1S8gS05MC6vGyJV0iMcz1WlSZUX8mZo3GH%2Bv%2BHZ10%2Fvb%2Bf5QOAIYHT4rHUlATA5NRoEGI2VX2KcLVnzA8r83BOoG%2Bx4HIXnfhV9xd2ngLjw3tkC1yiX%2FQJCrBTDa3UfLl%2Be3xeriCY4qQDfPzUKstUmP4KVz0yz2crbHggLzuw3kh06TLL81LIoGQBoziuZYMOamNrhwE1HFKH2pKXe5HI%2BTuMvwF08GpmQRCQ2whQNAtwVHu3JyH6uVxdytVuYEMIvo6qsGOp0BhBmhUg%2Fk%2FCA04sswrfA%2Fjrk2OD3ZcWF%2F2APaFrLBEmjTOh%2BHFpAbYupkuMPfOA%2BrPb6zsdJa5V9opU5upJLwKD2mvpSWVLBoN0I3K8zs35ZOmw4alyWgYX5D7f7gwyumNnsEAWHeV5SkxmHYsqh48t4TAXPNIgSdgetJoYq2EDVkN%2Fp2gowEdGal9lsKTxfhOZ5XHDoJQ50U7yg34Q%3D%3D")!
//    
//    
//    
//    @State var reels6: [Reel] = []
//    @State private var result_conv: Reel? = nil
//    @State private var textInput: String = "ap-northeast-1:be59e1d8-89b0-4171-9f2c-24c60b22800c:1701650188"
//    
//    var body: some View {
//        VStack {
//            
//            Text("Uncompressed Image")
//            AsyncImage(url: uncompressedImageURL) { image in
//                image.resizable()
//            } placeholder: {
//                AsyncImage(url: compressedImageURL) { image in
//                    
//                    ZStack{
//                        image.resizable()
//                    }
//                    .blur(radius: 2.0)
//                    
//                } placeholder: {
//                    //ProgressView()
//                    LoadingSpinner()
//                }
//            }
//            .frame(width: 200, height: 200)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .onAppear{
//                
//                GraphQL.shared.fetchSingleReelQL(reelQLId: textInput) { result in
//                    switch result {
//                    case .success(let reelQL):
//                        print("Fetched ReelQL: \(reelQL)")
//                        result_conv = Reel(reelQL: reelQL)
//                        reels6.append(result_conv!)
//                        compressedImageURL = URL(string: (result_conv?.postURL[1])!)!
//                        uncompressedImageURL = URL(string: (result_conv?.postURL[2])!)!
//                        
//                        print("\(compressedImageURL) : \(uncompressedImageURL)")
//                        // Use the fetched ReelQL data
//                    case .failure(let error):
//                        print("Error fetching ReelQL: \(error.localizedDescription)")
//                    }
//                    
//                }
//
//                
//                /*
//                Task{
//                    result_conv = Reel(postID: textInput)
//                    
//                    await result_conv?.fetchAndProcessReel() { result in
//                        switch result {
//                        case .success(let reel):
//                            
//                            result_conv = reel
//                            
//                            print("result_conv: \(result_conv!)")
//                            reels6.append(result_conv!)
//                            print("reels6: \(reels6)")
//                            
//                        case .failure(let error):
//                            print(error)
//                            // Handle error
//                        }
//                    }
//                }
//                 */
//                
//                
//            }
//        }
//    }
//}

//struct Retrieve_Previews: PreviewProvider {
//    static var previews: some View {
//        Retrieve()
//    }
//}

//struct imageLoadingTest_Previews: PreviewProvider {
//    static var previews: some View {
//        imageLoadingTest()
//    }
//}



//struct ShowPopover: View {
//    @State private var showModal = false
//    @State private var buttonFrame: CGRect = CGRect.zero
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                Color.black.opacity(0.5)
//                    .edgesIgnoringSafeArea(.all)
//
//                VStack{
//                    Button("Show Pannable View") {
//                        showModal = true
//                        
//                        Task{
//                            let result = await GraphQL.shared.fetchReelsByUserProfile(userProfileID: "d7941a08-9051-70f7-592b-4ad315ecf6e7")
//                            
//                            print(result as Any)
//                        }
//                    }
//                    .background(GeometryReader { buttonGeometry in
//                        Color.clear
//                            .onAppear {
//                                buttonFrame = buttonGeometry.frame(in: .global)
//                            }
//                    })
//                    .frame(width: 200, height: 60)
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//                    
//                    Spacer()
//                }
//
//                if showModal {
//                    PannableViewController(startFrame: buttonFrame, isPresented: $showModal)
//                        .ignoresSafeArea()
//                }
//            }
//        }
//    }
//}
//
//struct PannableViewController: UIViewControllerRepresentable {
//    var startFrame: CGRect
//    @Binding var isPresented: Bool
//
//    func makeUIViewController(context: Context) -> ViewControllerPannable {
//        let viewController = ViewControllerPannable()
//        viewController.startFrame = startFrame
//        viewController.isPresentedBinding = $isPresented
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: ViewControllerPannable, context: Context) {
//        // Update the view controller in response to new SwiftUI state.
//    }
//}

//class ViewControllerPannable: UIViewController {
//    var startFrame: CGRect = .zero
//    var isPresentedBinding: Binding<Bool>?
//    private var originalPosition: CGPoint?
//    private var originalSize: CGSize?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .orange
//        originalSize = view.frame.size
//        view.frame = startFrame
//        view.transform = CGAffineTransform(scaleX: startFrame.width / view.frame.width, y: startFrame.height / view.frame.height)
//        view.center = CGPoint(x: startFrame.midX, y: startFrame.midY)
//        
//        UIView.animate(withDuration: 0.3) {
//            self.view.transform = .identity
//            self.view.frame = UIScreen.main.bounds
//        }
//        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
//        self.view.addGestureRecognizer(panGestureRecognizer)
//    }
//    
//    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
//        switch panGesture.state {
//        case .began:
//            originalPosition = view.center
//        case .changed:
//            let translation = panGesture.translation(in: view)
//            view.center = CGPoint(
//                x: originalPosition!.x + translation.x,
//                y: originalPosition!.y + translation.y
//            )
//        case .ended:
//            let velocity = panGesture.velocity(in: view)
//            if velocity.y < 500 && velocity.x < 300 {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.view.center = self.originalPosition ?? CGPoint.zero
//                })
//                return
//            }
//
//            let finalScaleX = startFrame.width / UIScreen.main.bounds.width
//            let finalScaleY = startFrame.height / UIScreen.main.bounds.height
//            let finalCenter = CGPoint(x: startFrame.midX, y: startFrame.midY)
//
//            UIView.animate(withDuration: 0.2, animations: {
//                self.view.transform = CGAffineTransform(scaleX: finalScaleX, y: finalScaleY)
//                self.view.center = finalCenter
//            }, completion: { _ in
//                self.isPresentedBinding?.wrappedValue = false
//                self.dismiss(animated: false, completion: nil)
//            })
//        default:
//            return
//        }
//    }
//}

//struct ShowPopover_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowPopover()
//    }
//}




//struct ProfileTest: View {
//    
//    @State private var headerHeight: CGFloat = 60
//    @State private var tabBarHeight: CGFloat = 50
//    let toolBarButtonsHeight: CGFloat = 50
//    
//    @State private var tab1Height: CGFloat = UIScreen.main.bounds.height/4
//    @State private var tab2Height: CGFloat = UIScreen.main.bounds.height/4
//    
//    @State var tabIndex = 0
//    
//    let tabs: [Tab] = [
//        .init(title: "投稿"),
//        //.init(title: "保存"),
//        .init(title: "ライク"),
//    ]
//    
//    
//    @State private var tabBarY: CGFloat = 62
//    @State private var tabButtonOpacity: Float = 1.0
//    
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
//    
//    var body: some View {
//        
//        ZStack {
//            
//            backgroundView()
//                .opacity((tabBarY-headerHeight) <= 1 ? 0 : 1)
//            
//            
//            
//            ScrollView{
//                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
//                    header
//                    bottom
//                }
//            }
//            .animation(.easeOut(duration: 1), value: tabIndex)
//            .onPreferenceChange(TabBarPreferenceKey.self) { y in
//                guard let y = y, y > 0 else { return }
//                
//                self.tabBarY = y
//                
//                if (tabBarY-headerHeight) < ((UIScreen.main.bounds.height/2)-headerHeight) {
//                    
//                    let scrollFraction = CGFloat((tabBarY-headerHeight)/((UIScreen.main.bounds.height/2)-headerHeight))
//                    
//                    tabButtonOpacity = Float(scrollFraction)
//                    
//                    tabBarHeight = ((1-scrollFraction) * 50)
//                    
//                } else {
//                    tabButtonOpacity = 1.0
//                    
//                    tabBarHeight = 0
//                }
//            }
//            .ignoresSafeArea()
//            
//            
//            VStack{
//                toolBarButtons
//                Spacer()
//            }
//        }
//        .navigationBarHidden(true)
//    }
//    
//    private var header: some View {
//    
//        VStack {
//            
//            userStats
//        }
//        .frame(height: UIScreen.main.bounds.height)
//    }
//    
//    private var bottom: some View {
//        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
//            Section {
//                pager
//            } header: {
//                tabBar
//            }
//        }
//    }
//    
//    private var tabBar: some View {
//        GeometryReader { geometry in
//            ZStack {
//                
//                /*
//                HStack(alignment: .bottom, spacing: 0) {
//                    tab(title: "Tab 1", at: 0)
//                    tab(title: "Tab 2", at: 1)
//                }
//                 */
//                
//                HStack(alignment: .bottom, spacing: 0) {
//                 
//                    VStack{
//                        
//                        Spacer()
//                        
//                        Color.clear.frame(height: 80)
//                        
//                        Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $tabIndex)
//                            .padding(.horizontal, 50)
//                            .background(Color.white)
//                    }
//                 
//                }
//                .frame(maxWidth: .infinity)
//                //.frame(height: tabBarHeight)
//                .background(colorScheme == .dark ? Color.black : Color.white)
//                .onAppear {
//                    self.tabBarY = geometry.frame(in: .global).minY
//                }
//                .preference(key: TabBarPreferenceKey.self,value: geometry.frame(in: .global).minY)
//                
//            }
//        }
//        .frame(height: tabBarHeight + 50)
//    }
//
//    private func tab(title: String, at index: Int) -> some View {
//        Button {
//            withAnimation {
//                tabIndex = index
//            }
//        } label: {
//            
//            VStack{
//                
//                Spacer()
//                
//                Text(title)
//                    .foregroundColor(Color.primary)
//                    .frame(width: UIScreen.main.bounds.width / 2)
//            }
//            .padding(.bottom)
//        }
//    }
//
//    private var toolBarButtons: some View {
//        HStack{
//            
//            Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }, label: {
//                
//                Image(systemName: "chevron.backward")
//                    .font(Font.system(size: 25).weight(.bold))
//                    .foregroundColor(Color.primary)
//                    .padding(.leading)
//                
//            })
//            
//            Spacer(minLength: 0)
//            
//            NavigationLink(destination:
//                FollowRequest()
//            ) {
//                Image(systemName: "person.fill.checkmark")
//                    .font(Font.system(size: 25).weight(.bold))
//                    .foregroundColor(Color.primary)
//                    .padding(.leading)
//            }
//            .buttonStyle(PlainButtonStyle())
//            .opacity(Double(tabButtonOpacity))
//            
//            
//            NavigationLink(destination:
//                UserSetting()
//            ) {
//                Image(systemName: "gear")
//                    .font(Font.system(size: 25).weight(.bold))
//                    .foregroundColor(Color.primary)
//                
//            }
//            .buttonStyle(PlainButtonStyle())
//            .opacity(Double(tabButtonOpacity))
//        }
//        .padding()
//        .frame(height: toolBarButtonsHeight)
//        //.background(colorScheme == .dark ? Color.black.opacity(Double(1 - tabButtonOpacity)) : Color.white.opacity(Double(1 - tabButtonOpacity)))
//
//    }
//    
//    
//    @State var reelThumbnails: [UUID: UIImage] = [:]
//    @State private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
//    
//    @State var userLuma: [Reel] = MediaFileJSON.map { item -> Reel in
//        
//        let url = Bundle.main.path(forResource: item.url, ofType: "mp4") ?? ""
//        
//        let player = AVPlayer(url: URL(fileURLWithPath: url))
//        
//        return Reel(
//            likedUsers: [
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa"),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Shun Fujisawa", following: true),
//                OtherUserInfo(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", fullname: "Takeda Shinji", following: true)
//            ],
//            userPostDescription: Comment(profileImage: Image("postcontentmock"), username: "@GoPhoUrself", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！"),
//            userComments: [
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！も是非使ってみてください！"),
//                Comment(username: "@shunfujisawa_", content: "Love that, slay"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！も是非使ってみてください！"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Love that, slay"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Curelさんが出しているこのローション、若者の間ではものすごく人気のある商品です！みなさんも是非使ってみてください！も是非使ってみてください！"),
//                Comment(profileImage: Image("postcontentmock"), username: "@shunfujisawa_", content: "Love that, slay"),
//                Comment(profileImage: Image("postcontentmock"), username: "@oppapi", content: "いいいねええええええ")
//            ],
//            tagProducts: [
//                TagCosmetic(
//                    cosmeticID: "test1", cosmeticItem: cosmetic(
//                        productName: "Lip Gloss",
//                        companyID: "GlamUp",
//                        price: "1200",
//                        amount: "20 ml",
//                        productImage: Image("lipGlossImage"),
//                        totTagCount: 13
//                    ),
//                    recommendRating: 0.2,
//                    effectRating: 0.4,
//                    fadingRating: 0.8,
//                    feelingRating: 1,
//                    authProduct: true
//                ),
//                TagCosmetic(cosmeticID: "test3", cosmeticItem: cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml")),
//                TagCosmetic(
//                    cosmeticID: "test2", cosmeticItem: cosmetic(
//                        productName: "Mascara",
//                        companyID: "EyeCatcher",
//                        price: "1500",
//                        amount: "15 ml",
//                        productImage: Image("mascaraImage"),
//                        totTagCount: 20
//                    ),
//                    recommendRating: 0.1,
//                    effectRating: 0.1,
//                    fadingRating: 0.8,
//                    feelingRating: 0.2,
//                    authProduct: false
//                )
//            ],
//
//            userLiked: false,
//            contents: [.video(ReelVideo(player: player, mediaFile: item))
//                                   ,.image(ReelImage(image: UIImage(named: "gayMan1")!))
//                                   ,.image(ReelImage(image: UIImage(named: "gayMan2")!))
//                                   ,.video(ReelVideo(player: AVPlayer(url: URL(string: "https://www.w3schools.com/html/mov_bbb.mp4")!)))
//                                   ,.image(ReelImage(image: UIImage(named: "mock3")!))
//                                   ,.video(ReelVideo(player: AVPlayer(url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)))
//                                   ,.image(ReelImage(image: UIImage(named: "gayMan3")!))
//                                  ]
//        
//        )
//    }
//    @State var likeLuma: [Reel] = []
//    
//    private var userGrid: some View {
//        
//        ScrollView {
//            if userLuma.isEmpty {
//                
//                Text("No Luma Available")
//                    .padding(.vertical, 150)
//                
//            } else {
//                LazyVGrid(columns: columns, spacing: 2) {
////                    ForEach(userLuma, id: \.id) { reel in
////                        NavigationLink(destination: profilereelpage(reels: $userLuma, reelLocation: reel.id)) {
////                            if let thumbnail = reelThumbnails[reel.id] {
////                                Image(uiImage: thumbnail)
////                                    .centerCropped()
////                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
////                            } else {
////                                ShimmerEffectBox()
////                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
//////                                    .task {
//////                                        if reelThumbnails[reel.id] == nil {
//////                                            reelThumbnails[reel.id] = await reel.thumbnail()
//////                                        }
//////                                    }
////                            }
////                        }
////                    }
//                    
//                    ForEach(0..<40){_ in
//                        ShimmerEffectBox()
//                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
//                    }
//                }
//            }
//        }
//        .onAppear{
//            userLuma = GI.shared.userPosts ?? []
//        }
//    }
//    
//    private var likeGrid: some View {
//        
//        ScrollView {
//            if likeLuma.isEmpty {
//                
//                Text("No Luma Available")
//                    .padding(.vertical, 150)
//                
//            } else {
//                LazyVGrid(columns: columns, spacing: 2) {
////                    ForEach(likeLuma, id: \.id) { reel in
////                        NavigationLink(destination: profilereelpage(reels: $likeLuma, reelLocation: reel.id)) {
////                            if let thumbnail = reelThumbnails[reel.id] {
////                                Image(uiImage: thumbnail)
////                                    .centerCropped()
////                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
////                            } else {
////                                ShimmerEffectBox()
////                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
//////                                    .task {
//////                                        if reelThumbnails[reel.id] == nil {
//////                                            reelThumbnails[reel.id] = await reel.thumbnail()
//////                                        }
//////                                    }
////                            }
////                        }
////                    }
//                    
//                    ForEach(0..<40){_ in
//                        ShimmerEffectBox()
//                            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 5)
//                    }
//                }
//            }
//        }
//    }
//
//    private var pager: some View {
//        
//        TabView(selection: $tabIndex) {
//            
//            userGrid
//            .tag(0)
//            
//            likeGrid
//            .tag(1)
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//        .frame(minHeight: UIScreen.main.bounds.height - ((tabBarHeight + 50) + headerHeight), alignment: .top)
//        .background(colorScheme == .dark ? Color.black : Color.white)
//    }
//    
//    @State private var
//    
//    private var userStats: some View {
//        
//        ZStack{
//            VStack{
//                
//                TopRoundedRectangle(radius: 40)
//                    .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
//                    .ignoresSafeArea()
//            }
//            .padding(.top, 70)
//            
//            
//            VStack{
//                
//                if let profileImage = GI.shared.profileSettings?.profileImage?.image {
//                    Image(uiImage: profileImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 100, height: 100) // Adjust the size as needed
//                        .clipShape(Circle())
//                        .overlay(
//                            Circle()
//                                .stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 4) // Adjust the border width as needed
//                        )
//                } else {
//                    Image(systemName: "person.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .padding()
//                        .frame(width: 100, height: 100) // Adjust the size as needed
//                        .clipShape(Circle())
//                        .foregroundColor(Color.secondary)
//                        .background(
//                            Circle()
//                                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
//                        )
//                }
//                
//                Group {
//                    Text((GI.shared.profileSettings?.preferredUsername.isEmpty ?? true) ? " " : "@\(GI.shared.profileSettings?.preferredUsername ?? " ")")
//                        .font(.title2)
//                    
//                    Text((GI.shared.profileSettings?.givenName.isEmpty ?? true) ?  " " : "\(GI.shared.profileSettings!.givenName)")
//                        .font(.footnote)
//                }
//                .fontWeight(.bold)
//                .background(colorScheme == .dark ? Color.black : Color.white)
//                
//                
//                Spacer()
//                
//                VStack{
//                    
//                    ZStack{
//                        
//                        HStack{
//                            NavigationLink(destination: userFollowList(selectedTab: 0)){
//                                VStack{
//                                    Text("10K") //Text("\(formatNumber(profile.followerUsers.count))")
//                                        .foregroundColor(Color(red: 0.723, green: 0.88, blue: 0.825))
//                                        .font(.title2)
//                                    
//                                    
//                                    Text("フォロワー")
//                                        .font(.footnote)
//                                        .foregroundColor(Color.primary)
//                                }
//                                .frame(width: UIScreen.main.bounds.width/4)
//                            }
//                            
//                            Spacer()
//                            
//                            
//                            NavigationLink(destination: userFollowList(selectedTab: 1)){
//                                VStack{
//                                    Text("30")
//                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
//                                        .font(.title2)
//                                    
//                                    Text("フォロー中")
//                                        .font(.footnote)
//                                        .foregroundColor(Color.primary)
//                                }
//                                .frame(width: UIScreen.main.bounds.width/4)
//                            }
//                            
//                            Spacer()
//                            
//                            VStack{
//                                Text("30")
//                                    .foregroundColor(Color(red: 0.946, green: 0.76, blue: 0.839))
//                                    .font(.title2)
//                                
//                                Text("投稿数")
//                                    .font(.footnote)
//                            }
//                            .frame(width: UIScreen.main.bounds.width/4)
//                        }
//                        .fontWeight(.bold)
//                        .padding(.horizontal, 30)
//                        .padding(.bottom)
//                        
//                    }
//                    
//                    Text((GI.shared.profileSettings?.bio.isEmpty ?? true) ? " " : "\(GI.shared.profileSettings!.bio)")
//                }
//                .background(colorScheme == .dark ? Color.black : Color.white)
//            }
//            .frame(height: 227)
//            
//        }
//        .ignoresSafeArea()
//        .padding(.top, UIScreen.main.bounds.height*0.65)
//    }
//    
//    @ViewBuilder
//    private func backgroundView() -> some View {
//        
//        Group {
//            if let backgroundImage = GI.shared.profileSettings?.backgroundImage?.image {
//                Image(uiImage: backgroundImage)
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//            } else {
//                GradientEffectView(
//                    .constant(
//                        AnimatedGradient.Model(
//                            colors: [
//                                Color(red: 0.723, green: 0.88, blue: 0.825),
//                                Color(red: 0.552, green: 0.724, blue: 0.831),
//                                Color(red: 0.946, green: 0.76, blue: 0.839),
//                                (colorScheme == .dark ? Color.black : Color.white)
//                            ]
//                        )
//                    )
//                )
//            }
//        }
//        .frame(maxWidth: UIScreen.main.bounds.width)
//    }
//    
//    func formatNumber(_ num: Int) -> String {
//        let thousand = 1_000
//        let million = 1_000_000
//        
//        if num < thousand {
//            return "\(num)"
//        } else if num < million {
//            return String(format: "%.1fk", Double(num) / Double(thousand))
//        } else {
//            return String(format: "%.1fm", Double(num) / Double(million))
//        }
//    }
//}



//struct ProfileTest_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileTest()
//    }
//}





/*

struct testProfile: View {
    
    @State private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    @State var tabIndex = 0
    
    let tabs: [Tab] = [
        .init(title: "投稿"),
        //.init(title: "保存"),
        .init(title: "ライク"),
    ]
    
    @State private var tabBarY: CGFloat = 62
    
    
    var body: some View {
        
        
        ZStack{
            
            
            Color.brown
                .ignoresSafeArea()
            
            
            ScrollView{
                
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    
                    Section {
                        
                        TabView {
                            ScrollView{
                                Text("Content 1")
                                    .frame(height: 4000)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.yellow)
                            }
                            .tag(0)
                            
                            ScrollView{
                                Text("Content 2")
                                    .frame(width: UIScreen.main.bounds.width, height: 5000)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                            }
                            .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .ignoresSafeArea()
                        .frame(width: UIScreen.main.bounds.width, height: 5000)
                        .padding(.top, UIScreen.main.bounds.height*0.5)
                        
                    } header: {
                        
                        VStack{
                            
                            Color.black
                                .frame(width: UIScreen.main.bounds.width, height: 50-tabBarY)
                            Color.blue
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.5)
                            
//                            Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $tabIndex)
//                                .padding(.horizontal, 50)
//                                .background(Color.white)
                        }
                    }
                }
            }
            .onPreferenceChange(TabBarPreferenceKey.self) { y in
                guard let y = y, y > 0 else { return }
                
                self.tabBarY = y
                
            }
            .ignoresSafeArea()
        }
    }
}



struct testBackBlurProfile: View {
    
    @State var currentPage: Int = 0
    
    @State var Images: [UIImage] = []
    
    var body: some View {
        
        ZStack{
            
            backgroundBlur(images: $Images, currentPage: $currentPage)
                .onAppear{
                    Images = [ UIImage(imageLiteralResourceName: "1"),
                               UIImage(imageLiteralResourceName: "2"),
                               UIImage(imageLiteralResourceName: "3"),
                               UIImage(imageLiteralResourceName: "4"),
                               UIImage(imageLiteralResourceName: "5"),
                               UIImage(imageLiteralResourceName: "6")
                             ]
                }
            
            HStack{
                
                Button("Left"){
                    
                    if currentPage > 0 {
                        currentPage -= 1
                    }
                    print(currentPage)
                }
                
                Button("Right") {
                    
                    if currentPage < Images.count {
                        currentPage += 1
                    }
                    
                    print(currentPage)
                }
                
            }
        }
    }
}


//struct testBackBlurProfile_Previews: PreviewProvider {
//    static var previews: some View {
//        testBackBlurProfile()
//    }
//}




import UIKit

class PagingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages = [UIViewController]()
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        // Instantiate view controllers
        let page1 = UIViewController() // Your custom view controller
        let page2 = UIViewController() // Your custom view controller
        // Add more pages as needed
        
        // Add view controllers to the array
        pages.append(contentsOf: [page1, page2])
        
        // Set the initial view controller
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        // Customize the UIPageViewController
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: UIPageViewControllerDataSource methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil // Looping disabled
        }
        
        guard pages.count > previousIndex else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let pagesCount = pages.count
        
        guard pagesCount != nextIndex else {
            return nil // Looping disabled
        }
        
        guard pagesCount > nextIndex else {
            return nil
        }
        
        return pages[nextIndex]
    }
}




class FirstPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        view.addSubview(tableView)
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        // Perform your data refresh here
        
        // End refreshing
        refreshControl.endRefreshing()
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return 10 // Example
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue and configure your cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
}
*/


import SwiftUI
import AVKit


/*
struct VideoPlayerView: UIViewControllerRepresentable {
    @Binding var url: URL  // Use a Binding to allow the URL to be updated

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Check if the current URL in the player is different from the new URL
        if let currentItemUrl = uiViewController.player?.currentItem?.asset as? AVURLAsset, currentItemUrl.url != url {
            // Replace the current player item with a new one if the URL has changed
            uiViewController.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
    }
}

struct HLSTestView: View {
    @State private var videoURL = URL(string: "https://d1s4m1vkr1js6q.cloudfront.net/public/ap-northeast-1:b8e67646-d675-c305-9a29-5ad831af4ed5/ap-northeast-1:b8e67646-d675-c305-9a29-5ad831af4ed5:1714013950/video3/video3.m3u8")!
    
    @State private var urlString = ""
    
    var body: some View {
        VStack {
            Text("HLS Video Player")
                .font(.title)
                .padding()
            
            VideoPlayerView(url: $videoURL) // Pass the Binding URL to the player view
                .frame(height: 300)
            
            TextField("HLS URL", text: $urlString)
            
            Button("Change Video") {
                // Update the video URL to demonstrate dynamic change
                videoURL = URL(string: urlString)!
            }
        }
    }
}

class HLSTestViewViewController: UIViewController {
    private var hostingController: UIHostingController<HLSTestView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize your SwiftUI view
        var mainView = HLSTestView()
        
        // Create a hosting controller with SwiftUI view
        hostingController = UIHostingController(rootView: mainView)
        
        // Setup the hosting controller
        guard let hostingController = hostingController else { return }
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.pinToEdges(of: view)
        hostingController.didMove(toParent: self)
    }
}

#Preview {
    HLSTestView()
}

 */

import SwiftUI

import UIKit

class HorizontalTabViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create view controllers for each tab
        let firstViewController = UIViewController()
        firstViewController.view.backgroundColor = .red
        firstViewController.tabBarItem = UITabBarItem(title: "First", image: nil, selectedImage: nil)
        
        let secondViewController = UIViewController()
        secondViewController.view.backgroundColor = .green
        secondViewController.tabBarItem = UITabBarItem(title: "Second", image: nil, selectedImage: nil)
        
        // Add view controllers to the array
        viewControllers = [VerticalTabViewController(), VerticalTabViewController()]
        
        // Create a page view controller
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        
        // Set the first view controller
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        // Add the page view controller as a child view controller
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = index - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex < viewControllers.count else {
            return nil
        }
        return viewControllers[nextIndex]
    }
}




class VerticalTabViewController: UIViewController, UIScrollViewDelegate {
    
    private var scrollView: UIScrollView!
//    private var buttonsStackView: UIStackView!
    private var contentStackView: UIStackView!
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Create ScrollView for content
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true // Enable paging
        view.addSubview(scrollView)
        
        // Setup scrollView constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Content stack view inside scroll view
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        //contentStackView.spacing = 10
        contentStackView.distribution = .fill
        
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup content stack view constraints
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Initialize and add the refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        scrollView.addSubview(refreshControl)
        scrollView.refreshControl = refreshControl

        // Adjust contentInsetAdjustmentBehavior
        scrollView.contentInsetAdjustmentBehavior = .never

        addTabs()
        
        scrollView.delegate = self
    }
    
    private func addTabs() {
        let titles = ["Tab 1", "Tab 2", "Tab 3"] // Example tabs
        for title in titles {
            let contentView = UIView()
            contentView.backgroundColor = UIColor.random() // Just for distinct visual difference
            contentStackView.addArrangedSubview(contentView)
            
            contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true // Set each content view height
        }
    }
    
    @objc private func refreshAction() {
        // Refresh data or perform any necessary updates
        // For now, just end refreshing after a delay to simulate a refresh
        print("refreshing")
        scrollView.contentInsetAdjustmentBehavior = .always
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.scrollView.contentInsetAdjustmentBehavior = .never
            
            // Scroll to the first tab
            let yOffset: CGFloat = 0 // Adjust this value if needed
            self.scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        
        // Check if the scrollView has scrolled to the bottom
        if position + scrollViewHeight >= contentHeight - 100 {  // 100 can be adjusted based on when you want to trigger the load
            loadMoreTabs()
        }
    }
    
    private func loadMoreTabs() {
        let newTitles = ["Tab 4", "Tab 5", "Tab 6"]  // New tabs to add
        
        for title in newTitles {
            let contentView = UIView()
            contentView.backgroundColor = UIColor.random()  // Just for distinct visual difference
            contentStackView.addArrangedSubview(contentView)
            
            contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true  // Set each content view height
        }
    }
}
 

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
