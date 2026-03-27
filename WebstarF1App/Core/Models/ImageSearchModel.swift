//
//  ImageSearchModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

struct CSEImage: Decodable {
    let src: String
}

struct PageMap: Decodable {
    let cse_image: [CSEImage]?
}

struct SearchItem: Decodable {
    let title: String
    let link: String
    let pagemap: PageMap?
}

struct ImageSearchResponse: Decodable {
    let items: [SearchItem]
    
    var imageURL: String? {
            items.first?.pagemap?.cse_image?.first?.src
        }
}
