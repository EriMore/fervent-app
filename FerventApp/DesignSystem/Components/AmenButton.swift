import SwiftUI

// MARK: - Amen Button Component
// A reusable long-press button for completing prayer
// "Nothing pops. Everything settles."

struct AmenButton: View {
    
    // MARK: - Properties
    
    /// Action to perform when long press completes
    let onComplete: () -> Void
    
    /// Duration required to hold (seconds)
    var holdDuration: TimeInterval = 2.0
    
    /// Button text
    var text: String = "Amen"
    
    // MARK: - State
    
    @State private var isPressed: Bool = false
    @State private var progress: Double = 0
    @State private var pressStartTime: Date?
    @State private var progressTimer: Timer?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: FerventSpacing.sm) {
            // Progress bar (visible when pressing)
            if isPressed {
                progressBar
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
            
            // Main button
            buttonContent
                .gesture(longPressGesture)
        }
        .animation(.ferventStandard, value: isPressed)
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(Color.bone.opacity(0.1))
                
                // Progress fill
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.ferventOrange, .warmAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(width: 180, height: 4)
    }
    
    // MARK: - Button Content
    
    private var buttonContent: some View {
        Text(text)
            .font(.ferventAmen)
            .foregroundColor(isPressed ? .ferventOrange : .bone.opacity(0.5))
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .padding(.horizontal, FerventSpacing.xl)
            .padding(.vertical, FerventSpacing.md)
    }
    
    // MARK: - Gesture
    
    private var longPressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isPressed {
                    startPress()
                }
                
                updateProgress()
                
                if progress >= 1.0 {
                    completePress()
                }
            }
            .onEnded { _ in
                if progress < 1.0 {
                    cancelPress()
                }
            }
    }
    
    // MARK: - Press Handling
    
    private func startPress() {
        isPressed = true
        pressStartTime = Date()
        progress = 0
        
        // Light haptic
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Start progress timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let start = pressStartTime, isPressed else { return }
        let elapsed = Date().timeIntervalSince(start)
        progress = min(1.0, elapsed / holdDuration)
    }
    
    private func cancelPress() {
        progressTimer?.invalidate()
        progressTimer = nil
        
        withAnimation(.ferventStandard) {
            isPressed = false
            progress = 0
        }
        pressStartTime = nil
    }
    
    private func completePress() {
        progressTimer?.invalidate()
        progressTimer = nil
        
        // Medium haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        onComplete()
        
        // Reset state
        isPressed = false
        progress = 0
        pressStartTime = nil
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.charcoal
            .ignoresSafeArea()
        
        AmenButton {
            print("Prayer completed!")
        }
    }
}

