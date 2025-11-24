import Foundation
import LocalAuthentication
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var isUnlocked = false

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock your Kryptocloud vault."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // Handle error
                    }
                }
            }
        } else {
            // No biometrics available
        }
    }
}
