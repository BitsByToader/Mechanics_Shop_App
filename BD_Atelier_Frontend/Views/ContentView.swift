import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        NavigationStack(path: $store.navPath) {
            LoginView()
                .navigationTitle("Atelier Mecanica")
        }
    }
}
