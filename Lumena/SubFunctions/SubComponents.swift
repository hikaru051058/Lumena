//
//  SubComponents.swift
//  MyPalette
//
//  Created by 島田晃 on 2023/09/09.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: Marquee Text View
struct Marquee: View{
    
    var text: String
    var font: UIFont
    
    @State var storedSize: CGSize = .zero
    @State var offset: CGFloat = 0
    @State var animatedText: String = ""
    
    var animationSpeed: Double = 0.03
    var delayTime: Double = 1.8
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View{
        
        // Since it scrolls horizontal using ScrollView
        GeometryReader{proxy in
            
            let size = proxy.size
            
            let condition = textSize(text: text).width < (size.width - 50)
            
            ScrollView(condition ? .init() : .horizontal, showsIndicators: false) {
                
                Text(condition ? text : animatedText)
                    .font(Font(font))
                    .offset(x: condition ? 0 : offset)
                    .padding(.horizontal,15)
                    .foregroundColor(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .center)
        }
        .frame(height: storedSize.height)
        // MARK: Opacity Effect
        .overlay(content: {
            
        })
        // Disbaling Manual Scrolling
        .disabled(true)
        .onAppear{
            startAnimation(text: text)
        }
        // MARK: Repeating Marquee Effect with the help of Timer
        // Optional: If you want some dalay for next animation
        .onReceive(Timer.publish(every: ((animationSpeed * storedSize.width) + delayTime), on: .main, in: .default).autoconnect()) { _ in
            
            // Resetting offset to 0
            // Thus its look like its looping
            offset = 0
            withAnimation(.linear(duration: (animationSpeed * storedSize.width))){
                offset = -storedSize.width
            }
        }
        // MARK: Re-calculating text size when text is changed
        .onChange(of: text) { newValue in
            animatedText = ""
            offset = 0
            startAnimation(text: newValue)
        }
    }
    
    // MARK: Starting Animation
    func startAnimation(text: String){
        
        // MARK: Continous Text Animation
        // Adding Spacing For Continous Text
        animatedText.append(text)
        (1...15).forEach { _ in
            animatedText.append(" ")
        }
        // Stoping Animation exactly before the next text
        storedSize = textSize(text: animatedText)
        animatedText.append(text)
        
        // Calculating Total Secs based on Text Width
        // Our Animation Speed for Each Character will be 0.02s
        let timing: Double = (animationSpeed * storedSize.width)
        
        // Delaying FIrst Animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            withAnimation(.linear(duration: timing)){
                offset = -storedSize.width
            }
        }
    }
    
    // MARK: Fetching Text Size for Offset Animation
    func textSize(text: String)->CGSize{
        
        let attributes = [NSAttributedString.Key.font: font]
        
        let size = (text as NSString).size(withAttributes: attributes)
        
        return size
    }
}



// MARK: -- Loading
struct LoadingSpinner: View {

    let rotationTime: Double = 1
    let animationTime: Double = 1.9 // Sum of all animation times
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)

    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var spinnerEndS2S3: CGFloat = 0.03

    @State var rotationDegreeS1 = initialDegree
    @State var rotationDegreeS2 = initialDegree
    @State var rotationDegreeS3 = initialDegree
    
    @State var spinnerEndS4: CGFloat = 0.09
    @State var spinnerEndS4S5: CGFloat = 0.09
    @State var spinnerEndS6: CGFloat = 0.03

    @State var rotationDegreeS4 = initialDegree
    @State var rotationDegreeS5 = initialDegree
    @State var rotationDegreeS6 = initialDegree

    var body: some View {
        ZStack {
            // S3
            SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS3, color: Color.white)

            // S2
            SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS2, color: Color(red: 0.552, green: 0.724, blue: 0.831))

            // S1
            SpinnerCircle(start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, color: Color(red: 0.946, green: 0.76, blue: 0.839))
            
            // S4
            SpinnerCircle(start: spinnerStart, end: spinnerEndS4, rotation: rotationDegreeS4, color: Color(red: 0.723, green: 0.88, blue: 0.825))

            // S5
            SpinnerCircle(start: spinnerStart, end: spinnerEndS4S5, rotation: rotationDegreeS5, color: Color(red: 0.552, green: 0.724, blue: 0.831))

            // S6
            SpinnerCircle(start: spinnerStart, end: spinnerEndS6, rotation: rotationDegreeS6, color: Color(red: 0.946, green: 0.76, blue: 0.839))
        }
        .frame(width: 75, height: 75)
        .onAppear() {
            self.animateSpinner()
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { (mainTimer) in
                self.animateSpinner()
            }
        }
    }

    // MARK: Animation methods
    func animateSpinner(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }

    func animateSpinner() {
        // Existing animations
        animateSpinner(with: rotationTime) { self.spinnerEndS1 = 1.0 }
        
        animateSpinner(with: (rotationTime * 1.5) - 0.025) {
            self.rotationDegreeS1 += fullRotation/2
            self.spinnerEndS2S3 = 0.4
        }

        animateSpinner(with: (rotationTime * 2)) {
            self.spinnerEndS1 = 0.03
            self.spinnerEndS2S3 = 0.03
        }

        animateSpinner(with: (rotationTime * 2) + 0.0525) { self.rotationDegreeS2 += fullRotation }
        
        animateSpinner(with: (rotationTime * 2) + 0.225) { self.rotationDegreeS3 += fullRotation }

        // New animations for S4, S5, S6
        animateSpinner(with: (rotationTime * 2) + 0.3) {
            self.rotationDegreeS4 += fullRotation
            self.spinnerEndS4 = 0.8
        }

        animateSpinner(with: (rotationTime * 2) + 0.4) {
            self.spinnerEndS4 = 0.03
            self.spinnerEndS4S5 = 0.8
        }

        animateSpinner(with: (rotationTime * 2) + 0.5) {
            self.rotationDegreeS5 += fullRotation
            self.spinnerEndS6 = 0.8
        }

        animateSpinner(with: (rotationTime * 2) + 0.6) {
            self.rotationDegreeS6 += fullRotation
        }

        // Collapsing animations for S4, S5, S6
        animateSpinner(with: (rotationTime * 3) - 0.025) {
            self.rotationDegreeS4 += fullRotation
            self.spinnerEndS4S5 = 0.03
        }

        animateSpinner(with: (rotationTime * 3)) {
            self.spinnerEndS4 = 0.03
            self.spinnerEndS6 = 0.03
        }
    }
}

