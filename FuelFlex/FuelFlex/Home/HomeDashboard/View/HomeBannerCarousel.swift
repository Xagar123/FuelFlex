//
//  HomeBannerCarousel.swift
//  FuelFlex
//
//  Created by DAS Sagar on 23/01/26.
//

import SwiftUI

struct HomeBannerCarousel: View {
    
    let banners: [HomeBanner]

    private let height: CGFloat = 230
    
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(banners.indices, id: \.self) { index in
                HomeBannerCard(banner: banners[index])
                    .tag(index)
            }
        }
        .frame(height: height)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .onReceive(timer) { _ in
            withAnimation(.easeInOut) {
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
    }
}

struct HomeBannerCard: View {

    let banner: HomeBanner

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            Image(banner.image)
                .resizable()
                .scaledToFill()
                .frame(height: 230)
                .opacity(0.8)

//            LinearGradient(
//                colors: [
//                    ColorTheme.background.opacity(0.85),
//                    ColorTheme.background.opacity(0.4),
//                    Color.clear
//                ],
//                startPoint: .bottom,
//                endPoint: .top
//            )
            // Multi-layered Overlay for Depth
            LinearGradient(
                colors: [
                    ColorTheme.background,
                    ColorTheme.background.opacity(0.4),
                    ColorTheme.background.opacity(0.2),
                    ColorTheme.background.opacity(0.5),
                    ColorTheme.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Accent Ambient Glow
            RadialGradient(
                colors: [ColorTheme.primary.opacity(0.10), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            ////////// Content //////////
            VStack(alignment: .leading, spacing: 8) {

                Text(banner.title)
                    .font(.title2.bold())
                    .foregroundColor(ColorTheme.textPrimary)

                Text(banner.subtitle)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)

                Button(action: {}) {
                    HStack {
                        Text("ENTER THE ZONE")
                            .font(.system(size: 10, weight: .bold))
                            .italic()
                            .tracking(2)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .black))
                    }
                    .padding(.horizontal,8)
                    .padding(.vertical,8)
                    .background(
                        LinearGradient(colors: [ColorTheme.primary, ColorTheme.secondary], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.black)
                    .cornerRadius(14)
                    .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
        )
    }
}



#Preview {
    HomeBannerCarousel(
        banners: [
            HomeBanner(
                image: "banner_workout",
                title: "Train Smarter 💪",
                subtitle: "AI-powered workouts made for you"
            ),
            HomeBanner(
                image: "banner_nutrition",
                title: "Fuel Your Body 🥗",
                subtitle: "Track nutrition & hydration daily"
            ),
            HomeBanner(
                image: "banner_progress",
                title: "See Real Progress 📈",
                subtitle: "Analytics that keep you motivated"
            ),
        ]
    )
}
