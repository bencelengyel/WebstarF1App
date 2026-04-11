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
    private let apiService = F1APIService()
    
    @Published var state: ViewState<[Season]> = .idle
    
    func fetchSeasons() async {
        state = .loading
        
        do {
            let result = try await apiService.fetchSeasons().reversed()
            state = result.isEmpty ? .empty : .loaded(Array(result))
        } catch {
            let message = error.localizedDescription
            state = .error(message)
            print("Error while fetching seasons:" + message)
        }
    }
}
