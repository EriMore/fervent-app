import SwiftUI
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
    
    /// Whether to show time picker
    @Published var showingTimePicker: Bool = false
    
    /// Selected prayer time for scheduling
    @Published var selectedPrayerTime: Date = Date()
    
    // MARK: - Services
    
    private let notifications: NotificationService
    private let persistence: PersistenceService
    
    // MARK: - Initialization
    
    init(
        notifications: NotificationService? = nil,
        persistence: PersistenceService? = nil
    ) {
        // Access shared instances on main actor
        self.notifications = notifications ?? NotificationService.shared
        self.persistence = persistence ?? PersistenceService.shared
        
        // Load saved duration
        self.selectedDuration = self.persistence.settings.defaultPrayerDuration
        self.selectedPreset = PrayerDurationPreset.preset(for: selectedDuration)
    }
    
    // MARK: - Computed Properties
    
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
    
    /// Request notification permission
    func requestNotificationPermission() async {
        do {
            try await notifications.requestAuthorization()
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
}
