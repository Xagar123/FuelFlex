//
//  CameraView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 14/01/26.
//

import SwiftUI

struct CameraView: View {
    
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(ColorTheme.buttonGradient)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 40))
                        .foregroundColor(ColorTheme.background)
                    
                }
                
                VStack(spacing: 8) {
                    Text("Track Your Fuel")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ColorTheme.textPrimary)
                    Text("Snap a photo of your meal to get\ninstant nutritional breakdown.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                Spacer()
                
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Open Camera")
                    }
                    .font(.headline)
                    .foregroundColor(ColorTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(ColorTheme.buttonGradient)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    CameraView {
        //
    }
}
