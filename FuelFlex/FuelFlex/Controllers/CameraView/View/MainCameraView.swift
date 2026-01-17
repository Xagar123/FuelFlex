//
//  MainCameraView.swift
//  FuelFlex
//
//  Created by DAS Sagar on 15/01/26.
//

import SwiftUI

struct MainCameraView: View {
    
    enum AppView {
        case home, camera, analysis
    }
    @State private var currentView: AppView = .home
    @State private var capturedImage: UIImage? = UIImage(named: "food")//nil
    
    var body: some View {
        ZStack {
            ColorTheme.background.ignoresSafeArea()
            
            switch currentView {
            case .home:
                CameraView {
                    currentView = .camera
                }
            case .camera:
                CameraCaptureView { image in
                    capturedImage = image
                    currentView = .analysis
                } onDismiss: {
                    currentView = .home
                }
                
            case .analysis:
                AnalysisView(image: (UIImage(named: "food") ?? UIImage()), onBack: { currentView = .home })
            }
        }
    }
}

#Preview {
    MainCameraView()
}
