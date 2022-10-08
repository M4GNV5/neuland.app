//
//  FoodTypes.swift
//  App
//
//  Created by Robert Eggl on 09.10.22.
//

import Foundation

// MARK: - FoodLocation
enum FoodLocation: String, CaseIterable {
    case mensa
    case reimanns
    
    var name: String {
        switch self {
        case .mensa:
            return "Mensa"
        case .reimanns:
            return "Reimanns"
        }
    }
    
    var url: URL {
        switch self {
        case .mensa:
            return NeulandAPI.mensa.asURL()
        case .reimanns:
            return NeulandAPI.reimanns.asURL()
        }
    }
    
}


// MARK: - FoodElement
struct FoodElement: Identifiable, Codable {
    
    var id = UUID()
    let timestamp: String
    let meals: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case timestamp = "timestamp"
        case meals = "meals"
    }
    
    static let placeholder = [FoodElement(timestamp: "14042022", meals: [Meal(name: "Essen 1", prices: Prices(student: 2.00, employee: 3.00, guest: 4.00), allergens: ["Ei", "4"], flags: ["G"]), Meal(name: "Essen 2", prices: Prices(student: 2.50, employee: 4.00, guest: 6.00), allergens: ["Wz", "7"], flags: ["CO2"]), Meal(name: "Essen 3", prices: Prices(student: 1.50, employee: 3.00, guest: 4.50), allergens: ["Ei", "13"], flags: ["G"])]), FoodElement(timestamp: "15042022", meals: [Meal(name: "Essen 1", prices: Prices(student: 2.00, employee: 3.00, guest: 4.00), allergens: ["Ei", "4"], flags: ["G"]), Meal(name: "Essen 2", prices: Prices(student: 2.50, employee: 4.00, guest: 6.00), allergens: ["Wz", "7"], flags: ["CO2"])])]
}


// MARK: - Meal
struct Meal: Identifiable, Codable {
    var id = UUID()
    let name: String
    let prices: Prices
    let allergens: [String]?
    let flags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case prices = "prices"
        case allergens = "allergens"
        case flags = "flags"
    }
}


// MARK: - Prices
struct Prices: Identifiable, Codable {
    var id = UUID()
    let student: Double?
    let employee: Double?
    let guest: Double?
    
    enum CodingKeys: String, CodingKey {
        case student = "student"
        case employee = "employee"
        case guest = "guest"
    }
}

typealias Food = [FoodElement]
