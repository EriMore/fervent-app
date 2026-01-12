import SwiftUI

// MARK: - Hello World View
// Placeholder screen after loading
// Uses canonical Fervent design language

struct HelloWorldView: View {
    
    // MARK: - Animation State
    
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color.charcoal
                .ignoresSafeArea()
            
            // Subtle ambient warmth at bottom
            VStack {
                Spacer()
                RadialGradient(
                    colors: [
                        Color.deepEmber.opacity(0.2),
                        Color.charcoal.opacity(0)
                    ],
                    center: .bottom,
                    startRadius: 50,
                    endRadius: 300
                )
                .frame(height: 300)
            }
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: FerventSpacing.md) {
                Text("Hello World")
                    .font(.ferventDisplay)
                    .foregroundColor(.bone)
                
                Text("Fervent is ready")
                    .font(.ferventCaption)
                    .foregroundColor(.secondaryText)
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            enterScreen()
        }
    }
    
    // MARK: - Animations
    
    /// Entry animation - content settles into place
    private func enterScreen() {
        withAnimation(.ferventFade) {
            contentOpacity = 1.0
            contentOffset = 0
        }
    }
}

// MARK: - Preview

#Preview {
    HelloWorldView()
}
