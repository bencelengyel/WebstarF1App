//
//  DriverProfileView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//
import SwiftUI

struct DriverProfileView: View {
    @StateObject private var viewModel: DriverProfileViewModel
    @Environment(\.openURL) private var openURL
    
    init(driver: Driver) {
        _viewModel = StateObject(wrappedValue: DriverProfileViewModel(driver: driver))
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12){
            AsyncImage(url: viewModel.driverImage) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }.task {
                await viewModel.fetchDriverImage()
            }
            HStack (alignment: .top, spacing: 0){
                Text("\(viewModel.driver.givenName) \(viewModel.driver.familyName)")
                if let code = viewModel.driver.code { Text("- \(code)")}
                Spacer()
                Button(action: {
                    if let urlString = viewModel.driver.url, let url = URL(string: urlString) {
                        openURL(url)
                    }
                },
                       label: {
                    Image(systemName: "info.circle")
                })
                .buttonStyle(.borderless)
            }
            if let nationality = viewModel.driver.nationality { Text("Nationality: \(nationality)") }
            if let number = viewModel.driver.racingNumber { Text("Number: \(number)") }
            if let dob = viewModel.driver.dateOfBirth { Text("Date of birth: \(DateFormatting.format(dob))") }
            Spacer()
        }
    }
}
