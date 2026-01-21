//
//  ProgressBar.swift
//  spendwise_nick
//
//  Created by Nick on 1/13/26.
//

import SwiftUI

/// Reusable animated progress bar
struct ProgressBar: View {
    let progress: Double
    let color: Color
    var height: CGFloat = 10
    var backgroundColor: Color = Color.secondaryBackground
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                
                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(max(progress, 0), 1.0))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.3, color: .green)
        ProgressBar(progress: 0.7, color: .orange)
        ProgressBar(progress: 1.0, color: .red)
        ProgressBar(progress: 0.5, color: .blue, height: 20)
    }
    .padding()
    .background(Color.black)
}
