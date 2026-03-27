//
//  F1APIService.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.27.
//

import Foundation

struct F1APIService {
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
}
