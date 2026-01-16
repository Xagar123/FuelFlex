//
//  MainTabView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 13/01/26.
//

import SwiftUI

// MARK: - Tab Definition
enum Tab: String, CaseIterable {
    case home = "house.fill"
    case stats = "chart.bar.fill"
    case plan = "calendar"
    case profile = "person.fill"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .stats: return "Stats"
        case .plan: return "Plan"
        case .profile: return "Profile"
        }
    }
}

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .home
    @State private var showLogSheet = false
    @State private var isCameraPresented = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    Dashboard()
                case .stats:
                    Text("Stats View")
                        .foregroundColor(.white)
                case .plan:
                    Text("Plan View")
                        .foregroundColor(.white)
                case .profile:
                    Text("Profile View")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
           
            // 2. Custom Tab Bar Overlay
            CustomTabBar(selectedTab: $selectedTab, action: {
//                showLogSheet.toggle()
//                MainCameraView()
                isCameraPresented.toggle()
            })
            .background {
                ColorTheme.background
                    .shadow(color: ColorTheme.primary.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: -6)
            }
      
            .navigationDestination(isPresented: $isCameraPresented) {
                MainCameraView()
                    .preferredColorScheme(.dark)
            }

        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Custom Tab Bar Component
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                // Background Bar
                HStack(spacing: 0) {
                    TabButton(tab: .home, selectedTab: $selectedTab)
                    TabButton(tab: .stats, selectedTab: $selectedTab)
                    
                    // Space for Central Button
                    Spacer()
                        .frame(width: 80)
                    
                    TabButton(tab: .plan, selectedTab: $selectedTab)
                    TabButton(tab: .profile, selectedTab: $selectedTab)
                }
                .padding(.top, 15)
                .padding(.bottom, 25)
                
                // Central FAB Button
                Button(action: action) {
                    ZStack {
                        Circle()
                            .fill(ColorTheme.buttonGradient)
                            .frame(width: 60, height: 60)
                            .shadow(color: ColorTheme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .offset(y: -40) // Pops out of the bar
            }
        }
    }
}

// MARK: - Helper: Tab Button
struct TabButton: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 20))
                Text(tab.title)
                    .font(.system(size: 10, weight: .black))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selectedTab == tab ? ColorTheme.primary : ColorTheme.textSecondary.opacity(0.5))
        }
    }
}

// MARK: - Helper: Custom Shape for the "Dip"
struct CustomTabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.35, y: 0))
        
        // The Curve for the Center Button
        path.addCurve(to: CGPoint(x: rect.width * 0.65, y: 0),
                     control1: CGPoint(x: rect.width * 0.42, y: 40),
                     control2: CGPoint(x: rect.width * 0.58, y: 40))
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
}
