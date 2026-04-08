//
//  ImageCache.swift
//  WebstarF1App
//
//  Created by Bence on 2026.04.08.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    
    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func store(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
