//
//  HeightView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 29/11/25.
//

import SwiftUI

struct HeightWeightView: View {
    
    @Binding var heightCM: Int
    @Binding var weightKG: Int
    
    var onContinue: () -> Void
    
    @State private var tempHeight = 170
    @State private var tempWeight = 70
    
    
    var body: some View {
        VStack(spacing: 40) {
            
            Text("Your Height & Weight")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("This helps us calculate your calorie and fitness profile.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 32) {
                
                // Height
                VStack(spacing: 10) {
                    Text("Height")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Text("\(tempHeight) cm")
                            .font(.system(size: 40, weight: .bold))
                        
                        Stepper("", value: $tempHeight, in: 100...230)
                            .labelsHidden()
                    }
                }
                
                Divider()
                    .padding(.horizontal, 40)
                
                // Weight
                VStack(spacing: 10) {
                    Text("Weight")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Text("\(tempWeight) kg")
                            .font(.system(size: 40, weight: .bold))
                        
                        Stepper("", value: $tempWeight, in: 30...200)
                            .labelsHidden()
                    }
                }
            }
            
            Button(action: {
                heightCM = tempHeight
                weightKG = tempWeight
                onContinue()
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            tempHeight = heightCM
            tempWeight = weightKG
        }
    }
}


#Preview {
    HeightWeightView(heightCM: .constant(170), weightKG: .constant(70), onContinue: {})
}
