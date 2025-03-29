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
    @Published var showResultView = false
    @Published var removalText = "unwanted elements"
    @Published var showConfetti = false
    @Published var navigateToResult = false
    
    private let serverURL = "https://watermark-remover.app.juli.sh/api/remove-watermark"
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.julianbeck.watermarkremover",
        category: "WaterMarkRemovalModel"
    )
    
    func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        showConfetti = false
        
        Task {
            do {
                let processedImg = try await removeWatermark(from: image)
                self.processedImage = processedImg
                self.showConfetti = true // Trigger confetti when successful
                self.logger.info("Image processed successfully")
            } catch {
                self.errorMessage = "Failed to process image: \(error.localizedDescription)"
                self.logger.error("Failed to process image: \(error.localizedDescription)")
            }
            self.isProcessing = false
        }
    }
    
    func clearImages() {
        selectedImage = nil
        processedImage = nil
        errorMessage = nil
        showResultView = false
        navigateToResult = false
        isProcessing = false
        showConfetti = false
    }
    
    private func removeWatermark(from image: UIImage) async throws -> UIImage {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "Untag", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        // Convert UIImage to base64 string
        let base64String = imageData.base64EncodedString()
        
        // Create request body
        let requestBody: [String: Any] = [
            "image": [
                "data": base64String,
                "mime_type": "image/jpeg"
            ],
            "removalText": removalText
        ]
        
        // Convert request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw NSError(domain: "Untag", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request"])
        }
        
        // Create URL request
        guard let url = URL(string: serverURL) else {
            throw NSError(domain: "Untag", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "Untag", code: 4, userInfo: [
                NSLocalizedDescriptionKey: "Server returned error: \(statusCode)",
                "serverResponse": errorMessage
            ])
        }
        
        // Create UIImage from response data
        guard let processedImage = UIImage(data: data) else {
            throw NSError(domain: "Untag", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from response data"])
        }
        
        return processedImage
    }
}
