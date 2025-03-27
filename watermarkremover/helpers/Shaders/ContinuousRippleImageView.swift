//
//  ContinuousRippleImageView.swift
//  watermarkremover
//
//  Created by Julian Beck on 27.03.25.
//


import SwiftUI

#Preview("Continuous Random Ripple") {
    ContinuousRippleImageView()
}

struct ContinuousRippleImageView: View {
    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0
    @State private var timer: Timer? = nil
    
    // Bounds for random ripple generation
    @State private var viewBounds: CGRect = .zero
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("example")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .modifier(RippleEffect(at: origin, trigger: counter))
                .shadow(radius: 3, y: 2)
                .background(GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            // Store the view bounds for random point generation
                            viewBounds = geometry.frame(in: .local)
                            // Start the continuous ripple timer
                            startContinuousRipple()
                        }
                })
            
            Spacer()
        }
        .padding()
        .onDisappear {
            // Clean up the timer when view disappears
            timer?.invalidate()
            timer = nil
        }
    }
    
    // Function to create ripples at random positions
    private func startContinuousRipple() {
        // Cancel any existing timer
        timer?.invalidate()
        
        // Create a new timer that triggers ripples randomly
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            // Generate random position within the view bounds
            let randomX = CGFloat.random(in: viewBounds.minX...viewBounds.maxX)
            let randomY = CGFloat.random(in: viewBounds.minY...viewBounds.maxY)
            
            // Update origin and counter to trigger new ripple
            origin = CGPoint(x: randomX, y: randomY)
            counter += 1
        }
    }
}

