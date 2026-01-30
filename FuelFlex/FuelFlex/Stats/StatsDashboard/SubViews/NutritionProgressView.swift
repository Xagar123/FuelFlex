//
//  NutritionProgressView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 18/01/26.
//

import SwiftUI

struct NutritionProgressView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Nutrition Progress")
                    .font(.title3.bold())
                    .foregroundColor(ColorTheme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .opacity(0.4)
            }
            
            HStack(spacing: 24) {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: 0.74)
                        .stroke(ColorTheme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 6)
                        .frame(width: 55, height: 55)
                    Circle()
                        .trim(from: 0, to: 0.6)
                        .stroke(ColorTheme.secondary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 55, height: 55)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("1,840")
                            .font(.system(size: 14, weight: .bold))
                        Text("kcal")
                            .font(.system(size: 8, weight: .bold))
                            .opacity(0.6)
                    }
                }
                .frame(width: 85, height: 85)
                
                // Macro Bars
                VStack(spacing: 12) {
                    MacroBar(label: "Protein", current: 120, total: 150, color: ColorTheme.primary)
                    MacroBar(label: "Carbs", current: 210, total: 250, color: ColorTheme.secondary)
                    MacroBar(label: "Fats", current: 45, total: 70, color: ColorTheme.accent)
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

struct MacroBar: View {
    let label: String
    let current: Int
    let total: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(ColorTheme.textSecondary)
                Spacer()
                Text("\(current)g / \(total)g")
                    .font(.system(size: 10, weight: .bold))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 6)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(current) / CGFloat(total), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    NutritionProgressView()
}
