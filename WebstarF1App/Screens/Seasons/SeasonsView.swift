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
            case .error:
                ErrorView(message: "Something went wrong", onRetry: { Task { await viewModel.fetchSeasons() }})
            case .empty:
                Text("Couldn't load seasons")
            case .loaded(let seasons):
                ScrollView {
                    ForEach(seasons) { season in
                        NavigationLink(value: season) {
                            SeasonCard(season)
                        }
                    }
                }
                .navigationTitle("F1 Seasons")
                .navigationDestination(for: Season.self, destination: { season in
                    SeasonDriversView(season: season)
                })
            }
        }
        .task { await viewModel.fetchSeasons() }
    }
    
    private func SeasonCard(_ season: Season) -> some View {
        LazyVStack (spacing: 0) {
            Image(SeasonImage.name(for: season.year))
                .resizable()
                .aspectRatio(contentMode: .fill)
            HStack {
                Text(season.year)
                    .font(.title3)
                    .foregroundStyle(.black)
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
            .padding()
            
        }
        .aspectRatio(5/3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 4, y: 2)
        )
        .padding()
    }
}

#Preview {
    SeasonsView()
}
