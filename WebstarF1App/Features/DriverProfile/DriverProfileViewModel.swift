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
    //let driver: Driver
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    @Published var driverImage: URL = URL(string: "https://via.placeholder.com/150")!
    
    func fetchDriverImage(name: String) async  {
        guard let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=AIzaSyADx9HTfg1vEtKt2KllxBhwpjB5qUvO52k&cx=000213537299717655806:fsqehiydnxg&q=\(name)_F1") else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(GoogleImageSearchResponse.self, from: data)
            
            if let urlString = decoded.imageURL,
               let foundImage = URL(string: urlString) {
                driverImage = foundImage
            } else {
                return
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
