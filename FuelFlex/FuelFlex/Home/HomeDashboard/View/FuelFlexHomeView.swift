//
//  FuelFlexHomeView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 21/01/26.
//

import SwiftUI

struct FuelFlexHomeView: View {
    @State private var bpm: Int = 72
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // --- Immersive Hero Banner ---
                    ZStack(alignment: .bottomLeading) {
                        // Background Image
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&q=80&w=1000")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(height: 380)
                        .clipped()
                        
                        // Overlays
                        LinearGradient(
                            gradient: Gradient(colors: [ColorTheme.background, ColorTheme.background.opacity(0.3), .clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        
                        LinearGradient(
                            gradient: Gradient(colors: [ColorTheme.background.opacity(0.5), .clear]),
                            startPoint: .top,
                            endPoint: .center
                        )
                        
                        // Content
                        VStack(alignment: .leading, spacing: 12) {
                            // Motivational Tag
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(ColorTheme.primary)
                                Text("FUEL YOUR FIRE")
                                    .font(.system(size: 10, weight: .black))
                                    .tracking(2)
                                    .foregroundColor(ColorTheme.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(ColorTheme.primary.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(ColorTheme.primary.opacity(0.3), lineWidth: 1))
                            
                            Text("WIN THE\n")
                                .font(.system(size: 48, weight: .black))
                                .foregroundColor(.white)
                            + Text("MORNING.")
                                .font(.system(size: 48, weight: .black))
                                .foregroundStyle(
                                    LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary], startPoint: .leading, endPoint: .trailing)
                                )
                            
                            // CTA Button
                            Button(action: {}) {
                                HStack {
                                    Text("ENTER THE ZONE")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(2)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .black))
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundColor(.black)
                                .cornerRadius(16)
                                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .frame(height: 380)
                    .clipShape(CustomRoundedCorner(radius: 48, corners: [.bottomLeft, .bottomRight]))
                    .ignoresSafeArea(edges: .top)
                    
                    // --- Dashboard Metrics ---
                    VStack(spacing: 24) {
                        // Vital Signs
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Label("VITAL SIGNS", systemImage: "timer")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                    .tracking(1)
                                Spacer()
                                Text("LIVE")
                                    .font(.system(size: 10, weight: .black))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(icon: "heart.fill", value: "\(bpm)", unit: "BPM", label: "PULSE", color: ColorTheme.accent, isPulse: true, pulseScale: pulseScale)
                                StatCard(icon: "drop.fill", value: "1.8", unit: "LTR", label: "WATER", color: ColorTheme.secondary)
                                StatCard(icon: "figure.walk", value: "8.4", unit: "K", label: "STEPS", color: ColorTheme.primary)
                            }
                        }
                        
                        // Fuel Status Card
                        FuelStatusCard()
                    }
                    .padding(.horizontal, 24)
                    .offset(y: -20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // --- Overlaid Header Buttons ---
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(Color.green).frame(width: 6, height: 6)
                            Text("PEAK MODE").font(.system(size: 10, weight: .bold)).opacity(0.7)
                        }
                        Text("Alex").font(.system(size: 28, weight: .black))
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        HeaderButton(icon: "magnifyingglass")
                        HeaderButton(icon: "bell.badge.fill")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 50)
                Spacer()
            }
            
            // --- Bottom Navigation ---
            VStack {
                Spacer()
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 56, height: 56)
                            .background(LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, y: 5)
                    }
                    
                    NavIcon(icon: "activity")
                    NavIcon(icon: "fork.knife")
                    NavIcon(icon: "person.fill")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Blur(style: .systemUltraThinMaterialDark))
                .cornerRadius(32)
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.1), lineWidth: 1))
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            startHeartRateAnimation()
        }
    }
    
    private func startHeartRateAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            bpm = Int.random(in: 70...78)
        }
    }
}

// --- Helper Components ---

