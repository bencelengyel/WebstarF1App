//
//  GoogleImageModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

struct CSEImage: Decodable {
    let src: String
}

struct PageMap: Decodable {
    let cse_image: [CSEImage]?
}

struct SearchItem: Decodable {
    let title: String
    let link: String
    let pagemap: PageMap?
}

struct GoogleImageSearchResponse: Decodable {
    let items: [SearchItem]
    
    var imageURL: String? {
            items.first?.pagemap?.cse_image?.first?.src
        }
}

/*struct Season: Codable, Identifiable, Hashable {
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

struct SeasonMRData: Codable {
    let seasonTable: SeasonTable
    
    enum CodingKeys: String, CodingKey {
            case seasonTable = "SeasonTable"
        }
}

struct SeasonResponse: Codable {
    let mrData: SeasonMRData
    
    enum CodingKeys: String, CodingKey {
        case mrData = "MRData"
    }
    
    var seasons: [Season] { mrData.seasonTable.seasons }
}*/
