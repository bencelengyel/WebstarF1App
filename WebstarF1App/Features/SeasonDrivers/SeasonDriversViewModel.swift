//
//  SeasonDriversViewModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

import Foundation
import Combine

@MainActor
class SeasonDriversViewModel: ObservableObject {
    @Published var drivers: [Driver] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    var nationalityCounts: [(String, Int)] {
        Dictionary(grouping: drivers, by: \.nationality)
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    func fetchSeasonDrivers(season: Season) async {
        guard let url = URL(string: "https://api.jolpi.ca/ergast/f1/\(season.year)/drivers?limit=100") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(DriverResponse.self, from: data)
            drivers = decoded.drivers
        } catch {
            errorMessage = error.localizedDescription
        }
        
    }
}
