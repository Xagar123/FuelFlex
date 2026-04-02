//
//  PlanGenerationViewModel.swift
//  FuelFlex
//
//  Created by DAS Sagar on 28/02/26.
//

import Foundation

@MainActor
class PlanGenerationViewModel: ObservableObject {
    
    @Published var isPlanGenerated: Bool = false
    @Published var generationProgress: Double = 0.0
    
    
    func startPlanGeneration() async{
        
        while generationProgress < 100 {
            try? await Task.sleep(nanoseconds: 100_000_000)
            generationProgress += 10
        }
        isPlanGenerated = true
    }
    
}

