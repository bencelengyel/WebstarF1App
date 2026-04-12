//
//  ImageSearchService.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.27.
//

import Foundation

struct ImageURLService {
    private let apiKey = "API_KEY"
    private let engineKey = "ENGINE_KEY"
    
    func fetchImageURL(for query: String) async throws -> URL? {
        guard let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=\(apiKey)&cx=\(engineKey)&q=\(query)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ImageSearchResponse.self, from: data)
        
        guard let urlString = decoded.imageURL else { return nil }
        return URL(string: urlString)
    }
}
