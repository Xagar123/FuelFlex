//
//  ScanningAnimationView.swift
//  FuelFlex
//

import SwiftUI

struct ScanningAnimationView: View {
    
    let image: UIImage
    let onComplete: () -> Void
    
    @State private var scanLineOffset: CGFloat = -150
    @State private var pulse = false
    @State private var statusText = "Detecting food items..."
    @State private var progress: Double = 0
    
    private let scanDuration: Double = 3.5
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Captured image with scan overlay
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 400)
                        .clipped()
                        .overlay(Color.black.opacity(0.3))
                    
                    // Scan line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.primary.opacity(0), ColorTheme.primary.opacity(0.8), ColorTheme.primary.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 4)
                        .shadow(color: ColorTheme.primary, radius: 20)
                        .shadow(color: ColorTheme.primary.opacity(0.5), radius: 40)
                        .offset(y: scanLineOffset)
                    
                    // Corner brackets
                    cornerBrackets
                        .opacity(pulse ? 1 : 0.5)
                }
                .frame(height: 400)
                .clipped()
                
                Spacer()
                
                // Status section
                VStack(spacing: 20) {
                    // Pulsing icon
                    ZStack {
                        Circle()
                            .fill(ColorTheme.primary.opacity(0.1))
                            .frame(width: 70, height: 70)
                            .scaleEffect(pulse ? 1.2 : 1)
                        
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ColorTheme.primary)
                    }
                    
                    Text(statusText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ColorTheme.buttonGradient)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 60)
                    
                    Text("Analyzing nutritional content")
                        .font(.system(size: 12))
                        .foregroundColor(ColorTheme.textSecondary.opacity(0.5))
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
            scheduleCompletion()
        }
    }
    
    private func startAnimations() {
        // Scan line animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            scanLineOffset = 150
        }
        
        // Pulse
        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            pulse = true
        }
        
        // Progress
        withAnimation(.easeInOut(duration: scanDuration)) {
            progress = 1.0
        }
        
        // Status text changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { statusText = "Calculating macros..." }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation { statusText = "Almost done..." }
        }
    }
    
    private func scheduleCompletion() {
        DispatchQueue.main.asyncAfter(deadline: .now() + scanDuration) {
            onComplete()
        }
    }
    
    // MARK: - Corner Brackets
    
    private var cornerBrackets: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let len: CGFloat = 40
            let pad: CGFloat = 30
            
            ZStack {
                // Top-left
                bracketCorner(at: CGPoint(x: pad, y: pad), len: len, flipX: false, flipY: false)
                // Top-right
                bracketCorner(at: CGPoint(x: w - pad, y: pad), len: len, flipX: true, flipY: false)
                // Bottom-left
                bracketCorner(at: CGPoint(x: pad, y: h - pad), len: len, flipX: false, flipY: true)
                // Bottom-right
                bracketCorner(at: CGPoint(x: w - pad, y: h - pad), len: len, flipX: true, flipY: true)
            }
        }
    }
    
    private func bracketCorner(at point: CGPoint, len: CGFloat, flipX: Bool, flipY: Bool) -> some View {
        Path { path in
            let dx: CGFloat = flipX ? -len : len
            let dy: CGFloat = flipY ? -len : len
            path.move(to: CGPoint(x: point.x + dx, y: point.y))
            path.addLine(to: point)
            path.addLine(to: CGPoint(x: point.x, y: point.y + dy))
        }
        .stroke(ColorTheme.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }
}
