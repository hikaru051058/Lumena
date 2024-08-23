//
//  CosmeticViewModel.swift
//  MyPalette
//
//  Created by 島田晃 on 2024/03/03.
//

import Foundation
import UIKit
import SwiftUI


//MARK: - cosmetic view for product tags

struct CosmeticsTagView: View {
    
    @Binding var TagCosmetics: [TagCosmetic]

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                ForEach(TagCosmetics.indices, id: \.self) { index in
                    IndividualTagCosmeticsTagView(TagCosmetic: TagCosmetics[index], showDetails: index == 0)
                }
            }
            .padding(.top, 25)
        }
    }
}

struct IndividualCosmeticsTagView: View {
    
    @ObservedObject var cosmetic: Cosmetic
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isSheetPresented = false
    @State private var isLoading = true
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 3)
                .foregroundColor(colorScheme == .light ? Color.white : Color.black)
            
            VStack{
                HStack {
                    
                    if let productImages = cosmetic.productImages {
                        
//                        CardStack(productImages) { item in
//                            
//                            // Subsequent items - Show the image
//                            if let uiItemImage = item.image, uiItemImage != UIImage() {
//                                
//                                Image(uiImage: uiItemImage)
//                                    .resizable()
//                                    .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
//                                    .frame(width: 70, height: 70)
//                                    .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
//                                    .shadow(radius: 5)
//                                
//                            } else {
//                                
//                                Image(systemName: "cross.vial")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 70, height: 70)
//                                    .cornerRadius(10)
//                                    .padding(.trailing)
//                            }
//                        }
//                        .padding(.trailing)
                        
                        if let uiItemImage = productImages.first?.image, uiItemImage != UIImage() {
                            
                            Image(uiImage: uiItemImage)
                                .resizable()
                                .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
                                .shadow(radius: 5)
                            
                        } else {
                            
                            Image(systemName: "cross.vial")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                .padding(.trailing)
                        }
                        
                    } else {
                        
                        Image(systemName: "cross.vial")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .padding(.trailing)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        
                        Text(cosmetic.productName)
                            .font(.headline)
                        
                        Text(cosmetic.companyID)
                            .font(.caption)
                    
                        HStack {
                            
//                            if cosmetic.price != "0" {
//                                Text("$\(cosmetic.price)")
//                                    .font(.callout)
//                                
//                                Rectangle()
//                                    .frame(width: 1, height: 25)
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 2)
//                            }
//                            
//                            if cosmetic.amount != "" {
//                                Text(cosmetic.amount)
//                                
//                                Rectangle()
//                                    .frame(width: 1, height: 25)
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 2)
//                            }
                            
                            
                            if !cosmetic.isProductURLEmpty() {
                                if let url = cosmetic.returnProductURL()
                                {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(Color(uiColor: UIColor.arinBlue))
                                        .frame(width: 25, height: 25)
                                        .onTapGesture {
                                            NotificationCenter.default.post(name: .showSheetBrowser, object: nil, userInfo: ["url": url])
                                        }
                                }
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .padding(.leading)
                    
                }
            }
        }
        .padding(.horizontal, 20)
    }
}


struct IndividualTagCosmeticsTagView: View {
    
    @ObservedObject var TagCosmetic: TagCosmetic
    
    @State var cosmetic: Cosmetic?
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showDetails: Bool = false
    @State var showInside: Bool = false
    
    @State private var isSheetPresented = false
    @State private var isLoading = true
    
    @State private var verticalOffset: CGFloat = 0
    
