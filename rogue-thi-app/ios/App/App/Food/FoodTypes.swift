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
    var meals: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case timestamp = "timestamp"
        case meals = "meals"
    }
    
    static let placeholder = [FoodElement(timestamp: "14042022", meals: [Meal(name: "Daten konnten nicht geladen werden", category: "Essen", prices: Prices(student: 0.00, employee: 0.00, guest: 0.00), allergens: nil, flags: nil), Meal(name: "Bitte überprüfe deine Internetverbindung", category: "Essen", prices: Prices(student: 0.00, employee: 0.00, guest: 0.00), allergens: nil, flags: nil)])]
    }


// MARK: - Meal
struct Meal: Identifiable, Codable {
    var id = UUID()
    let name: String
    let category: String
    let prices: Prices
    let allergens: [String]?
    let flags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case category = "category"
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
