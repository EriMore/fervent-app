import SwiftUI
import FamilyControls
import Combine

// MARK: - Home View Model
// Manages state for the home screen
// "Give us this day our daily bread" (Matthew 6:11)

@MainActor
final class HomeViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Selected prayer duration
    @Published var selectedDuration: TimeInterval = 300
    
    /// Currently selected duration preset
    @Published var selectedPreset: PrayerDurationPreset = .fiveMinutes
    
    /// Whether the app picker is showing
    @Published var showingAppPicker: Bool = false
    
    /// Whether to show time picker
    @Published var showingTimePicker: Bool = false
    
    /// Selected prayer time for scheduling
    @Published var selectedPrayerTime: Date = Date()
    
    /// Whether permissions setup is needed
    @Published var needsPermissions: Bool = true
    
    // MARK: - Services
    
    private let appBlocking: AppBlockingService
    private let notifications: NotificationService
    private let persistence: PersistenceService
    
    // MARK: - Initialization
    
    init(
        appBlocking: AppBlockingService = .shared,
        notifications: NotificationService = .shared,
        persistence: PersistenceService = .shared
    ) {
        self.appBlocking = appBlocking
        self.notifications = notifications
        self.persistence = persistence
        
        // Load saved duration
        self.selectedDuration = persistence.settings.defaultPrayerDuration
        self.selectedPreset = PrayerDurationPreset.preset(for: selectedDuration)
        
        // Check permissions
        updatePermissionState()
    }
    
    // MARK: - Computed Properties
    
    /// The user's app selection for blocking
    var appSelection: Binding<FamilyActivitySelection> {
        Binding(
            get: { self.appBlocking.selectedApps },
            set: { self.appBlocking.selectedApps = $0 }
        )
    }
    
    /// Whether apps are selected for blocking
    var hasAppsSelected: Bool {
        appBlocking.hasSelection
    }
    
    /// Number of apps selected
    var selectedAppsCount: Int {
        appBlocking.selectionCount
    }
    
    /// Whether app blocking is authorized
    var isAppBlockingAuthorized: Bool {
        appBlocking.isAuthorized
    }
    
    /// Whether notifications are authorized
    var areNotificationsAuthorized: Bool {
        notifications.isAuthorized
    }
    
    /// Formatted duration string
    var formattedDuration: String {
        let minutes = Int(selectedDuration) / 60
        if minutes == 1 {
            return "1 minute"
        }
        return "\(minutes) minutes"
    }
    
    // MARK: - Actions
    
    /// Select a duration preset
    func selectPreset(_ preset: PrayerDurationPreset) {
        selectedPreset = preset
        if preset != .custom {
            selectedDuration = preset.duration
            saveDuration()
        }
    }
    
    /// Update custom duration
    func updateDuration(_ duration: TimeInterval) {
        selectedDuration = max(60, duration) // Minimum 1 minute
        selectedPreset = .custom
        saveDuration()
    }
    
    private func saveDuration() {
        persistence.updateSettings { $0.defaultPrayerDuration = selectedDuration }
    }
    
    /// Open the app picker
    func openAppPicker() {
        showingAppPicker = true
    }
    
    /// Request app blocking permission
    func requestAppBlockingPermission() async {
        do {
            try await appBlocking.requestAuthorization()
            updatePermissionState()
        } catch {
            print("Failed to request app blocking permission: \(error)")
        }
    }
    
    /// Request notification permission
    func requestNotificationPermission() async {
        do {
            try await notifications.requestAuthorization()
            updatePermissionState()
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    /// Schedule a prayer time
    func schedulePrayerTime() async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedPrayerTime)
        
        let prayerTime = PrayerTime(
            hour: components.hour ?? 6,
            minute: components.minute ?? 0,
            isEnabled: true,
            label: "Daily Prayer"
        )
        
        persistence.addPrayerTime(prayerTime)
        
        do {
            try await notifications.schedulePrayerReminder(for: prayerTime)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
        
        showingTimePicker = false
    }
    
    /// Update permission state
    private func updatePermissionState() {
        needsPermissions = !appBlocking.isAuthorized
    }
    
    /// Check if ready to start prayer
    var canStartPrayer: Bool {
        // Can start if we have permission (apps selected is optional)
        appBlocking.isAuthorized || !needsPermissions
    }
}