    var body: some View {
        
        ZStack {
            
            Color.clear
                .onAppear{
                    let CosmeticID = TagCosmetic.cosmeticID
                    cosmetic = CosmeticManager.shared.getCosmetic(withID: CosmeticID)
                }
            
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 3)
                .foregroundColor(colorScheme == .light ? Color.white : Color.black)
            
            VStack{
                
                HStack {
                    if let productImages = cosmetic?.productImages {
//                        CardStack(productImages) { item in
//                            
//                            if let uiItemImage = item.image, uiItemImage != UIImage() {
//                                
//                                Image(uiImage: uiItemImage)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 70, height: 70)
//                                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                                    .shadow(radius: 5)
//                                
//                            } else {
//                                
//                                Image(systemName: "cross.vial")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 70, height: 70)
//                                    .cornerRadius(10)
//                                    .padding(.trailing)
//                            }
//                        }
//                        .padding(.trailing)
                        
                        if let uiItemImage = productImages.first?.image, uiItemImage != UIImage() {
                            
                            Image(uiImage: uiItemImage)
                                .resizable()
                                .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
                                .shadow(radius: 5)
                            
                        } else {
                            
                            Image(systemName: "cross.vial")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                .padding(.trailing)
                        }
                        
                    } else {
                        
                        Image(systemName: "cross.vial")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .padding(.trailing)
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text(cosmetic?.productName ?? "null")
                            .font(.headline)
                        
                        Text(cosmetic?.companyID ?? "null")
                            .font(.caption)
                        
                        HStack {
                            
//                            if cosmetic?.price != "0" {
//                                Text("$\(cosmetic?.price ?? "")")
//                                    .font(.callout)
//                                
//                                Rectangle()
//                                    .frame(width: 1, height: 25)
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 2)
//                            }
//                            
//                            if cosmetic?.amount != "" {
//                                
//                                Text(cosmetic?.amount ?? "null")
//                                
//                                Rectangle()
//                                    .frame(width: 1, height: 25)
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 2)
//                            }
                            
                            if let link = TagCosmetic.attachedURL,
                                let url = URL(string: link)
                            {
                                Image(systemName: "link.circle.fill")
                                    .foregroundColor(Color(uiColor: UIColor.arinBlue))
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        NotificationCenter.default.post(name: .showSheetBrowser, object: nil, userInfo: ["url": url])
                                    }
                                
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                            }
                            
                            if TagCosmetic.authProduct {
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                    .font(.title2)
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .padding(.leading)
                    
                }
                .padding(.vertical)
                
                if showDetails {
                    HStack{
                        
                        VStack{
                            CircularInfoBar(stat: CGFloat(TagCosmetic.effectRating))
                            Text("効果")
                                .fontWeight(.bold)
                            
                        }
                        .padding()
                        
                        VStack{
                            CircularInfoBar(stat: CGFloat(TagCosmetic.recommendRating))
                            Text("おすすめ度")
                                .fontWeight(.bold)
                        }
                        .padding()
                        
                        VStack{
                            VStack{
                                HStack{
                                    Text("肌触り")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                HStack{
                                    
                                    Text("ベトベト")
                                        .font(.caption2)
                                    
                                    Spacer()
                                    
                                    Text("サラサラ")
                                        .font(.caption2)
                                }
                                .font(.footnote)
                                LinearInfoBar(stat: CGFloat(TagCosmetic.feelingRating))
                            }
                            
                            VStack{
                                HStack{
                                    Text("落ち具合")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                HStack{
                                    
                                    Text("落ちやすい")
                                        .font(.caption2)
                                    
                                    Spacer()
                                    
                                    Text("落ちにくい")
                                        .font(.caption2)
                                }
                                .font(.footnote)
                                LinearInfoBar(stat: CGFloat(TagCosmetic.fadingRating))
                            }
                        }
                        .padding(.bottom)
                    }
                    .font(.footnote)
                    .opacity(showInside ? 1 : 0)
                    .offset(y: verticalOffset)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            withAnimation(showInside ? .easeOut : .easeIn){
                showInside.toggle()
                if showInside {
                    verticalOffset = 0
                } else {
                    verticalOffset = -80
                }
            }
            withAnimation{
                showDetails.toggle()
            }
        }
        .onAppear{
            
            showInside = showDetails
        }
    }
}


struct CircularInfoBar: View {
    var stat: CGFloat
    @State private var animationProgress: CGFloat = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 7.0)
                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53).opacity(0.3))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(animationProgress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 7.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                .rotationEffect(Angle(degrees: 270.0))
            Text(String(format: "%.0f", min(stat, 1.0)*100.0))
                .font(.title3)
                .bold()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = stat
            }
        }
    }
}


