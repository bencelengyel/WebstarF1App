//
//  SeasonsViewModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.20.
//
import Foundation
import Combine

@MainActor
class SeasonsViewModel: ObservableObject {
    @Published var seasons: [Season] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiService = F1APIService()
    
    func fetchSeasons() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let decoded: SeasonResponse = try await apiService.fetch(from: "https://api.jolpi.ca/ergast/f1/seasons?limit=100")
            seasons = decoded.seasons.reversed()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
