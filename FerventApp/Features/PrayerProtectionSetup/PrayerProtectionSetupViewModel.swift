import SwiftUI
import FamilyControls

// MARK: - Prayer Protection Setup View Model
// Manages the setup flow for app blocking
// "Set apart for prayer" (1 Corinthians 7:5)

@MainActor
final class PrayerProtectionSetupViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Whether the user is authorized
    @Published private(set) var isAuthorized: Bool = false
    
    /// Whether authorization is in progress
    @Published var isRequestingAuthorization: Bool = false
    
    /// Currently selected apps (for FamilyActivityPicker)
    @Published var selection = FamilyActivitySelection()
    
    /// Whether setup is complete
    @Published var isComplete: Bool = false
    
    /// Error message to display
    @Published var errorMessage: String?
    
    // MARK: - Services
    
    private let appBlocking: AppBlockingService
    
    // MARK: - Initialization
    
    init(appBlocking: AppBlockingService? = nil) {
        self.appBlocking = appBlocking ?? AppBlockingService.shared
        checkAuthorization()
    }
    
    // MARK: - Computed Properties
    
    /// Whether authorization button should be shown
    var showAuthorizationButton: Bool {
        !isAuthorized
    }
    
    /// Whether app selection should be shown
    var showAppSelection: Bool {
        isAuthorized
    }
    
    /// Whether apps are currently selected
    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
    
    /// Number of items selected
    var selectionCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }
    
    /// Whether complete button should be enabled
    var canComplete: Bool {
        isAuthorized && hasSelection
    }
    
    /// Authorization status text
    var authorizationStatusText: String {
        if isAuthorized {
            return "Authorized"
        } else {
            return "Authorization required"
        }
    }
    
    // MARK: - Actions
    
    /// Check current authorization status
    func checkAuthorization() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }
    
    /// Request Screen Time authorization
    func requestAuthorization() async {
        guard !isAuthorized else { return }
        
        isRequestingAuthorization = true
        errorMessage = nil
        
        do {
            try await appBlocking.requestAuthorization()
            checkAuthorization()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isRequestingAuthorization = false
    }
    
    /// Save the current selection
    func saveSelection() {
        guard isAuthorized else {
            errorMessage = "Please authorize Screen Time access first."
            return
        }
        
        guard hasSelection else {
            errorMessage = "Please select at least one app to block during prayer."
            return
        }
        
        // Save selection to AppBlockingService
        appBlocking.saveSelection(selection)
        
        // Mark setup as complete
        isComplete = true
        errorMessage = nil
    }
}
