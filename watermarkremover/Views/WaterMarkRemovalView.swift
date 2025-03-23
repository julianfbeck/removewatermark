//
//  WaterMarkRemovalView.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//
import SwiftUI
import PhotosUI

struct WaterMarkRemovalView: View {
    @EnvironmentObject private var model: WaterMarkRemovalModel
    @EnvironmentObject private var globalViewModel: GlobalViewModel
    
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient with better contrast
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
                
                // Single gradient orb in background
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accentColor.opacity(0.6),
                                    Color.purple.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: geometry.size.width * 0.8)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.3)
                        .blur(radius: 60)
                }
                .ignoresSafeArea()
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        headerView
                        
                        imageSelectionView
                        
                        if model.isProcessing {
                            processingView
                        } else if let _ = model.processedImage {
                            // Display View Result button with Reset button inline
                            HStack(spacing: 15) {
                                Button {
                                    model.showResultView = true
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "eye")
                                            .font(.system(size: 18))
                                        Text("View Result")
                                            .font(.system(.body, design: .rounded, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.accentColor)
                                    )
                                    .foregroundColor(.white)
                                }
                                .shadow(radius: 4, x: 0, y: 2)
                                
                                Button {
                                    model.clearImages()
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 18))
                                        Text("New Image")
                                            .font(.system(.body, design: .rounded, weight: .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.black.opacity(0.4))
                                    )
                                    .foregroundColor(.white)
                                }
                                .shadow(radius: 4, x: 0, y: 2)
                            }
                        }
                        
                        if let errorMessage = model.errorMessage {
                            VStack(spacing: 16) {
                                Text(errorMessage)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                
                                HStack(spacing: 16) {
                                    Button {
                                        if let image = model.selectedImage {
                                            model.processImage(image)
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Retry")
                                        }
                                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.accentColor)
                                        )
                                    }
                                    .disabled(model.selectedImage == nil)
                                    .opacity(model.selectedImage == nil ? 0.5 : 1)
                                    
                                    Button {
                                        model.clearImages()
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                            Text("Reset")
                                        }
                                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.6))
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black.opacity(0.5))
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial)
                                    )
                            )
                            .shadow(radius: 8, x: 0, y: 4)
                        }
                        
                        // Add reset button when an image is selected but no error or result is shown
                        if model.selectedImage != nil && !model.isProcessing && model.errorMessage == nil && model.processedImage == nil {
                            Button {
                                model.clearImages()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Reset")
                                }
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.6))
                                )
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 40) // Increased top padding since we're hiding the nav bar
                }
            }
            // Navigation to ResultView
            .fullScreenCover(isPresented: $model.showResultView) {
                ResultView()
            }
            // Remove navigation title and hide the navigation bar
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if model.selectedImage != nil {
                        Button(action: {
                            model.clearImages()
                        }) {
                            Text("Clear")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Success!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your image has been saved to the photo library")
                    .font(.system(.body, design: .rounded))
            }
            .photosPicker(isPresented: $showImagePicker, selection: $photoPickerItem, matching: .images)
            .onChange(of: photoPickerItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            model.selectedImage = uiImage
                            model.processImage(uiImage)
                        }
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Remove Watermarks")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select an image to remove watermarks from your photos")
                .font(.system(.subheadline, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.vertical, 10)
    }
    
    private var imageSelectionView: some View {
        VStack(spacing: 16) {
            if let selectedImage = model.selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(16)
                    .shadow(radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                Text("Original Image")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            } else {
                selectImageButton
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.5))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .shadow(radius: 8, x: 0, y: 4)
        )
    }
    
    private var selectImageButton: some View {
        Button {
            showImagePicker = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "photo.stack")
                    .font(.system(size: 42))
                    .foregroundColor(.white)
                Text("Select Photo")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor, 
                                Color.accentColor.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(radius: 8, x: 0, y: 4)
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Removing watermark...")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.5))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .shadow(radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    WaterMarkRemovalView()
//        .environmentObject(WaterMarkRemovalModel())
//        .environmentObject(GlobalViewModel())
}
