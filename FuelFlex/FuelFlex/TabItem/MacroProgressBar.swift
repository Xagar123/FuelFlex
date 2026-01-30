//
//  MacroProgressBar.swift
//  FuelFlex
//
//  Created by DAS Sagar on 13/01/26.
//

import SwiftUI

struct MacroProgressBar: View {
    
    let label: String
    let icon: String
    let current: Double
    let total: Double
    let unit: String
    let color: LinearGradient
    
    private var progress: CGFloat {
        CGFloat(min(current / total, 1.0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(icon) \(label.uppercased())")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .kerning(1.2)
                    .foregroundColor(ColorTheme.textSecondary)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 2) {
                    Text("\(Int(current))")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(ColorTheme.textPrimary)
                    Text("/ \(Int(total))\(unit)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 6)
                    
                    // Progress
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 6)
                        .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Component 2: Daily Summary Card
struct DailySummaryCard: View {
    var body: some View {
        VStack(spacing: 24) {
            // Card Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .foregroundColor(ColorTheme.secondary)
                    Text("Daily Stats")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                Spacer()
                
                // Streak Badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(ColorTheme.accent)
                    Text("3 DAY STREAK")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(ColorTheme.accent)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(ColorTheme.accent.opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ColorTheme.accent.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Macro List
            VStack(spacing: 20) {
                MacroProgressBar(
                    label: "Calories",
                    icon: "🔥",
                    current: 1800,
                    total: 2000,
                    unit: "",
                    color: ColorTheme.buttonGradient
                )
                
                MacroProgressBar(
                    label: "Protein",
                    icon: "🍗",
                    current: 95,
                    total: 100,
                    unit: "g",
                    color: LinearGradient(colors: [ColorTheme.secondary], startPoint: .leading, endPoint: .trailing)
                )
                
                MacroProgressBar(
                    label: "Carbs",
                    icon: "🍞",
                    current: 230,
                    total: 250,
                    unit: "g",
                    color: LinearGradient(colors: [ColorTheme.golden], startPoint: .leading, endPoint: .trailing)
                )
                
                MacroProgressBar(
                    label: "Fats",
                    icon: "🥑",
                    current: 60,
                    total: 70,
                    unit: "g",
                    color: LinearGradient(colors: [ColorTheme.accent], startPoint: .leading, endPoint: .trailing)
                )
            }
        }
        .padding(24)
        .background(Color(hex: "#161D2F"))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

#Preview {
    MacroProgressBar(label: "", icon: "", current: 0.55, total: 1, unit: "", color: LinearGradient(colors: [ColorTheme.secondary], startPoint: .leading, endPoint: .trailing))
}
