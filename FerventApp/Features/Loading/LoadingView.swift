import SwiftUI

// MARK: - Loading View
// The first screen anyone sees when entering Fervent
// "Nothing pops. Everything settles."
//
// Fire is expressed through heat diffusion and glow gradients,
// not literal flames. The logo breathes gently.

struct LoadingView: View {
    
    // MARK: - Animation State
    
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.95
    @State private var isBreathing: Bool = false
    @State private var spinnerRotation: Double = 0
    @State private var spinnerOpacity: Double = 0
    
    // MARK: - Callback
    
    /// Called when loading completes and ready to transition
    var onLoadingComplete: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep charcoal base
                Color.charcoal
                    .ignoresSafeArea()
                
                // Radial heat gradient - warmth emanating from center
                heatGradient(in: geometry)
                
                // Content
                VStack(spacing: FerventSpacing.xl) {
                    Spacer()
                    
                    // Fervent Logo (with embedded wordmark)
                    logoView
                    
                    Spacer()
                    
                    // Subtle loading indicator
                    loadingIndicator
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                }
            }
        }
        .statusBarHidden(true)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Heat Gradient Background
    
    /// Radial gradient simulating heat diffusion from center
    /// Warm, never neon. High contrast, never harsh.
    private func heatGradient(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Primary radial gradient - deep ember glow
            RadialGradient(
                colors: [
                    Color.deepEmber.opacity(0.5),
                    Color.deepEmber.opacity(0.2),
                    Color.charcoal
                ],
                center: .center,
                startRadius: 50,
                endRadius: geometry.size.height * 0.7
            )
            .ignoresSafeArea()
            
            // Secondary subtle warmth layer
            RadialGradient(
                colors: [
                    Color.emberRed.opacity(0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: geometry.size.width * 0.5
            )
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Logo View
    
    /// The Fervent logo with breathing animation
    /// Logo includes the wordmark as provided
    private var logoView: some View {
        Image("FerventLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 200)
            .opacity(logoOpacity)
            .scaleEffect(logoScale)
    }
    
    // MARK: - Loading Indicator
    
    /// Custom warm-colored loading spinner
    /// Subtle, not clinical. Matches the fire aesthetic.
    private var loadingIndicator: some View {
        ZStack {
            // Track circle
            Circle()
                .stroke(Color.bone.opacity(0.1), lineWidth: 2)
                .frame(width: 32, height: 32)
            
            // Animated arc
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.ferventOrange,
                            Color.ferventOrange.opacity(0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(spinnerRotation))
        }
        .opacity(spinnerOpacity)
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        // Logo fades in with ferventFade timing
        withAnimation(.ferventFade) {
            logoOpacity = 1.0
        }
        
        // Logo settles into position
        withAnimation(.ferventFade.delay(0.1)) {
            logoScale = 1.0
        }
        
        // Start breathing after initial fade
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            startBreathing()
        }
        
        // Spinner fades in after logo
        withAnimation(.ferventFade.delay(0.4)) {
            spinnerOpacity = 1.0
        }
        
        // Start spinner rotation
        withAnimation(
            .linear(duration: 1.5)
            .repeatForever(autoreverses: false)
        ) {
            spinnerRotation = 360
        }
        
        // Trigger completion after loading period
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            onLoadingComplete?()
        }
    }
    
    /// Gentle breathing animation - subtle scale pulse
    private func startBreathing() {
        isBreathing = true
        withAnimation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true)
        ) {
            logoScale = 1.03
        }
    }
}

// MARK: - Preview

#Preview {
    LoadingView {
        print("Loading complete!")
    }
}
