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
                
                // Subtle dark background - bare minimum visibility
                darkAtmosphere(in: geometry)
                
                // Content Layer
                ZStack {
                    // Centered Logo (contains wordmark)
                    logoView
                    
                    // Bottom Loading Indicator
                    VStack {
                        Spacer()
                        loadingIndicator
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 60)
                    }
                }
            }
        }
        .statusBarHidden(true)
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Background
    
    /// Extremely subtle, deep atmospheric background
    /// "Deep darkness... The stillness before and around the fire"
    private func darkAtmosphere(in geometry: GeometryProxy) -> some View {
        RadialGradient(
            colors: [
                Color.deepEmber.opacity(0.15), // Very faint center
                Color.charcoal.opacity(0.8),   // Darkens quickly
                Color.charcoal                 // Pure charcoal edges
            ],
            center: .center,
            startRadius: 10,
            endRadius: geometry.size.width * 0.8
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Logo View
    
    /// The Fervent logo asset (includes wordmark)
    private var logoView: some View {
        Image("FerventLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 180) // Slightly smaller to be tasteful
            .opacity(logoOpacity)
            .scaleEffect(logoScale)
    }
    
    // MARK: - Loading Indicator
    
    /// Minimal, dark loading spinner
    private var loadingIndicator: some View {
        ZStack {
            // Track circle - barely visible
            Circle()
                .stroke(Color.charcoal.opacity(0.5), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            // Animated arc - deep ember, not bright orange
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.emberRed.opacity(0.8),
                            Color.deepEmber.opacity(0)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 24, height: 24)
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
