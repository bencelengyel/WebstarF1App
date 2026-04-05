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
    private let apiService = F1APIService()
    
    @Published var searchText: String = ""
    @Published var state: ViewState<[Driver]> = .idle
    
    private var drivers: [Driver] {
        if case .loaded(let drivers) = state {
            return drivers.filter { $0.nationality != nil }
        }
        return []
    }
    
    var filteredDrivers: [Driver] {
        if searchText.isEmpty { return drivers }
        let query = searchText.lowercased()
        return drivers.filter {
            $0.givenName.lowercased().contains(query)
            || $0.familyName.lowercased().contains(query)
            || ($0.nationality?.lowercased().contains(query) ?? false)
        }
    }
    
    var nationalityCounts: [(String, Int)] {
        Dictionary(grouping: drivers.compactMap(\.nationality), by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    func fetchDrivers(for season: Season) async {
        state = .loading
        
        do {
            let result = try await apiService.fetchDrivers(for: season.year)
            state = result.isEmpty ? .empty : .loaded(result)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
