//
//  StatsHeaderView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 18/01/26.
//

import SwiftUI

struct StatsHeaderView: View {
    var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("STATS")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .italic()
                        .foregroundColor(ColorTheme.textPrimary)
                    Text("Today, Jan 18")
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Spacer()
                
                // Goal Status Widget
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("GOAL")
                            .font(.system(size: 10, weight: .bold))
                            .opacity(0.6)
                            .foregroundColor(ColorTheme.textSecondary)
                        Text("74%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ColorTheme.primary)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(ColorTheme.buttonGradient)
                            .frame(width: 44, height: 44)
                            .shadow(color: ColorTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "trophy.fill")
                            .foregroundColor(ColorTheme.background)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .padding(.vertical, 6)
                .padding(.leading, 16)
                .padding(.trailing, 6)
                .background(ColorTheme.surface)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
}

#Preview {
    StatsHeaderView()
}
