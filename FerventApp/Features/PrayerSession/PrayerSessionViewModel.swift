import SwiftUI
import Combine

// MARK: - Prayer Session View Model
// Manages the state of an active prayer session
// "Continue steadfastly in prayer" (Colossians 4:2)

@MainActor
final class PrayerSessionViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// Time elapsed in the current session
    @Published private(set) var elapsedTime: TimeInterval = 0
    
    /// Visual intensity (0.0 to 1.0) - builds over time
    @Published private(set) var intensity: Double = 0
    
    /// Whether the session is active
    @Published private(set) var isActive: Bool = false
    
    /// Progress toward long-press completion (0.0 to 1.0)
    @Published var longPressProgress: Double = 0
    
    /// Whether long press is in progress
    @Published var isLongPressing: Bool = false
    
    // MARK: - Session Data
    
    let session: PrayerSession
    private let intendedDuration: TimeInterval
    
    // MARK: - Private
    
    // Store timers as nonisolated to allow cleanup in deinit
    nonisolated private var timer: Timer?
    nonisolated private var longPressTimer: Timer?
    
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    // Long press configuration
    private let longPressDuration: TimeInterval = 2.0 // seconds to hold
    private var longPressStartTime: Date?
    
    // MARK: - Initialization
    
    init(session: PrayerSession) {
        self.session = session
        self.intendedDuration = session.intendedDuration
        
        // Start tracking immediately
        startSession()
    }
    
    nonisolated deinit {
        // Cleanup timers - Timer invalidation is thread-safe
        timer?.invalidate()
        longPressTimer?.invalidate()
    }
    
    // MARK: - Computed Properties
    
    /// Formatted elapsed time (MM:SS)
    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Formatted elapsed time with hours for long sessions
    var formattedTimeLong: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Progress toward intended duration (0.0 to 1.0, can exceed 1.0)
    var progress: Double {
        guard intendedDuration > 0 else { return 0 }
        return elapsedTime / intendedDuration
    }
    
    /// Whether the intended duration has been reached
    var hasReachedIntendedDuration: Bool {
        elapsedTime >= intendedDuration
    }
    
    // MARK: - Session Control
    
    /// Start the prayer session timer
    func startSession() {
        guard !isActive else { return }
        
        isActive = true
        startTime = Date()
        
        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime()
            }
        }
        
        print("Prayer session started")
    }
    
    /// Stop the session timer
    func stopSession() {
        isActive = false
        stopTimer()
        print("Prayer session stopped at \(formattedTime)")
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let start = startTime else { return }
        elapsedTime = Date().timeIntervalSince(start)
        updateIntensity()
    }
    
    // MARK: - Intensity Calculation
    // Visual intensity builds slowly over time
    // "The fire shall ever be burning... it shall never go out" (Leviticus 6:13)
    
    private func updateIntensity() {
        // Intensity builds gradually, reaching max around intended duration
        // Uses a smooth curve that continues to grow slowly after
        
        let baseIntensity: Double
        if intendedDuration > 0 {
            // Smooth curve that approaches but doesn't quite reach 1.0
            // at intended duration, then continues growing slowly
            let normalizedTime = elapsedTime / intendedDuration
            baseIntensity = 1.0 - exp(-2.0 * normalizedTime)
        } else {
            // Fallback: grow based on absolute time
            baseIntensity = 1.0 - exp(-elapsedTime / 300) // 5 min to reach ~63%
        }
        
        // Add subtle breathing variation
        let breathingPhase = sin(elapsedTime * 0.3) * 0.05
        
        intensity = min(1.0, max(0, baseIntensity + breathingPhase))
    }
    
    // MARK: - Long Press Gesture
    // Ending prayer requires intentional long-press
    // "Nothing pops. Everything settles."
    
    /// Begin the long press
    func startLongPress() {
        guard !isLongPressing else { return }
        
        isLongPressing = true
        longPressStartTime = Date()
        longPressProgress = 0
        
        // Start long press progress timer
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateLongPressProgress()
            }
        }
    }
    
    /// Cancel the long press
    func cancelLongPress() {
        isLongPressing = false
        longPressStartTime = nil
        stopLongPressTimer()
        
        // Animate progress back to zero
        withAnimation(.ferventStandard) {
            longPressProgress = 0
        }
    }
    
    /// Check if long press is complete
    func checkLongPressComplete() -> Bool {
        longPressProgress >= 1.0
    }
    
    private func updateLongPressProgress() {
        guard let start = longPressStartTime, isLongPressing else { return }
        
        let elapsed = Date().timeIntervalSince(start)
        longPressProgress = min(1.0, elapsed / longPressDuration)
    }
    
    private func stopLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}
