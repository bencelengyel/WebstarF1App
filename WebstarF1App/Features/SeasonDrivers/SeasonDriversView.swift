//
//  SeasonDriversView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

import SwiftUI

struct SeasonDriversView: View {
    @StateObject private var viewModel = SeasonDriversViewModel()
    @Environment(\.openURL) private var openURL
    let season: Season
    
    var body: some View {
        List {
            if viewModel.searchText.isEmpty {
                Section("Nationalities") {
                    ForEach(viewModel.nationalityCounts, id: \.0) { nationality, count in
                        Text("\(nationality): \(count)")
                    }
                }
            }
            
            Section("Drivers") {
                ForEach(viewModel.filteredDrivers) { driver in
                    NavigationLink(value: driver) {
                        HStack {
                            VStack (alignment: .leading) {
                                Text("\(driver.givenName) \(driver.familyName)")
                                if let number = driver.racingNumber { Text("Number: \(number)")}
                                Text("Nationality: \(driver.nationality)")
                                Text("Date of birth: \(driver.dateOfBirth)")
                            }
                            Spacer()
                            Button(action: {
                                if let url = URL(string: driver.url) {
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
            }
        }
        .task { await viewModel.fetchSeasonDrivers(season: season) }
        .navigationTitle("\(season.year) season")
        .navigationDestination(for: Driver.self, destination: { driver in
            DriverProfileView(driver: driver)
        })
        .searchable(text: $viewModel.searchText)
    }
}

#Preview {
    SeasonDriversView(season: Season(year: "2019", url: "https://en.wikipedia.org/wiki/2019_Formula_One_World_Championship"))
}
