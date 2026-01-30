//
//  StatsDashboardView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 18/01/26.
//

import SwiftUI

struct StatsDashboardView: View {
    
    @State var isShowingDetail: Bool = false
    
    var body: some View {
            ZStack {
                ColorTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    StatsHeaderView()
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            AIInsightCardView()
                            
                            DailyLogPreview(isShowingDetail: $isShowingDetail)
                            
                            WorkoutProgressView()
                            
                            NutritionProgressView()
                            
                            // Footer Placeholder
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 24))
                                Text("ADVANCED TRENDS COMING SOON")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(3)
                            }
                            .opacity(0.3)
                            .padding(.top, 20)
                            .padding(.bottom, 100)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                .navigationBarBackButtonHidden()
                .navigationDestination(isPresented: $isShowingDetail, destination: {
                    DailyLogView()
                })
            }
        }
}

#Preview {
    StatsDashboardView()
}
