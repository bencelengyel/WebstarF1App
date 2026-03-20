//
//  SeasonsView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.20.
//

import SwiftUI

struct SeasonsView: View {
    @StateObject private var viewModel = SeasonsViewModel()
    
    var body: some View {
        List(viewModel.seasons) { season in
                Text(season.year)
            }.task {
                await viewModel.fetchSeasons()
            }
    }
}

#Preview {
    SeasonsView()
}
