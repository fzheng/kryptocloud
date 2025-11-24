import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()

    var body: some View {
        VStack {
            if authService.isUnlocked {
                GalleryView()
            } else {
                Button("Unlock with Face ID / Touch ID") {
                    authService.authenticate()
                }
            }
        }
        .onAppear {
            authService.authenticate()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
