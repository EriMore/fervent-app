import SwiftUI

// MARK: - Prayer Protection Setup View Model
// Stub implementation - Family Controls requires Apple approval
// "Set apart for prayer" (1 Corinthians 7:5)
//
// NOTE: This is a simplified setup flow while waiting for Apple
// to approve Family Controls capability. App blocking is disabled.

@MainActor
final class PrayerProtectionSetupViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Whether setup is complete
    @Published var isComplete: Bool = false
    
    /// Error message to display (shows Family Controls unavailable notice)
    @Published var errorMessage: String?
    
    /// Whether to show the unavailable notice
    @Published var showUnavailableNotice: Bool = true
    
    // MARK: - Services
    
    private let appBlocking: AppBlockingService
    private let persistence: PersistenceService
    
    // MARK: - Initialization
    
    init(appBlocking: AppBlockingService? = nil, persistence: PersistenceService? = nil) {
        self.appBlocking = appBlocking ?? AppBlockingService.shared
        self.persistence = persistence ?? PersistenceService.shared
    }
    
    // MARK: - Computed Properties
    
    /// Whether authorization button should be shown (always false in stub)
    var showAuthorizationButton: Bool {
        false
    }
    
    /// Whether app selection should be shown (always false in stub)
    var showAppSelection: Bool {
        false
    }
    
    /// Whether apps are "selected" (stub - true after continue)
    var hasSelection: Bool {
        appBlocking.hasSelection
    }
    
    /// Number of items selected (stub)
    var selectionCount: Int {
        0
    }
    
    /// Whether complete button should be enabled (always true in stub)
    var canComplete: Bool {
        true
    }
    
    /// Authorization status text (stub)
    var authorizationStatusText: String {
        "App blocking requires Apple approval"
    }
    
    // MARK: - Actions
    
    /// Complete setup without app selection (stub)
    func completeSetup() {
        // Save stub selection and mark setup complete
        appBlocking.saveSelection()
        isComplete = true
        errorMessage = nil
    }
}
