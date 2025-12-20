import SwiftUI
import UserNotifications

// MARK: - Fervent App
// "…the effectual, fervent prayer of a righteous man availeth much."
// — James 5:16 (KJV)

@main
struct FerventAppApp: App {
    
    // MARK: - State
    
    @StateObject private var coordinator = RootCoordinator()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .preferredColorScheme(.dark)
                .task {
                    await coordinator.initialize()
                }
        }
    }
}

// MARK: - Root View
// Handles navigation between screens based on coordinator state

struct RootView: View {
    
    @EnvironmentObject var coordinator: RootCoordinator
    
    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .home:
                HomeView()
                    .transition(.opacity)
                
            case .prayer(let session):
                PrayerScreenView(session: session)
                    .transition(.opacity)
                
            case .prayerComplete(let session):
                PrayerCompletionView(session: session)
                    .transition(.opacity)
            }
        }
        .animation(.ferventStandard, value: coordinator.currentScreen)
    }
}

// MARK: - App Delegate
// Handles app lifecycle and notification delegate setup

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let notificationDelegate = NotificationDelegate()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Emergency unblock on app termination
        Task { @MainActor in
            AppBlockingService.shared.emergencyUnblock()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Clear badge count
        application.applicationIconBadgeNumber = 0
    }
}

// MARK: - Preview

#Preview {
    RootView()
        .environmentObject(RootCoordinator())
}

