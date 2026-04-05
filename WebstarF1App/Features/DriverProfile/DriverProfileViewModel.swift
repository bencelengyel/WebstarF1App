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

    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var driverImage: URL? = nil

    let driver: Driver
    
    init(driver: Driver) {
        self.driver = driver
    }
    
    func fetchDriverImage() async  {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            driverImage = try await imageService.fetchImageURL(for: "\(driver.givenName)_\(driver.familyName)_F1")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
