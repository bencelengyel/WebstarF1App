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
        NavigationStack{
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .error(let message):
                ErrorView(message: message,
                          onRetry: { Task { await viewModel.fetchSeasons() }})
            case .empty:
                Text("No seasons available")
            case .loaded(let seasons):
                List(seasons) { season in
                    NavigationLink(value: season) {
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
                    }
                }
                .navigationTitle("Seasons")
                .navigationDestination(for: Season.self, destination: { season in
                    SeasonDriversView(season: season)
                })
            }
        }
        .task { await viewModel.fetchSeasons() }
        
    }
}

#Preview {
    SeasonsView()
}
