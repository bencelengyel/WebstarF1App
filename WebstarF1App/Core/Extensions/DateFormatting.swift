//
//  DateFormatting.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.28.
//

import Foundation
 
enum DateFormatting {
    private static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
 
    private static let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
 
    static func format(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        return outputFormatter.string(from: date)
    }
}
