import SwiftUI

// MARK: - Prayer Completion View
// Quiet, grounded, brief acknowledgment of completed prayer
// "Prayer is power — but power must be cultivated."

struct PrayerCompletionView: View {
    
    let session: PrayerSession
    @EnvironmentObject var coordinator: RootCoordinator
    
    // Animation state
    @State private var showContent: Bool = false
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.prayerBackground
                    .ignoresSafeArea()
                
                // Warm ambient glow (fading ember)
                RadialGradient(
                    colors: [
                        Color.ferventOrange.opacity(0.15 * glowIntensity),
                        Color.emberRed.opacity(0.05 * glowIntensity),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: geometry.size.width * 0.8
                )
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: FerventSpacing.section) {
                    Spacer()
                    
                    // Completion message
                    completionMessage
                    
                    // Duration display
                    durationDisplay
                    
                    Spacer()
                    
                    // Return button
                    returnButton
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                }
                .padding(.horizontal, FerventSpacing.screenEdge)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        }
        .statusBarHidden(true)
        .onAppear {
            animateIn()
        }
    }
    
    // MARK: - Completion Message
    
    private var completionMessage: some View {
        VStack(spacing: FerventSpacing.md) {
            // Subtle ember icon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.ferventOrange.opacity(0.5),
                            Color.emberRed.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
            
            Text("Prayer Completed")
                .font(.ferventTitle)
                .foregroundColor(.primaryText)
            
            // Optional: subtle scripture
            Text("\"The effectual, fervent prayer of a righteous man availeth much.\"")
                .font(.ferventCaption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FerventSpacing.lg)
        }
    }
    
    // MARK: - Duration Display
    
    private var durationDisplay: some View {
        VStack(spacing: FerventSpacing.sm) {
            Text(session.formattedDuration)
                .font(.ferventDuration)
                .foregroundColor(.ferventOrange)
                .monospacedDigit()
            
            Text("Time in prayer")
                .font(.ferventCaption)
                .foregroundColor(.secondaryText)
        }
    }
    
    // MARK: - Return Button
    
    private var returnButton: some View {
        Button {
            returnHome()
        } label: {
            Text("Return")
                .font(.ferventButton)
                .foregroundColor(.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FerventSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.bone.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func returnHome() {
        // Apps are already unblocked by coordinator
        // Focus mode already exited
        coordinator.returnFromCompletion()
    }
    
    // MARK: - Animations
    
    private func animateIn() {
        // Fade in content
        withAnimation(.ferventFade.delay(0.2)) {
            showContent = true
        }
        
        // Glow builds then settles
        withAnimation(.easeIn(duration: 0.8)) {
            glowIntensity = 1.0
        }
        
        // Then slowly fades
        withAnimation(.easeOut(duration: 3.0).delay(1.0)) {
            glowIntensity = 0.6
        }
    }
}

// MARK: - Preview

#Preview {
    let session = {
        var s = PrayerSession.startNew(intendedDuration: 600)
        s.actualEnd = Date()
        s.completedSuccessfully = true
        return s
    }()
    
    return PrayerCompletionView(session: session)
        .environmentObject(RootCoordinator())
}

