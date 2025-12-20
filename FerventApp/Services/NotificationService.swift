import Foundation
import UserNotifications
import Combine

// MARK: - Notification Service
// Schedules prayer time reminders
// "Men ought always to pray, and not to faint" (Luke 18:1)

/// Manages local notifications for prayer reminders
/// Notifications are reverent, not noisy - simple call to prayer
@MainActor
final class NotificationService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationService()
    
    // MARK: - Published State
    
    /// Whether notification permission has been granted
    @Published private(set) var isAuthorized: Bool = false
    
    /// Current authorization status
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Constants
    
    private enum Constants {
        static let prayerReminderCategory = "PRAYER_REMINDER"
        static let startPrayerAction = "START_PRAYER"
        static let dismissAction = "DISMISS"
    }
    
    // MARK: - Initialization
    
    private init() {
        Task {
            await checkAuthorizationStatus()
            await registerNotificationCategories()
        }
    }
    
    // MARK: - Authorization
    
    /// Check current notification authorization status
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    /// Request notification permissions
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            await checkAuthorizationStatus()
            
            if !granted {
                throw NotificationError.permissionDenied
            }
        } catch {
            throw NotificationError.authorizationFailed(error)
        }
    }
    
    // MARK: - Notification Categories
    
    /// Register notification action categories
    private func registerNotificationCategories() async {
        let startAction = UNNotificationAction(
            identifier: Constants.startPrayerAction,
            title: "Begin Prayer",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: Constants.dismissAction,
            title: "Later",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: Constants.prayerReminderCategory,
            actions: [startAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule a notification for a prayer time
    func schedulePrayerReminder(for prayerTime: PrayerTime) async throws {
        guard isAuthorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Pray"
        content.body = prayerTime.label ?? "Your scheduled prayer time has arrived."
        content.sound = .default
        content.categoryIdentifier = Constants.prayerReminderCategory
        
        // Add user info for handling the notification
        content.userInfo = [
            "prayerTimeID": prayerTime.id.uuidString,
            "type": "prayerReminder"
        ]
        
        // Create trigger based on prayer time
        var dateComponents = DateComponents()
        dateComponents.hour = prayerTime.hour
        dateComponents.minute = prayerTime.minute
        
        let trigger: UNNotificationTrigger
        
        if prayerTime.daysOfWeek.isEmpty {
            // Daily trigger
            trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
        } else {
            // Weekly triggers for specific days
            // Schedule one notification for each day
            for day in prayerTime.daysOfWeek {
                var dayComponents = dateComponents
                dayComponents.weekday = day
                
                let dayTrigger = UNCalendarNotificationTrigger(
                    dateMatching: dayComponents,
                    repeats: true
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(prayerTime.id.uuidString)_\(day)",
                    content: content,
                    trigger: dayTrigger
                )
                
                try await UNUserNotificationCenter.current().add(request)
            }
            return
        }
        
        let request = UNNotificationRequest(
            identifier: prayerTime.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
        print("Scheduled prayer reminder for \(prayerTime.formattedTime)")
    }
    
    /// Schedule a one-time notification for a specific date
    func scheduleOneTimeReminder(at date: Date, label: String? = nil) async throws {
        guard isAuthorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Pray"
        content.body = label ?? "Your prayer time has arrived."
        content.sound = .default
        content.categoryIdentifier = Constants.prayerReminderCategory
        content.userInfo = ["type": "oneTimePrayer"]
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
        print("Scheduled one-time prayer reminder for \(date)")
    }
    
    // MARK: - Cancel Notifications
    
    /// Cancel a specific prayer time's notifications
    func cancelPrayerReminder(for prayerTime: PrayerTime) {
        var identifiers = [prayerTime.id.uuidString]
        
        // Also cancel day-specific notifications
        for day in 1...7 {
            identifiers.append("\(prayerTime.id.uuidString)_\(day)")
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
        print("Cancelled prayer reminder for \(prayerTime.formattedTime)")
    }
    
    /// Cancel all pending prayer notifications
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all prayer reminders")
    }
    
    // MARK: - Sync All Prayer Times
    
    /// Reschedule all notifications from current prayer times
    func syncAllNotifications(from prayerTimes: [PrayerTime]) async {
        // First, cancel all existing
        cancelAllReminders()
        
        // Then schedule enabled times
        for time in prayerTimes where time.isEnabled {
            do {
                try await schedulePrayerReminder(for: time)
            } catch {
                print("Failed to schedule notification for \(time.formattedTime): \(error)")
            }
        }
    }
    
    // MARK: - Pending Notifications
    
    /// Get all pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}

// MARK: - Errors

enum NotificationError: LocalizedError {
    case notAuthorized
    case permissionDenied
    case authorizationFailed(Error)
    case schedulingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notifications are not authorized. Please enable in Settings."
        case .permissionDenied:
            return "Notification permission was denied."
        case .authorizationFailed(let error):
            return "Failed to request notification permission: \(error.localizedDescription)"
        case .schedulingFailed(let error):
            return "Failed to schedule notification: \(error.localizedDescription)"
        }
    }
}

// MARK: - Notification Delegate Handler

/// Handles notification interactions
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    /// Called when notification is tapped
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier, "START_PRAYER":
            // User tapped notification or "Begin Prayer" - launch into prayer
            NotificationCenter.default.post(
                name: .startPrayerFromNotification,
                object: nil,
                userInfo: userInfo
            )
            
        case "DISMISS":
            // User chose to dismiss
            break
            
        default:
            break
        }
        
        completionHandler()
    }
    
    /// Called when notification arrives while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when in foreground (unless in prayer)
        completionHandler([.banner, .sound])
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let startPrayerFromNotification = Notification.Name("startPrayerFromNotification")
}

