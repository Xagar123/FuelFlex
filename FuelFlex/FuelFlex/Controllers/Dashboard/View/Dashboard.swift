//
//  Dashboard.swift
//  FuelFlex
//
//  Created by DAS Sagar on 12/01/26.
//

import SwiftUI

struct Dashboard: View {
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Image("profile_pic")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(ColorTheme.primary, lineWidth: 2)
                        )
                    
                    Spacer()
                 
                    Button(action: {
                        print("Notification tapped")
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(ColorTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(ColorTheme.splashGradient)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Header Area Mock
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TODAY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ColorTheme.textSecondary)
                                .kerning(2)
                            
                            Text("Tuesday, ")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(ColorTheme.textPrimary)
                            + Text("January 13")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(ColorTheme.primary)
                        }
                        .padding(.horizontal)
                        
                        DailySummaryCard()
                            .padding(.horizontal)
                        
                        VStack {
                            ColorTheme.background.ignoresSafeArea()
                            ScrollView {
                                ProgressSectionView()
                            }
                        }
                        .padding(.top,-24)
                    }
                    .padding(.vertical)
                }
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    Dashboard()
        .preferredColorScheme(.dark)
}
