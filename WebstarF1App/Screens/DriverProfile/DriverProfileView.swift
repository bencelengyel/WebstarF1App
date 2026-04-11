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
        driverCard(for: viewModel.driver)
            .frame(maxHeight: .infinity, alignment: .center)
            .background(Color(.systemGroupedBackground))
            .task { await viewModel.fetchDriverImage() }
        
        
}
    
    private func driverCard(for driver: Driver) -> some View {
        VStack(spacing: 0) {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 250)
            case .error, .empty:
                VStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                    Text("Couldn't load image")
                }
                .foregroundColor(.gray.opacity(0.4))
                .frame(maxWidth: .infinity, minHeight: 250)
                .background(Color.gray.opacity(0.1))
            case .loaded(let image):
                Color.clear
                    .frame(height: 250)
                    .overlay(
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(driver.givenName) \(driver.familyName)")
                        .font(.title.bold())
                    Spacer()
                    Button(action: {
                        if let urlString = driver.url, let url = URL(string: urlString) {
                            openURL(url)
                        }
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.borderless)
                    .font(.title2)
                }
                HStack {
                    if let number = driver.racingNumber { Text("#\(number)") }
                    if let code = driver.code { Text("(\(code))") }
                }
                .font(.title3)
                if let nationality = driver.nationality {
                    Text("\(NationalityFlags.flag(for: nationality)) \(nationality)")
                }
                if let dob = driver.dateOfBirth {
                    Text("Born \(DateFormatting.format(dob))")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding()
    }
}

#Preview {
    let previewDriver = Driver(id: "alonso", racingNumber: "14", code: "ALO", givenName: "Fernando", familyName: "Alonso", dateOfBirth: "1981-07-29", nationality: "Spanish", url: "http://en.wikipedia.org/wiki/Fernando_Alonso")
    NavigationStack {
        DriverProfileView(driver: previewDriver)
    }
}
