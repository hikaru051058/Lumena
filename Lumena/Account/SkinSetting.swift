//
//  SkinSetting.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/13.
//

import SwiftUI
import Amplify

struct SkinSetting: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedOption: String = "感度"
    @State private var barLength: Double = 0.0
    
    @State private var sensitivity: Int? = nil
    @State private var sunBathing: Int? = nil
    @State private var skinType: Int? = nil
    
    @State var skinSetting: [Int]?
    @State var MainOrSetting: Bool = false // false = jump to main view , true = setting
    
    @State private var doneEditing: Bool = false
    
    var onNavigate: () -> Void
    
    var body: some View {
        
        ZStack{
            Color(red: 0.86, green: 0.92, blue: 0.87)
                .ignoresSafeArea()
            
            
            VStack(){
                
                HStack{
                    
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                            .foregroundColor(.black)
                            .padding(.leading, 15)
                        
                    })
                    
                    Text("肌設定")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                    
                    Image(systemName: "gear")
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 0.49, green: 0.629, blue: 0.53))
                    
                    Spacer()
                }
                .padding(.vertical, 5)
                
                HStack{
                    Text ("ユーザーに適したコンテンツを設定に基づいて表示します")
                        .foregroundColor(Color(red: 0.452, green: 0.634, blue: 0.521))
                        .fontWeight(.bold)
                        .font(.footnote)
                    
                    Spacer()
                }
                .padding(.horizontal, 45)
                
                Spacer()
            }
            
            
            
            VStack{
                
                Spacer()
                
                
                Group {
                    
                    VStack {
                        
                        ZStack{
                            
                            HStack {
                                TextOptionView(text: "感度", selectedOption: $selectedOption)
                                Spacer()
                            }
                            HStack{
                                TextOptionView(text: "日光", selectedOption: $selectedOption)
                            }
                            HStack{
                                Spacer()
                                TextOptionView(text: "肌種類", selectedOption: $selectedOption)
                            }
                        }
                            
                        GeometryReader { geometry in
                            
                            ZStack {
                                Divider()
                                    .frame(minHeight: 1)
                                    .overlay(Color(red: 0.686, green: 0.817, blue: 0.724))
                                
                                HStack{
                                    Divider()
                                        .frame(width: selectedOption == "感度" ? 0.0 :
                                                selectedOption == "日光" ? geometry.size.width/2 :
                                                selectedOption == "肌種類" ? geometry.size.width-10 : 0.0
                                               , height: 3)
                                        .overlay(Color(red: 0.486, green: 0.629, blue: 0.53))
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    CircleOptionView(selectedOption: $selectedOption, option: "感度")
                                    Spacer()
                                    CircleOptionView(selectedOption: $selectedOption, option: "日光")
                                    Spacer()
                                    CircleOptionView(selectedOption: $selectedOption, option: "肌種類")
                                }
                            }
                        }
                        .frame(height: 30)
                    }
                    
                    
                    HStack{
                        Text(
                            selectedOption == "感度" ? "肌の感度" :
                            selectedOption == "日光" ? "一日に日光を浴びる時間" :
                            selectedOption == "肌種類" ? "肌質" : "肌の敏感度"
                            )
                        .font(.title3)
                        .fontWeight(.bold)
                                
                        Spacer()
                    }
                }
                .foregroundColor(Color(red: 0.486, green: 0.629, blue: 0.53))
                .padding(.horizontal, 50)
                
                Spacer()
                
                VStack{
                    if selectedOption == "感度" {
                        let sensitivityOptions = ["ものすごく敏感", "すごく敏感", "敏感", "少々敏感", "敏感ではない"]
                        ForEach(sensitivityOptions.indices, id: \.self) { index in
                            CustomButtonView(label: sensitivityOptions[index], index: index, selection: $sensitivity)
                        }
                        .onChange(of: sensitivity) { _ in
                            
                            Task {
                                do {
                                    let message = try await AuthenticationManager.shared.updateUserAttributes(attributeName: .custom("SkinSensitivity"), value: "\(sensitivity ?? 0)")
                                    print(message)
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            
                            if !MainOrSetting {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.25){
                                    withAnimation{
                                        selectedOption = "日光"
                                    }
                                }
                            }
                            updateSkinSetting()
                        }
                    } else if selectedOption == "日光" {
                        let sunBathingOptions = ["7時間以上", "5-6時間", "2-4時間", "1-2時間", "１時間以下"]
                        ForEach(sunBathingOptions.indices, id: \.self) { index in
                            CustomButtonView(label: sunBathingOptions[index], index: index, selection: $sunBathing)
                        }
                        .onChange(of: sunBathing) { _ in
                            
                            Task {
                                do {
                                    let message = try await AuthenticationManager.shared.updateUserAttributes(attributeName: .custom("SkinUVBathing"), value: "\(sunBathing ?? 0)")
                                    print(message)
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.25){
                                withAnimation{
                                    selectedOption = "肌種類"
                                }
                            }
                            updateSkinSetting()
                        }
                    } else if selectedOption == "肌種類" {
                        let skinTypeOptions = ["脂性肌", "混合肌", "乾燥肌", "敏感肌", "普通"]
                        ForEach(skinTypeOptions.indices, id: \.self) { index in
                            CustomButtonView(label: skinTypeOptions[index], index: index, selection: $skinType)
                        }
                        .onChange(of: skinType) { _ in
                            
                            Task {
                                do {
                                    let message = try await AuthenticationManager.shared.updateUserAttributes(attributeName: .custom("SkinType"), value: "\(skinType ?? 0)")
                                    print(message)
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            
                            updateSkinSetting()
                            
                            if let _ = sensitivity, let _ = sunBathing, let _ = skinType {
                                
                                withAnimation{
                                    doneEditing = true
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 100)
            
            
            VStack{
                
                Spacer()
                
                if !MainOrSetting {
                    
                    Button(action: onNavigate) {
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 100, height: 50)
                                .cornerRadius(50)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            
                            HStack{
                                Text("完了")
                                    .fontWeight(.bold)
                                    .font(.body)
                                
                                Image(systemName: "checkmark")
                                
                            }
                            .foregroundColor(Color.primary)
                        }
                    }
                } else {
                    
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                        
                    }){
                        ZStack {
                            Rectangle()
                                .frame(width: 100, height: 50)
                                .cornerRadius(50)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                            
                            HStack{
                                Text("完了")
                                    .fontWeight(.bold)
                                    .font(.body)
                                
                                Image(systemName: "checkmark")
                                
                            }
                            .foregroundColor(Color.primary)
                        }
                    }
                }
            }
            .opacity(doneEditing ? 1 : 0)
        }
        .onAppear {
            if let skinSettings = skinSetting {
                self.sensitivity = skinSettings.count > 0 ? skinSettings[0] : nil
                self.sunBathing = skinSettings.count > 1 ? skinSettings[1] : nil
                self.skinType = skinSettings.count > 2 ? skinSettings[2] : nil
            }
        }

        .navigationBarHidden(true)
    }
    
    func updateSkinSetting() {
        GI.shared.profileSettings?.skinSetting = [sensitivity, sunBathing, skinType].compactMap { $0 }
    }
    
    struct TextOptionView: View {
        let text: String
        @Binding var selectedOption: String
        
        var body: some View {
            Text(NSLocalizedString(text, comment: "SkinSetting Page status bar option"))
                .font(text == selectedOption ? .title3 : .callout)
                .fontWeight(text == selectedOption ? .bold: .regular)
                .onTapGesture {
                    withAnimation{
                        selectedOption = text
                    }
                }
        }
    }
    
    struct CircleOptionView: View {
        @Binding var selectedOption: String
        let option: String
        
        var body: some View {
            Circle()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    withAnimation{
                        selectedOption = option
                    }
                }
        }
    }
    
    struct CustomButtonView: View {
        var label: String
        var index: Int
        @Binding var selection: Int?

        var body: some View {
            Button(action: {
                selection = index
            }) {
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(selection == index ? Color(red: 0.49, green: 0.629, blue: 0.53) : .white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 1)
                    
                    Text(NSLocalizedString(label, comment: "SkinSetting Page Survey Options"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(selection == index ? .white : Color(red: 0.49, green: 0.629, blue: 0.53))
                }
            }
        }
    }
}

//struct SkinSetting_Previews: PreviewProvider {
//    static var previews: some View {
//        SkinSetting()
//    }
//}
//
