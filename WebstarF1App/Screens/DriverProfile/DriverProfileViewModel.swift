//
//  DriverProfileViewModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

import Foundation
import Combine
import UIKit

@MainActor
class DriverProfileViewModel: ObservableObject {
    private let imageService = ImageLoader()
    
    @Published var state: ViewState<UIImage> = .idle
    
    let driver: Driver
    
    init(driver: Driver) {
        self.driver = driver
    }

    
    func fetchDriverImage() async {
        state = .loading
        
        if let image = await imageService.fetch(for: "\(driver.givenName)_\(driver.familyName)_F1") {
            state = .loaded(image)
        } else {
            state = .empty
        }
    }
}
