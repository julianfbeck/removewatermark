//
//  FirstOnboardingScreen.swift
//  watermarkremover
//
//  Created by Julian Beck on 26.03.25.
//


import SwiftUI

struct FirstOnboardingScreen: View {
    // Animation states
    @State private var titleOpacity = 0.0
    @State private var imageOpacity = 0.0
    @State private var featuresOpacity = 0.0
    
    // Feature items
    let features = [
        ("photo.badge.checkmark", "Remove Watermarks", "Erase logos, text & copyright notices"),
        ("lasso", "Object Removal", "Delete unwanted items & people"),
        ("rectangle.badge.checkmark", "Background Cleanup", "Replace or remove backgrounds")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // App logo and title
            VStack(spacing: 16) {
                Text("Untag")
                    .font(.system(size: 42, weight: .bold))
                
                Text("Remove anything from your photos")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            .opacity(titleOpacity)
            
            Image("iconapp")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                .padding(.horizontal, 32)
                .opacity(imageOpacity)
            
            // Key features
            VStack(alignment: .leading, spacing: 20) {
                Text("Key Features")
                    .font(.headline)
                    .padding(.leading, 16)
                
                ForEach(features, id: \.0) { feature in
                    HStack(spacing: 16) {
                        Image(systemName: feature.0)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .frame(width: 32, height: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(feature.1)
                                .font(.headline)
                            
                            Text(feature.2)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 16)
            .opacity(featuresOpacity)
            
            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    func startAnimations() {
        // Sequence the animations for a nicer reveal
        withAnimation(.easeOut(duration: 0.8)) {
            titleOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            imageOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            featuresOpacity = 1.0
        }
    }
}

// For preview purposes
struct FirstOnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        FirstOnboardingScreen()
    }
}