struct LinearInfoBar: View {
    var stat: CGFloat
    @State private var animationProgress: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: 7.0)
                    .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53).opacity(0.3))
                
                Rectangle().frame(width: geometry.size.width * min(max(animationProgress, 0), 1), height: 7.0)
                    .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                
            }.cornerRadius(5.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = stat
            }
        }
    }
}



//MARK: - cosmetic view for product submission and posting

struct ProductView: View {
    
    @ObservedObject var postLume: Lume
    
    @Binding var tagAny: Bool
    @Binding var filterTag: Bool
    
    @Binding var url: URL?
    @Binding var isShowingBrowser: Bool
    
    @ObservedObject var cosmeticsWrapper: CosmeticsWrapper
    
    var body: some View {
        List {
            ForEach(cosmeticsWrapper.cosmetics.indices, id: \.self) { index in
                if !filterTag || postLume.tagProducts.contains(where: { $0.cosmeticID == cosmeticsWrapper.cosmetics[index].cosmeticID }) {
                    TagIndividualCosmeticsTagView(
                        postLume: postLume,
                        cosmetic: $cosmeticsWrapper.cosmetics[index],
                        tagAny: $tagAny,
                        url: $url,
                        isShowingBrowser: $isShowingBrowser
                    )
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 10)
                }
            }
            .listRowInsets(EdgeInsets(top: 25, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
    }
}



struct TagIndividualCosmeticsTagView: View {
    
    @ObservedObject var postLume: Lume
    
    @Binding var cosmetic: Cosmetic
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var tagStat: Bool = false
    
    @Binding var tagAny: Bool
    
    var initiTag: Bool = false
    
    @Binding var url: URL?
    @Binding var isShowingBrowser: Bool
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 3)
                .foregroundColor(tagStat ? (colorScheme == .light ? Color(red: 0.686, green: 0.817, blue: 0.724) : Color(red: 0.486, green: 0.629, blue: 0.53)) : (colorScheme == .light ? Color.white : Color.black))
            
            HStack {
                
                Group {
                    if let productImages = cosmetic.productImages, !productImages.isEmpty  {
//                        CardStack(productImages) { item in
//                            
//                            // Subsequent items - Show the image
//                            if let uiItemImage = item.image {
//                                
//                                Image(uiImage: uiItemImage)
//                                    .resizable()
//                                    .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
//                                    .frame(width: 70, height: 70)
//                                    .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
//                                    .shadow(radius: 5)
//                                
//                            } else {
//                                
//                                Image(systemName: "cross.vial")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 70, height: 70)
//                                    .cornerRadius(10)
//                                    .padding(.trailing)
//                                
//                            }
//                        }
//                        .padding(.trailing)
                        
                        if let uiItemImage = productImages.first?.image, uiItemImage != UIImage() {
                            
                            Image(uiImage: uiItemImage)
                                .resizable()
                                .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
                                .shadow(radius: 5)
                            
                        } else {
                            
                            Image(systemName: "cross.vial")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                .padding(.trailing)
                        }
                        
                    } else {
                        
                        Image(systemName: "cross.vial")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .padding(.trailing)
                        
                    }
                }
                .frame(width: 100)
                
                
                VStack(alignment: .leading) {
                    
                    Text(cosmetic.productName)
                        .font(.headline)
                    
                    Text(cosmetic.companyID)
                        .font(.caption)
                    
                    HStack {
                        
//                        if cosmetic.price != "null" {
//                            Text("$\(cosmetic.price)")
//                            //Text(cosmetic.id.uuidString)
//                                .font(.callout)
//                            
//                            Rectangle()
//                                .frame(width: 1, height: 25)
//                                .foregroundColor(.gray)
//                                .padding(.horizontal, 2)
//                        }
//                        
//                        
//                        if cosmetic.amount != "" {
//                            
//                            Text(cosmetic.amount)
//                            
//                            Rectangle()
//                                .frame(width: 1, height: 25)
//                                .foregroundColor(.gray)
//                                .padding(.horizontal, 2)
//                        }
                        
                        if !cosmetic.isProductURLEmpty() {
                            if let url = cosmetic.returnProductURL()
                            {
                                Image(systemName: "link.circle.fill")
                                    .foregroundColor(Color(uiColor: UIColor.arinBlue))
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        NotificationCenter.default.post(name: .showSheetBrowser, object: nil, userInfo: ["url": url])
                                    }
                            }
                        }
                    }
                }
                .fontWeight(.bold)
                .padding(.leading)
                
                Spacer()
                
            }
            .padding(.horizontal)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 7)
        .onTapGesture {
            
            withAnimation(.easeIn(duration: 0.12)){
                tagStat.toggle()
                
                if tagStat {
                    
                    tagAny = true
                    
                    let newTagCosmetic = TagCosmetic(cosmeticID: cosmetic.cosmeticID, cosmeticItem: cosmetic)
                    
                    postLume.tagProducts.append(newTagCosmetic)
                    
                } else {
                    
                    if let index = postLume.tagProducts.firstIndex(where: { $0.cosmeticItem?.id == cosmetic.id }) {
                        postLume.tagProducts.remove(at: index)
                    }
                    
                    if postLume.tagProducts.isEmpty {
                        tagAny = false
                    }
                }
            }
        }
        .onAppear{
            if postLume.tagProducts.contains(where: { $0.cosmeticItem?.id == cosmetic.id }) {
                tagStat = true
            }
        }
    }
}


