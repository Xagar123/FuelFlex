//
//  CoreMatrix.swift
//  FuelFlex
//
//  Created by DAS Sagar on 29/11/25.
//

import SwiftUI

/*
enum Gender: String {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}


struct CoreMatrix: View {
    
    @State private var age: Int = 20
    @State private var sliderValue: Double = 20
    @State private var selectedGender: Gender = .male
    @State private var heightCM: Int = 170
    @State private var weightKG: Int = 60
    
    @State private var tempHeight = 170
    @State private var tempWeight = 70
    
    
    var body: some View {
        ZStack {
            ColorTheme.splashGradient
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 0) {
                    Image("fuelFlexLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 150)
                    
                    Text("Your Core Matrix")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                    
                    Text("Tell us a little about yourself to get started on your personalized nutrition plan.")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        
                }
                .padding(.top,-20)
                
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(ColorTheme.accentGradient.opacity(0.9))
                        .shadow(color: Color.white.opacity(0.5), radius: 10, x: 0, y: 10)
                        .padding(20)
                        .frame(height: 150)
                        .overlay(content: {
                            VStack(spacing: 0) {
                                HStack(content: {
                                    Image(systemName: "calendar.badge")
                                        .foregroundColor(Color.white)
                                    
                                    Text("Age")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                    
                                    Spacer()
                                })
                                .padding(.leading,30)
                                
                                HStack(spacing: 15) {
                                    Text("\(age)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                    Text("years")
                                        .font(.title3)
                                        .foregroundColor(Color.white)
                                    Spacer()
                                    
                                    Slider(
                                        value: Binding(
                                            get: { Double(age) },
                                            set: { age = Int($0) }
                                        ),
                                        in: 10...100,
                                        step: 1
                                    )
                                    .tint(Color.black)
                                }
                                .padding(.leading,30)
                                
                                HStack {
                                    Text("10 years")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("99 years")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .padding(.leading,30)
                            }
                            .padding(.trailing,50)
                        })
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(ColorTheme.accentGradient.opacity(0.9))
                        .shadow(color: Color.white.opacity(0.5), radius: 10, x: 0, y: 10)
                        .padding(20)
                        .frame(height: 150)
                        .overlay(content: {
                            VStack {
                                HStack(content: {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color.white)
                                    
                                    Text("Gender")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                    
                                    Spacer()
                                })
                                .padding(.leading,40)
                                
                                HStack(spacing: 15) {
                                    genderOption(.male)
                                    genderOption(.female)
                                    genderOption(.other)
                                }
                                .padding(.horizontal,10)
                            }

                        })
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(ColorTheme.accentGradient.opacity(0.9))
                        .shadow(color: Color.white.opacity(0.5), radius: 10, x: 0, y: 10)
                        .padding(20)
                        .frame(height: 220)
                        .overlay(content: {
                            
                            VStack {
                                VStack {
                                    HStack(content: {
                                        Image(systemName: "pencil.and.ruler.fill")
                                            .foregroundColor(Color.white)
                                        
                                        Text("Height")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.white)
                                        
                                        Spacer()
                                    })
                                    .padding(.leading,40)
                                    
                                    HStack(spacing: 20) {
                                        Spacer()
                                        
                                        Text("\(tempHeight) cm")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Stepper("", value: $tempHeight, in: 100...230)
                                            .labelsHidden()
                                        
                                        Spacer()
                                    }
                                   
                                }
                                
                                Divider()
                                    
                                
                                VStack {
                                    HStack(content: {
                                        Image(systemName: "figure.arms.open")
                                            .foregroundColor(Color.white)
                                        
                                        Text("Weight")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.white)
                                        
                                        Spacer()
                                    })
                                    .padding(.leading,40)
                                    
                                    HStack(spacing: 20) {
                                        Spacer()
                                        Text("\(tempWeight) kg")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Stepper("", value: $tempWeight, in: 30...200)
                                            .labelsHidden()
                                        
                                        Spacer()
                                    }
                                }
                            }
                        })
                    
 
                }
                
                Button(action: {
                    heightCM = tempHeight
                    weightKG = tempWeight
//                    onContinue()
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .foregroundColor(ColorTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.background)
                        .cornerRadius(16)
                        .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 0)
                }
                .padding(.horizontal)
                
                
                Spacer()
            }
            .padding()
        }
    }
    
    
    @ViewBuilder
    func genderOption(_ gender: Gender) -> some View {
        Text(gender.rawValue)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(
                selectedGender == gender ?
                    .white : Color.black
            )
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        selectedGender == gender ?
                        Color.black :   // selected color
                        Color("PrimaryAccent").opacity(0.1) // unselected color
                    )
            )
            .onTapGesture {
                selectedGender = gender
            }
            .animation(.easeInOut(duration: 0.15), value: selectedGender)
    }
    
    

}
 */

