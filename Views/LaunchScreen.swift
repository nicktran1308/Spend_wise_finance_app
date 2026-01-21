//
//  LaunchScreen.swift
//  spendwise_nick
//
//  Created by Nick on 1/20/26.
//

import SwiftUI

/// Animated launch screen
struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    
    var body: some View {
        if showMainApp {
            MainTabView()
        } else {
            launchContent
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8)) {
                        isAnimating = true
                    }
                    
                    // Transition to main app after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMainApp = true
                        }
                    }
                }
        }
    }
    
    private var launchContent: some View {
        ZStack {
            // Background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.incomeGreen, Color.accentBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    Image(systemName: "dollarsign")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.0)
                }
                
                // App Name
                Text("SpendWise")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                // Tagline
                Text("Smart spending, simplified")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 10)
            }
        }
    }
}

#Preview {
    LaunchScreen()
        .preferredColorScheme(.dark)
}
