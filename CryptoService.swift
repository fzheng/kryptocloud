import Foundation
import CryptoKit

class CryptoService {
    private let keyIdentifier = "com.kryptocloud.encryptionkey.v1"
    private let keychainService = KeychainService()
    
    private var encryptionKey: SymmetricKey?

    init() {
        do {
            self.encryptionKey = try loadKeyFromKeychain()
        } catch KeychainService.KeychainError.itemNotFound {
            print("No key found in keychain, generating a new one.")
            self.encryptionKey = generateAndStoreKey()
        } catch {
            print("Error loading key from keychain: \(error)")
            // In a real app, you might want to handle this more gracefully,
            // maybe by blocking the app from proceeding.
            self.encryptionKey = nil
        }
    }
    
    private func generateAndStoreKey() -> SymmetricKey {
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data(Array($0)) }
        
        do {
            try keychainService.save(key: keyIdentifier, data: keyData)
            return newKey
        } catch {
            // This is a critical failure. In a real app, you would need robust error handling.
            fatalError("Failed to save new encryption key to keychain: \(error)")
        }
    }
    
    private func loadKeyFromKeychain() throws -> SymmetricKey {
        let keyData = try keychainService.load(key: keyIdentifier)
        return SymmetricKey(data: keyData)
    }

    func encrypt(data: Data) -> Data? {
        guard let key = encryptionKey else {
            print("Encryption failed: key is not available.")
            return nil
        }
        guard let sealedBox = try? AES.GCM.seal(data, using: key) else { return nil }
        return sealedBox.combined
    }

    func decrypt(data: Data) -> Data? {
        guard let key = encryptionKey else {
            print("Decryption failed: key is not available.")
            return nil
        }
        guard let sealedBox = try? AES.GCM.SealedBox(combined: data) else { return nil }
        let decryptedData = try? AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }
}
