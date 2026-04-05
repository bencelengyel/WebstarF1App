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
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            case .error(let message):
                VStack {
                    Image(systemName: "photo.fill")
                    Text(message)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .foregroundColor(.secondary)
            case .empty:
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.4))
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color.gray.opacity(0.1))
            case .loaded(let url):
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
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
        .task { await viewModel.fetchDriverImage() }
    }
}
