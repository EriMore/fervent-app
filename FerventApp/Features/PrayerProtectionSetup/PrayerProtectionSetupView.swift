import SwiftUI

// MARK: - Prayer Protection Setup View
// Stub implementation - Family Controls requires Apple approval
// "Set apart for prayer" (1 Corinthians 7:5)
//
// NOTE: This is a simplified setup flow while waiting for Apple
// to approve Family Controls capability. App blocking is disabled.

struct PrayerProtectionSetupView: View {
    
    @StateObject private var viewModel = PrayerProtectionSetupViewModel()
    @EnvironmentObject var coordinator: RootCoordinator
    
    var body: some View {
        ZStack {
            // Background
            Color.screenBackground
                .ignoresSafeArea()
            
            // Subtle ambient warmth
            RadialGradient(
                colors: [
                    Color.deepEmber.opacity(0.3),
                    Color.charcoal.opacity(0)
                ],
                center: .bottom,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: FerventSpacing.section) {
                Spacer()
                
                // Logo
                FerventLogo(intensity: 0.5, isBreathing: true, size: 80)
                
                Spacer()
                    .frame(height: FerventSpacing.xl)
                
                // Title
                titleSection
                
                Spacer()
                    .frame(height: FerventSpacing.lg)
                
                // Notice about Family Controls
                noticeSection
                
                Spacer()
                
                // Continue button
                continueButton
                
                Spacer()
                    .frame(height: FerventSpacing.xl)
            }
            .padding(.horizontal, FerventSpacing.screenEdge)
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                coordinator.goHome()
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: FerventSpacing.md) {
            Text("Welcome to Fervent")
                .font(.ferventDisplay)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
            
            Text("A sacred space for prayer")
                .font(.ferventBody)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Notice Section
    
    private var noticeSection: some View {
        VStack(spacing: FerventSpacing.md) {
            Image(systemName: "info.circle")
                .font(.system(size: 32))
                .foregroundColor(.ferventOrange.opacity(0.7))
            
            Text("App blocking coming soon")
                .font(.ferventSubtitle)
                .foregroundColor(.primaryText)
            
            Text("We're waiting for Apple to approve our Family Controls capability. Until then, you can still use all prayer features — app blocking will be enabled in a future update.")
                .font(.ferventCaption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FerventSpacing.lg)
        }
        .padding(.vertical, FerventSpacing.lg)
        .padding(.horizontal, FerventSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.charcoal.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.ferventOrange.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button {
            viewModel.completeSetup()
        } label: {
            Text("Begin Praying")
                .font(.ferventButton)
                .foregroundColor(.charcoal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FerventSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.ferventOrange)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PrayerProtectionSetupView()
        .environmentObject(RootCoordinator())
}
