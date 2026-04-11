//
//  ImageFetchService.swift
//  WebstarF1App
//
//  Created by Bence on 2026.04.08.
//

import Foundation
import UIKit

struct ImageLoader {
    private let imageService = ImageURLService()
    
    func fetch(for query: String) async -> UIImage? {
        if let imageData = ImageCache.shared.image(for: query) { return imageData }
        
        do {
            guard let url = try await imageService.fetchImageURL(for: query) else { return nil }
            let (responseData, _) = try await URLSession.shared.data(from: url)
            guard let imageData = UIImage(data: responseData) else { return nil }
            ImageCache.shared.store(imageData, for: query)
            return imageData
        } catch {
            return nil
        }
    }
}
