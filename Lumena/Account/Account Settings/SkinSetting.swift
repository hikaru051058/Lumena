//
//  SkinSetting.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/07/13.
//

import SwiftUI
import Amplify

struct SkinSettingsAttributes {
    var sensitivity: SensitivityOptions
    var uv: UVOptions
    var skinType: SkinTypeOptions
    var personalColor: PersonalColorOptions
    var eyeColor: String
    var skinColor: String
    var concerns: ConcernsOptions

    init(from dictionary: [SkinSettingsType: String] = [:]) {
        self.sensitivity = SensitivityOptions(rawValue: dictionary[.sensitivity] ?? "") ?? .notSensitive
        self.uv = UVOptions(rawValue: dictionary[.uv] ?? "") ?? .lessThan1Hour
        self.skinType = SkinTypeOptions(rawValue: dictionary[.skinType] ?? "") ?? .normal
        self.personalColor = PersonalColorOptions(rawValue: dictionary[.personalColor] ?? "") ?? .lightSpring
        self.eyeColor = UIColor.color(from: dictionary[.eyeColor]).toHexString() // Default to clear color if not provided
        self.skinColor = UIColor.color(from: dictionary[.skinColor]).toHexString() // Default to clear color if not provided
        self.concerns = ConcernsOptions(rawValue: dictionary[.concerns] ?? "") ?? .drySkin
    }

    func toDictionary() -> [SkinSettingsType: String] {
        return [
            .sensitivity: sensitivity.rawValue,
            .uv: uv.rawValue,
            .skinType: skinType.rawValue,
            .personalColor: personalColor.rawValue,
            .eyeColor: eyeColor,
            .skinColor: skinColor,
            .concerns: concerns.rawValue
        ]
    }

    // Initialize from UserProfileQL
    init(from skinSettingsAttributesQL: SkinSettingsAttributesQL) {
        self.sensitivity = SensitivityOptions.fromGraphQL(skinSettingsAttributesQL.skinSensitivity ?? .notSensitive)
        self.uv = UVOptions.fromGraphQLINT(Int(skinSettingsAttributesQL.skinUVBathing ?? "1") ?? 1) ?? .lessThan1Hour
        self.skinType =  SkinTypeOptions.fromGraphQL(skinSettingsAttributesQL.skinType ?? .oily)
        self.personalColor = PersonalColorOptions.fromGraphQL(skinSettingsAttributesQL.skinPersonalColor ?? .brightSpring)
        self.eyeColor = skinSettingsAttributesQL.skinEyeColor ?? "#00000000"
        self.skinColor = skinSettingsAttributesQL.skinColor ?? "#00000000" // Default to white color if not provided
        self.concerns = ConcernsOptions.fromGraphQL(skinSettingsAttributesQL.skinConcerns ?? .drySkin)
    }

    // Convert to UserProfileQL
    func toUserProfileQLDictionary() -> SkinSettingsAttributesQL {
        return SkinSettingsAttributesQL(
            skinSensitivity: self.sensitivity.toGraphQL(),
            skinUVBathing: String(self.uv.toGraphQLINT()),
            skinType: self.skinType.toGraphQL(),
            skinPersonalColor: self.personalColor.toGraphQL(),
            skinEyeColor: self.eyeColor,
            skinColor: self.skinColor,
            skinConcerns: self.concerns.toGraphQL()
        )
    }
}

enum SkinSettingsType: String, CaseIterable {
    case sensitivity
    case uv
    case skinType
    case personalColor
    case eyeColor
    case skinColor
    case concerns

    var settings: SkinSettingsTextStruct {
        switch self {
        case .sensitivity:
            return SkinSettingsType.sensitivitySettings
        case .uv:
            return SkinSettingsType.uvSettings
        case .skinType:
            return SkinSettingsType.skinTypeSettings
        case .personalColor:
            return SkinSettingsType.personalColorSettings
        case .eyeColor:
            return SkinSettingsType.eyeColorSettings
        case .skinColor:
            return SkinSettingsType.skinColorSettings
        case .concerns:
            return SkinSettingsType.concernsSettings
        }
    }
}

private extension SkinSettingsType {
    static var sensitivitySettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "肌の感度",
            subTitle: "肌が様々な要因にどれだけ敏感であるか",
            options: SensitivityOptions.allCases.map { $0.rawValue },
            selected: ""
        )
    }

    static var uvSettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "日光",
            subTitle: "一日に日光を浴びる時間",
            options: UVOptions.allCases.map { $0.rawValue },
            selected: ""
        )
    }

    static var skinTypeSettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "肌種類",
            subTitle: "油分や乾燥に基づく肌の種類",
            options: SkinTypeOptions.allCases.map { $0.rawValue },
            selected: ""
        )
    }

    static var personalColorSettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "パーソナルカラー",
            subTitle: "あなたの自然な色合いに最も合うカラーパレット",
            options: PersonalColorOptions.allCases.map { $0.rawValue },
            selected: ""
        )
    }

    static var eyeColorSettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "目の色",
            subTitle: "あなたの自然な目の色",
            options: [],
            selected: ""
        )
    }

    static var skinColorSettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "肌色",
            subTitle: "あなたの自然な肌の色",
            options: [],
            selected: ""
        )
    }

    static var concernsSettings: SkinSettingsTextStruct {
        return SkinSettingsTextStruct(
            title: "肌の悩み",
            subTitle: "肌に関する悩みや状態",
            options: ConcernsOptions.allCases.map { $0.rawValue },
            selected: ""
        )
    }
}

