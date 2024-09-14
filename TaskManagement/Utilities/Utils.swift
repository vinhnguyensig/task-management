//
//  Utils.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation

class Utils {
    static func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    static func taskDateFormatter(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    static func monthYearFormatter(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    static func clearSpecialChar(text: String) -> String {
        let pattern = "[^a-zA-Z0-9 .,?!\n:]"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: text.utf16.count)
            
            let cleanedString = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
            
            return cleanedString
        } catch {
            print("Error creating regex: \(error)")
            return text
        }
    }

}
