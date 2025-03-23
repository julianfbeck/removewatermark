//
//  AppError.swift
//  watermarkremover
//
//  Created by Julian Beck on 23.03.25.
//


import Foundation
import SwiftUI
import os.log

// View model acting as a bridge between our views and the TryOnService actor
@MainActor
class WaterMarkRemovalModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var processedImage: UIImage?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.julianbeck.watermarkremover",
        category: "WaterMarkRemovalModel"
    )
    
    func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        
        // Simulate processing the image
        // In a real implementation, this would be where the watermark removal algorithm runs
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            // For demo purposes, just using the original image
            // In a real implementation, this would be the processed image
            self.processedImage = image
            self.isProcessing = false
            self.logger.info("Image processed successfully")
        }
    }
    
    func clearImages() {
        selectedImage = nil
        processedImage = nil
        errorMessage = nil
    }
}
