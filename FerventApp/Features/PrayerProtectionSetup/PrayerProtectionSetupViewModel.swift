import SwiftUI
import Combine
import FamilyControls

// MARK: - Prayer Protection Setup View Model
// Manages the setup flow for app blocking
// "Set apart for prayer" (1 Corinthians 7:5)

@MainActor
final class PrayerProtectionSetupViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Current authorization status
    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    
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
    private let authorizationCenter = AuthorizationCenter.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(appBlocking: AppBlockingService? = nil) {
        self.appBlocking = appBlocking ?? AppBlockingService.shared
        
        // Observe authorization status
        observeAuthorizationStatus()
        
        // Check current status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization Observing
    
    private func observeAuthorizationStatus() {
        authorizationCenter.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                Task { @MainActor in
                    self?.authorizationStatus = status
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = authorizationCenter.authorizationStatus
    }
    
    /// Request Screen Time authorization
    func requestAuthorization() async {
        guard authorizationStatus != .approved else {
            return
        }
        
        isRequestingAuthorization = true
        errorMessage = nil
        
        do {
            try await appBlocking.requestAuthorization()
            // Status will be updated via observer
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isRequestingAuthorization = false
    }
    
    // MARK: - Selection Management
    
    /// Save the current selection
    func saveSelection() {
        guard authorizationStatus == .approved else {
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
    
    /// Whether apps are currently selected
    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
    
    /// Number of items selected
    var selectionCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }
    
    // MARK: - Computed Properties
    
    /// Whether authorization button should be shown
    var showAuthorizationButton: Bool {
        authorizationStatus != .approved
    }
    
    /// Whether app selection should be shown
    var showAppSelection: Bool {
        authorizationStatus == .approved
    }
    
    /// Whether complete button should be enabled
    var canComplete: Bool {
        authorizationStatus == .approved && hasSelection
    }
    
    /// Authorization status text
    var authorizationStatusText: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Authorization required"
        case .denied:
            return "Authorization denied"
        case .approved:
            return "Authorized"
        @unknown default:
            return "Unknown status"
        }
    }
}
