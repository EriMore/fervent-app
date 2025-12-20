import SwiftUI
import Combine

// MARK: - Root Coordinator
// State-driven navigation for Fervent
// Single source of truth - no ad-hoc NavigationLinks

/// The root navigation state for the entire app
enum AppScreen: Equatable {
    case home
    case prayer(session: PrayerSession)
    case prayerComplete(session: PrayerSession)
}

/// Coordinates app-wide navigation and state
@MainActor
final class RootCoordinator: ObservableObject {
    
    // MARK: - Published State
    
    /// Current screen being displayed
    @Published var currentScreen: AppScreen = .home
    
    /// Whether app is ready (services initialized)
    @Published private(set) var isReady: Bool = false
    
    /// Any error to display
    @Published var activeError: AppError?
    
    // MARK: - Services
    
    let persistence: PersistenceService
    let appBlocking: AppBlockingService
    let focusMode: FocusModeService
    let notifications: NotificationService
    
    // MARK: - Private
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        persistence: PersistenceService = .shared,
        appBlocking: AppBlockingService = .shared,
        focusMode: FocusModeService = .shared,
        notifications: NotificationService = .shared
    ) {
        self.persistence = persistence
        self.appBlocking = appBlocking
        self.focusMode = focusMode
        self.notifications = notifications
        
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Listen for notification-triggered prayer starts
        NotificationCenter.default.publisher(for: .startPrayerFromNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.startPrayerFromNotification()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Initialize all services and prepare the app
    func initialize() async {
        // Check for crash recovery
        persistence.recoverFromCrash()
        
        // Ensure any lingering app blocks are cleared
        appBlocking.emergencyUnblock()
        
        // Check authorization statuses
        appBlocking.checkAuthorizationStatus()
        await notifications.checkAuthorizationStatus()
        
        isReady = true
    }
    
    // MARK: - Navigation Actions
    
    /// Navigate to home screen
    func goHome() {
        withAnimation(.ferventStandard) {
            currentScreen = .home
        }
    }
    
    /// Start a new prayer session
    func startPrayer(duration: TimeInterval) async {
        // Get blocked app bundle IDs (simplified for tokens)
        let blockedIDs = appBlocking.selectedApps.applicationTokens.map { _ in "blocked" }
        
        // Create session
        let session = persistence.startSession(
            intendedDuration: duration,
            blockedAppBundleIDs: blockedIDs
        )
        
        // Start blocking apps
        appBlocking.startBlocking()
        
        // Enter focus mode
        await focusMode.enterFocusMode()
        
        // Mark focus mode activated
        persistence.updateCurrentSession { $0.focusModeActivated = true }
        
        // Navigate to prayer screen
        withAnimation(.ferventStandard) {
            currentScreen = .prayer(session: session)
        }
    }
    
    /// Complete the current prayer session (via long-press Amen)
    func completePrayer() async {
        guard let completedSession = persistence.completeCurrentSession() else {
            goHome()
            return
        }
        
        // Stop blocking apps immediately
        appBlocking.stopBlocking()
        
        // Exit focus mode
        await focusMode.exitFocusMode()
        
        // Navigate to completion screen
        withAnimation(.ferventCompletion) {
            currentScreen = .prayerComplete(session: completedSession)
        }
    }
    
    /// Cancel the current prayer session
    func cancelPrayer() async {
        _ = persistence.cancelCurrentSession()
        
        // Stop blocking apps immediately
        appBlocking.stopBlocking()
        
        // Exit focus mode
        await focusMode.exitFocusMode()
        
        // Return home
        goHome()
    }
    
    /// Return home from completion screen
    func returnFromCompletion() {
        goHome()
    }
    
    // MARK: - Notification Handling
    
    /// Start prayer when triggered by notification
    private func startPrayerFromNotification() {
        Task {
            await startPrayer(duration: persistence.settings.defaultPrayerDuration)
        }
    }
    
    // MARK: - Permissions
    
    /// Request all necessary permissions
    func requestPermissions() async {
        do {
            // Request app blocking permission
            try await appBlocking.requestAuthorization()
        } catch {
            print("App blocking authorization failed: \(error)")
        }
        
        do {
            // Request notification permission
            try await notifications.requestAuthorization()
        } catch {
            print("Notification authorization failed: \(error)")
        }
    }
    
    /// Check if key permissions are granted
    var hasRequiredPermissions: Bool {
        appBlocking.isAuthorized
    }
}

// MARK: - App Errors

enum AppError: LocalizedError, Identifiable {
    case appBlockingFailed(Error)
    case notificationsFailed(Error)
    case sessionError(String)
    
    var id: String {
        switch self {
        case .appBlockingFailed: return "appBlocking"
        case .notificationsFailed: return "notifications"
        case .sessionError(let msg): return "session_\(msg)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .appBlockingFailed(let error):
            return "App blocking error: \(error.localizedDescription)"
        case .notificationsFailed(let error):
            return "Notification error: \(error.localizedDescription)"
        case .sessionError(let message):
            return message
        }
    }
}

// MARK: - View Extension for Coordinator Access

struct RootCoordinatorKey: EnvironmentKey {
    static let defaultValue: RootCoordinator? = nil
}

extension EnvironmentValues {
    var rootCoordinator: RootCoordinator? {
        get { self[RootCoordinatorKey.self] }
        set { self[RootCoordinatorKey.self] = newValue }
    }
}

