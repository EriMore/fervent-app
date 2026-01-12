import SwiftUI

// MARK: - Loading View
// The first screen anyone sees when entering Fervent
// Vibrant heat gradient with centered logo
// "Our God is a consuming fire"

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
                // Vibrant Heat Gradient Background
                vibrantAtmosphere
                
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
    
    /// Vibrant vertical gradient: Orange -> Red -> Deep Ember
    /// Matches the reference image's warm, intense heat
    private var vibrantAtmosphere: some View {
        LinearGradient(
            colors: [
                Color.ferventOrange,  // Top: Bright Fire
                Color.emberRed,       // Middle: Deep Red
                Color.deepEmber       // Bottom: Dark Ember
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Logo View
    
    /// The Fervent logo asset (includes wordmark)
    private var logoView: some View {
        Image("FerventLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 180)
            .opacity(logoOpacity)
            .scaleEffect(logoScale)
    }
    
    // MARK: - Loading Indicator
    
    /// Minimal loading spinner - White for contrast against vibrant background
    private var loadingIndicator: some View {
        ZStack {
            // Track circle - subtle white
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            // Animated arc - pure white
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(
                    Color.white,
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
        
        // Trigger completion after 4 seconds (per user request)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
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
