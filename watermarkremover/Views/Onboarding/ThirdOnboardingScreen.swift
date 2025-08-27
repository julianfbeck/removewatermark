//
//  ThirdOnboardingScreen.swift
//  watermarkremover
//
//  Created by Julian Beck on 26.03.25.
//
import SwiftUI

struct ThirdOnboardingScreen: View {
    // Selected options state
    @State private var selectedOptions: Set<String> = []
    
    // Removal options - limited to 5
    let removalOptions = [
        ("person", "People", "Remove or blur unwanted individuals", "person.crop.circle.badge.xmark"),
        ("background", "Backgrounds", "Replace or remove image backgrounds", "rectangle.badge.checkmark"),
        ("object", "Objects", "Remove photobombers and unwanted items", "lasso"),
        ("text", "Text", "Remove or edit text from images", "text.badge.minus")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("What Would You Like to Remove?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .padding(.horizontal)
            
            // Simple list of options
            VStack(spacing: 12) {
                ForEach(removalOptions, id: \.0) { option in
                    RemovalOptionRow(
                        icon: option.3,
                        title: option.1,
                        description: option.2,
                        isSelected: selectedOptions.contains(option.0),
                        action: {
                            toggleSelection(option.0)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // Helper function
    func toggleSelection(_ option: String) {
        // Apply haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Toggle selection
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}

// Simple row component for removal options
struct RemovalOptionRow: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .accentColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(0.1))
                    )
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .gray.opacity(0.5))
                    .font(.title3)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.05),
                            radius: isSelected ? 5 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
