//
//  ErrorView.swift
//  WebstarF1App
//
//  Created by Bence on 2026.04.05.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack (spacing: 32) {
            Text(message)
                .font(.title)
            Button("Retry") {
                onRetry()
            }
                .buttonStyle(.borderedProminent)
                .font(.title3)
        }
        .padding()
    }
}

#Preview {
    ErrorView(message: "Something went wrong", onRetry: {})
}
