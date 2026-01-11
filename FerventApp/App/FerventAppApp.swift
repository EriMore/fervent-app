import SwiftUI

@main
struct FerventAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Text("Hello, World!")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