struct RatingIndividualListView: View {
    
    @ObservedObject var postLume: Lume
    
    let tagCosmetic: TagCosmetic
    @Environment(\.colorScheme) var colorScheme
    
    @State var tagStat: Bool = false
    
    var initiTag: Bool = false
    
    @State var showSlider: Bool = false
    @State var maxWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    
    let sliderConfigs: [SliderConfiguration] = [
        SliderConfiguration(title: "おすすめ", minRating: "おすすめじゃない", maxRating: "めっちゃおすすめ"),
        SliderConfiguration(title: "効果", minRating: "効果が見られない", maxRating: "めっちゃ効果的"),
        SliderConfiguration(title: "落ち具合", minRating: "落ちやすい", maxRating: "落ちにくい"),
        SliderConfiguration(title: "肌触り", minRating: "ベトベト", maxRating: "サラサラ")
    ]
    
    @State private var isShowingScanner = false
    @State private var scannedCode: String = ""
    
    @State private var productAuthenticated: Bool = false
    
    @State private var dynamicBottomPadding: CGFloat = 55
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let adjustedWidth = geometry.size.width - 60 // Adjusted for padding
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .shadow(radius: 3)
                    .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                
                VStack{
                    HStack {
                        
                        Group {
                            if let productImages = tagCosmetic.cosmeticItem?.productImages {
                                
                                //                            CardStack(productImages) { item in
                                //
                                //                                // Subsequent items - Show the image
                                //                                if let uiItemImage = item.image, uiItemImage != UIImage() {
                                //
                                //                                    Image(uiImage: uiItemImage)
                                //                                        .resizable()
                                //                                        .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
                                //                                        .frame(width: 70, height: 70)
                                //                                        .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
                                //                                        .shadow(radius: 5)
                                //
                                //                                } else {
                                //
                                //                                    Image(systemName: "cross.vial")
                                //                                        .resizable()
                                //                                        .scaledToFit()
                                //                                        .frame(width: 70, height: 70)
                                //                                        .cornerRadius(10)
                                //                                        .padding(.trailing)
                                //                                }
                                //                            }
                                //                            .padding(.trailing)
                                
                                if let uiItemImage = productImages.first?.image, uiItemImage != UIImage() {
                                    
                                    Image(uiImage: uiItemImage)
                                        .resizable()
                                        .scaledToFill() // ensures the content scales to fill the size of the view and may be clipped
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 16)) // crops the image to the same shape as the RoundedRectangle
                                        .shadow(radius: 5)
                                    
                                } else {
                                    
                                    Image(systemName: "cross.vial")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                        .cornerRadius(10)
                                        .padding(.trailing)
                                }
                                
                            } else {
                                
                                Image(systemName: "cross.vial")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(10)
                                    .padding(.trailing)
                            }
                        } 
                        .padding(.leading)
                        
