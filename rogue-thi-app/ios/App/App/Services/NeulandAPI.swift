//
//  NeulandAPI.swift
//  App
//
//  Created by Robert Eggl on 08.10.22.
//

import Foundation


enum NeulandAPI {
    
    case mensa
    case reimanns
    
    
    static let baseURLString = "https://neuland.app/api/"
    
    
    var path: String {
        
        switch self {
        case .mensa:
            return "mensa"
        case .reimanns:
            return "reimanns"
        }
        
        
    }
    
    func asURL() -> URL {
        URL(string: NeulandAPI.baseURLString + path)!
    }
}




extension Encodable {
    func toJSONData() throws -> Data {
        try! JSONEncoder().encode(self)
    }
}
