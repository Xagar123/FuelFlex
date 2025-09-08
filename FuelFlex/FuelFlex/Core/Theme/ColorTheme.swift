//
//  ColorTheme.swift
//  FuelFlex
//
//  Created by sagar on 06/09/25.
//

import SwiftUI

struct ColorTheme {
    // MARK: - Brand Colors
    static let primary      = Color(hex: "#00FF7F")   // Neon Green
    static let secondary    = Color(hex: "#00CFFF")   // Electric Blue
    static let background   = Color(hex: "#0A0F1C")   // Deep Navy
    static let surface      = Color.white
    static let textPrimary  = Color.white
    static let textSecondary = Color(hex: "#D9D9D9")  // Light Gray
    static let accent       = Color(hex: "#FF6B00")   // Orange Fuel
    static let golden       = Color(hex: "#FFD700") // Gold (hex for golden yellow)
    
    // MARK: - Gradients
    static let getStartedGradient = LinearGradient(
        gradient: Gradient(colors: [background, secondary, primary]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let splashGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: ColorTheme.background, location: 0.0),
            .init(color: ColorTheme.background, location: 0.6),
            .init(color: ColorTheme.primary, location: 1.0)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
        
    static let buttonGradient = LinearGradient(
        gradient: Gradient(colors: [primary, secondary]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [accent, golden]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Soft Gradient (lighter / subtle version)
    static let buttonGradientSoft = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: background.opacity(0.7), location: 0.0),
            .init(color: secondary.opacity(0.7), location: 0.6),
            .init(color: background.opacity(0.7), location: 1.0),
            
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let buttonGradientLight = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: primary.opacity(0.7), location: 0.0),
            .init(color: secondary.opacity(0.7), location: 0.5),
            .init(color: primary.opacity(0.1), location: 1.0),
            
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
}

