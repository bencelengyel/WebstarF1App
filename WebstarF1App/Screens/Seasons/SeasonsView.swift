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
    @State private var expandedEras: Set<String> = ["2020 – 2026"]
    
    var body: some View {
        NavigationStack {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .error:
                ErrorView(message: "Something went wrong", onRetry: { Task { await viewModel.fetchSeasons() } })
            case .empty:
                Text("Couldn't load seasons")
            case .loaded(let seasons):
                ScrollView {
                    ForEach(groupByEra(seasons), id: \.label) { era in
                        eraCard(for: era.seasons, label: era.label, image: era.image)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("F1 Seasons")
                .navigationDestination(for: Season.self) { season in
                    SeasonDriversView(season: season)
                }
            }
        }
        
        .task { await viewModel.fetchSeasons() }
    }
    
    private func eraCard(for seasons: [Season], label: String, image: String) -> some View {
        let isExpanded = Binding(
            get: { expandedEras.contains(label) },
            set: { newValue in
                if newValue { expandedEras.insert(label) }
                else { expandedEras.remove(label) }
            }
        )
        
        return VStack(spacing: 0) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .onTapGesture {
                    withAnimation { isExpanded.wrappedValue.toggle() }
                }
            
            DisclosureGroup(isExpanded: isExpanded) {
                Divider()
                ForEach(seasons) { season in
                    NavigationLink(value: season) {
                        VStack {
                            HStack {
                                Text(season.year)
                                    .font(.title3)
                                    .foregroundStyle(Color(.label))
                                
                                Button {
                                    if let url = URL(string: season.url) { openURL(url) }
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                                .buttonStyle(.borderless)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            Divider()
                        }
                    }
                }
            } label: {
                Text(label)
                    .font(.title3)
                    .foregroundStyle(Color(.label))
                    .padding()
            }
            .padding(.trailing)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(radius: 4, y: 2)
        )
        .padding()
    }
    
    private func groupByEra(_ seasons: [Season]) -> [(label: String, image: String, seasons: [Season])] {
        let decades: [(range: ClosedRange<Int>, label: String, image: String)] = [
            (2020...2029, "2020 – 2026", "era_2020s"),
            (2010...2019, "2010 – 2019", "era_2010s"),
            (2000...2009, "2000 – 2009", "era_2000s"),
            (1990...1999, "1990 – 1999", "era_1990s"),
            (1980...1989, "1980 – 1989", "era_1980s"),
            (1970...1979, "1970 – 1979", "era_1970s"),
            (1960...1969, "1960 – 1969", "era_1960s"),
            (1950...1959, "1950 – 1959", "era_1950s"),
        ]
        
        return decades.compactMap { decade in
            let matching = seasons.filter { season in
                guard let y = Int(season.year) else { return false }
                return decade.range.contains(y)
            }
            guard !matching.isEmpty else { return nil }
            return (label: decade.label, image: decade.image, seasons: matching)
        }
    }
}

#Preview {
    SeasonsView()
}
