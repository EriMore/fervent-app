import SwiftUI

// MARK: - Prayer Screen View
// The most important screen in the app
// "When thou prayest, enter into thy closet…" (Matthew 6:6)
//
// This screen must feel alive, weighty, reverent.
// No scrolling. No feeds. No clutter.
// The prayer screen is a threshold, not a dashboard.

struct PrayerScreenView: View {
    
    @StateObject private var viewModel: PrayerSessionViewModel
    @EnvironmentObject var coordinator: RootCoordinator
    
    // Animation state
    @State private var breathingScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var heatOffset: CGFloat = 0
    
    init(session: PrayerSession) {
        _viewModel = StateObject(wrappedValue: PrayerSessionViewModel(session: session))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep background
                Color.prayerBackground
                    .ignoresSafeArea()
                
                // Heat rising effect - subtle convection
                heatRisingLayer(in: geometry)
                
                // Central altar glow
                altarGlow(in: geometry)
                
                // Content
                VStack {
                    Spacer()
                    
                    // Timer (minimal)
                    timerDisplay
                    
                    Spacer()
                    
                    // Central altar / focus point
                    altarCenter(in: geometry)
                    
                    Spacer()
                    
                    // Amen button
                    amenButton
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                }
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            startAmbientAnimations()
        }
    }
    
    // MARK: - Timer Display
    
    private var timerDisplay: some View {
        Text(viewModel.formattedTime)
            .font(.ferventTimer)
            .foregroundColor(.bone.opacity(0.6 + viewModel.intensity * 0.4))
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.1), value: viewModel.elapsedTime)
    }
    
    // MARK: - Heat Rising Layer
    // Subtle convection-like motion in the background
    
    private func heatRisingLayer(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Multiple layers of heat distortion
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 200)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.emberRed.opacity(0.05 + viewModel.intensity * 0.1),
                                Color.ferventOrange.opacity(0.02 + viewModel.intensity * 0.05),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: geometry.size.width * (0.6 + Double(index) * 0.2))
                    .frame(height: geometry.size.height * 0.8)
                    .offset(y: heatOffset + CGFloat(index * 20))
                    .blur(radius: 30 + CGFloat(index * 10))
            }
        }
        .offset(y: geometry.size.height * 0.2)
    }
    
    // MARK: - Altar Glow
    // Central radial glow that intensifies with prayer
    
    private func altarGlow(in geometry: GeometryProxy) -> some View {
        Circle()
            .fill(
                RadialGradient.prayerIntensity(viewModel.intensity)
            )
            .frame(width: geometry.size.width * 1.5)
            .offset(y: geometry.size.height * 0.15)
            .scaleEffect(breathingScale)
            .blur(radius: 60)
    }
    
    // MARK: - Altar Center
    // The visual focus point - responds to stillness
    
    private func altarCenter(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    Color.ferventOrange.opacity(0.2 + viewModel.intensity * 0.3),
                    lineWidth: 2
                )
                .frame(width: 120, height: 120)
                .scaleEffect(breathingScale * 1.1)
            
            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.ferventOrange.opacity(0.3 + viewModel.intensity * 0.4),
                            Color.emberRed.opacity(0.1 + viewModel.intensity * 0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(breathingScale)
            
            // Core ember
            Circle()
                .fill(Color.ferventOrange.opacity(glowOpacity + viewModel.intensity * 0.3))
                .frame(width: 20, height: 20)
                .blur(radius: 5)
        }
    }
    
    // MARK: - Amen Button
    // Long-press to complete prayer - intentional friction
    
    private var amenButton: some View {
        VStack(spacing: FerventSpacing.sm) {
            // Progress indicator
            if viewModel.isLongPressing {
                ProgressView(value: viewModel.longPressProgress)
                    .progressViewStyle(AmenProgressStyle())
                    .frame(width: 200)
                    .transition(.opacity)
            }
            
            // Amen text/button
            Text("Amen")
                .font(.ferventAmen)
                .foregroundColor(
                    viewModel.isLongPressing
                    ? .ferventOrange
                    : .bone.opacity(0.5)
                )
                .scaleEffect(viewModel.isLongPressing ? 1.1 : 1.0)
                .animation(.ferventLongPress, value: viewModel.isLongPressing)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !viewModel.isLongPressing {
                                viewModel.startLongPress()
                                // Haptic feedback
                                let impactLight = UIImpactFeedbackGenerator(style: .light)
                                impactLight.impactOccurred()
                            }
                            
                            // Check for completion
                            if viewModel.checkLongPressComplete() {
                                completePrayer()
                            }
                        }
                        .onEnded { _ in
                            if !viewModel.checkLongPressComplete() {
                                viewModel.cancelLongPress()
                            }
                        }
                )
            
            Text("Hold to complete")
                .font(.ferventCaption)
                .foregroundColor(.secondaryText.opacity(0.5))
        }
    }
    
    // MARK: - Actions
    
    private func completePrayer() {
        // Haptic feedback
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactMedium.impactOccurred()
        
        // Stop session
        viewModel.stopSession()
        
        // Navigate to completion
        Task {
            await coordinator.completePrayer()
        }
    }
    
    // MARK: - Ambient Animations
    
    private func startAmbientAnimations() {
        // Breathing scale animation
        withAnimation(.ferventBreathing) {
            breathingScale = 1.05
        }
        
        // Glow pulse animation
        withAnimation(.ferventGlowPulse) {
            glowOpacity = 0.5
        }
        
        // Heat rising animation
        withAnimation(
            Animation
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
        ) {
            heatOffset = -30
        }
    }
}

// MARK: - Amen Progress Style
// Custom progress indicator for the long-press

struct AmenProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.bone.opacity(0.1))
                    .frame(height: 4)
                
                // Progress
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.ferventOrange, .warmAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * (configuration.fractionCompleted ?? 0),
                        height: 4
                    )
                    .animation(.linear(duration: 0.05), value: configuration.fractionCompleted)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Preview

#Preview {
    PrayerScreenView(session: PrayerSession.startNew(intendedDuration: 300))
        .environmentObject(RootCoordinator())
}

