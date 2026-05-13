//
//  MainCameraView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 15/01/26.
//

import SwiftUI

struct MainCameraView: View {
    
    enum CameraFlow {
        case capture, scanning, analysis
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentFlow: CameraFlow = .capture
    @State private var capturedImage: UIImage?
    
    var logedData: (() -> Void)
    
    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch currentFlow {
            case .capture:
                ImagePicker(
                    sourceType: cameraAvailable ? .camera : .photoLibrary,
                    onCapture: { image in
                        capturedImage = image
                        withAnimation { currentFlow = .scanning }
                    },
                    onDismiss: {
                        dismiss()
                    }
                )
                .ignoresSafeArea()
                
            case .scanning:
                if let image = capturedImage {
                    ScanningAnimationView(image: image) {
                        withAnimation { currentFlow = .analysis }
                    }
                    .transition(.opacity)
                }
                
            case .analysis:
                if let image = capturedImage {
                    AnalysisView(image: image, onBack: {
                        logedData()
                    })
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    MainCameraView(logedData: {})
}
