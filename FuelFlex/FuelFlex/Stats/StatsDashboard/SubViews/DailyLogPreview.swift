//
//  DailyLogPreview.swift
//  FuelFlex
//
//  Created by DAS Sagar on 18/01/26.
//

import SwiftUI

struct DailyLogPreview: View {
    
    @Binding var isShowingDetail: Bool
    
    let items = [
        ("Morning Smoothie", "08:00 AM", "320", "sparkles", ColorTheme.secondary),
        ("Salmon Bowl", "12:30 PM", "650", "fork.knife", ColorTheme.primary),
        ("Protein Shake", "04:00 PM", "210", "bolt.fill", ColorTheme.golden)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Log")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Spacer()
//                Image(systemName: "calendar")
//                    .opacity(0.4)
                Button(action: {
                    // Action for calendar button
                    isShowingDetail.toggle()
                }) {
                    Text("View All")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ColorTheme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 0)
                
                }
            }
            
            VStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 44, height: 44)
                            Image(systemName: item.3)
                                .foregroundColor(item.4)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.0)
                                .font(.system(size: 14, weight: .semibold))
                            Text(item.1)
                                .font(.system(size: 10, weight: .bold))
                                .opacity(0.4)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(item.2)
                                .font(.system(size: 14, weight: .bold))
                            Text("kcal")
                                .font(.system(size: 10))
                                .opacity(0.4)
                        }
                    }
                    .padding(14)
                    .background(ColorTheme.surface)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
        }
    }
}

#Preview {
    DailyLogPreview(isShowingDetail: .constant(false))
}
