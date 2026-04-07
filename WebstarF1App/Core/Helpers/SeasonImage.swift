//
//  SeasonImage.swift
//  WebstarF1App
//
//  Created by Bence on 2026.04.07.
//

enum SeasonImage {
    static func name(for year: String) -> String {
        guard let y = Int(year) else { return "era_1950s" }
        switch y {
        case ..<1960: return "era_1950s"
        case ..<1970: return "era_1960s"
        case ..<1980: return "era_1970s"
        case ..<1990: return "era_1980s"
        case ..<2000: return "era_1990s"
        case ..<2010: return "era_2000s"
        case ..<2020: return "era_2010s"
        default:      return "era_2020s"
        }
    }
}
