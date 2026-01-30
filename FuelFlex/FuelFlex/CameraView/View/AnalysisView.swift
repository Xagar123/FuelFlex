//
//  AnalysisView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 15/01/26.
//

import SwiftUI

// MARK: - Analysis View
struct AnalysisView: View {
    let image: UIImage
    let onBack: () -> Void
    
    @State private var macros = [
        Macro(id: "protein", name: "Protein", value: 32, unit: "g", color: ColorTheme.primary),
        Macro(id: "carbs", name: "Carbs", value: 45, unit: "g", color: ColorTheme.secondary),
        Macro(id: "fats", name: "Fats", value: 12, unit: "g", color: ColorTheme.accent)
    ]
    
    @State private var editingId: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Image
                ZStack(alignment: .topLeading) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                    
                    LinearGradient(gradient: Gradient(colors: [ColorTheme.background.opacity(0.8), .clear]), startPoint: .bottom, endPoint: .center)
                    
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.top, 50)
                    .padding(.leading, 20)
                }
                
                // Analysis Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Grilled Salmon Salad")
                                .font(.title2.bold())
                                .foregroundColor(ColorTheme.textPrimary)
                            Label("420 kcal total", systemImage: "flame.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        Text("ANALYZED")
                            .font(.caption2.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(ColorTheme.primary.opacity(0.2))
                            .foregroundColor(ColorTheme.primary)
                            .cornerRadius(20)
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    // Macros
                    VStack(spacing: 25) {
                        ForEach($macros) { $macro in
                            MacroRow(macro: $macro, isEditing: editingId == macro.id) {
                                withAnimation(.spring()) {
                                    editingId = (editingId == macro.id) ? nil : macro.id
                                }
                            }
                        }
                    }
                    
                    Button(action: onBack) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Log Meal")
                        }
                        .font(.headline)
                        .foregroundColor(ColorTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ColorTheme.buttonGradient)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(24)
                .background(ColorTheme.surface)
                .cornerRadius(32)
                .offset(y: -30)
                .padding(.horizontal)
            }
            
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct MacroRow: View {
    @Binding var macro: Macro
    let isEditing: Bool
    let onEditToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Circle().fill(macro.color).frame(width: 8, height: 8)
                    Text(macro.name.uppercased())
                        .font(.caption.bold())
                        .tracking(1.2)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                Spacer()
                HStack(spacing: 12) {
                    Text("\(macro.value)\(macro.unit)")
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Button(action: onEditToggle) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(isEditing ? ColorTheme.primary : ColorTheme.textSecondary)
                            .padding(6)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(8)
                    }
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.05))
                    Capsule()
                        .fill(macro.color)
                        .frame(width: geo.size.width * CGFloat(min(1.0, Double(macro.value)/100.0)))
                        .shadow(color: macro.color.opacity(0.4), radius: 4)
                }
            }
            .frame(height: 6)
            
            // Inline Stepper
            if isEditing {
                HStack(spacing: 30) {
                    StepperButton(icon: "minus") { if macro.value > 0 { macro.value -= 1 } }
                    Text("\(macro.value)")
                        .font(.system(size: 24, weight: .black, design: .default))
                        .foregroundColor(ColorTheme.primary)
                    StepperButton(icon: "plus") { macro.value += 1 }
                }
                .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .opacity))
                .padding(.top, 8)
            }
        }
    }
}

struct StepperButton: View {
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.white.opacity(0.1)))
        }
    }
}

//#Preview {
//    AnalysisView()
//}
