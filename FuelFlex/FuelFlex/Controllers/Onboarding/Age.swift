//
//  Age.swift
//  FuelFlex
//
//  Created by DAS Sagar on 29/11/25.
//

import SwiftUI

struct Age: View {
    
    @Binding var age: Int
    var onContinue: () -> Void
    
    @State var tempAge = 25
    
    var body: some View {
        VStack(spacing: 40) {
            Text("How old are you?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top,40)
            
            Text("This helps us personalize your calorie needs.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Picker("Age", selection: $tempAge) {
                ForEach(14..<90) { age in
                    Text("\(age) years")
                        .tag(age)
                }
            }
            
            Button(action: {
                age = tempAge
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
        .onAppear() {
            tempAge = age
        }
    }
}

#Preview {
    Age(age: .constant(25), onContinue: {})
}
