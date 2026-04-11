//
//  F1APIService.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.27.
//

import Foundation

struct F1APIService {
    private static let baseURL = "https://api.jolpi.ca/ergast/f1"
    
    func fetchSeasons() async throws -> [Season] {
        let response: SeasonResponse = try await fetch(from: Self.baseURL + "/seasons?limit=100")
        return response.seasons
    }
    
    func fetchDrivers(for year: String) async throws -> [Driver] {
        let response: DriverResponse = try await fetch(from: Self.baseURL + "/\(year)/drivers?limit=100")
        return response.drivers
    }

    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
}