struct StatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    var isPulse: Bool = false
    var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.1))
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .bold))
                    .scaleEffect(isPulse ? pulseScale : 1.0)
            }
            .frame(width: 44, height: 44)
            
            VStack(spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(value).font(.system(size: 20, weight: .black))
                    Text(unit).font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
                }
                Text(label).font(.system(size: 10, weight: .bold)).foregroundColor(.gray).tracking(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            ZStack {
                ColorTheme.surface
                LinearGradient(gradient: Gradient(colors: [color.opacity(0.1), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        )
        .cornerRadius(28)
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

//struct FuelStatusCard: View {
//    var body: some View {
//        VStack(spacing: 24) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("FUEL STATUS").font(.system(size: 18, weight: .black))
//                    Text("GOAL: 2,400 KCAL").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
//                }
//                Spacer()
//                VStack(alignment: .trailing, spacing: 4) {
//                    Text("1,850").font(.system(size: 22, weight: .black)).foregroundColor(ColorTheme.primary)
//                    Text("CONSUMED").font(.system(size: 10, weight: .bold)).foregroundColor(.gray)
//                }
//            }
//            
//            HStack(spacing: 20) {
//                MacroRing(label: "PRO", progress: 0.65, color: ColorTheme.secondary)
//                MacroRing(label: "CARB", progress: 0.75, color: ColorTheme.golden)
//                MacroRing(label: "FAT", progress: 0.55, color: ColorTheme.accent)
//                MacroRing(label: "FIB", progress: 0.80, color: ColorTheme.primary)
//            }
//        }
//        .padding(24)
//        .background(
//            ZStack {
//                ColorTheme.surface
//                LinearGradient(gradient: Gradient(colors: [ColorTheme.primary.opacity(0.1), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing)
//            }
//        )
//        .cornerRadius(32)
//        .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.1), lineWidth: 1))
//    }
//}

//struct MacroRing: View {
//    let label: String
//    let progress: CGFloat
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            ZStack {
//                Circle().stroke(Color.white.opacity(0.05), lineWidth: 4)
//                Circle()
//                    .trim(from: 0, to: progress)
//                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
//                    .rotationEffect(.degrees(-90))
//                Text("\(Int(progress * 100))%")
//                    .font(.system(size: 9, weight: .black))
//            }
//            .frame(width: 48, height: 48)
//            Text(label).font(.system(size: 9, weight: .bold)).foregroundColor(.gray)
//        }
//    }
//}

struct FuelStatusCard: View {
    var body: some View {
        VStack(spacing: 28) {

            // HEADER
            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Fuel Status")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.textPrimary)

                    Text("Goal · 2,400 kcal")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("1,850")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.primary)

                    Text("Consumed")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }

            // MACRO RINGS
            HStack(spacing: 24) {
                MacroRing(label: "Protein", progress: 0.65, color: ColorTheme.secondary)
                MacroRing(label: "Carbs", progress: 0.75, color: ColorTheme.golden)
                MacroRing(label: "Fat", progress: 0.55, color: ColorTheme.accent)
                MacroRing(label: "Fiber", progress: 0.80, color: ColorTheme.primary)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(ColorTheme.surface)
                .overlay(
                    LinearGradient(
                        colors: [
                            ColorTheme.primary.opacity(0.12),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 14, y: 8)
    }
}

struct MacroRing: View {
    let label: String
    let progress: CGFloat
    let color: Color

    private let ringSize: CGFloat = 52
    private let totalHeight: CGFloat = 60
    private let lineWidth: CGFloat = 5

    var body: some View {
        VStack(spacing: 6) {

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(ColorTheme.textPrimary)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: ringSize, height: ringSize)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(ColorTheme.textSecondary)
                .lineLimit(1)
                .frame(height: 12) // 🔒 text height locked
        }
        .frame(width: 60, height: 80)
        .clipped()                                   // ✂️ prevents overflow
        .fixedSize()                                // 🚫 no layout negotiation
    }
}



struct HeaderButton: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .frame(width: 44, height: 44)
            .background(Blur(style: .systemUltraThinMaterialLight).opacity(0.2))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}

struct NavIcon: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 22))
            .foregroundColor(.gray)
            .frame(width: 50, height: 50)
    }
}


struct CustomRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    FuelFlexHomeView()
}
