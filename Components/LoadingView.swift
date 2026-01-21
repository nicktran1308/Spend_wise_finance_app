//
//  LoadingView.swift
//  spendwise_nick
//
//  Created by Nick on 1/20/26.
//

import SwiftUI

/// Reusable loading indicator
struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentBlue)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    LoadingView()
        .preferredColorScheme(.dark)
}