                        VStack(alignment: .leading) {
                            
                            HStack{
                                Text(tagCosmetic.cosmeticItem!.productName)
                                    .font(.headline)
                                
                                Text(tagCosmetic.cosmeticItem!.companyID)
                                    .font(.caption)
                            }
                            
                            HStack {
                                
//                                Text(tagCosmetic.cosmeticItem!.amount)
//                                
//                                Rectangle()
//                                    .frame(width: 1, height: 25)
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 2)
                                
                                
                                if !productAuthenticated {
                                    Button(action: {
                                        isShowingScanner = true
                                    }) {
                                        Text("認証")
                                            .foregroundColor(Color(red: 0.946, green: 0.76, blue: 0.839))
                                        
                                        Image(systemName: "barcode.viewfinder")
                                            .foregroundColor(Color(red: 0.946, green: 0.76, blue: 0.839))
                                            .font(.title2)
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
                                                if scannedCode == tagCosmetic.cosmeticID {
                                                    tagCosmetic.authProduct = true
                                                    withAnimation {
                                                        productAuthenticated = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    Text("認証済み")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                        .font(.title2)
                                }
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                                
                                Button(action: {
                                    withAnimation{
                                        showSlider.toggle()
                                    }
                                }) {
                                    
                                    Text("詳細")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                    
                                    Image(systemName: showSlider ? "chevron.up" : "slider.horizontal.3")
                                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                        .font(.title2)
                                }
                                
                            }
                            .font(.caption2)
                        }
                        .fontWeight(.bold)
                        .padding(.leading)
                    }
                    .padding(.vertical)
                    
                    if showSlider {
                        ForEach(0..<sliderConfigs.count, id: \.self) { index in
                            RatingSliderView(
                                postLume: postLume,
                                tagCosmeticID: tagCosmetic.cosmeticItem!.cosmeticID,
                                title: sliderConfigs[index].title, maxWidth: adjustedWidth,
                                minRating: sliderConfigs[index].minRating,
                                maxRating: sliderConfigs[index].maxRating
                            )
                            .padding(.bottom, index == sliderConfigs.count - 1 ? 16 : 2)
                        }
                    }
                }
            }
        }
        .padding(.bottom, showSlider ? CGFloat((55+(sliderConfigs.count * 68))) : 55)
        .padding(.horizontal)
    }
}

struct RatingSliderView: View {
    
    @ObservedObject var postLume: Lume
    
    let tagCosmeticID: String
    let title: String
    let maxWidth: CGFloat
    let minRating: String
    let maxRating: String
    @State private var tempWidth: CGFloat = 0
    
    var body: some View {
        
        if postLume.tagProducts.firstIndex(where: { $0.cosmeticID == tagCosmeticID }) != nil {
            VStack(alignment: .leading) {

                HStack {
                     Text(NSLocalizedString(title, comment: ""))
                        .font(.callout)
                        .fontWeight(.bold)
                    Spacer()
                }

                VStack {
                    ZStack(alignment: .leading, content: {
                        Rectangle()
                            .fill(Color(red: 0.486, green: 0.629, blue: 0.53).opacity(0.2))

                        Rectangle()
                            .fill(Color(red: 0.486, green: 0.629, blue: 0.53))
                            .frame(width: min((tempWidth), maxWidth))
                    })
                    .frame(width: maxWidth, height: 10)
                    .cornerRadius(35)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ (value) in
                            let newWidth = (CGFloat(self.getCurrentRating()) * maxWidth) + value.translation.width
                            tempWidth = min(max(newWidth, 0), maxWidth)
                        })
                        .onEnded({ (value) in
                            
                            print(Double(tempWidth/maxWidth))
                            self.setCurrentRating(Double(tempWidth/maxWidth))
                            print(self.setCurrentRating)
                            
                        })
                    )
                }

