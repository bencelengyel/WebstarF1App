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
        if case .loaded(let drivers) = state { return drivers }
        return []
    }
    
    private var regularDrivers: [Driver] {
        drivers.filter { $0.nationality != nil }
    }
    
    private var guestDrivers: [Driver] {
        drivers.filter { $0.nationality == nil }
    }
    
    var filteredRegularDrivers: [Driver] {
        if searchText.isEmpty { return regularDrivers }
        let query = searchText.lowercased()
        return regularDrivers.filter {
            $0.givenName.lowercased().contains(query)
            || $0.familyName.lowercased().contains(query)
            || ($0.nationality?.lowercased().contains(query) ?? false)
        }
    }
    
    var filteredGuestDrivers: [Driver] {
        if searchText.isEmpty { return guestDrivers }
        let query = searchText.lowercased()
        return guestDrivers.filter {
            $0.givenName.lowercased().contains(query)
            || $0.familyName.lowercased().contains(query)
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
