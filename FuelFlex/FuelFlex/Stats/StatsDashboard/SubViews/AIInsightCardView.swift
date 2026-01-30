//
//  AIInsightCardView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 18/01/26.
//

import SwiftUI

struct AIInsightCardView: View {
    var body: some View {
        ZStack {
            // Glow Effect
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: [ColorTheme.primary.opacity(0.2), ColorTheme.secondary.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blur(radius: 20)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.headset")
                            .foregroundColor(ColorTheme.primary)
                        Text("AI INSIGHT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(ColorTheme.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(ColorTheme.primary)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .opacity(0.6)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                Text("Grilled Salmon & Asparagus")
                    .font(.headline)
                
                Text("High protein efficiency detected. This meal supports your muscle recovery goal for today's leg session. Consider adding 15g more fats for satiety.")
                    .font(.system(size: 14))
                    .foregroundColor(ColorTheme.textSecondary)
                    .lineSpacing(4)
                
                HStack(spacing: 12) {
                    VStack {
                        Text("Confidence")
                            .font(.system(size: 10))
                            .opacity(0.6)
                        Text("98%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ColorTheme.golden)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    
                    Button(action: {}) {
                        Text("View Full Breakdown")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(ColorTheme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ColorTheme.buttonGradient)
                            .cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity, multiplier: 2)
                }
            }
            .padding(20)
            .background(ColorTheme.surface)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

#Preview {
    AIInsightCardView()
}
