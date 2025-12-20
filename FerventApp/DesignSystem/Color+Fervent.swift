import SwiftUI

// MARK: - Fervent Color Palette
// Fire is not spectacle. It is energy, purity, transformation, and sustained presence.
// Colors are warm, never neon. Contrast is high, never harsh.

extension Color {
    
    // MARK: - Primary Colors
    
    /// Deep Fire Orange - The primary brand color
    /// Represents the consuming fire of prayer
    static let ferventOrange = Color(hex: "E13E07")
    
    /// Ember Red - Deep, sustained heat
    /// "Our God is a consuming fire" (Hebrews 12:29)
    static let emberRed = Color(hex: "B8261C")
    
    /// Warm Accent - Glowing highlights
    /// The warmth that builds with sustained prayer
    static let warmAccent = Color(hex: "F79544")
    
    // MARK: - Neutral Colors
    
    /// Bone / Off-white - Sacred parchment
    /// Clean, reverent, breathable
    static let bone = Color(hex: "FAF6C7")
    
    /// Charcoal - Deep darkness
    /// The stillness before and around the fire
    static let charcoal = Color(hex: "0B0A10")
    
    // MARK: - Extended Palette
    
    /// Secondary ember for gradients
    static let deepEmber = Color(hex: "230D11")
    
    /// Bright flame accent
    static let flameAccent = Color(hex: "F7751E")
    
    /// Soft amber for subtle highlights
    static let softAmber = Color(hex: "E79544")
    
    /// Coral flame
    static let coralFlame = Color(hex: "E56630")
}

// MARK: - Hex Color Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Semantic Colors

extension Color {
    
    /// Background for the prayer screen - deep, warm darkness
    static let prayerBackground = Color.charcoal
    
    /// Background for home and general screens
    static let screenBackground = Color.charcoal
    
    /// Primary text color
    static let primaryText = Color.bone
    
    /// Secondary/muted text
    static let secondaryText = Color.bone.opacity(0.7)
    
    /// The glow color for heat effects
    static let heatGlow = Color.ferventOrange
    
    /// Accent for interactive elements
    static let actionAccent = Color.ferventOrange
}

// MARK: - Gradient Definitions

extension LinearGradient {
    
    /// Vertical heat gradient for backgrounds
    /// Simulates heat rising
    static let heatRising = LinearGradient(
        colors: [
            Color.deepEmber,
            Color.charcoal
        ],
        startPoint: .bottom,
        endPoint: .top
    )
    
    /// Radial-like gradient for the prayer altar glow
    static let altarGlow = LinearGradient(
        colors: [
            Color.ferventOrange.opacity(0.6),
            Color.emberRed.opacity(0.3),
            Color.charcoal.opacity(0)
        ],
        startPoint: .center,
        endPoint: .bottom
    )
    
    /// Subtle background warmth
    static let warmAmbient = LinearGradient(
        colors: [
            Color.charcoal,
            Color.deepEmber.opacity(0.3),
            Color.charcoal
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Radial Gradients for Heat Effects

extension RadialGradient {
    
    /// Central glow for the prayer altar
    static let altarHeat = RadialGradient(
        colors: [
            Color.ferventOrange.opacity(0.5),
            Color.emberRed.opacity(0.2),
            Color.charcoal.opacity(0)
        ],
        center: .center,
        startRadius: 20,
        endRadius: 200
    )
    
    /// Intense glow for sustained prayer
    static func prayerIntensity(_ intensity: Double) -> RadialGradient {
        RadialGradient(
            colors: [
                Color.ferventOrange.opacity(0.3 + (intensity * 0.4)),
                Color.emberRed.opacity(0.1 + (intensity * 0.2)),
                Color.charcoal.opacity(0)
            ],
            center: .center,
            startRadius: 10,
            endRadius: 150 + (intensity * 100)
        )
    }
}

