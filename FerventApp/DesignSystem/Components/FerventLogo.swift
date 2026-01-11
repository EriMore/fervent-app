import SwiftUI

// MARK: - Fervent Logo
// The sacred symbol - two interlocked squares
// "Tongues of Fire" (Acts 2:3)

struct FerventLogo: View {
    
    // MARK: - Properties
    
    /// Glow intensity (0.0 to 1.0) - affects opacity and scale
    var intensity: Double = 0.3
    
    /// Whether to show breathing animation
    var isBreathing: Bool = true
    
    /// Size of the logo
    var size: CGFloat = 80
    
    /// Stroke width
    var strokeWidth: CGFloat = 2.5
    
    // MARK: - Animation State
    
    @State private var breathingScale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Two interlocked rounded rectangles
            // Left square - slightly smaller, positioned lower
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.bone.opacity(glowOpacity), lineWidth: strokeWidth)
                .frame(width: size * 0.45, height: size * 0.45)
                .offset(x: -size * 0.25, y: 2)
            
            // Right square - slightly larger, positioned higher
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.bone.opacity(glowOpacity), lineWidth: strokeWidth)
                .frame(width: size * 0.55, height: size * 0.55)
                .offset(x: size * 0.25, y: -2)
        }
        .frame(width: size * 1.2, height: size)
        .scaleEffect(breathingScale)
        .onAppear {
            if isBreathing {
                startBreathing()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Glow opacity based on intensity
    private var glowOpacity: Double {
        0.3 + (intensity * 0.6) // Range: 0.3 to 0.9
    }
    
    // MARK: - Animations
    
    private func startBreathing() {
        withAnimation(.ferventBreathing) {
            breathingScale = 1.05
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.charcoal.ignoresSafeArea()
        
        VStack(spacing: 40) {
            FerventLogo(intensity: 0.3, isBreathing: true)
            FerventLogo(intensity: 0.6, isBreathing: true)
            FerventLogo(intensity: 1.0, isBreathing: true)
        }
    }
}
