//
//  WorkoutProgressView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 18/01/26.
//

import SwiftUI

struct WorkoutProgressView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity")
                .font(.title3.bold())
            
            VStack(spacing: 20) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorTheme.accent.opacity(0.1))
                            .frame(width: 50, height: 50)
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(ColorTheme.accent)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Push Session")
                            .font(.headline)
                        Text("Duration: 45m | Intensity: High")
                            .font(.caption)
                            .opacity(0.6)
                    }
                    Spacer()
                }
                
                HStack(spacing: 12) {
                    ActivityMetric(label: "BURNED", value: "482", unit: "kcal", icon: "flame.fill", color: ColorTheme.accent)
                    ActivityMetric(label: "AVG BPM", value: "142", unit: "bpm", icon: "waveform.path.ecg", color: ColorTheme.secondary)
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

struct ActivityMetric: View {
    let label: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .opacity(0.6)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .italic()
                Text(unit)
                    .font(.caption2)
                    .opacity(0.6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

#Preview {
    WorkoutProgressView()
}
