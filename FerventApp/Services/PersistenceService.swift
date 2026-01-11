import Foundation
import Combine

// MARK: - Persistence Service
// Local-first data storage using UserDefaults
// "Write the vision" (Habakkuk 2:2)

/// Manages local persistence of prayer data and settings
/// Offline prayer always works - cloud sync is secondary
@MainActor
final class PersistenceService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = PersistenceService()
    
    // MARK: - Published State
    
    @Published private(set) var settings: PrayerSettings
    @Published private(set) var history: PrayerHistory
    @Published private(set) var currentSession: PrayerSession?
    
    // MARK: - Storage Keys
    
    private enum Keys {
        static let settings = "fervent.settings"
        static let history = "fervent.history"
        static let currentSession = "fervent.currentSession"
    }
    
    // MARK: - Private Properties
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        // Load settings or use defaults
        if let data = defaults.data(forKey: Keys.settings),
           let settings = try? decoder.decode(PrayerSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = .default
        }
        
        // Load history or start fresh
        if let data = defaults.data(forKey: Keys.history),
           let history = try? decoder.decode(PrayerHistory.self, from: data) {
            self.history = history
        } else {
            self.history = PrayerHistory()
        }
        
        // Load any active session (crash recovery)
        if let data = defaults.data(forKey: Keys.currentSession),
           let session = try? decoder.decode(PrayerSession.self, from: data) {
            self.currentSession = session
        } else {
            self.currentSession = nil
        }
    }
    
    // MARK: - Settings Management
    
    /// Update prayer settings
    func updateSettings(_ settings: PrayerSettings) {
        self.settings = settings
        saveSettings()
    }
    
    /// Update a specific setting using a closure
    func updateSettings(_ update: (inout PrayerSettings) -> Void) {
        var newSettings = settings
        update(&newSettings)
        self.settings = newSettings
        saveSettings()
    }
    
    private func saveSettings() {
        if let data = try? encoder.encode(settings) {
            defaults.set(data, forKey: Keys.settings)
        }
    }
    
    // MARK: - Session Management
    
    /// Start a new prayer session
    func startSession(
        intendedDuration: TimeInterval,
        blockedAppBundleIDs: [String] = []
    ) -> PrayerSession {
        let session = PrayerSession.startNew(
            intendedDuration: intendedDuration,
            blockedAppBundleIDs: blockedAppBundleIDs
        )
        self.currentSession = session
        saveCurrentSession()
        
        // Update settings with active session ID
        updateSettings { $0.lastActiveSessionID = session.id }
        
        return session
    }
    
    /// Complete the current prayer session successfully
    func completeCurrentSession() -> PrayerSession? {
        guard var session = currentSession else { return nil }
        
        session.complete()
        
        // Add to history
        history.add(session)
        saveHistory()
        
        // Clear current session
        self.currentSession = nil
        clearCurrentSession()
        
        // Clear active session ID
        updateSettings { $0.lastActiveSessionID = nil }
        
        return session
    }
    
    /// Cancel the current prayer session
    func cancelCurrentSession() -> PrayerSession? {
        guard var session = currentSession else { return nil }
        
        session.cancel()
        
        // Still add to history (for tracking)
        history.add(session)
        saveHistory()
        
        // Clear current session
        self.currentSession = nil
        clearCurrentSession()
        
        // Clear active session ID
        updateSettings { $0.lastActiveSessionID = nil }
        
        return session
    }
    
    /// Update the current session (e.g., to mark Focus mode activated)
    func updateCurrentSession(_ update: (inout PrayerSession) -> Void) {
        guard var session = currentSession else { return }
        update(&session)
        self.currentSession = session
        saveCurrentSession()
    }
    
    private func saveCurrentSession() {
        if let session = currentSession,
           let data = try? encoder.encode(session) {
            defaults.set(data, forKey: Keys.currentSession)
        }
    }
    
    private func clearCurrentSession() {
        defaults.removeObject(forKey: Keys.currentSession)
    }
    
    // MARK: - History Management
    
    private func saveHistory() {
        if let data = try? encoder.encode(history) {
            defaults.set(data, forKey: Keys.history)
        }
    }
    
    /// Clear all history (for testing/reset)
    func clearHistory() {
        self.history = PrayerHistory()
        saveHistory()
    }
    
    // MARK: - Crash Recovery
    
    /// Check if there's an incomplete session from a crash
    func checkForIncompleteSession() -> PrayerSession? {
        guard let session = currentSession, session.isActive else {
            return nil
        }
        return session
    }
    
    /// Handle recovery from an incomplete session
    func recoverFromCrash() {
        // If there's an active session, cancel it
        // This ensures apps get unblocked
        if currentSession?.isActive == true {
            _ = cancelCurrentSession()
        }
    }
    
    // MARK: - Prayer Times Management
    
    /// Add a new prayer time
    func addPrayerTime(_ time: PrayerTime) {
        updateSettings { $0.prayerTimes.append(time) }
    }
    
    /// Remove a prayer time
    func removePrayerTime(_ time: PrayerTime) {
        updateSettings { settings in
            settings.prayerTimes.removeAll { $0.id == time.id }
        }
    }
    
    /// Update a prayer time
    func updatePrayerTime(_ time: PrayerTime) {
        updateSettings { settings in
            if let index = settings.prayerTimes.firstIndex(where: { $0.id == time.id }) {
                settings.prayerTimes[index] = time
            }
        }
    }
    
    /// Toggle a prayer time's enabled state
    func togglePrayerTime(_ time: PrayerTime) {
        updateSettings { settings in
            if let index = settings.prayerTimes.firstIndex(where: { $0.id == time.id }) {
                settings.prayerTimes[index].isEnabled.toggle()
            }
        }
    }
    
    // MARK: - Selected App Tokens Management
    
    /// Save selected app tokens data
    func saveSelectedAppTokens(_ data: Data?) {
        updateSettings { $0.selectedApplicationTokensData = data }
    }
    
    /// Load selected app tokens data
    var selectedAppTokensData: Data? {
        settings.selectedApplicationTokensData
    }
    
    /// Whether apps have been selected
    var hasSelectedApps: Bool {
        settings.hasSelectedApps
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension PersistenceService {
    /// Reset all data (for testing)
    func resetAll() {
        self.settings = .default
        self.history = PrayerHistory()
        self.currentSession = nil
        
        defaults.removeObject(forKey: Keys.settings)
        defaults.removeObject(forKey: Keys.history)
        defaults.removeObject(forKey: Keys.currentSession)
    }
    
    /// Create a mock completed session (for testing)
    func addMockSession() {
        var session = PrayerSession(
            actualStart: Date().addingTimeInterval(-600),
            intendedDuration: 600
        )
        session.actualEnd = Date()
        session.completedSuccessfully = true
        history.add(session)
        saveHistory()
    }
}
#endif