// MARK: SpinnerCircle

struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}



struct SimpleProgressBarView: View {
    @Binding var progress: Double // Bind to the progress value
    let barWidth: CGFloat = 90 // Define the width of the progress bar
    let barHeight: CGFloat = 6 // Define the height of the progress bar
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background of the progress bar
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.3))
                .frame(width: barWidth, height: barHeight)
                .cornerRadius(barHeight / 2)
            
            // Foreground (progress) of the progress bar
            Rectangle()
                .foregroundColor(Color.white) // Color of the progress
                .frame(width: barWidth * CGFloat(progress), height: barHeight)
                .cornerRadius(barHeight / 2)
        }
        .frame(width: barWidth, height: barHeight) // Set the frame of the entire progress bar view
    }
}


struct loadingProgressView: View {
    @State private var isLoading: [Bool]
    @State private var barLength: Double = 90
    let maxNumber: Int = 35
    let barHeight: Int = 3
    
    init() {
        // Initialize isLoading array with the desired number of false values
        isLoading = Array(repeating: false, count: maxNumber)
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<maxNumber, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1 * Double(index + 1)))
                    .frame(width: CGFloat(barHeight*2), height: CGFloat(barHeight*2))
                    .offset(x: isLoading[index] ? (barLength / 2) : -(barLength / 2), y: 0)
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 1)
                            .repeatForever(autoreverses: true)
                            .delay(0.008 * Double(maxNumber - index))
                        ) {
                            self.isLoading[index] = true
                        }
                    }
            }
        }
    }
}




// MARK: -- Tab View

struct Tab {
    
    var title: String
}

struct Tabs: View {
    var fixed = true
    var tabs: [Tab]
    var geoWidth: CGFloat
    var useWhite: Bool = false
    
    @Binding var selectedTab: Int
    
    @State private var indicatorPosition: CGFloat = 0
    
    @State private var adjustWidth: Int = 100
    
    var body: some View {
        VStack(alignment: .center) { // Add VStack with alignment
            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ForEach(0 ..< tabs.count, id: \.self) { row in
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            selectedTab = row
                                            updateIndicatorPosition(selectedTab: row, geoWidth: geo.size.width, tabCount: tabs.count)
                                        }
                                    }, label: {
                                        VStack(spacing: 0) {
                                            HStack {
                                                
                                                if(useWhite){
                                                    Text(NSLocalizedString(tabs[row].title, comment: ""))
                                                        .padding(.top, 10)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(selectedTab == row ? Color.white : Color.gray)
                                                    
                                                } else {
                                                    
                                                    Text(NSLocalizedString(tabs[row].title, comment: ""))
                                                        .padding(.top, 10)
                                                }
                                            }
                                        }
                                        .frame(width: fixed ? ((geoWidth-CGFloat(adjustWidth)) / CGFloat(tabs.count)) : .none, height: 45)
                                        .fixedSize()
                                    })
                                    .accentColor(Color.white)
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .onChange(of: selectedTab) { target in
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                
                                withAnimation {
                                    proxy.scrollTo(target)
                                    updateIndicatorPosition(selectedTab: target, geoWidth: geo.size.width, tabCount: tabs.count)
                                }
                            }
                            
