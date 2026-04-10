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
    @Published var selectedNationality: String?
    @Published var state: ViewState<[Driver]> = .idle
    
    private var drivers: [Driver] {
        if case .loaded(let drivers) = state {
            return drivers.filter { $0.nationality != nil }
        }
        return []
    }
    
    var hasDriverWithNumber: Bool {
        drivers.contains { $0.racingNumber != nil }
    }
    
    var filteredDrivers: [Driver] {
        var result = drivers
        if let nationality = selectedNationality {
            result = result.filter { $0.nationality == nationality }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.givenName.lowercased().contains(query)
                || $0.familyName.lowercased().contains(query)
                || ($0.nationality?.lowercased().contains(query) ?? false)
            }
        }
        return result
    }
    
    var nationalityCounts: [(String, Int)] {
        Dictionary(grouping: drivers.compactMap(\.nationality), by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }
    
    func fetchDrivers(for season: Season) async {
        state = .loading
        
        do {
            let result = try await apiService.fetchDrivers(for: season.year)
            state = result.isEmpty ? .empty : .loaded(result)
        } catch {
            let message = error.localizedDescription
            state = .error(message)
            print("Error while fetching drivers for \(season.year) season:" + message)
        }
    }
}
