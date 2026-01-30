//
//  MealRecord.swift
//  FuelFlex
//
//  Created by DAS Sagar on 20/01/26.
//

import Foundation

// MARK: - Models
struct MealRecord: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    let kcal: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    let imageUrl: String
}
