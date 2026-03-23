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
    
    func fetchSeasons() async {
        guard let url = URL(string: "https://api.jolpi.ca/ergast/f1/seasons?limit=100") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(SeasonResponse.self, from: data)
            seasons = decoded.seasons.reversed()
        } catch {
            errorMessage = error.localizedDescription
        }
        
    }
}
