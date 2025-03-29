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
                                NavigationLink(destination: ResultView()) {
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
                                    photoPickerItem = nil
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
                        
                        // Add a programmatic navigation link
                        NavigationLink(destination: ResultView(), isActive: $model.navigateToResult) {
                            EmptyView()
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
                                        photoPickerItem = nil
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                            Text("Reset")
                                        }
                                        .font(.system(.body, design: .rounded, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(Color.gray.opacity(0.3))
                                        )
                                        .foregroundColor(.white)
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
                                photoPickerItem = nil
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
            // Remove navigation title and hide the navigation bar
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if model.selectedImage != nil {
                        Button(action: {
                            model.clearImages()
                            photoPickerItem = nil
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
                            // Remove automatic processing
                            // model.processImage(uiImage)
                        }
                    }
                }
            }
            .onChange(of: model.navigateToResult) { navigating in
                if navigating {
                    // We'll reset the photoPickerItem after navigation completes
                    // This allows selection of a new image next time
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        photoPickerItem = nil
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Untag Photos")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundColor(.white)
            
            Text("Select an image to remove unwanted elements from your photos")
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
                
                if model.errorMessage != nil {
                    errorView
                } else {
                    // Always show the custom removal input field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What to remove:")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("Enter what to remove", text: $model.removalText)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.top, 8)
                    
                    // Start removal button
                    Button {
                        if !self.globalViewModel.isPro &&  globalViewModel.remainingUses <= 0 {
                           self.globalViewModel.isShowingPayWall = true
                            return
                        }
                            
                        if let image = model.selectedImage {
                            model.processImage(image)
                            globalViewModel.useFeature()
                            model.navigateToResult = true
                            
                            // Reset photoPickerItem after a slight delay
                            // This ensures we can select a new image when we return to this view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                photoPickerItem = nil
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 18))
                            Text("Start Removal")
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
                    .padding(.top, 8)
                }
            } else {
                VStack(spacing: 20) {
                    selectImageButton
                    
                    // Feature preview cards
                    featureCardsView
                }
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
            .overlay(
                VStack {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Tap to Begin")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.6))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(radius: 4)
                    .offset(y: -20)
                    
                    Spacer()
                }
            )
        }
    }
    
    // New feature cards view
    private var featureCardsView: some View {
        VStack(spacing: 16) {
            Text("How It Works")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 8)
            
            // Feature cards
            featureCard(
                icon: "sparkles.rectangle.stack",
                title: "Smart Detection",
                description: "Our AI automatically detects watermarks and elements to remove"
            )
            
            featureCard(
                icon: "wand.and.stars",
                title: "Seamless Removal",
                description: "Eliminates unwanted elements with smart content reconstruction"
            )
            
            featureCard(
                icon: "square.and.arrow.down",
                title: "Easy Export",
                description: "Save your clean images directly to your photo library"
            )
            
            // Inspirational message at the bottom
            VStack(spacing: 10) {
                Text("Ready to transform your photos?")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Select a photo above to start the magic")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.accentColor)
                    .padding(.top, 5)
            }
            .padding(.vertical, 20)
        }
    }
    
    private func featureCard(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accentColor,
                                    Color.purple
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.accentColor.opacity(0.5), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Untagging photo...")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(errorBackgroundStyle)
    }
    
    private var errorView: some View {
        VStack(spacing: 24) {
            // Error icon and heading
            VStack(spacing: 16) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.red)
                
                Text("Something Went Wrong")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Failed to process image: cancelled")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button {
                    // retry is always free
                    if let image = model.selectedImage {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if !globalViewModel.isPro  {
                                globalViewModel.isShowingPayWall = true
                            }
                        }
                        
                        model.processImage(image)
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.purple)
                    )
                    .foregroundColor(.white)
                }
                
                Button {
                    model.clearImages()
                    photoPickerItem = nil
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Reset")
                    }
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.95))
        )
    }
    
    private var errorBackgroundStyle: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.7))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .shadow(radius: 8, x: 0, y: 4)
    }
}

#Preview {
    WaterMarkRemovalView()
//        .environmentObject(WaterMarkRemovalModel())
//        .environmentObject(GlobalViewModel())
}
