import Combine
import SwiftUI

struct AnimatedGradient: View {
    struct Model {
        init(colors: [Color]) {
            firstGradientColors = colors
        }

        var colors: [Color] {
            get {
                isFirstGradientVisible ? firstGradientColors : secondGradientColors
            }
            set {
                if isFirstGradientVisible {
                    secondGradientColors = newValue
                } else {
                    firstGradientColors = newValue
                }
                isFirstGradientVisible.toggle()
            }
        }

        fileprivate var isFirstGradientVisible = true
        fileprivate var firstGradientColors: [Color]
        fileprivate var secondGradientColors: [Color] = []
    }

    @Binding private var model: Model

    init(_ model: Binding<Model>) {
        _model = model
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: model.firstGradientColors),
                startPoint: .top,
                endPoint: .bottom
            ).opacity(model.isFirstGradientVisible ? 1 : 0)
            LinearGradient(
                gradient: Gradient(colors: model.secondGradientColors),
                startPoint: .top,
                endPoint: .bottom
            ).opacity(model.isFirstGradientVisible ? 0 : 1)
        }
    }
}

struct VisualEffect: UIViewRepresentable {
    
    var effect: UIVisualEffect?
    let effectView = UIVisualEffectView(effect: nil)

    func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        effectView.effect = effect
        return effectView
    }

    func updateUIView(_: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) {}
}

struct GradientEffectView: View {
    private struct Blot: Identifiable {
        let id = UUID()
        let sizeModifier: CGSize
        let scale: CGFloat
        let rotation: Angle
        let offset: CGPoint
        let saturation: Double

        static var random: Blot {
            Blot(
                sizeModifier: CGSize(width: .random(in: 100 ... 300), height: .random(in: 100 ... 300)),
                scale: .random(in: 1 ... 2.5),
                rotation: .degrees(.random(in: 0 ... 360)),
                offset: CGPoint(x: .random(in: -300 ... 300), y: .random(in: -300 ... 300)),
                saturation: .random(in: 0.4 ... 2.0)
            )
        }
    }
    
    let timeUpdate = 5.0

    @State private var backgroundAngle: Angle = .zero
    @State private var blots: [Blot] = (0 ..< 5).map { _ in .random }
    @Binding private var model: AnimatedGradient.Model
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init(_ model: Binding<AnimatedGradient.Model>) {
        _model = model
        timer = Timer.publish(every: timeUpdate, on: .main, in: .common).autoconnect()
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background(geometry)
                blot(withParams: blots[0], geometry)
                blot(withParams: blots[1], geometry)
                blot(withParams: blots[2], geometry)
                blot(withParams: blots[3], geometry)
                blot(withParams: blots[4], geometry)
                
                //VisualEffect(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                VisualEffect(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                update()
            }
            .onReceive(timer) { _ in
                update()
            }
            .onChange(of: model.isFirstGradientVisible) { _ in
                update()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
    }

    private func update() {
        
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: timeUpdate).speed(0.3)) {
                backgroundAngle = .degrees(.random(in: 0 ... 360))
                blots = (0 ..< blots.count).map { _ in .random }
            }
        }
    }

    private func background(_ geometry: GeometryProxy) -> some View {
        let size = hypot(geometry.size.width, geometry.size.height)
        return AnimatedGradient($model)
            .rotationEffect(backgroundAngle, anchor: .center)
            .frame(width: size, height: size)
    }

    private func blot(withParams blot: Blot, _ geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        
        return AnimatedGradient($model)
            .clipShape(Capsule())
            .frame(
                width: size + blot.sizeModifier.width,
                height: size + blot.sizeModifier.height
            )
            .scaleEffect(blot.scale)
            .opacity(0.1)
            .rotationEffect(blot.rotation, anchor: .center)
            .offset(x: blot.offset.x, y: blot.offset.y)
            .blendMode(.lighten)
            .saturation(blot.saturation)
            .contrast(1)
            .foregroundColor(.clear)
    }

}

struct GradientEffectView_Previews: PreviewProvider {
    static var previews: some View {
        GradientEffectView(
            .constant(
                AnimatedGradient.Model(
                    colors: [
                         Color(red: 0.723, green: 0.88, blue: 0.825),
                         Color(red: 0.552, green: 0.724, blue: 0.831),
                         Color(red: 0.946, green: 0.76, blue: 0.839),
                    ]
                        //.map { Color(uiColor: $0) }
                )
            )
        )
    }
}



import ColorKit


//This glitches out if i dont add 0.01 seconds of other view before so that
struct backgroundBlur: View {
    @State var colors: [(id: Int, color: UIColor, frequency: CGFloat)] = []
    @State var gradientModel = AnimatedGradient.Model(colors: [])
    
    @Binding var images: [UIImage]
    @Binding var currentPage: Int
    
    @State var isLoading = true
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        
        ZStack{
            
            Spacer()
                .background(GradientEffectView($gradientModel))
        }
        .onAppear{
            updateColors()
        }
        .ignoresSafeArea()
        .onChange(of: currentPage) { _ in
            updateColors()
        }
    }
}

private extension backgroundBlur {
    
    var image: UIImage? {
        if !images.isEmpty {
            return images[currentPage % images.count].convertToRGBColorspace()
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



struct ShimmerEffectBox: View{
    
    private var gradientColors = [
    
        Color(uiColor: UIColor.systemGray5),
        Color(uiColor: UIColor.systemGray6),
        Color(uiColor: UIColor.systemGray5),
    ]
    
    @State var startPoint: UnitPoint = .init(x: -1, y: 0.5)
    @State var endPoint: UnitPoint   = .init(x: 0, y: 0.5)
    
    
    var body: some View{
        
        
        LinearGradient(colors: gradientColors,
                       startPoint: startPoint,
                       endPoint: endPoint)
        .onAppear{
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 1.4)
                    .repeatForever(autoreverses: false)){
                        startPoint = .init(x: 1.5, y: 0.5)
                        endPoint   = .init(x: 2.5, y: 0.5)
                    }
            }
        }
    }
}


struct ShimmerEffectBox_previews: PreviewProvider {
    static var previews: some View {
        ShimmerEffectBox()
            .frame(height: 200)
            
    }
}
