import SwiftUI

// MARK: - Prayer Screen View
// The most important screen in the app
// "When thou prayest, enter into thy closet…" (Matthew 6:6)
//
// This screen is an altar, not a dashboard.
// Prayer is a state, not an action.
// Time is felt, not counted.

struct PrayerScreenView: View {
    
    @StateObject private var viewModel: PrayerSessionViewModel
    @EnvironmentObject var coordinator: RootCoordinator
    
    // Entry/exit animation state
    @State private var entryOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    
    init(session: PrayerSession) {
        _viewModel = StateObject(wrappedValue: PrayerSessionViewModel(session: session))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Deep charcoal background
                Color.prayerBackground
                    .ignoresSafeArea()
                
                // Atmospheric background warmth (deepens over time)
                atmosphericBackground(in: geometry)
                
                // Heat diffusion layers (convection-like motion)
                heatDiffusionLayers(in: geometry)
                
                // Central radial heat gradient (intensifies with prayer)
                centralHeatGradient(in: geometry)
                
                // Central altar - logo with long-press gesture
                centralAltar(in: geometry)
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .opacity(entryOpacity)
        .onAppear {
            enterPrayerSpace()
        }
    }
    
    // MARK: - Atmospheric Background
    
    /// Background that deepens from charcoal to deep ember over time
    private func atmosphericBackground(in geometry: GeometryProxy) -> some View {
        RadialGradient(
            colors: [
                Color.deepEmber.opacity(0.1 + viewModel.atmosphericDensity * 0.3),
                Color.charcoal
            ],
            center: .center,
            startRadius: geometry.size.width * 0.5,
            endRadius: geometry.size.width * 1.2
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Heat Diffusion Layers
    
    /// Multiple blurred layers that move slowly upward (convection)
    private func heatDiffusionLayers(in geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 300)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.ferventOrange.opacity(0.05 + viewModel.intensity * 0.15),
                                Color.emberRed.opacity(0.02 + viewModel.intensity * 0.08),
                                Color.deepEmber.opacity(0.01 + viewModel.intensity * 0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 200 + CGFloat(index * 50)
                        )
                    )
                    .frame(width: geometry.size.width * (0.5 + Double(index) * 0.15))
                    .frame(height: geometry.size.height * 0.6)
                    .offset(y: geometry.size.height * 0.3 + CGFloat(index * 30))
                    .blur(radius: 40 + CGFloat(index * 15) + CGFloat(viewModel.intensity * 20))
                    .opacity(0.6 + viewModel.intensity * 0.4)
            }
        }
        .animation(
            Animation.easeInOut(duration: max(5.0, 8.0 - viewModel.intensity * 4.0))
                .repeatForever(autoreverses: true),
            value: viewModel.intensity
        )
    }
    
    // MARK: - Central Heat Gradient
    
    /// Radial gradient that intensifies from center outward
    /// Represents spiritual heat accumulation, not flames
    private func centralHeatGradient(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Multiple layers for depth and atmospheric haze
            ForEach(0..<3, id: \.self) { layer in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.ferventOrange.opacity(0.1 + viewModel.intensity * (0.5 - Double(layer) * 0.1)),
                                Color.emberRed.opacity(0.05 + viewModel.intensity * (0.3 - Double(layer) * 0.05)),
                                Color.deepEmber.opacity(0.02 + viewModel.intensity * (0.1 - Double(layer) * 0.02)),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20 + CGFloat(layer * 10),
                            endRadius: 150 + CGFloat(viewModel.intensity * 200) + CGFloat(layer * 50)
                        )
                    )
                    .frame(width: geometry.size.width * (1.2 + Double(layer) * 0.3))
                    .blur(radius: 60 + CGFloat(viewModel.intensity * 40) + CGFloat(layer * 20))
                    .offset(y: geometry.size.height * 0.1)
                    .opacity(1.0 - Double(layer) * 0.2)
            }
        }
    }
    
    // MARK: - Central Altar
    
    /// The sacred center - logo with integrated long-press Amen gesture
    private func centralAltar(in geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            // Central altar area (logo + gesture region)
            ZStack {
                // Invisible gesture area (larger than logo)
                Circle()
                    .fill(Color.clear)
                    .frame(width: 200, height: 200)
                    .contentShape(Circle())
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
                
                // Fervent logo at center
                FerventLogo(
                    intensity: viewModel.isLongPressing ? 1.0 : viewModel.intensity,
                    isBreathing: true,
                    size: 80
                )
                .scaleEffect(logoScale)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Entry Animation
    
    /// Enter the prayer space - feels like entering a sacred place
    private func enterPrayerSpace() {
        // Logo emerges from darkness
        withAnimation(.ferventFade) {
            entryOpacity = 1.0
        }
        
        withAnimation(Animation.ferventFade.delay(0.1)) {
            logoScale = 1.0
        }
    }
    
    // MARK: - Actions
    
    private func completePrayer() {
        // Haptic feedback
        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactMedium.impactOccurred()
        
        // Begin cooling animation
        withAnimation(.ferventCompletion) {
            entryOpacity = 0.8
        }
        
        // Stop session
        viewModel.stopSession()
        
        // Navigate to completion (feels like departing)
        Task {
            // Brief pause to feel the cooling
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            await coordinator.completePrayer()
        }
    }
}

// MARK: - Preview

#Preview {
    PrayerScreenView(session: PrayerSession.startNew(intendedDuration: 300))
        .environmentObject(RootCoordinator())
}
