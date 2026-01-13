//
//  CoreMatrix.swift
//  FuelFlex
//
//  Created by DAS Sagar on 29/11/25.
//

import SwiftUI

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

#Preview {
    CoreMatrix()
}
