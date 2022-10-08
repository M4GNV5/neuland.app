//
//  Helper.swift
//  App
//
//  Created by Robert Eggl on 09.10.22.
//

import Foundation


class Helper {
    
    static func changeDateFormat(dateString: String) -> String {
        let date = stringToDate(dateString: dateString)
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateStyle = .long
        outputDateFormatter.locale = Locale.current
        outputDateFormatter.doesRelativeDateFormatting = true
        return outputDateFormatter.string(from: date)
    }
    
    static func widgetDateFormat(dateString: String) -> String {
        let date = stringToDate(dateString: dateString)
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "EEEE, dd. MMMM"
        outputDateFormatter.locale = Locale.current
        return outputDateFormatter.string(from: date)
    }
    
    static func stringToDate(dateString: String) -> Date {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd"
        return inputDateFormatter.date(from: dateString) ?? Date()
    }
}

extension Date {
    
    func stripTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date = Calendar.current.date(from: components)
        return date!
    }
}
