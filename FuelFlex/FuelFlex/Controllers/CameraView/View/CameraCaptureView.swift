//
//  CameraCaptureView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 15/01/26.
//

import SwiftUI

struct CameraCaptureView: View {
    
    let onCapture: (UIImage) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        onDismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    })
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 30)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 250, height: 250)
                
                Text("Center your food in the frame")
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.4))
                    .cornerRadius(20)
                    .padding(.top, 20)
                
                Spacer()
                
                Button(action: { onCapture(UIImage(systemName: "leaf.fill") ?? UIImage()) }) {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .overlay(Circle().fill(Color.white).padding(6))
                }
                .padding(.bottom, 40)
                
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    CameraCaptureView(onCapture: { image in
        //
    }, onDismiss: {
        //
    })
}
