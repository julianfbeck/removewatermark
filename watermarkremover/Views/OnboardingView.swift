//
//  OnboardingView.swift
//  watermarkremover
//
//  Created by Julian Beck on 25.05.25.
//

import SwiftUI
import ConfettiSwiftUI // Make sure to import the package


struct OnboardingView: View {
    @State private var currentPage = 0
    @EnvironmentObject var globalViewModel: GlobalViewModel
    
    // For haptic feedback
    let lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let mediumFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            ZStack {
                FirstOnboardingScreen()
                    .opacity(currentPage == 0 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
                
                SecondOnboardingScreen()
                    .opacity(currentPage == 1 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
                
                ThirdOnboardingScreen()
                    .opacity(currentPage == 2 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
            }
            
            Button(action: {
                lightFeedbackGenerator.prepare()
                
                if currentPage < 2 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                    // Light haptic for page changes
                    lightFeedbackGenerator.impactOccurred()
                } else {
                    // Medium haptic for completion
                    mediumFeedbackGenerator.prepare()
                    mediumFeedbackGenerator.impactOccurred()
                    // We're at the last screen, dismiss the onboarding
                    globalViewModel.isShowingOnboarding = false
                }
            }) {
                Text(currentPage == 2 ? "Get Started" : "Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .onAppear {
            // Prepare the haptic engines when view appears
            lightFeedbackGenerator.prepare()
            mediumFeedbackGenerator.prepare()
        }
    }
}

struct FirstOnboardingScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(Color.accentColor)
            
            Text("Remove Watermarks")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Easily remove watermarks from your photos with our advanced AI technology")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal)
    }
}


struct SecondOnboardingScreen: View {
    // Define animation phases
    enum AnimationPhase: CaseIterable {
        case initial, shaking, complete
    }
    
    // Auto-start the animation when view appears
    @State private var animationTrigger = 0
    
    // For haptic feedback
    let hapticFeedback = UINotificationFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // For confetti
    @State private var confettiCounter = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // PhaseAnimator for the transition
            PhaseAnimator(AnimationPhase.allCases, trigger: animationTrigger) { phase in
                ZStack {
                    // Original image (with watermark)
                    Image("example")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)  // Take up the full width
                        .padding(.horizontal, 20)    // Small padding on the sides
                        .cornerRadius(20)
                        .opacity(phase == .complete ? 0 : 1)
                        .offset(x: phase == .shaking ? 8 : 0)
                        .onChange(of: phase) { oldPhase, newPhase in
                            if newPhase == .shaking {
                                // Continuous haptic feedback during shaking
                                startShakingHaptics()
                            } else if newPhase == .complete {
                                // Success haptic when watermark is removed
                                hapticFeedback.notificationOccurred(.success)
                                // Trigger confetti
                                confettiCounter += 1
                            }
                        }
                    
                    // Replacement clean image
                    Image("example1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)  // Take up the full width
                        .padding(.horizontal, 20)    // Small padding on the sides
                        .cornerRadius(20)
                        .opacity(phase == .complete ? 1 : 0)
                }
                // Add confetti view
//                .overlay(
//                    ConfettiCannon(
//                        counter: $confettiCounter,
//                        num: 50,
//                        openingAngle: Angle(degrees: 0),
//                        closingAngle: Angle(degrees: 360),
//                        radius: 200
//                    )
//                )
            } animation: { phase in
                switch phase {
                case .initial:
                    .easeInOut(duration: 0.5)
                case .shaking:
                    .easeInOut(duration: 0.1).repeatCount(15)
                case .complete:
                    .easeInOut(duration: 0.8)
                }
            }
            
            Text("Powerful AI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            Text("Our app uses state-of-the-art AI to detect and remove watermarks while preserving image quality")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 40)
        .padding(.horizontal)
        .onAppear {
            // Prepare haptic feedback
            hapticFeedback.prepare()
            impactFeedback.prepare()
            
            // Start the animation after a small delay
            startAnimation()
        }
    }
    
    func startAnimation() {
        // Reset to initial state first
        animationTrigger = 0
        
        // Start the animation sequence after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animationTrigger += 1
            
            // Set up timer to restart animation after 8 seconds
            // This gives plenty of time for the clean image to be visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                startAnimation()
            }
        }
    }
    
    func startShakingHaptics() {
        // Create a timer for haptic feedback during shaking
        var hapticCount = 0
        let hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            hapticCount += 1
            impactFeedback.impactOccurred()
            
            // Stop after a number of haptic pulses
            if hapticCount >= 15 {
                timer.invalidate()
            }
        }
    }
}

struct ThirdOnboardingScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(Color.accentColor)
            
            Text("Simple & Fast")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Just upload your image, select the watermark area, and let our app do the magic for you")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(GlobalViewModel())
} 
