//
//  DriverProfileView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//
import SwiftUI

struct DriverProfileView: View {
    let driver: Driver
    
    @StateObject private var viewModel = DriverProfileViewModel()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack (alignment: .leading){
                HStack (alignment: .top){
                Text("\(driver.givenName) \(driver.familyName)")
                if let code = driver.code { Text("- \(code)")}
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
            Text("Nationality: \(driver.nationality)")
            if let number = driver.racingNumber { Text("Number: \(number)")}
            Text("Date of birth: \(driver.dateOfBirth)")
            
        }
    }
}
