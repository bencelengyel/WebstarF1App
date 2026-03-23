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
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error)
            } else {
                List(viewModel.seasons) { season in
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
                }.navigationDestination(for: Season.self, destination: { season in
                    SeasonDriversView(season: season)
                })
            }
        }
        .task { await viewModel.fetchSeasons() }
        .navigationTitle("Seasons")
        
    }
}

#Preview {
    SeasonsView()
}
