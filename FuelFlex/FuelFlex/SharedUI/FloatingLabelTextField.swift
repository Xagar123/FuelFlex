//
//  FloatingLabelTextField.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

import SwiftUI

struct FloatingLabelTextField: View {
    var label: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isFocused: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Floating label
            Text(label)
                .foregroundColor(isFocused || !text.isEmpty ? .white : .white.opacity(0.7))
                .font(.system(size: isFocused || !text.isEmpty ? 12 : 16, weight: .semibold))
                .padding(.horizontal, 12)
                .background(Color.clear)
                .offset(y: (isFocused || !text.isEmpty) ? -30 : 0)
                .scaleEffect((isFocused || !text.isEmpty) ? 0.9 : 1.0, anchor: .leading)
                .animation(.easeInOut(duration: 0.2), value: isFocused || !text.isEmpty)
            
            HStack {
                if isSecure {
                    if isPasswordVisible {
                        TextField("", text: $text, onEditingChanged: { editing in
                            self.isFocused = editing
                        })
                        .autocapitalization(.none)
                        .keyboardType(.default)
                        .foregroundColor(.white)
                    } else {
                        SecureField("", text: $text)
                            .foregroundColor(.white)
                            .onTapGesture {
                                self.isFocused = true
                            }
                    }
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else {
                    TextField("", text: $text, onEditingChanged: { editing in
                        self.isFocused = editing
                    })
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                }
            }
//            .padding(.vertical, 12)
//            .padding(.horizontal, 12)
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
        }
        .padding(.top, 24) // Extra padding for floating label
    }
}

#Preview {
    FloatingLabelTextField(label: "Email", text: .constant("Email"))
}