enum SensitivityOptions: String, CaseIterable {
    case extremelySensitive = "ものすごく敏感"
    case verySensitive = "すごく敏感"
    case sensitive = "敏感"
    case slightlySensitive = "少々敏感"
    case notSensitive = "敏感ではない"

    func toGraphQL() -> SkinSensitivity {
        switch self {
        case .extremelySensitive: return SkinSensitivity.extremelySensitive
        case .verySensitive: return SkinSensitivity.verySensitive
        case .sensitive: return SkinSensitivity.sensitive
        case .slightlySensitive: return SkinSensitivity.slightlySensitive
        case .notSensitive: return SkinSensitivity.notSensitive
        }
    }

    static func fromGraphQL(_ value: SkinSensitivity) -> SensitivityOptions {
        switch value {
        case SkinSensitivity.extremelySensitive: return .extremelySensitive
        case SkinSensitivity.verySensitive: return .verySensitive
        case SkinSensitivity.sensitive: return .sensitive
        case SkinSensitivity.slightlySensitive: return .slightlySensitive
        case SkinSensitivity.notSensitive: return .notSensitive
        }
    }
}

enum UVOptions: String, CaseIterable {
    case moreThan7Hours = "7時間以上"
    case fiveTo6Hours = "5-6時間"
    case twoTo4Hours = "2-4時間"
    case oneTo2Hours = "1-2時間"
    case lessThan1Hour = "１時間以下"
    
    func toGraphQLINT() -> Int {
        switch self {
        case .moreThan7Hours: return 7
        case .fiveTo6Hours: return 6
        case .twoTo4Hours: return 4
        case .oneTo2Hours: return 2
        case .lessThan1Hour: return 1
        }
    }

    static func fromGraphQLINT(_ value: Int) -> UVOptions? {
        switch value {
        case 7: return .moreThan7Hours
        case 6: return .fiveTo6Hours
        case 4: return .twoTo4Hours
        case 2: return .oneTo2Hours
        case 1: return .lessThan1Hour
        default: return nil
        }
    }
}

enum SkinTypeOptions: String, CaseIterable {
    case oily = "脂性肌"
    case combination = "混合肌"
    case normal = "普通"
    case sensitive = "敏感肌"
    case dry = "乾燥肌"

    func toGraphQL() -> SkinType {
        switch self {
        case .oily: return .oily
        case .combination: return .combination
        case .normal: return .normal
        case .sensitive: return .sensitive
        case .dry: return .dry
        }
    }

    static func fromGraphQL(_ value: SkinType) -> SkinTypeOptions {
        switch value {
        case .oily: return .oily
        case .combination: return .combination
        case .normal: return .normal
        case .sensitive: return .sensitive
        case .dry: return .dry
        }
    }
}

enum SkinEyeColor: String, EnumPersistable {
    case hazel = "HAZEL"
    case red = "RED"
    case amber = "AMBER"
    case blue = "BLUE"
    case brown = "BROWN"
    case black = "BLACK"
    case gray = "GRAY"
    case green = "GREEN"
    case violet = "VIOLET"  // New color added
    
    func toColor() -> UIColor {
        switch self {
        case .hazel: return UIColor(red: 218/255, green: 112/255, blue: 214/255, alpha: 1) // Hazel color
        case .red: return UIColor.red
        case .amber: return UIColor.orange
        case .blue: return UIColor.blue
        case .brown: return UIColor.brown
        case .gray: return UIColor.gray
        case .green: return UIColor.green
        case .black: return UIColor.black
        case .violet: return UIColor.purple // Violet color
        }
    }
}

enum PersonalColorOptions: String, CaseIterable {
    case lightSummer = "ライトサマー"
    case coolSummer = "クールサマー"
    case softSummer = "ソフトサマー"
    case softAutumn = "ソフトオータム"
    case darkAutumn = "ダークオータム"
    case darkWinter = "ダークウィンター"
    case coolWinter = "クールウィンター"
    case brightWinter = "ブライトウィンター"
    case brightSpring = "ブライトスプリング"
    case warmSpring = "ウォームスプリング"
    case lightSpring = "ライトスプリング"

    func toGraphQL() -> SkinPersonalColor {
        switch self {
        case .lightSummer: return .lightSummer
        case .coolSummer: return .coolSummer
        case .softSummer: return .softSummer
        case .softAutumn: return .softAutumn
        case .darkAutumn: return .darkAutumn
        case .darkWinter: return .darkWinter
        case .coolWinter: return .coolWinter
        case .brightWinter: return .brightWinter
        case .brightSpring: return .brightSpring
        case .warmSpring: return .warmSpring
        case .lightSpring: return .lightSpring
        }
    }

    static func fromGraphQL(_ value: SkinPersonalColor) -> PersonalColorOptions {
        switch value {
        case .lightSummer: return .lightSummer
        case .coolSummer: return .coolSummer
        case .softSummer: return .softSummer
        case .softAutumn: return .softAutumn
        case .darkAutumn: return .darkAutumn
        case .darkWinter: return .darkWinter
        case .coolWinter: return .coolWinter
        case .brightWinter: return .brightWinter
        case .brightSpring: return .brightSpring
        case .warmSpring: return .warmSpring
        case .lightSpring: return .lightSpring
        }
    }
}

