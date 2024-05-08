//
//  Search.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/16.
//

import Foundation
import SwiftUI
import AVFoundation


/*

struct Search: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchTerm: String = ""
    
    @State private var cosmeticsCategoryRanking: [SearchCategory] = [/*SearchCategory(category: "マスカラ", icon: Image(systemName: "pencil"), products: [cosmetic(companyID: "The Ordinary"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Ordinary"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido") ]), SearchCategory(category: "アイブロウ", icon: Image(systemName: "eye.fill"), products: [cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido")]), SearchCategory(category: "アイライナー", icon: Image(systemName: "pencil.tip"), products: [cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido")])*/]
    
    //SearchOutput
    
    @State private var SearchOutputShow: Bool = false
    
    @State private var selectedTab: Int = 0
    
    let tabs: [Tab] = [
        .init(title: "トップ"),
        .init(title: "商品"),
        .init(title: "アカウント"),
    ]
    

    init(){//cosmeticsCategoryRanking: [SearchCategory]) {
        //_cosmeticsCategoryRanking = State(initialValue: cosmeticsCategoryRanking)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(.white)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    // Barcode Scanner
    @State private var isShowingScanner = false
    @State private var scannedCode: String = ""
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                VStack{
                    
                    
                    
                    HStack{
                        
                        Button(action: {
                            
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            
                            Image(systemName: "chevron.backward")
                                .font(Font.system(size: 25).weight(.bold))
                                .foregroundColor(colorScheme == .dark ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 128/255, green: 155/255, blue: 206/255))
                                .padding(.leading)
                            
                        })
                        
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
                            .cornerRadius(7)
                            
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

                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Image(systemName: "barcode.viewfinder")
                                .foregroundColor(colorScheme == .dark ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 128/255, green: 155/255, blue: 206/255))
                                .font(.largeTitle)
                                .padding(.trailing, 15)
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
                                    
                                    ScanOverlayView()
                                    
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
                    
                    Spacer()
                        
                    VStack {
                        
                        if(SearchOutputShow){
                            
                                
                            VStack(spacing: 0) {
                                Tabs(tabs: tabs, geoWidth: UIScreen.main.bounds.width, selectedTab: $selectedTab)
                                    .padding(.horizontal, 50)
                                    .fontWeight(.bold)
                                    .foregroundColor(colorScheme == .dark ? Color(red: 0.552, green: 0.724, blue: 0.831) : Color(red: 128/255, green: 155/255, blue: 206/255))
                                    .background(.clear)
                                    .ignoresSafeArea()

                                TabView(selection: $selectedTab) {
                                    SearchResultViews.TopView()
                                        .tag(0)
                                    SearchResultViews.ProductView()
                                        .tag(1)
                                    SearchResultViews.AccountView()
                                        .tag(2)
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            }
                            .ignoresSafeArea()

                            
                        } else {
                            
                            
                            ScrollView {
                                ForEach(Array(cosmeticsCategoryRanking.enumerated()), id: \.1.id) { index, category in
                                    let colors: [Color] = [
                                        Color(red: 0.723, green: 0.88, blue: 0.825),
                                        Color(red: 0.552, green: 0.724, blue: 0.831),
                                        Color(red: 0.946, green: 0.76, blue: 0.839)
                                    ]
                                    let colorIndex = index % colors.count
                                    
                                    
                                    
                                    NavigationLink(destination:
                                        IndividualCategoryRanking(categoryRanking: category)
                                    ) {
                                        SearchCategoryListIndividual(category: category)
                                            .foregroundColor(colors[colorIndex])
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.top)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct SearchCategoryListIndividual: View {
    
    @State var category: SearchCategory
    
    var body: some View {
        
        ZStack{
            
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 80)
            
            VStack{
                HStack{
                    category.icon
                        .font(.title)
                    Text(category.category)
                        .font(.title3)
                    
                    Spacer()
                }
                .fontWeight(.bold)
                
                
                HStack {
                    if !$category.products.isEmpty {
                        Text("1. \(category.products[0].companyID)")
                        
                        if category.products.count >= 2 {
                            Text("2. \(category.products[1].companyID)")
                        }
                    }
                    
                    Spacer()
                    
                    //Image(systemName: "ellipsis")
                }
                
            }
            .padding(.horizontal)
            .foregroundColor(.white)
            .fontWeight(.bold)
        }
    }
}



struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        
        return Search()
    }
}

//struct IndividualCategoryRanking_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        
//        let category1 = SearchCategory(category: "マスカラ", icon: Image(systemName: "pencil"), products: [cosmetic(companyID: "The Ordinary"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Ordinary"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido"), cosmetic(companyID: "The Flavour Design"), cosmetic(companyID: "Shiseido") ])
//        
//        IndividualCategoryRanking(categoryRanking: category1)
//    }
//}




struct IndividualCategoryRanking: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @State var categoryRanking: SearchCategory
    
    var body: some View {
        
        VStack {
            
            HStack{
                
                Button(action: {
                    
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    
                    Image(systemName: "chevron.backward")
                        .font(Font.system(size: 25).weight(.bold))
                        .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
                    
                })
                
                Text(categoryRanking.category)
                
                categoryRanking.icon
                
                Spacer()
            }
            .foregroundColor(Color(red: 0.552, green: 0.724, blue: 0.831))
            .font(.title)
            .fontWeight(.bold)
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
            
            
            
            VStack{
                
                List {
                    
                    HStack{
                        Text("トレンド")
                        
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .font(.title2)
                    .fontWeight(.bold)
                    .listRowSeparator(.hidden)
                    
                    
                    VStack{
                        
                        HStack {
                            // Display the second product
                            if $categoryRanking.products.indices.contains(1) {
                                IndividualCategoryIndividualTopView(product: categoryRanking.products[1], index: 1)
                                    .listRowSeparator(.hidden)
                            }
                            
                            // Display the first product
                            if !categoryRanking.products.isEmpty {
                                
                                VStack{
                                        
                                    IndividualCategoryIndividualTopView(product: categoryRanking.products[0], index: 0)
                                        .listRowSeparator(.hidden)
                                    
                                    Spacer()
                                        .padding(.vertical)
                                }
                            }
                            
                            // Display the third product
                            if categoryRanking.products.indices.contains(2) {
                                IndividualCategoryIndividualTopView(product: categoryRanking.products[2], index: 2)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        
                        
                        // Make the rest of the products as a list view
                        ForEach(Array(categoryRanking.products.enumerated()), id: \.1.id) { index, product in
                            if index >= 3 {
                                IndividualCategoryIndividualListView(product: product, index: index)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        
                        Spacer()
                            .listRowSeparator(.hidden)
                        
                    }
                    .padding(.top)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
                    
                    
                    Spacer()
                        .listRowSeparator(.hidden)
                    
                    
                    ForEach(0..<10) { rowIndex in
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
                }
                .listStyle(.inset)
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
    }
}

struct IndividualCategoryIndividualListView: View {
    
    @State var product: Cosmetic
    var index: Int = 0
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 50)
                .foregroundColor(Color(.systemBackground))
                .shadow(radius: 4)
            
            HStack {
                Text("\(index + 1)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.label))
                
                VStack(alignment: .leading) {
                    Text(product.productName)
                        .foregroundColor(Color(.label))
                    
                    Text(product.companyID)
                        .foregroundColor(Color(.secondaryLabel))
                    
                }
                .padding(.leading, 10)
                .fontWeight(.bold)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            
        }
    }
}

struct IndividualCategoryIndividualTopView: View {
    
    @State var product: Cosmetic
    var index: Int = 0
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(red: 0.863, green: 0.903, blue: 0.928))
                .shadow(radius: 4)
            
            
            VStack{
                
                Text("\(index + 1)")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let productImage = product.productImage {
                    Image(uiImage: productImage)
                        .resizable()
                        .font(.title)
                        .scaledToFit()
                        .frame(width:UIScreen.main.bounds.width*0.12, height:UIScreen.main.bounds.width*0.12)
                        .cornerRadius(20)
                } else {
                    Image(systemName: "cross.vial")
                        .resizable()
                        .font(.title)
                        .scaledToFit()
                        .frame(width:UIScreen.main.bounds.width*0.12, height:UIScreen.main.bounds.width*0.12)
                        .cornerRadius(20)
                }
                
                VStack{
                    Text(product.companyID)
                    Text(product.productName)
                }
                .padding(.horizontal, 2)
                .font(.caption2)
                
            }
            .foregroundColor(Color.black)
            .padding(.vertical, 5)
            
        }
        .frame(width: UIScreen.main.bounds.width*0.27, height: UIScreen.main.bounds.height*0.165)
    }
}


class SearchResultViews {
    
    struct TopView: View {
        
        let cosmetics = [
            Cosmetic(productName: "Product 1", companyID: "Company A", price: "1999", amount: "30 ml"),
            Cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml"),
            Cosmetic(productName: "Product 4", companyID: "Company B", price: "12999", amount: "50 ml")
            ]
        
        var body: some View {
            
            List {
                
                ForEach(cosmetics) { cosmetic in
                    IndividualCosmeticsTagView(cosmetic: cosmetic)
                        .listRowSeparator(.hidden)
                        .padding(.bottom)
                }
                .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
                .listRowSeparator(.hidden)
                
                ForEach(0..<10) { rowIndex in
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
            }
            .listStyle(.inset)
        }
    }
    
    struct ProductView: View {
        
        let cosmetics = [
            Cosmetic(productName: "Product 1", companyID: "Company A", price: "1999", amount: "30 ml"),
            Cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml"),
            Cosmetic(productName: "Product 4", companyID: "Company B", price: "12999", amount: "50 ml"),
            Cosmetic(productName: "Product 1", companyID: "Company A", price: "1999", amount: "30 ml"),
            Cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml"),
            Cosmetic(productName: "Product 4", companyID: "Company B", price: "12999", amount: "50 ml"),
            Cosmetic(productName: "Product 1", companyID: "Company A", price: "1999", amount: "30 ml"),
            Cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml"),
            Cosmetic(productName: "Product 4", companyID: "Company B", price: "12999", amount: "50 ml"),
            Cosmetic(productName: "Product 1", companyID: "Company A", price: "1999", amount: "30 ml"),
            Cosmetic(productName: "Product 2", companyID: "Company B", price: "2999", amount: "50 ml"),
            Cosmetic(productName: "Product 4", companyID: "Company B", price: "12999", amount: "50 ml"),
            // Add more test makeup products here
        ]
        
        var body: some View {
            
            List {
                ForEach(cosmetics) { cosmetic in
                    IndividualCosmeticsTagView(cosmetic: cosmetic)
                        .listRowSeparator(.hidden)
                        .padding(.bottom)
                }
                .listRowInsets(.init(top: 15, leading: 0, bottom: 15, trailing: 0))
                .listRowSeparator(.hidden)
            }
            .listStyle(.inset)
        }
    }
    
    struct AccountView: View {
        
        @State var searchUsers: [UserProfileQL] = []
        
        var body: some View {
            
            ZStack {
                
                ScrollView(showsIndicators: false) {
                    ScrollViewReader { scrollView in
                        
                        ForEach(searchUsers.indices, id: \.self) { index in
                            IndividualLikeView(like: $searchUsers[index])
                                .id("FirstLikeView")
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
            }
        }
    }
}

*/
