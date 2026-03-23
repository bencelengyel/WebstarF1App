//
//  Season.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.20.
//

struct Season: Codable, Identifiable, Hashable {
    var id: String { year }
    let year: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
            case year = "season"
            case url
        }
}

struct SeasonTable: Codable {
    let seasons : [Season]
    
    enum CodingKeys: String, CodingKey {
            case seasons = "Seasons"
        }
}

struct MRData: Codable {
    let seasonTable: SeasonTable
    
    enum CodingKeys: String, CodingKey {
            case seasonTable = "SeasonTable"
        }
}

struct SeasonResponse: Codable {
    let mrData: MRData
    
    enum CodingKeys: String, CodingKey {
        case mrData = "MRData"
    }
    
    var seasons: [Season] { mrData.seasonTable.seasons }
}
