//
//  SeasonsView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.20.
//

import SwiftUI

struct SeasonsView: View {
    @StateObject private var viewModel = SeasonsViewModel()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        List(viewModel.seasons) { season in
            HStack {
                Text(season.year)
                Spacer()
                Button(action: {
                    if let url = URL(string: season.url) {
                        openURL(url)
                    }
                },
                       label: {
                    Image(systemName: "info.circle")
                })
                .buttonStyle(.borderless)
            }
        }.task {
            await viewModel.fetchSeasons()
        }
    }
}

#Preview {
    SeasonsView()
}
