//
//  DriverProfileViewModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

import Foundation
import Combine

@MainActor
class DriverProfileViewModel: ObservableObject {
    private let imageService = ImageSearchService()
    
    @Published var state: ViewState<URL> = .idle
    
    
    let driver: Driver
    
    init(driver: Driver) {
        self.driver = driver
    }

    
    func fetchDriverImage() async  {
        state = .loading
        
        do {
            if let url = try await imageService.fetchImageURL(for: "\(driver.givenName)_\(driver.familyName)_F1") {
                state = .loaded(url)
            } else {
                state = .empty
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
