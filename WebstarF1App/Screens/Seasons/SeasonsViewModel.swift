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
    @Published var state: ViewState<[Season]> = .idle
    
    private let apiService = F1APIService()
    
    func fetchSeasons() async {
        state = .loading
        
        do {
            let result = try await apiService.fetchSeasons().reversed()
            state = result.isEmpty ? .empty : .loaded(Array(result))
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
