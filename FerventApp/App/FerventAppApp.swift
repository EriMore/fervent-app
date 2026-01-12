import SwiftUI

@main
struct FerventAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Content View
// Manages the Loading → HelloWorld transition
// "Starting a session feels like entering, not pressing a button"

struct ContentView: View {
    
    // MARK: - State
    
    @State private var isLoading: Bool = true
    @State private var showHelloWorld: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Hello World (underneath, revealed when loading fades)
            if showHelloWorld {
                HelloWorldView()
                    .transition(.opacity)
            }
            
            // Loading screen (on top initially)
            if isLoading {
                LoadingView {
                    completeLoading()
                }
                .transition(.opacity)
            }
        }
        .animation(.ferventFade, value: isLoading)
    }
    
    // MARK: - Actions
    
    /// Transition from loading to hello world
    /// Feels like departing, not snapping
    private func completeLoading() {
        // Prepare hello world underneath
        showHelloWorld = true
        
        // Brief moment to ensure smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.ferventFade) {
                isLoading = false
            }
        }
    }
}

#Preview {
    ContentView()
}
