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
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
                        ForEach(viewModel.nationalityCounts, id: \.0) { nationality, count in
                            Text("\(NationalityFlags.flag(for: nationality)) \(count)")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(16)
                        }
                    }
                }
            }
            if !viewModel.filteredRegularDrivers.isEmpty {
                Section("Drivers") {
                    ForEach(viewModel.filteredRegularDrivers) { driver in
                        driverRow(driver)
                    }
                }
            }
            
            if !viewModel.filteredGuestDrivers.isEmpty {
                Section("Guest Drivers") {
                    ForEach(viewModel.filteredGuestDrivers) { driver in
                        driverRow(driver)
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
    private func driverRow(_ driver: Driver) -> some View {
        NavigationLink(value: driver) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(driver.givenName) \(driver.familyName)")
                    if let number = driver.racingNumber { Text("Number: \(number)") }
                    if let nationality = driver.nationality { Text("Nationality: \(nationality)") }
                    if let dob = driver.dateOfBirth { Text("Date of birth: \(dob)") }
                }
                Spacer()
                if let urlString = driver.url, let url = URL(string: urlString) {
                    Button(action: {
                        
                        openURL(url)
                        
                    }, label: {
                        Image(systemName: "info.circle")
                    })
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

#Preview {
    SeasonDriversView(season: Season(year: "2019", url: "https://en.wikipedia.org/wiki/2019_Formula_One_World_Championship"))
}