                HStack {
                    Text(NSLocalizedString(minRating, comment: ""))
                        .font(.caption2)
                        .fontWeight(.bold)
                    Spacer()
                    Text(NSLocalizedString(maxRating, comment: ""))
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
            .frame(width: maxWidth)
            .onAppear{
                
                withAnimation {
                    tempWidth = self.getCurrentRating() * maxWidth
                }
            }
            
        } else {
            EmptyView()
        }
    }
    
    func getCurrentRating() -> Double {
        switch title {
        case "おすすめ":
            return postLume.tagProducts.first(where: { $0.cosmeticID == tagCosmeticID })?.recommendRating ?? 0
        case "効果":
            return postLume.tagProducts.first(where: { $0.cosmeticID == tagCosmeticID })?.effectRating ?? 0
        case "落ち具合":
            return postLume.tagProducts.first(where: { $0.cosmeticID == tagCosmeticID })?.fadingRating ?? 0
        case "肌触り":
            return postLume.tagProducts.first(where: { $0.cosmeticID == tagCosmeticID })?.feelingRating ?? 0
        default:
            return 0
        }
    }
    
    func setCurrentRating(_ rating: Double) {
        if let index = postLume.tagProducts.firstIndex(where: { $0.cosmeticID == tagCosmeticID }) {
            switch title {
            case "おすすめ":
                postLume.tagProducts[index].recommendRating = rating
            case "効果":
                postLume.tagProducts[index].effectRating = rating
            case "落ち具合":
                postLume.tagProducts[index].fadingRating = rating
            case "肌触り":
                postLume.tagProducts[index].feelingRating = rating
            default:
                break
            }
        }
    }
}

struct SideButtonCosmeticsTagView: View {
    
    @State var TagCosmetics: [TagCosmetic]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider() // Adds a visual line
                    .background(Color.clear)

                ScrollView {
                    VStack(spacing: 25) {
                        ForEach(TagCosmetics.indices, id: \.self) { index in
                            SideButtonIndividualTagCosmeticsTagView(TagCosmetic: TagCosmetics[index], showDetails: index == 0)
                        }
                    }
                    .padding(.top, 25)
                }
            }
            .navigationBarTitle(Text("タグされたコスメ"), displayMode: .inline)
        }
    }
}

struct SideButtonIndividualTagCosmeticsTagView: View {
    
    @ObservedObject var TagCosmetic: TagCosmetic
    
    @State var cosmetic: Cosmetic?
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var showDetails: Bool = false
    @State var showInside: Bool = false
    
    @State private var verticalOffset: CGFloat = 0
    
