import Foundation

// MARK: - Prayer Settings Model
// User preferences for prayer sessions
// "Men ought always to pray, and not to faint" (Luke 18:1)

/// Global settings for the Fervent app
struct PrayerSettings: Codable {
    
    /// Default prayer duration in seconds
    var defaultPrayerDuration: TimeInterval
    
    /// Scheduled prayer times
    var prayerTimes: [PrayerTime]
    
    /// Whether to enable Focus mode during prayer
    var enableFocusMode: Bool
    
    /// Whether to block apps during prayer
    var enableAppBlocking: Bool
    
    /// Whether notifications are enabled
    var notificationsEnabled: Bool
    
    /// Last completed session ID (for recovery)
    var lastActiveSessionID: UUID?
    
    /// Selected application tokens (encoded FamilyActivitySelection data)
    /// Stored as base64-encoded JSON data
    var selectedApplicationTokensData: Data?
    
    // MARK: - Defaults
    
    static let `default` = PrayerSettings(
        defaultPrayerDuration: 300, // 5 minutes
        prayerTimes: [],
        enableFocusMode: true,
        enableAppBlocking: true,
        notificationsEnabled: true,
        lastActiveSessionID: nil,
        selectedApplicationTokensData: nil
    )
    
    init(
        defaultPrayerDuration: TimeInterval = 300,
        prayerTimes: [PrayerTime] = [],
        enableFocusMode: Bool = true,
        enableAppBlocking: Bool = true,
        notificationsEnabled: Bool = true,
        lastActiveSessionID: UUID? = nil,
        selectedApplicationTokensData: Data? = nil
    ) {
        self.defaultPrayerDuration = defaultPrayerDuration
        self.prayerTimes = prayerTimes
        self.enableFocusMode = enableFocusMode
        self.enableAppBlocking = enableAppBlocking
        self.notificationsEnabled = notificationsEnabled
        self.lastActiveSessionID = lastActiveSessionID
        self.selectedApplicationTokensData = selectedApplicationTokensData
    }
    
    // MARK: - Computed Properties
    
    /// Whether apps have been selected
    var hasSelectedApps: Bool {
        selectedApplicationTokensData != nil
    }
}

// MARK: - Duration Presets

enum PrayerDurationPreset: CaseIterable {
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case twentyMinutes
    case thirtyMinutes
    case custom
    
    var duration: TimeInterval {
        switch self {
        case .fiveMinutes: return 300
        case .tenMinutes: return 600
        case .fifteenMinutes: return 900
        case .twentyMinutes: return 1200
        case .thirtyMinutes: return 1800
        case .custom: return 0
        }
    }
    
    var displayName: String {
        switch self {
        case .fiveMinutes: return "5 min"
        case .tenMinutes: return "10 min"
        case .fifteenMinutes: return "15 min"
        case .twentyMinutes: return "20 min"
        case .thirtyMinutes: return "30 min"
        case .custom: return "Custom"
        }
    }
    
    static func preset(for duration: TimeInterval) -> PrayerDurationPreset {
        switch duration {
        case 300: return .fiveMinutes
        case 600: return .tenMinutes
        case 900: return .fifteenMinutes
        case 1200: return .twentyMinutes
        case 1800: return .thirtyMinutes
        default: return .custom
        }
    }
}

// MARK: - Session History

/// Simple container for prayer history
struct PrayerHistory: Codable {
    var sessions: [PrayerSession]
    
    init(sessions: [PrayerSession] = []) {
        self.sessions = sessions
    }
    
    /// Total prayer time across all sessions
    var totalPrayerTime: TimeInterval {
        sessions.compactMap { $0.actualDuration }.reduce(0, +)
    }
    
    /// Number of completed sessions
    var completedCount: Int {
        sessions.filter { $0.completedSuccessfully }.count
    }
    
    /// Add a new session to history
    mutating func add(_ session: PrayerSession) {
        sessions.append(session)
    }
    
    /// Get sessions from today
    var todaysSessions: [PrayerSession] {
        let calendar = Calendar.current
        return sessions.filter { session in
            guard let start = session.actualStart else { return false }
            return calendar.isDateInToday(start)
        }
    }
}