                            if(useWhite) {
                                Rectangle()
                                    .frame(width: 50, height: 3)
                                    .cornerRadius(20)
                                    .position(x: indicatorPosition)
                                    .onAppear {
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            
                                            withAnimation {
                                                proxy.scrollTo(0)
                                                updateIndicatorPosition(selectedTab: selectedTab, geoWidth: geo.size.width, tabCount: tabs.count)
                                            }
                                        }
                                    }
                                    .foregroundColor(Color.white)
                                
                            } else {
                                
                                Rectangle()
                                    .frame(width: 50, height: 3)
                                    .cornerRadius(20)
                                    .position(x: indicatorPosition)
                                    .onAppear {
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            
                                            withAnimation {
                                                proxy.scrollTo(0)
                                                updateIndicatorPosition(selectedTab: selectedTab, geoWidth: geo.size.width, tabCount: tabs.count)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                .frame(height: 50)
                .onAppear {
                    UIScrollView.appearance().bounces = fixed ? false : true
                    updateIndicatorPosition(selectedTab: selectedTab, geoWidth: geo.size.width, tabCount: tabs.count)
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50) // Align center horizontally
        .onAppear {
            // This will correctly set the initial position of the indicator
            updateIndicatorPosition(selectedTab: selectedTab, geoWidth: UIScreen.main.bounds.width, tabCount: tabs.count)
        }
    }
    
    private func updateIndicatorPosition(selectedTab: Int, geoWidth: CGFloat, tabCount: Int) {
        let tabWidth = geoWidth / CGFloat(tabCount)
        indicatorPosition = CGFloat(selectedTab) * tabWidth + (tabWidth / 2)
    }
}

struct BubbleShape: Shape {
    var myMessage: Bool
    var curveAmount: CGFloat = 25  // Default value, adjust as needed

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        let bezierPath = UIBezierPath()

        if !myMessage {
            bezierPath.move(to: CGPoint(x: curveAmount, y: height))
            bezierPath.addLine(to: CGPoint(x: width - curveAmount, y: height))
            bezierPath.addCurve(to: CGPoint(x: width, y: height - curveAmount), controlPoint1: CGPoint(x: width - curveAmount/2, y: height), controlPoint2: CGPoint(x: width, y: height - curveAmount/2))
            bezierPath.addLine(to: CGPoint(x: width, y: curveAmount))
            bezierPath.addCurve(to: CGPoint(x: width - curveAmount, y: 0), controlPoint1: CGPoint(x: width, y: curveAmount/2), controlPoint2: CGPoint(x: width - (curveAmount/2), y: 0))
            bezierPath.addLine(to: CGPoint(x: curveAmount+10, y: 0))
            bezierPath.addCurve(to: CGPoint(x: 5, y: curveAmount+5), controlPoint1: CGPoint(x: (curveAmount/2) + 5, y: 0), controlPoint2: CGPoint(x: 5, y: (curveAmount/2) + 5))
            bezierPath.addLine(to: CGPoint(x: 5, y: height - curveAmount))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 5, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: -1, y: height))
            bezierPath.addCurve(to: CGPoint(x: 12, y: height - 4), controlPoint1: CGPoint(x: 4, y: height + 1), controlPoint2: CGPoint(x: 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: 20, y: height), controlPoint1: CGPoint(x: 15, y: height), controlPoint2: CGPoint(x: 20, y: height))
        } else {
            bezierPath.move(to: CGPoint(x: width - curveAmount, y: height))
            bezierPath.addLine(to: CGPoint(x: curveAmount, y: height))
            bezierPath.addCurve(to: CGPoint(x: 0, y: height - curveAmount), controlPoint1: CGPoint(x: curveAmount/2, y: height), controlPoint2: CGPoint(x: 0, y: height - curveAmount/2))
            bezierPath.addLine(to: CGPoint(x: 0, y: curveAmount))
            bezierPath.addCurve(to: CGPoint(x: curveAmount, y: 0), controlPoint1: CGPoint(x: 0, y: curveAmount/2), controlPoint2: CGPoint(x: curveAmount/2, y: 0))
            bezierPath.addLine(to: CGPoint(x: width - curveAmount-5, y: 0))
            bezierPath.addCurve(to: CGPoint(x: width - 5, y: curveAmount), controlPoint1: CGPoint(x: width - (curveAmount/2), y: 0), controlPoint2: CGPoint(x: width - 5, y: (curveAmount/2)))
            bezierPath.addLine(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width - 5, y: height - 1), controlPoint2: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width + 1, y: height))
            bezierPath.addCurve(to: CGPoint(x: width - 12, y: height - 4), controlPoint1: CGPoint(x: width - 4, y: height + 1), controlPoint2: CGPoint(x: width - 8, y: height - 1))
            bezierPath.addCurve(to: CGPoint(x: width - 20, y: height), controlPoint1: CGPoint(x: width - 15, y: height), controlPoint2: CGPoint(x: width - 20, y: height))
        }
        return Path(bezierPath.cgPath)
    }
}