    @State private var isSheetPresented: Bool = false
    @State private var url: URL?
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 3)
                .foregroundColor(colorScheme == .light ? Color.white : Color.black)
            
            VStack{
                
                HStack {
                    
                    Group {
                        if let productImages = cosmetic?.productImages {
                            //                        CardStack(productImages) { item in
                            //
                            //                            if let uiItemImage = item.image, uiItemImage != UIImage() {
                            //
                            //                                Image(uiImage: uiItemImage)
                            //                                    .resizable()
                            //                                    .scaledToFill()
                            //                                    .frame(width: 70, height: 70)
                            //                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            //                                    .shadow(radius: 5)
                            //
                            //                            } else {
                            //
                            //                                Image(systemName: "cross.vial")
                            //                                    .resizable()
                            //                                    .scaledToFit()
                            //                                    .frame(width: 70, height: 70)
                            //                                    .cornerRadius(10)
                            //                                    .padding(.trailing)
                            //                            }
                            //                        }
                            //                        .padding(.trailing)
                            
                            if let uiItemImage = productImages.first?.image, uiItemImage != UIImage() {
                                
                                Image(uiImage: uiItemImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .shadow(radius: 5)
                                
                            } else {
                                
                                Image(systemName: "cross.vial")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(10)
                                    .padding(.trailing)
                            }
                            
                        } else {
                            
                            Image(systemName: "cross.vial")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                                .padding(.trailing)
                        }
                    }
                    .padding(.leading)
                    
                    VStack(alignment: .leading) {
                        
                        Text(cosmetic?.productName ?? "null")
                            .font(.headline)
                        
                        Text(cosmetic?.companyID ?? "null")
                            .font(.caption)
                        
                        HStack {
                            
//                            if cosmetic?.price != "0" {
//                                Text("$\(cosmetic?.price ?? "null")")
//                                    .font(.callout)
//                            }
//                            
//                            if cosmetic?.amount != "" {
//                                
//                                Rectangle()
//                                    .frame(width: 1, height: 25)
//                                    .foregroundColor(.gray)
//                                    .padding(.horizontal, 2)
//                                
//                                Text(cosmetic?.amount ?? "null")
//                            }
                            
                            if let cosme = cosmetic, 
                                !cosme.isProductURLEmpty(),
                                let url = cosme.returnProductURL()
                            {
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                                
                                Button(action: {
                                    self.url = url
                                    isSheetPresented.toggle()
                                }) {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(Color(uiColor: UIColor.arinBlue))
                                }
                                .frame(width: 25, height: 25)
                            }
                            
                            if TagCosmetic.authProduct {
                                
                                Rectangle()
                                    .frame(width: 1, height: 25)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 2)
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                                    .font(.title2)
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .padding(.leading)
                    
                }
                .padding(.vertical)
                
                if showDetails {
                    HStack{
                        
                        VStack{
                            CircularInfoBar(stat: CGFloat(TagCosmetic.effectRating))
                            Text("効果")
                                .fontWeight(.bold)
                        }
                        .padding()
                        
                        VStack{
                            CircularInfoBar(stat: CGFloat(TagCosmetic.recommendRating))
                            Text("おすすめ度")
                                .fontWeight(.bold)
                        }
                        .padding()
                        
                        VStack{
                            VStack{
                                HStack{
                                    Text("肌触り")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                HStack{
                                    
                                    Text("ベトベト")
                                        .font(.caption2)
                                    Spacer()
                                    
                                    Text("サラサラ")
                                        .font(.caption2)
                                }
                                .font(.footnote)
                                LinearInfoBar(stat: CGFloat(TagCosmetic.feelingRating))
                            }
                            
                            VStack{
                                HStack{
                                    Text("落ち具合")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                HStack{
                                    
                                    Text("落ちやすい")
                                        .font(.caption2)
                                    
                                    Spacer()
                                    
                                    Text("落ちにくい")
                                        .font(.caption2)
                                }
                                .font(.footnote)
                                LinearInfoBar(stat: CGFloat(TagCosmetic.fadingRating))
                            }
                        }
                        .padding(.bottom)
                    }
                    .font(.footnote)
                    .opacity(showInside ? 1 : 0)
                    .offset(y: verticalOffset)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal, 20)
        .onTapGesture {
            withAnimation(showInside ? .easeOut : .easeIn){
                showInside.toggle()
                if showInside {
                    verticalOffset = 0
                } else {
                    verticalOffset = -80
                }
            }
            withAnimation{
                showDetails.toggle()
            }
        }
        .onAppear{
            let CosmeticID = TagCosmetic.cosmeticID
            cosmetic = CosmeticManager.shared.getCosmetic(withID: CosmeticID)
            
            if let url = cosmetic?.returnProductURL()
            {
                self.url = url
            }
            showInside = showDetails
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack(spacing: 0) {
                #if os(macOS)
                HStack {
                    Text(url?.absoluteString ?? "")
                    Spacer()
                    Button {
                        isSheetPresented.toggle()
                    } label: {
                        Label("Close", systemImage: "xmark.circle")
                            .labelStyle(.iconOnly)
                    }
                }
                .padding(10)
                #endif
                LoadingWebView(url: url)
                    .frame(minWidth: 300, minHeight: 300)
            }
        }
    }
}
