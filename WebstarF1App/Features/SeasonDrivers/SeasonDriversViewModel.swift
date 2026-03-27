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
    
    private let apiService = F1APIService()
    
    var nationalityCounts: [(String, Int)] {
        Dictionary(grouping: drivers, by: \.nationality)
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    func fetchSeasonDrivers(season: Season) async {
        let url = "https://api.jolpi.ca/ergast/f1/\(season.year)/drivers?limit=100"
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let decoded: DriverResponse = try await apiService.fetch(from: url)
            drivers = decoded.drivers
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
