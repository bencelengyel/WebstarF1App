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
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .error:
                ErrorView(message: "Something went wrong", onRetry: { Task { await viewModel.fetchDrivers(for: season) } })
            case .empty:
                Text("Couldn't load any drivers for this season")
            case .loaded:
                List {
                    if viewModel.searchText.isEmpty {
                        Section("Nationalities") {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))]) {
                                ForEach(viewModel.nationalityCounts, id: \.0) { nationality, count in
                                    Text("\(NationalityFlags.flag(for: nationality)) \(count)")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(.white)
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                }
                            }
                            .padding(.vertical, 4)
                            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .listRowBackground(Color(.systemGroupedBackground))
                        }
                    }
                    Section("Drivers") {
                        if viewModel.filteredDrivers.isEmpty {
                            Text("No drives that match the search criteria")
                        }else {
                            ForEach(viewModel.filteredDrivers) { driver in
                                DriverRow(for: driver)
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
            }
        }
        .task { await viewModel.fetchDrivers(for: season) }
        .navigationTitle("\(season.year) season")
        .navigationDestination(for: Driver.self, destination: { driver in
            DriverProfileView(driver: driver)
        })
    }
    
    private func DriverRow(for driver: Driver) -> some View {
        NavigationLink(value: driver) {
            HStack {
                HStack {
                    if viewModel.hasDriverWithNumber {
                        Text(driver.racingNumber ?? "—")
                            .font(.title)
                            .frame(minWidth: 48, alignment: .center)
                    }
                    VStack (alignment: .leading) {
                        HStack {
                            Text("\(driver.givenName) \(driver.familyName)").font(.headline)
                            if let nationality = driver.nationality { Text(NationalityFlags.flag(for: nationality)) }
                        }
                        if let dob = driver.dateOfBirth { Text("Born " + DateFormatting.format(dob)).font(.footnote) }
                    }
                    
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
    let previewSeason = Season(year: "2025", url: "")
//    let previewDriver = Driver(id: "alonso", racingNumber: "14", code: "ALO", givenName: "Fernando", familyName: "Alonso", dateOfBirth: "1981-07-29", nationality: "Spanish", url: "http://en.wikipedia.org/wiki/Fernando_Alonso")
    NavigationStack {
            SeasonDriversView(season: previewSeason)
        }
}
