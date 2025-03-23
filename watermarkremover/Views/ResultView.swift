//
//  ResultView.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//

import SwiftUI

struct ResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var model: WaterMarkRemovalModel
    
    @State private var showComparison = false
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.9),
                    Color.accentColor.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Result")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Image viewer
                        if let processedImage = model.processedImage {
                            if showComparison, let originalImage = model.selectedImage {
                                ComparisonView(
                                    originalImage: originalImage,
                                    processedImage: processedImage
                                )
                                .frame(height: 400)
                                .cornerRadius(16)
                                .shadow(radius: 10, x: 0, y: 5)
                            } else {
                                Image(uiImage: processedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 400)
                                    .cornerRadius(16)
                                    .shadow(radius: 10, x: 0, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            
                            // Toggle comparison button
                            Button {
                                withAnimation {
                                    showComparison.toggle()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: showComparison ? "rectangle.fill" : "rectangle.on.rectangle")
                                        .font(.system(size: 18))
                                    Text(showComparison ? "Show Result" : "Compare Original")
                                        .font(.system(.body, design: .rounded, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                                .foregroundColor(.white)
                            }
                            
                            // Action buttons
                            HStack(spacing: 15) {
                                ActionButton(
                                    title: "Save",
                                    icon: "square.and.arrow.down",
                                    backgroundColor: Color.accentColor
                                ) {
                                    saveImageToPhotoLibrary(processedImage)
                                }
                                
                                ActionButton(
                                    title: "New Image",
                                    icon: "photo",
                                    backgroundColor: Color.black.opacity(0.4),
                                    action:  {
                                        model.clearImages()
                                        dismiss()
                                    }, showBorder: true)
                            }
                        } else {
                            Text("No processed image available")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = model.processedImage {
                ShareSheet(items: [image])
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

// MARK: - Helper Views

struct ComparisonView: View {
    let originalImage: UIImage
    let processedImage: UIImage
    
    @State private var sliderPosition: CGFloat = 0.5
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Container for both images
                ZStack(alignment: .leading) {
                    // Original image (full width, visible on left side)
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    // Processed image (masked to show only right side)
                    Image(uiImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .mask(
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: geometry.size.width * sliderPosition)
                                    .opacity(0) // Make left side transparent
                                Rectangle()
                                    .frame(width: geometry.size.width * (1 - sliderPosition))
                            }
                        )
                }
                
                // Divider line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: geometry.size.height)
                    .position(x: geometry.size.width * sliderPosition, y: geometry.size.height / 2)
                
                // Slider handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .shadow(radius: 2)
                    .overlay(
                        HStack(spacing: 0) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 10, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.accentColor)
                    )
                    .position(x: geometry.size.width * sliderPosition, y: geometry.size.height / 2)
                
                // Labels
                VStack {
                    HStack {
                        // Original label
                        Text("Original")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .offset(x: geometry.size.width * 0.25 - 35)
                        
                        Spacer()
                        
                        // Processed label
                        Text("Processed")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .offset(x: -geometry.size.width * 0.25 + 40)
                    }
                    .frame(width: geometry.size.width)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                
                // Gesture area
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newPosition = value.location.x / geometry.size.width
                                sliderPosition = min(max(newPosition, 0), 1)
                            }
                    )
            }
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let action: () -> Void
    var showBorder: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(.body, design: .rounded, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(backgroundColor)
                    .overlay(
                        showBorder ?
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                            : nil
                    )
            )
            .foregroundColor(.white)
            .shadow(radius: 4, x: 0, y: 2)
        }
        .frame(height: 56) // Fixed height for all buttons
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultView()
        .environmentObject(WaterMarkRemovalModel())
}

