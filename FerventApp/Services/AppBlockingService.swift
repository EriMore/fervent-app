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
    @Published var selection = FamilyActivitySelection()
    
    // MARK: - Private Properties
    
    private let authorizationCenter = AuthorizationCenter.shared
    private let managedSettingsStore = ManagedSettingsStore()
    private let persistence: PersistenceService
    
    // MARK: - Initialization
    
    private init(persistence: PersistenceService? = nil) {
        self.persistence = persistence ?? PersistenceService.shared
        
        // Load saved selection
        loadSelection()
        
        // Check current authorization status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        isAuthorized = (authorizationCenter.authorizationStatus == .approved)
    }
    
    /// Request Family Controls authorization
    func requestAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
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
    func saveSelection(_ newSelection: FamilyActivitySelection) {
        self.selection = newSelection
        
        // Encode selection to Data using PropertyListEncoder
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(newSelection)
            persistence.saveSelectedAppTokens(data)
        } catch {
            print("Failed to save app selection: \(error)")
        }
    }
    
    /// Load saved selection from persistence
    private func loadSelection() {
        guard let data = persistence.selectedAppTokensData else {
            selection = FamilyActivitySelection()
            return
        }
        
        do {
            let decoder = PropertyListDecoder()
            selection = try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load app selection: \(error)")
            selection = FamilyActivitySelection()
        }
    }
    
    /// Clear the current selection
    func clearSelection() {
        selection = FamilyActivitySelection()
        persistence.saveSelectedAppTokens(nil)
    }
    
    /// Whether user has selected any apps to block
    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
    
    /// Number of items selected
    var selectionCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count
    }
    
    // MARK: - Blocking Control
    
    /// Start blocking selected apps
    func startBlocking() {
        guard isAuthorized else {
            print("App Blocking: Skipped - not authorized")
            return
        }
        
        guard hasSelection else {
            print("App Blocking: Skipped - no apps selected")
            return
        }
        
        // Apply blocking using ManagedSettingsStore
        if !selection.applicationTokens.isEmpty {
            managedSettingsStore.shield.applications = selection.applicationTokens
        }
        if !selection.categoryTokens.isEmpty {
            managedSettingsStore.shield.applicationCategories = ShieldSettings.ActivityCategorySelection.specific(selection.categoryTokens)
        }
        
        isBlocking = true
        print("App Blocking: Started blocking \(selectionCount) item(s)")
    }
    
    /// Stop blocking all apps
    func stopBlocking() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        isBlocking = false
        print("App Blocking: Stopped blocking")
    }
    
    /// Emergency stop - ensures all apps are unblocked
    func emergencyUnblock() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
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
