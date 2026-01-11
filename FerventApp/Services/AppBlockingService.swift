import Foundation
import Combine
import FamilyControls
import ManagedSettings

// MARK: - App Blocking Service
// Screen Time API integration for prayer protection
// "Watch and pray" (Matthew 26:41)

/// Manages app blocking using Apple's Family Controls framework
@MainActor
final class AppBlockingService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AppBlockingService()
    
    // MARK: - Published State
    
    /// Whether the user has granted Family Controls authorization
    @Published private(set) var isAuthorized: Bool = false
    
    /// Whether blocking is currently active
    @Published private(set) var isBlocking: Bool = false
    
    /// Currently selected app tokens
    @Published private(set) var selection: FamilyActivitySelection?
    
    // MARK: - Private Properties
    
    private let authorizationCenter = AuthorizationCenter.shared
    private var managedSettingsStore = ManagedSettingsStore(named: .init("FerventPrayer"))
    private let persistence: PersistenceService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init(persistence: PersistenceService? = nil) {
        self.persistence = persistence ?? PersistenceService.shared
        
        // Observe authorization status changes
        observeAuthorizationStatus()
        
        // Load saved selection
        loadSelection()
        
        // Check current authorization status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization Observing
    
    private func observeAuthorizationStatus() {
        authorizationCenter.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                Task { @MainActor in
                    self?.isAuthorized = (status == .approved)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        isAuthorized = (authorizationCenter.authorizationStatus == .approved)
    }
    
    /// Request Family Controls authorization
    func requestAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization()
            isAuthorized = (authorizationCenter.authorizationStatus == .approved)
            
            if !isAuthorized {
                throw AppBlockingError.notAuthorized
            }
        } catch {
            throw AppBlockingError.authorizationFailed(error)
        }
    }
    
    // MARK: - Selection Management
    
    /// Save the current selection
    func saveSelection(_ selection: FamilyActivitySelection) {
        self.selection = selection
        
        // Encode selection to Data and save
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(selection)
            persistence.saveSelectedAppTokens(data)
        } catch {
            print("Failed to save app selection: \(error)")
        }
    }
    
    /// Load saved selection from persistence
    private func loadSelection() {
        guard let data = persistence.selectedAppTokensData else {
            selection = nil
            return
        }
        
        do {
            let decoder = JSONDecoder()
            selection = try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load app selection: \(error)")
            selection = nil
        }
    }
    
    /// Clear the current selection
    func clearSelection() {
        selection = nil
        persistence.saveSelectedAppTokens(nil)
    }
    
    /// Whether user has selected any apps to block
    var hasSelection: Bool {
        guard let selection = selection else { return false }
        return !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
    
    /// Number of items selected
    var selectionCount: Int {
        guard let selection = selection else { return 0 }
        return selection.applicationTokens.count + selection.categoryTokens.count
    }
    
    // MARK: - Blocking Control
    
    /// Start blocking selected apps
    func startBlocking() {
        guard isAuthorized else {
            print("App Blocking: Skipped - not authorized")
            return
        }
        
        guard let selection = selection, hasSelection else {
            print("App Blocking: Skipped - no apps selected")
            return
        }
        
        // Apply blocking using ManagedSettingsStore
        managedSettingsStore.clearAllSettings()
        managedSettingsStore.shield.applications = Set(selection.applicationTokens)
        managedSettingsStore.shield.applicationCategories = ShieldSettings.ActivityCategorySelection.specific(Set(selection.categoryTokens))
        
        isBlocking = true
        print("App Blocking: Started blocking \(selectionCount) item(s)")
    }
    
    /// Stop blocking all apps
    func stopBlocking() {
        managedSettingsStore.clearAllSettings()
        isBlocking = false
        print("App Blocking: Stopped blocking")
    }
    
    /// Emergency stop - ensures all apps are unblocked
    func emergencyUnblock() {
        managedSettingsStore.clearAllSettings()
        isBlocking = false
        print("App Blocking: Emergency unblock executed")
    }
}

// MARK: - Errors

enum AppBlockingError: LocalizedError {
    case notAvailable
    case authorizationFailed(Error)
    case notAuthorized
    case noAppsSelected
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "App blocking requires Family Controls capability approval from Apple. Prayer features work normally without it."
        case .authorizationFailed(let error):
            return "Failed to authorize app blocking: \(error.localizedDescription)"
        case .notAuthorized:
            return "App blocking is not authorized. Please grant Screen Time access."
        case .noAppsSelected:
            return "No apps selected for blocking."
        }
    }
}