enum ConcernsOptions: String, CaseIterable {
    case acne = "にきび"
    case psoriasis = "乾癬"
    case drySkin = "乾燥肌"
    case pigmentation = "色素沈着"
    case dermatitis = "皮膚炎"

    func toGraphQL() -> SkinConcerns {
        switch self {
        case .acne: return .acne
        case .psoriasis: return .psoriasis
        case .drySkin: return .drySkin
        case .pigmentation: return .pigmentation
        case .dermatitis: return .dermatitis
        }
    }

    static func fromGraphQL(_ value: SkinConcerns) -> ConcernsOptions {
        switch value {
        case .acne: return .acne
        case .psoriasis: return .psoriasis
        case .drySkin: return .drySkin
        case .pigmentation: return .pigmentation
        case .dermatitis: return .dermatitis
        }
    }
}

struct SkinSettingsTextStruct {
    var title: String
    var subTitle: String
    var options: [String]
    var selected: String
}

struct SkinSetting: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedOption: SkinSettingsType = .sensitivity
    @State private var barLength: Double = 0.0
    
    @State var profile: ProfileSettings
    @State var skinSetting: SkinSettingsAttributes?

    @State var MainOrSetting: Bool = false // false = jump to main view , true = setting
    @State private var ignoreOnChange: Bool = true
    
    @State private var doneEditing: Bool = false
    @State private var showCheckButton: Bool = false
    
    @State private var fingerSkinPosition: CGPoint = .zero
    @State private var selectedSkinColor: UIColor = .clear
    @State private var initialSelectedSkinColor: UIColor = .clear
    
    @State private var fingerEyePosition: CGPoint = .zero
    @State private var selectedEyeColor: UIColor = .clear
    @State private var initialSelectedEyeColor: UIColor = .clear
    
    @State private var topLeftColor = SkinEyeColor.black.toColor()
    @State private var topCenterColor = SkinEyeColor.brown.toColor()
    @State private var topRightColor = SkinEyeColor.blue.toColor()

    @State private var middleLeftColor = SkinEyeColor.amber.toColor()
    @State private var middleCenterColor = SkinEyeColor.violet.toColor()
    @State private var middleRightColor = SkinEyeColor.green.toColor()

    @State private var bottomLeftColor = SkinEyeColor.red.toColor()
    @State private var bottomCenterColor = SkinEyeColor.gray.toColor()
    @State private var bottomRightColor = SkinEyeColor.hazel.toColor()

    var onNavigate: () -> Void
    
    var body: some View {
        
        ZStack {
            
            Group {
                
                VStack(spacing: -0.8) {
                    LinearGradient(
                        gradient: Gradient(colors: [selectedOption == .eyeColor ? Color(selectedEyeColor).opacity(1.0) : Color(selectedSkinColor).opacity(1.0), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                    .padding(.top, 200)
                    
                    Rectangle()
                        .foregroundColor(selectedOption == .eyeColor ? Color(selectedEyeColor).opacity(1.0) : Color(selectedSkinColor).opacity(1.0))
                        .frame(width: UIScreen.main.bounds.width, height: 50)
                }
                .edgesIgnoringSafeArea(.bottom)
                .opacity((selectedOption == .skinColor || selectedOption == .eyeColor) ? 1 : 0)
                
            }
            
            VStack {
                HStack {
                    Button(action: {
                        dismissSetting()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(Font.system(size: 25).weight(.bold))
                            .foregroundColor(Color(UIColor.arinMatGreen))
                            .padding(.leading)
                    })
                    
                    Text("ペルソナ設定")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(UIColor.arinMatGreen))
                        .padding(.leading)
                    
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(Color(UIColor.arinMatGreen))
                    
                    Spacer()
                    Spacer()
                }
                .padding(.top)
                .padding(.bottom, 5)
                
                Spacer()
            }
            
            VStack {
                
                HStack {
                    Text(NSLocalizedString(selectedOption.settings.title, comment: ""))
                        .font(.title)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color(UIColor.arinMatGreen))
                .padding(.horizontal, 50)
                
                Text(NSLocalizedString(selectedOption.settings.subTitle, comment: ""))
                    .foregroundColor(Color(UIColor.arinMatGreen))
                    .multilineTextAlignment(.center)
                    .fontWeight(.bold)
                    .font(.footnote)
                    .padding(.horizontal, 50)
                
                Spacer()
            }
            .padding(.top, 70)
            
            VStack{
                
                if selectedOption == .skinColor {
                    ColorSelectorContainerViewControllerWrapper(position: $fingerSkinPosition, selectedColor: $selectedSkinColor)
                        .frame(width: 300, height: 300)
                        .opacity(selectedOption == .skinColor ? 1 : 0)
                    
                } else if selectedOption == .eyeColor {
                    
                    ColorSelectorContainerViewControllerWrapper(
                        position: $fingerEyePosition,
                        selectedColor: $selectedEyeColor
                        ,topLeftColor: topLeftColor,
                        topRightColor: topRightColor,
                        bottomLeftColor: bottomLeftColor,
                        bottomRightColor: bottomRightColor,
                        topCenterColor: topCenterColor,
                        middleLeftColor: middleLeftColor,
                        middleRightColor: middleRightColor,
                        bottomCenterColor: bottomCenterColor
                    )
                    .frame(width: 300, height: 300)
                    .opacity(selectedOption == .eyeColor ? 1 : 0)
                    
                } else {
                    
                    Spacer()
                    
                    ScrollView {
                        VStack {
                            ForEach(selectedOption.settings.options.indices, id: \.self) { index in
                                CustomButtonView(label: selectedOption.settings.options[index], index: index, selection: binding(for: selectedOption))
                            }
                        }
                    }
                    .padding(.top, 140)
                }
            }
            .onChange(of: binding(for: selectedOption).wrappedValue) { newValue in
                if ignoreOnChange || MainOrSetting {
                    
                    if selectedOption == .concerns {
                        doneEditing = newValue != ""
                    }
                    
                    ignoreOnChange = false // Reset the flag
                    showCheckButton = true
                    return // Skip the onChange functionality if navigating back
                }

                if let value = newValue, selectedOption != .skinColor, selectedOption != .eyeColor {
                    Task {
                        do {
                            let message = try await AuthenticationManager.shared.updateUserAttributes(attributeName: .custom(selectedOption.rawValue), value: "\(value)")
                            print(message)
                        } catch {
                            print("Error: \(error)")
                        }
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            if selectedOption != .concerns {
                                ignoreOnChange = true // Set the flag to ignore the next onChange
                                selectedOption = nextOption(after: selectedOption)
                            } else {
                                doneEditing = value != ""
                            }
                        }
                    }
                    updateSkinSetting()
                } else {
                    showCheckButton = true
                    updateSkinSetting()
                }
            }
            
            VStack {
                Spacer()
                
                
                HStack {
                    
                    Button(action: {
                        withAnimation {
                            ignoreOnChange = true
                            selectedOption = previousOption(before: selectedOption)
                        }
                        updateSkinSetting()
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(20)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "arrowshape.left.fill")
                            }
                            .foregroundColor(Color(UIColor.background))
                        }
                    }
                    .padding(.trailing, 40)
                    .opacity(canNavigateBack() ? 1 : 0) // Enable or disable back button based on previous input
                    
                    if selectedOption == .skinColor || selectedOption == .eyeColor {
                        Button(action: {
                            ignoreOnChange = true
                            showCheckButton = false
                            
                            if selectedOption == .skinColor {
                                skinSetting?.skinColor = selectedSkinColor.toHexString()
                            } else if selectedOption == .eyeColor {
                                skinSetting?.eyeColor = selectedEyeColor.toHexString()
                            }

                            // Move to the next screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    selectedOption = nextOption(after: selectedOption)
                                }
                            }
                            updateSkinSetting()
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(20)
                                    .foregroundColor(.primary)

                                HStack {
                                    Image(systemName: "checkmark")
                                }
                                .foregroundColor(Color(UIColor.background))
                            }
                        }
                        .frame(width: 100, height: 50)
                        .opacity(showCheckButton ? 1 : 0)
                        
                    } else {
                        Button(action: MainOrSetting ? {
                            dismissSetting()
                        } : onNavigate) {
                            ZStack {
                                Rectangle()
                                    .frame(width: 100, height: 50)
                                    .cornerRadius(20)
                                    .foregroundColor(Color(.primary))
                                
                                HStack {
                                    Text("完了")
                                        .fontWeight(.bold)
                                        .font(.body)
                                    
                                    Image(systemName: "checkmark")
                                }
                                .foregroundColor(Color(.background))
                            }
                        }
                        .opacity((doneEditing && (selectedOption == .concerns)) ? 1 : 0)
                    }
                    
                    Button(action: {
                        
                        ignoreOnChange = true
                        showCheckButton = false
                        
                        if selectedOption == .skinColor {
                            skinSetting?.skinColor = selectedSkinColor.toHexString()
                        } else if selectedOption == .eyeColor {
                            skinSetting?.eyeColor = selectedEyeColor.toHexString()
                        }
                        
                        if selectedOption != .concerns {
                            // Move to the next screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    selectedOption = nextOption(after: selectedOption)
                                }
                            }
                            updateSkinSetting()
                        } else {
                            doneEditing = skinSetting?.concerns != nil
                            updateSkinSetting()
                        }
                    }) {
                        ZStack {
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .cornerRadius(20)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Image(systemName: "arrowshape.right.fill")
                            }
                            .foregroundColor(Color(UIColor.background))
                        }
                    }
                    .padding(.leading, 40)
                    .opacity(canNavigateForward() ? 1 : 0) // Enable or disable next button based on current input
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            self.profile = ProfileManager.shared.getProfile(withID: self.profile.identityID)
            guard let skinSetting = profile.skinSetting else { return }
            self.skinSetting = skinSetting
            if let color = UIColor(hex: skinSetting.skinColor) {
                self.selectedSkinColor = color
                self.initialSelectedSkinColor = color
            }
            if let color = UIColor(hex: skinSetting.eyeColor) {
                self.selectedEyeColor = color
                self.initialSelectedEyeColor = color
            }
        }
        .navigationBarHidden(true)
    }
    
    func binding(for option: SkinSettingsType) -> Binding<String?> {
        switch option {
        case .sensitivity:
            return Binding<String?>(
                get: { self.skinSetting?.sensitivity.rawValue },
                set: { self.skinSetting?.sensitivity = SensitivityOptions(rawValue: $0 ?? "") ?? .notSensitive }
            )
        case .uv:
            return Binding<String?>(
                get: { self.skinSetting?.uv.rawValue },
                set: { self.skinSetting?.uv = UVOptions(rawValue: $0 ?? "") ?? .lessThan1Hour }
            )
        case .skinType:
            return Binding<String?>(
                get: { self.skinSetting?.skinType.rawValue },
                set: { self.skinSetting?.skinType = SkinTypeOptions(rawValue: $0 ?? "") ?? .normal }
            )
        case .personalColor:
            return Binding<String?>(
                get: { self.skinSetting?.personalColor.rawValue },
                set: { self.skinSetting?.personalColor = PersonalColorOptions(rawValue: $0 ?? "") ?? .lightSpring }
            )
        case .eyeColor:
            return Binding<String?>(
                get: { self.skinSetting?.eyeColor },
                set: { self.skinSetting?.eyeColor = $0 ?? "#00000000" }
            )
        case .skinColor:
            return Binding<String?>(
                get: { self.skinSetting?.skinColor },
                set: { self.skinSetting?.skinColor = $0 ?? "#00000000" }
            )
        case .concerns:
            return Binding<String?>(
                get: { self.skinSetting?.concerns.rawValue },
                set: { self.skinSetting?.concerns = ConcernsOptions(rawValue: $0 ?? "") ?? .drySkin }
            )
        }
    }
    
    // Helper functions to check if navigation is allowed
    func canNavigateBack() -> Bool {
        switch selectedOption {
        case .sensitivity:
            return false // No previous option for sensitivity
        case .uv:
            return skinSetting?.sensitivity != nil
        case .skinType:
            return skinSetting?.uv != nil
        case .personalColor:
            return skinSetting?.skinType != nil
        case .eyeColor:
            return skinSetting?.personalColor != nil
        case .skinColor:
            return skinSetting?.eyeColor != nil
        case .concerns:
            return skinSetting?.skinColor != nil
        }
    }

    func canNavigateForward() -> Bool {
        switch selectedOption {
        case .sensitivity:
            return skinSetting?.sensitivity != nil
        case .uv:
            return skinSetting?.uv != nil
        case .skinType:
            return skinSetting?.skinType != nil
        case .personalColor:
            return skinSetting?.personalColor != nil
        case .eyeColor:
            return skinSetting?.eyeColor != nil
        case .skinColor:
            return skinSetting?.skinColor != nil
        case .concerns:
            return false // No next option for concerns
        }
    }

    func nextOption(after option: SkinSettingsType) -> SkinSettingsType {
        let allOptions = SkinSettingsType.allCases
        if let currentIndex = allOptions.firstIndex(of: option), currentIndex < allOptions.count - 1 {
            return allOptions[currentIndex + 1]
        }
        return allOptions.first!
    }

    func previousOption(before option: SkinSettingsType) -> SkinSettingsType {
        let allOptions = SkinSettingsType.allCases
        if let currentIndex = allOptions.firstIndex(of: option), currentIndex > 0 {
            return allOptions[currentIndex - 1]
        }
        return allOptions.last!
    }
    
    func updateSkinSetting() {
        profile.skinSetting = skinSetting
        Task {
            try await GraphQL.shared.updateUserProfile(profile: profile)
            ProfileManager.shared.updateProfile(profile)
        }
    }
    
    
    func dismissSetting() {
        updateSkinSetting()
//        Task {
//            do {
//                try await profile.updateProfile()
//            } catch {
//                print(error)
//            }
//        }
        presentationMode.wrappedValue.dismiss()
    }
    
    struct CustomButtonView: View {
        var label: String
        var index: Int
        @Binding var selection: String?
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        
        var body: some View {
            Button(action: {
                generator.impactOccurred()
                selection = label
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(selection == label ? Color(UIColor.arinBlue) : Color(UIColor.arinMatGreen))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 1)
                        .frame(height: 100)
                    
                    Text(NSLocalizedString(label, comment: "SkinSetting Page Survey Options"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct SkinSetting_Previews: PreviewProvider {
    
    static var Onnavigation : () -> Void = { }
    
    static var previews: some View {
        SkinSetting(profile: ProfileSettings(id: ""), onNavigate: Onnavigation)
    }
}

import SwiftUI

struct ColorSelectorContainerViewControllerWrapper: UIViewControllerRepresentable {
    @Binding var position: CGPoint
    @Binding var selectedColor: UIColor
    
    @State var topLeftColor = UIColor(red: 242/255, green: 213/255, blue: 208/255, alpha: 1)
    @State var topRightColor = UIColor(red: 76/255, green: 44/255, blue: 39/255, alpha: 1)
    @State var bottomLeftColor = UIColor(red: 234/255, green: 216/255, blue: 201/255, alpha: 1)
    @State var bottomRightColor = UIColor(red: 67/255, green: 49/255, blue: 29/255, alpha: 1)
    @State var topCenterColor = UIColor.clear
    @State var middleLeftColor = UIColor.clear
    @State var middleRightColor = UIColor.clear
    @State var bottomCenterColor = UIColor.clear
    @State var middleCenterColor = UIColor.clear
    
    func makeUIViewController(context: Context) -> ColorSelectorContainerViewController {
        let containerViewController = ColorSelectorContainerViewController()
        containerViewController.colorSelectorViewController.onPositionChange = { newPosition in
            DispatchQueue.main.async {
                self.position = newPosition
                self.selectedColor = containerViewController.colorSelectorViewController.selectedColor
            }
        }
        containerViewController.gridViewController.topLeftColor = self.topLeftColor
        containerViewController.gridViewController.topRightColor = self.topRightColor
        containerViewController.gridViewController.bottomLeftColor = self.bottomLeftColor
        containerViewController.gridViewController.bottomRightColor = self.bottomRightColor
        containerViewController.gridViewController.topCenterColor = self.topCenterColor
        containerViewController.gridViewController.middleLeftColor = self.middleLeftColor
        containerViewController.gridViewController.middleRightColor = self.middleRightColor
        containerViewController.gridViewController.bottomCenterColor = self.bottomCenterColor
        containerViewController.gridViewController.middleCenterColor = self.middleCenterColor
        return containerViewController
    }
    
    func updateUIViewController(_ uiViewController: ColorSelectorContainerViewController, context: Context) {
        uiViewController.gridViewController.topLeftColor = self.topLeftColor
        uiViewController.gridViewController.topRightColor = self.topRightColor
        uiViewController.gridViewController.bottomLeftColor = self.bottomLeftColor
        uiViewController.gridViewController.bottomRightColor = self.bottomRightColor
        uiViewController.gridViewController.topCenterColor = self.topCenterColor
        uiViewController.gridViewController.middleLeftColor = self.middleLeftColor
        uiViewController.gridViewController.middleRightColor = self.middleRightColor
        uiViewController.gridViewController.bottomCenterColor = self.bottomCenterColor
        uiViewController.gridViewController.middleCenterColor = self.middleCenterColor
    }
    
    class Coordinator {
        var parent: ColorSelectorContainerViewControllerWrapper
        
        init(parent: ColorSelectorContainerViewControllerWrapper) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

class ColorSelectorContainerViewController: UIViewController {

    let gridViewController = ColorSelectorGridViewController()
    let colorSelectorViewController = ColorSelectorViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorSelectorViewController.gridViewController = gridViewController
        
        addChild(gridViewController)
        view.addSubview(gridViewController.view)
        gridViewController.didMove(toParent: self)
        
        addChild(colorSelectorViewController)
        view.addSubview(colorSelectorViewController.view)
        colorSelectorViewController.didMove(toParent: self)
        
        view.bringSubviewToFront(colorSelectorViewController.view)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        gridViewController.view.translatesAutoresizingMaskIntoConstraints = false
        colorSelectorViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gridViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            gridViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gridViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            colorSelectorViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorSelectorViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            colorSelectorViewController.view.widthAnchor.constraint(equalToConstant: 300),
            colorSelectorViewController.view.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

class ColorSelectorViewController: UIViewController {
    
    let trackingView = UIView()
    var onPositionChange: ((CGPoint) -> Void)?
    var gridViewController: ColorSelectorGridViewController?
    private var isDraggingWithinBounds = false
    
    var selectedColor: UIColor = .clear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackingView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        trackingView.backgroundColor = .clear
        trackingView.layer.cornerRadius = 10
        view.addSubview(trackingView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        trackingView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        trackingView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        
        if gesture.state == .began {
            isDraggingWithinBounds = trackingView.frame.contains(location)
        }
        
        if isDraggingWithinBounds {
            onPositionChange?(location)
            gridViewController?.updateCellColor(at: location, withinBounds: trackingView.frame)
            if let newColor = gridViewController?.color(at: location, withinBounds: trackingView.frame) {
                selectedColor = newColor
            }
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        isDraggingWithinBounds = trackingView.frame.contains(location)
        
        if isDraggingWithinBounds {
            onPositionChange?(location)
            gridViewController?.updateCellColor(at: location, withinBounds: trackingView.frame)
            if let newColor = gridViewController?.color(at: location, withinBounds: trackingView.frame) {
                selectedColor = newColor
            }
        }
    }
}

class ColorSelectorGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var padding: CGFloat = 2
    var selectedIndexPath: IndexPath?
    
    var selectedColor: UIColor = .clear
    var prevSelectedColor: UIColor = .clear
    
    var topLeftColor = UIColor(red: 242/255, green: 213/255, blue: 208/255, alpha: 1)
    var topRightColor = UIColor(red: 76/255, green: 44/255, blue: 39/255, alpha: 1)
    var bottomLeftColor = UIColor(red: 234/255, green: 216/255, blue: 201/255, alpha: 1)
    var bottomRightColor = UIColor(red: 67/255, green: 49/255, blue: 29/255, alpha: 1)
    var topCenterColor = UIColor.clear
    var middleLeftColor = UIColor.clear
    var middleRightColor = UIColor.clear
    var bottomCenterColor = UIColor.clear
    var middleCenterColor = UIColor.clear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = padding
        layout.minimumLineSpacing = padding
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ColorSelectorRoundedCornerCell.self, forCellWithReuseIdentifier: "RoundedCornerCell")
        
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11 * 11
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoundedCornerCell", for: indexPath) as! ColorSelectorRoundedCornerCell
        
        let column = indexPath.item % 11
        let row = indexPath.item / 11
        let fractionX = CGFloat(column) / 10.0
        let fractionY = CGFloat(row) / 10.0
        
        let topColor = interpolateColorConsideringIntermediate(from: topLeftColor, to: topRightColor, midColor: topCenterColor, fraction: fractionX)
        let bottomColor = interpolateColorConsideringIntermediate(from: bottomLeftColor, to: bottomRightColor, midColor: bottomCenterColor, fraction: fractionX)
        
        let cellColor = interpolateColorConsideringAllIntermediates(
            from: topColor,
            to: bottomColor,
            leftMidColor: middleLeftColor,
            rightMidColor: middleRightColor,
            centerMidColor: middleCenterColor,
            fractionX: fractionX,
            fractionY: fractionY
        )
        
        cell.backgroundColor = cellColor
        
        if let selectedIndexPath = selectedIndexPath {
            let distance = calculateDistance(from: selectedIndexPath, to: indexPath)
            let baseSize = calculateBaseSize()
            cell.updateAppearance(for: distance, baseSize: baseSize)
        } else {
            let baseSize = calculateBaseSize()
            cell.updateAppearance(for: 0, baseSize: baseSize)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateBaseSize()
    }
    
    func calculateBaseSize() -> CGSize {
        let numberOfColumns: CGFloat = 11
        let numberOfRows: CGFloat = 11
        
        let totalPaddingHorizontal = padding * (numberOfColumns - 1)
        let totalPaddingVertical = padding * (numberOfRows - 1)
        
        let availableWidth = collectionView.frame.size.width - totalPaddingHorizontal
        let availableHeight = collectionView.frame.size.height - totalPaddingVertical
        
        let width = availableWidth / numberOfColumns
        let height = availableHeight / numberOfRows
        
        return CGSize(width: width, height: height)
    }
    
    func updateCellColor(at point: CGPoint, withinBounds bounds: CGRect) {
        var adjustedPoint = point

        if !bounds.contains(point) {
            if point.x < bounds.minX {
                adjustedPoint.x = bounds.minX
            } else if point.x > bounds.maxX {
                adjustedPoint.x = bounds.maxX
            }

            if point.y < bounds.minY {
                adjustedPoint.y = bounds.minY
            } else if point.y > bounds.maxY {
                adjustedPoint.y = bounds.maxY
            }
        }

        guard let indexPath = collectionView.indexPathForItem(at: adjustedPoint) else { return }

        selectedIndexPath = indexPath

        for cell in collectionView.visibleCells {
            if let cellIndexPath = collectionView.indexPath(for: cell) {
                let column = cellIndexPath.item % 11
                let row = cellIndexPath.item / 11
                let fractionX = CGFloat(column) / 10.0
                let fractionY = CGFloat(row) / 10.0

                let topColor = interpolateColorConsideringIntermediate(from: topLeftColor, to: topRightColor, midColor: topCenterColor, fraction: fractionX)
                let bottomColor = interpolateColorConsideringIntermediate(from: bottomLeftColor, to: bottomRightColor, midColor: bottomCenterColor, fraction: fractionX)

                let cellColor = interpolateColorConsideringAllIntermediates(
                    from: topColor,
                    to: bottomColor,
                    leftMidColor: middleLeftColor,
                    rightMidColor: middleRightColor,
                    centerMidColor: middleCenterColor,
                    fractionX: fractionX,
                    fractionY: fractionY
                )

                cell.backgroundColor = cellColor

                let distance = calculateDistance(from: indexPath, to: cellIndexPath)
                let baseSize = calculateBaseSize()
                (cell as! ColorSelectorRoundedCornerCell).updateAppearance(for: distance, baseSize: baseSize)
            }
        }

        if let cell = collectionView.cellForItem(at: indexPath) {
            if selectedColor != cell.backgroundColor {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            UIView.animate(withDuration: 0.1, animations: { [self] in
                selectedColor = cell.backgroundColor ?? .clear
            })
        }
    }
    
    func calculateDistance(from: IndexPath, to: IndexPath) -> Int {
        let columnDifference = abs(from.item % 11 - to.item % 11)
        let rowDifference = abs(from.item / 11 - to.item / 11)
        return max(columnDifference, rowDifference)
    }
    
    func interpolateColor(from startColor: UIColor, to endColor: UIColor, fraction: CGFloat) -> UIColor {
        var startRed: CGFloat = 0
        var startGreen: CGFloat = 0
        var startBlue: CGFloat = 0
        var startAlpha: CGFloat = 0
        
        var endRed: CGFloat = 0
        var endGreen: CGFloat = 0
        var endBlue: CGFloat = 0
        var endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        let red = startRed + (endRed - startRed) * fraction
        let green = startGreen + (endGreen - startGreen) * fraction
        let blue = startBlue + (endBlue - startBlue) * fraction
        let alpha = startAlpha + (endAlpha - startAlpha) * fraction
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func interpolateColorConsideringAllIntermediates(from startColor: UIColor, to endColor: UIColor, leftMidColor: UIColor, rightMidColor: UIColor, centerMidColor: UIColor, fractionX: CGFloat, fractionY: CGFloat) -> UIColor {
        if centerMidColor != UIColor.clear {
            if fractionX < 0.5 && fractionY < 0.5 {
                let firstHalfColor = interpolateColorConsideringIntermediate(from: startColor, to: leftMidColor, midColor: centerMidColor, fraction: fractionX * 2)
                return interpolateColorConsideringIntermediate(from: firstHalfColor, to: centerMidColor, midColor: centerMidColor, fraction: fractionY * 2)
            } else if fractionX >= 0.5 && fractionY < 0.5 {
                let firstHalfColor = interpolateColorConsideringIntermediate(from: rightMidColor, to: endColor, midColor: centerMidColor, fraction: (fractionX - 0.5) * 2)
                return interpolateColorConsideringIntermediate(from: firstHalfColor, to: centerMidColor, midColor: centerMidColor, fraction: fractionY * 2)
            } else if fractionX < 0.5 && fractionY >= 0.5 {
                let firstHalfColor = interpolateColorConsideringIntermediate(from: startColor, to: leftMidColor, midColor: centerMidColor, fraction: fractionX * 2)
                return interpolateColorConsideringIntermediate(from: centerMidColor, to: firstHalfColor, midColor: centerMidColor, fraction: (fractionY - 0.5) * 2)
            } else {
                let firstHalfColor = interpolateColorConsideringIntermediate(from: rightMidColor, to: endColor, midColor: centerMidColor, fraction: (fractionX - 0.5) * 2)
                return interpolateColorConsideringIntermediate(from: centerMidColor, to: firstHalfColor, midColor: centerMidColor, fraction: (fractionY - 0.5) * 2)
            }
        } else {
            return interpolateColorConsideringIntermediate(from: startColor, to: endColor, midColor: UIColor.clear, fraction: fractionY)
        }
    }

    func interpolateColorConsideringIntermediate(from startColor: UIColor, to endColor: UIColor, midColor: UIColor, fraction: CGFloat) -> UIColor {
        if midColor != UIColor.clear {
            if fraction < 0.5 {
                return interpolateColor(from: startColor, to: midColor, fraction: fraction * 2)
            } else {
                return interpolateColor(from: midColor, to: endColor, fraction: (fraction - 0.5) * 2)
            }
        } else {
            return interpolateColor(from: startColor, to: endColor, fraction: fraction)
        }
    }

    
    func interpolateColorConsideringIntermediateWithMiddleCenter(from startColor: UIColor, to endColor: UIColor, midColor: UIColor, fractionX: CGFloat, fractionY: CGFloat) -> UIColor {
        let intermediateColor = interpolateColorConsideringIntermediate(from: startColor, to: endColor, midColor: midColor, fraction: fractionY)
        if midColor != UIColor.clear {
            if fractionY < 0.5 {
                return interpolateColorConsideringIntermediate(from: startColor, to: midColor, midColor: midColor, fraction: fractionX)
            } else {
                return interpolateColorConsideringIntermediate(from: midColor, to: endColor, midColor: midColor, fraction: fractionX)
            }
        }
        return intermediateColor
    }
    
    func color(at point: CGPoint, withinBounds bounds: CGRect) -> UIColor {
        var adjustedPoint = point

        if !bounds.contains(point) {
            if point.x < bounds.minX {
                adjustedPoint.x = bounds.minX
            } else if point.x > bounds.maxX {
                adjustedPoint.x = bounds.maxX
            }

            if point.y < bounds.minY {
                adjustedPoint.y = bounds.minY
            } else if point.y > bounds.maxY {
                adjustedPoint.y = bounds.maxY
            }
        }

        guard let indexPath = collectionView.indexPathForItem(at: adjustedPoint) else { return selectedColor }

        let column = indexPath.item % 11
        let row = indexPath.item / 11
        let fractionX = CGFloat(column) / 10.0
        let fractionY = CGFloat(row) / 10.0

        let topColor = interpolateColorConsideringIntermediate(from: topLeftColor, to: topRightColor, midColor: topCenterColor, fraction: fractionX)
        let bottomColor = interpolateColorConsideringIntermediate(from: bottomLeftColor, to: bottomRightColor, midColor: bottomCenterColor, fraction: fractionX)
        
        return interpolateColorConsideringAllIntermediates(
            from: topColor,
            to: bottomColor,
            leftMidColor: middleLeftColor,
            rightMidColor: middleRightColor,
            centerMidColor: middleCenterColor,
            fractionX: fractionX,
            fractionY: fractionY
        )
    }
}

class ColorSelectorRoundedCornerCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .blue
    }
    
    func updateAppearance(for distance: Int, baseSize: CGSize) {
        let maxDistance = 5
        let shrinkFactor: CGFloat = 0.6
        
        let shrinkage = 1 - (1 - shrinkFactor) * CGFloat(min(distance, maxDistance)) / CGFloat(maxDistance)
        let newSize = CGSize(width: baseSize.width * shrinkage, height: baseSize.height * shrinkage)
        
        frame.size = newSize
        
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if layer.cornerRadius == 0 {
            layer.cornerRadius = 7
        }
    }
}
