//
//  FieldView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

import SwiftUI

struct FieldView: View, Hashable {
    let season: Season
    
    var body: some View {
        Text(season.year)
    }
}

/*#Preview {
    FieldView()
}*/
