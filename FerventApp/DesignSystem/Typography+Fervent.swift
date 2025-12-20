import SwiftUI

// MARK: - Fervent Typography
// New York for display / sacred text - brings gravitas and reverence
// SF Pro for UI / controls - clarity and function

extension Font {
    
    // MARK: - Display Typography (New York)
    // Used for sacred text, titles, and moments of spiritual weight
    
    /// Large display for primary headings
    /// "Fervent" title, prayer completion
    static let ferventDisplay = Font.system(.largeTitle, design: .serif, weight: .medium)
    
    /// Medium display for section headers
    static let ferventTitle = Font.system(.title, design: .serif, weight: .medium)
    
    /// Smaller display for subtitles
    static let ferventSubtitle = Font.system(.title2, design: .serif, weight: .regular)
    
    /// Scripture and sacred quotations
    static let ferventScripture = Font.system(.title3, design: .serif, weight: .regular).italic()
    
    /// The "Amen" text - weighted with intention
    static let ferventAmen = Font.system(size: 28, weight: .medium, design: .serif)
    
    // MARK: - UI Typography (SF Pro)
    // Used for buttons, labels, and functional text
    
    /// Primary body text
    static let ferventBody = Font.system(.body, design: .default, weight: .regular)
    
    /// Secondary/caption text
    static let ferventCaption = Font.system(.caption, design: .default, weight: .regular)
    
    /// Button labels
    static let ferventButton = Font.system(.body, design: .default, weight: .medium)
    
    /// Small labels and metadata
    static let ferventLabel = Font.system(.subheadline, design: .default, weight: .regular)
    
    /// Timer display - monospaced for stability
    static let ferventTimer = Font.system(size: 48, weight: .light, design: .monospaced)
    
    /// Duration display on completion
    static let ferventDuration = Font.system(size: 36, weight: .light, design: .monospaced)
}

// MARK: - Text Styles

extension View {
    
    /// Apply display typography with proper color
    func ferventDisplayStyle() -> some View {
        self
            .font(.ferventDisplay)
            .foregroundColor(.primaryText)
    }
    
    /// Apply title typography
    func ferventTitleStyle() -> some View {
        self
            .font(.ferventTitle)
            .foregroundColor(.primaryText)
    }
    
    /// Apply scripture typography - italic, reverent
    func ferventScriptureStyle() -> some View {
        self
            .font(.ferventScripture)
            .foregroundColor(.secondaryText)
            .multilineTextAlignment(.center)
    }
    
    /// Apply body typography
    func ferventBodyStyle() -> some View {
        self
            .font(.ferventBody)
            .foregroundColor(.primaryText)
    }
    
    /// Apply caption typography
    func ferventCaptionStyle() -> some View {
        self
            .font(.ferventCaption)
            .foregroundColor(.secondaryText)
    }
    
    /// Apply button typography
    func ferventButtonStyle() -> some View {
        self
            .font(.ferventButton)
            .foregroundColor(.primaryText)
    }
}

// MARK: - Animation Curves
// "Nothing pops. Everything settles."

extension Animation {
    
    /// Standard easing for UI transitions
    /// Long, gentle curves that feel weighty
    static let ferventStandard = Animation.easeInOut(duration: 0.4)
    
    /// Slow breathing animation for ambient effects
    static let ferventBreathing = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
    
    /// Heat building animation - slow accumulation
    static let ferventHeatBuild = Animation.easeIn(duration: 2.0)
    
    /// Gentle fade for transitions
    static let ferventFade = Animation.easeOut(duration: 0.6)
    
    /// Long press feedback
    static let ferventLongPress = Animation.easeInOut(duration: 0.3)
    
    /// Glow pulse - subtle, not frantic
    static let ferventGlowPulse = Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)
    
    /// Completion celebration - quiet, not explosive
    static let ferventCompletion = Animation.easeOut(duration: 1.0)
}

// MARK: - Spacing Constants

enum FerventSpacing {
    /// Minimal spacing
    static let xs: CGFloat = 4
    
    /// Small spacing
    static let sm: CGFloat = 8
    
    /// Medium spacing
    static let md: CGFloat = 16
    
    /// Large spacing
    static let lg: CGFloat = 24
    
    /// Extra large spacing
    static let xl: CGFloat = 32
    
    /// Section spacing
    static let section: CGFloat = 48
    
    /// Screen edge padding
    static let screenEdge: CGFloat = 20
}

