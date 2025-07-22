import SwiftUI
import ConfettiSwiftUI

struct SecondOnboardingScreen: View {
    // Animation state
    @State private var animationPhase = 1
    @State private var confettiTrigger = 0
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.0
    @State private var glowRadius: CGFloat = 0.0
    
    // Haptic feedback generators
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(spacing: 24) {
            // Title at the top
            Text("Remove Objects")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            // Image container
            ZStack {
                // Watermarked image
                if animationPhase == 1 || animationPhase == 2 {
                    Image("example")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.accentColor, lineWidth: 1))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(animationPhase == 2 ? 0.9 : 1.0)
                        .modifier(ShakeEffect(animating: animationPhase == 2))
                }
                
                // Clean image with glow effect
                if animationPhase == 3 {
                    Image("example1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.accentColor, lineWidth: 1))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(scale)
                        .transition(.scale)
                        // Inner glow effect
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.accentColor, lineWidth: 2)
                                .blur(radius: glowRadius)
                                .opacity(glowOpacity)
                        )
                        // Outer glow effect
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.accentColor)
                                .blur(radius: glowRadius * 2)
                                .opacity(glowOpacity * 0.5)
                                .scaleEffect(1.05)
                        )
                }
            }
            .animation(.easeInOut(duration: 0.5), value: animationPhase)
            .padding(.horizontal)
            .confettiCannon(
                trigger: $confettiTrigger,
                num: 50,
                confettis: [.shape(.circle), .shape(.triangle), .shape(.square)],
                colors: [.blue, .green, .red, .yellow, .purple],
                openingAngle: Angle(degrees: 60),
                closingAngle: Angle(degrees: 120),
                radius: 200
            )
            
            // Improved copywriting
            VStack(spacing: 16) {
                Text("One-tap magic for perfect photos")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text("Our advanced AI instantly detects and erases unwanted Objects while preserving the original quality of your precious memories.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        // Reset animation
        animationPhase = 1
        scale = 1.0
        glowOpacity = 0.0
        glowRadius = 0.0
        
        // After 1 second, start shaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                animationPhase = 2
            }
            
            
            // After 2 seconds of shaking, show the clean image
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    animationPhase = 3
                    confettiTrigger += 1
                }
                
                // Success haptic
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                
                // Apply scale animation to the clean image
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.2
                }
                
                // Animate the glow effect
                withAnimation(.easeIn(duration: 0.4)) {
                    glowOpacity = 0.8
                    glowRadius = 6
                }
                
                // Scale back to normal after a brief moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                    
                    // Pulse the glow effect
                    animateGlowPulse()
                }
                
                // Restart the animation after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    // Fade out glow before restarting
                    withAnimation(.easeOut(duration: 0.3)) {
                        glowOpacity = 0.0
                        glowRadius = 0.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        startAnimation()
                    }
                }
            }
        }
    }
    
    func animateGlowPulse() {
        // Create a subtle pulsing glow effect
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            glowOpacity = 0.6
            glowRadius = 4
        }
    }
    
}

// Custom shake effect modifier
struct ShakeEffect: ViewModifier {
    var animating: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: animating ? CGFloat(Int.random(in: -6...6)) : 0)
            .animation(
                animating ?
                .easeInOut(duration: 0.1)
                .repeatForever(autoreverses: true) :
                .default,
                value: animating
            )
    }
}
