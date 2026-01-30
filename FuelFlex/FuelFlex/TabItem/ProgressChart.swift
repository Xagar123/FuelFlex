//
//  ProgressChart.swift
//  FuelFlex
//
//  Created by DAS Sagar on 13/01/26.
//

import SwiftUI

// MARK: - Component: Activity Ring
struct ActivityRingView: View {
    let progress: Double // 0.0 to 1.0
    let color: LinearGradient
    let ringWidth: CGFloat = 12
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: ringWidth)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 5)
        }
        .frame(width: 80, height: 80)
    }
}

// MARK: - Component: Spark Bar Chart
struct ProgressChart: View {
    let data: [Double] = [0.3, 0.6, 0.4, 0.8, 0.5, 0.9, 0.7]
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 12, weight: .black))
                    .kerning(1.5)
                    .foregroundColor(ColorTheme.textSecondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(ColorTheme.textPrimary)
                    Text(unit)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ColorTheme.textSecondary)
                        .padding(.bottom, 4)
                }
            }
            
            // Bars
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<data.count, id: \.self) { index in
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4)
                                .fill(color.opacity(Double(index + 1) / Double(data.count)))
                                .frame(height: geo.size.height * CGFloat(data[index]))
                                .shadow(color: index == data.count - 1 ? color.opacity(0.5) : .clear, radius: 5)
                        }
                    }
                }
            }
            .frame(height: 40)
        }
        .padding(12)
        .background(ColorTheme.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Section: Progress Section
struct ProgressSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            HStack {
                Text("Performance")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("HISTORY")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(ColorTheme.primary)
                }
            }
            .padding(.horizontal)
            
            // Horizontal Scroll for Chart Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ProgressChart(title: "Energy", value: "1,800", unit: "kcal", color: ColorTheme.primary)
                        .frame(width: 140,height: 120)
                    
                    ProgressChart(title: "Muscle", value: "95", unit: "g", color: ColorTheme.secondary)
                        .frame(width: 140,height: 120)
                    
                    ProgressChart(title: "Hydration", value: "2.4", unit: "L", color: ColorTheme.secondary)
                        .frame(width: 140,height: 120)
                }
                .padding(.horizontal)
            }
            
            // AI Suggestion Box (Quick View)
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(ColorTheme.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "bolt.fill")
                        .foregroundColor(ColorTheme.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI RECOMMENDATION")
                        .font(.system(size: 9, weight: .black))
                        .kerning(1)
                        .foregroundColor(ColorTheme.primary)
                    
                    Text("Peak performance detected. Add spinach to your next meal.")
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundColor(ColorTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(16)
            .background(ColorTheme.surface)
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.bottom,80)
        }
    }
}

#Preview {
    ZStack {
        ColorTheme.background.ignoresSafeArea()
        ScrollView {
            ProgressSectionView()
        }
    }
    .preferredColorScheme(.dark)
}
