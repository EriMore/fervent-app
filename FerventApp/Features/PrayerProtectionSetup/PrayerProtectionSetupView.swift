import SwiftUI
import FamilyControls

// MARK: - Prayer Protection Setup View
// Permission-gated setup flow for app blocking
// "Set apart for prayer" (1 Corinthians 7:5)

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
            ScrollView {
                VStack(spacing: FerventSpacing.section) {
                    Spacer()
                        .frame(height: FerventSpacing.xl)
                    
                    // Title
                    titleSection
                    
                    Spacer()
                        .frame(height: FerventSpacing.lg)
                    
                    // Authorization section
                    if viewModel.showAuthorizationButton {
                        authorizationSection
                    }
                    
                    // App selection section
                    if viewModel.showAppSelection {
                        appSelectionSection
                    }
                    
                    Spacer()
                        .frame(height: FerventSpacing.xl)
                }
                .padding(.horizontal, FerventSpacing.screenEdge)
            }
        }
        .onChange(of: viewModel.isComplete) { isComplete in
            if isComplete {
                // Navigate to home
                coordinator.goHome()
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(spacing: FerventSpacing.md) {
            Text("Select apps to set aside during prayer")
                .font(.ferventTitle)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
            
            Text("These apps will be unavailable only while you pray")
                .font(.ferventBody)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Authorization Section
    
    private var authorizationSection: some View {
        VStack(spacing: FerventSpacing.md) {
            // Status
            Text(viewModel.authorizationStatusText)
                .font(.ferventLabel)
                .foregroundColor(.secondaryText)
            
            // Authorization button
            Button {
                Task {
                    await viewModel.requestAuthorization()
                }
            } label: {
                Text("Authorize Screen Time")
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
            .disabled(viewModel.isRequestingAuthorization)
            
            if viewModel.isRequestingAuthorization {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .ferventOrange))
                    .padding(.top, FerventSpacing.sm)
            }
        }
    }
    
    // MARK: - App Selection Section
    
    private var appSelectionSection: some View {
        VStack(spacing: FerventSpacing.lg) {
            // FamilyActivityPicker
            FamilyActivityPicker(selection: $viewModel.selection)
                .frame(height: 400)
            
            // Selection count
            if viewModel.hasSelection {
                Text("\(viewModel.selectionCount) app\(viewModel.selectionCount == 1 ? "" : "s") selected")
                    .font(.ferventCaption)
                    .foregroundColor(.secondaryText)
            }
            
            // Complete button
            Button {
                viewModel.saveSelection()
            } label: {
                Text("Continue")
                    .font(.ferventButton)
                    .foregroundColor(.charcoal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, FerventSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.canComplete ? Color.ferventOrange : Color.charcoal.opacity(0.5))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canComplete)
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.ferventCaption)
                    .foregroundColor(.emberRed)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PrayerProtectionSetupView()
        .environmentObject(RootCoordinator())
}
