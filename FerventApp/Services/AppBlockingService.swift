import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

// MARK: - App Blocking Service
// Uses Screen Time APIs to block distracting apps during prayer
// "Watch and pray" (Matthew 26:41)

/// Manages app blocking using Screen Time / Family Controls APIs
/// This logic is centralized and safe - blocking is reversed immediately when prayer ends
@MainActor
final class AppBlockingService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = AppBlockingService()
    
    // MARK: - Published State
    
    /// Whether the user has granted Family Controls authorization
    @Published private(set) var isAuthorized: Bool = false
    
    /// Currently selected apps to block
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    
    /// Whether blocking is currently active
    @Published private(set) var isBlocking: Bool = false
    
    // MARK: - Private Properties
    
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    
    // MARK: - Initialization
    
    private init() {
        // Check initial authorization status
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status
    func checkAuthorizationStatus() {
        switch center.authorizationStatus {
        case .approved:
            isAuthorized = true
        case .denied, .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    /// Request Family Controls authorization
    /// Must be called before attempting to block apps
    func requestAuthorization() async throws {
        do {
            try await center.requestAuthorization(for: .individual)
            checkAuthorizationStatus()
        } catch {
            print("Family Controls authorization failed: \(error)")
            throw AppBlockingError.authorizationFailed(error)
        }
    }
    
    // MARK: - Blocking Control
    
    /// Start blocking selected apps
    /// Called when prayer session begins
    func startBlocking() {
        guard isAuthorized else {
            print("Cannot block apps: not authorized")
            return
        }
        
        guard !selectedApps.applicationTokens.isEmpty ||
              !selectedApps.categoryTokens.isEmpty else {
            print("No apps selected to block")
            return
        }
        
        // Apply the shield to selected applications
        store.shield.applications = selectedApps.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selectedApps.categoryTokens)
        store.shield.webDomains = selectedApps.webDomainTokens
        
        isBlocking = true
        print("App blocking started - \(selectedApps.applicationTokens.count) apps blocked")
    }
    
    /// Stop blocking all apps
    /// Called when prayer session ends (complete or cancelled)
    func stopBlocking() {
        // Clear all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        isBlocking = false
        print("App blocking stopped - all apps unblocked")
    }
    
    /// Emergency stop - ensures all apps are unblocked
    /// Called on app launch to handle crash recovery
    func emergencyUnblock() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.clearAllSettings()
        isBlocking = false
        print("Emergency unblock executed")
    }
    
    // MARK: - Selection Helpers
    
    /// Whether user has selected any apps to block
    var hasSelection: Bool {
        !selectedApps.applicationTokens.isEmpty ||
        !selectedApps.categoryTokens.isEmpty ||
        !selectedApps.webDomainTokens.isEmpty
    }
    
    /// Number of items selected
    var selectionCount: Int {
        selectedApps.applicationTokens.count +
        selectedApps.categoryTokens.count +
        selectedApps.webDomainTokens.count
    }
    
    /// Clear all selections
    func clearSelection() {
        selectedApps = FamilyActivitySelection()
    }
}

// MARK: - Errors

enum AppBlockingError: LocalizedError {
    case authorizationFailed(Error)
    case notAuthorized
    case noAppsSelected
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed(let error):
            return "Failed to authorize app blocking: \(error.localizedDescription)"
        case .notAuthorized:
            return "App blocking is not authorized. Please grant Screen Time access."
        case .noAppsSelected:
            return "No apps selected for blocking."
        }
    }
}

// MARK: - Device Activity Management
// For scheduled blocking (prayer times)

extension AppBlockingService {
    
    /// Schedule blocking for a specific prayer time
    func scheduleBlocking(for prayerTime: PrayerTime, duration: TimeInterval) {
        // This would use DeviceActivitySchedule for automatic blocking
        // For MVP, we handle this manually when the notification fires
        // Future enhancement: use DeviceActivityMonitor for automatic activation
    }
    
    /// Cancel all scheduled blocking
    func cancelAllScheduledBlocking() {
        let center = DeviceActivityCenter()
        center.stopMonitoring()
    }
}

// MARK: - Shield Configuration
// Custom shield appearance (future enhancement)

extension AppBlockingService {
    
    /// Configure the appearance of blocked app shields
    /// For now, uses system defaults
    func configureShieldAppearance() {
        // ShieldConfiguration can be customized in a ShieldConfigurationExtension
        // This is a future enhancement to show Fervent branding on blocked apps
    }
}