// MARK: - Models
enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        case .other: return "figure.arms.open"
        }
    }
}

// MARK: - Main Core Matrix View
struct CoreMatrixView: View {
    @State private var age: Int = 24
    @State private var selectedGender: Gender = .male
    @State private var heightCM: Int = 175
    @State private var weightKG: Int = 72
    @State var isNavigateToDashboard: Bool = false
    
    var body: some View {
        ZStack {
            ColorTheme.background
                .ignoresSafeArea()
            
            // Subtle Background Glow
            Circle()
                .fill(ColorTheme.primary.opacity(0.05))
                .blur(radius: 100)
                .offset(x: -150, y: -200)
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ageCard
                        genderCard
                        metricsCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                
                footerSection
            }
            .navigationDestination(isPresented: $isNavigateToDashboard) {
//                MainTabView()
//                    .preferredColorScheme(.dark)
//                    .transition(.move(edge: .trailing).combined(with: .opacity))
                
                UserGoalMatrixView()
            }
            .navigationBarBackButtonHidden()
        }
    }
}

// MARK: - View Sections
private extension CoreMatrixView {
    var headerSection: some View {
        VStack(spacing: 8) {
            Text("YOUR CORE MATRIX")
                .font(.system(size: 24, weight: .black))
                .italic()
                .foregroundColor(ColorTheme.textPrimary)
            
            Text("Tell us about yourself to sync your personalized nutrition and training plan.")
                .font(.system(size: 14))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    var ageCard: some View {
        MatrixCardContainer(title: "Age", icon: "calendar.badge.clock") {
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(age)")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(ColorTheme.primary)
                    Text("YEARS")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                CustomSlider(value: Binding(
                    get: { Double(age) },
                    set: { age = Int($0) }
                ), range: 10...99)
            }
        }
    }
    
    var genderCard: some View {
        MatrixCardContainer(title: "Gender", icon: "person.fill") {
            HStack(spacing: 12) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    genderOption(gender)
                }
            }
        }
    }
    
    var metricsCard: some View {
        MatrixCardContainer(title: "Biometrics", icon: "pencil.and.ruler.fill") {
            VStack(spacing: 0) {
                metricStepper(title: "Height", value: $heightCM, unit: "cm", range: 100...230, icon: "arrow.up.and.down")
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 15)
                
                metricStepper(title: "Weight", value: $weightKG, unit: "kg", range: 30...200, icon: "scalemass.fill")
            }
        }
    }
    
    var footerSection: some View {
        VStack(spacing: 20) {
            Button(action: {
                // Action
                withAnimation(.easeInOut(duration: 0.45)) {
                    isNavigateToDashboard = true
                }
            }) {
                HStack {
                    Text("SYNC DATA")
                        .font(.system(size: 18, weight: .black))
                        .tracking(2)
                    Image(systemName: "checkmark.shield.fill")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(ColorTheme.buttonGradient)
                .cornerRadius(20)
                .shadow(color: ColorTheme.primary.opacity(0.3), radius: 10, x: 0, y: 8)
            }
        }
        .padding()
    }
}

// MARK: - Reusable Components
struct MatrixCardContainer<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(ColorTheme.secondary)
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(1)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            content
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

private extension CoreMatrixView {
    func genderOption(_ gender: Gender) -> some View {
        let isSelected = selectedGender == gender
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedGender = gender
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: gender.icon)
                    .font(.system(size: 20, weight: .bold))
                Text(gender.rawValue)
                    .font(.system(size: 12, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? ColorTheme.primary : Color.white.opacity(0.05))
            .foregroundColor(isSelected ? .black : ColorTheme.textSecondary)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? ColorTheme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
    
    func metricStepper(title: String, value: Binding<Int>, unit: String, range: ClosedRange<Int>, icon: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(ColorTheme.textSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(value.wrappedValue)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(ColorTheme.textPrimary)
                    Text(unit)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ColorTheme.secondary)
                }
            }
            
            Spacer()
            
            Stepper("", value: value, in: range)
                .labelsHidden()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .colorInvert() // Makes buttons white/visible on dark backgrounds
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(ColorTheme.buttonGradient)
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 6)
                    .cornerRadius(3)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: ColorTheme.primary.opacity(0.5), radius: 4)
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width - 12)
                    .gesture(
                        DragGesture().onChanged { gesture in
                            let percent = Double(gesture.location.x / geometry.size.width)
                            let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * percent
                            self.value = min(max(newValue, range.lowerBound), range.upperBound)
                        }
                    )
            }
        }
        .frame(height: 24)
    }
}
//
//#Preview {
//    CoreMatrix()
//}
