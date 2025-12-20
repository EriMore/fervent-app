import Foundation

// MARK: - Prayer Session Model
// The atomic unit of Fervent - each prayer session is a sacred act recorded

/// Represents a single prayer session
/// "Continue steadfastly in prayer" (Colossians 4:2)
struct PrayerSession: Codable, Identifiable, Equatable {
    
    /// Unique identifier for the session
    let id: UUID
    
    /// When the prayer was scheduled to begin (if scheduled)
    var scheduledStart: Date?
    
    /// When the prayer actually began
    var actualStart: Date?
    
    /// When the prayer ended
    var actualEnd: Date?
    
    /// Intended duration in seconds
    var intendedDuration: TimeInterval
    
    /// Bundle IDs of apps that were blocked during this session
    var blockedAppBundleIDs: [String]
    
    /// Whether the prayer was completed successfully (via long-press Amen)
    var completedSuccessfully: Bool
    
    /// Whether Focus mode was activated
    var focusModeActivated: Bool
    
    // MARK: - Computed Properties
    
    /// Actual duration of the prayer session
    var actualDuration: TimeInterval? {
        guard let start = actualStart, let end = actualEnd else { return nil }
        return end.timeIntervalSince(start)
    }
    
    /// Formatted duration string (e.g., "12:34")
    var formattedDuration: String {
        guard let duration = actualDuration else { return "--:--" }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Whether the session is currently active
    var isActive: Bool {
        actualStart != nil && actualEnd == nil
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        scheduledStart: Date? = nil,
        actualStart: Date? = nil,
        actualEnd: Date? = nil,
        intendedDuration: TimeInterval = 300, // 5 minutes default
        blockedAppBundleIDs: [String] = [],
        completedSuccessfully: Bool = false,
        focusModeActivated: Bool = false
    ) {
        self.id = id
        self.scheduledStart = scheduledStart
        self.actualStart = actualStart
        self.actualEnd = actualEnd
        self.intendedDuration = intendedDuration
        self.blockedAppBundleIDs = blockedAppBundleIDs
        self.completedSuccessfully = completedSuccessfully
        self.focusModeActivated = focusModeActivated
    }
    
    // MARK: - Session Lifecycle
    
    /// Create a new session and start it immediately
    static func startNew(
        intendedDuration: TimeInterval = 300,
        blockedAppBundleIDs: [String] = []
    ) -> PrayerSession {
        PrayerSession(
            actualStart: Date(),
            intendedDuration: intendedDuration,
            blockedAppBundleIDs: blockedAppBundleIDs
        )
    }
    
    /// Mark the session as completed successfully
    mutating func complete() {
        self.actualEnd = Date()
        self.completedSuccessfully = true
    }
    
    /// Mark the session as ended early (not completed)
    mutating func cancel() {
        self.actualEnd = Date()
        self.completedSuccessfully = false
    }
}

// MARK: - Prayer Time (for scheduling)

/// Represents a scheduled prayer time
struct PrayerTime: Codable, Identifiable, Equatable {
    let id: UUID
    
    /// Hour of day (0-23)
    var hour: Int
    
    /// Minute of hour (0-59)
    var minute: Int
    
    /// Whether this time is enabled
    var isEnabled: Bool
    
    /// Days of week this applies to (1 = Sunday, 7 = Saturday)
    /// Empty means every day
    var daysOfWeek: Set<Int>
    
    /// Label for this prayer time (e.g., "Morning Prayer")
    var label: String?
    
    init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int,
        isEnabled: Bool = true,
        daysOfWeek: Set<Int> = [],
        label: String? = nil
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.isEnabled = isEnabled
        self.daysOfWeek = daysOfWeek
        self.label = label
    }
    
    /// Formatted time string (e.g., "6:30 AM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }
    
    /// Next occurrence of this prayer time from now
    var nextOccurrence: Date? {
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        guard var date = calendar.date(from: components) else { return nil }
        
        // If the time has passed today, move to tomorrow
        if date <= now {
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        // If specific days are set, find the next matching day
        if !daysOfWeek.isEmpty {
            while let weekday = calendar.dateComponents([.weekday], from: date).weekday,
                  !daysOfWeek.contains(weekday) {
                date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
        }
        
        return date
    }
}

