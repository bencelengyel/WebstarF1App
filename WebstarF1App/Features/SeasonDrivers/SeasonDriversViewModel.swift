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
    
    @Published var drivers: [Driver] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    
    
    var nationalityCounts: [(String, Int)] {
        Dictionary(grouping: drivers.compactMap(\.nationality), by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .map { ($0.key, $0.value) }
    }
    
    func fetchDrivers(from season: Season) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            drivers = try await apiService.fetchDrivers(from: season.year)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
