//
//  FoodWidgetProvider.swift
//  Neuland Food WidgetExtension
//
//  Created by Robert Eggl on 08.10.22.
//

import Foundation


class FoodWidgetProvider {
    func getMensaData(location: Enum, completion: @escaping ([FoodElement]?) -> Void){
        let url: URL
        switch location {
        case .reimanns: url = NeulandAPI.reimanns.asURL()
        case .mensa: url = NeulandAPI.mensa.asURL()
        default: url = NeulandAPI.mensa.asURL()
        }
        
        URLSession.shared.dataTask(with: url){ d, res, err in
            var result: [FoodElement]?
            
            if let data = d,
               let response = res as? HTTPURLResponse,
               response.statusCode == 200 {
                do{
                    result = try JSONDecoder().decode([FoodElement].self, from: data)
                    result = result?.filter({ Helper.stringToDate(dateString: $0.timestamp) >= Date().stripTime() })
                }catch{
                    print(error)
                }
            }
            
            return completion(result)
        }
        .resume()
    }
}

enum LocationNames: String, CaseIterable {
    case unkown
    case mensa
    case reimanns
    
    var names: String {
        switch self {
        case .unkown:
            return "Mensa"
        case .mensa:
            return "Mensa"
        case .reimanns:
            return "Reimanns"
        }
    }
}
