# Kryptocloud

Kryptocloud: Your Personal Encryption Key for the Cloud.

Worried about your private memories in the cloud? Kryptocloud adds a powerful layer of security, encrypting your photos and videos before they are stored in your own iCloud Drive. You control the files and you hold the key.

Your Kryptocloud vault is locked with Face ID or Touch ID, ensuring only you can see what's inside. Browse your protected photos and videos seamlessly in a secure, private gallery. When you're ready to share, simply export the decrypted file anywhere you wish.

Kryptocloud puts you in control of your digital privacy. Simple, powerful, and secure.

## Technical Description

Kryptocloud is a native iOS application built with Swift and SwiftUI that provides secure, client-side encryption for photos and videos.

*   **Authentication**: Access to the app's content is gated by Apple's LocalAuthentication framework, requiring Face ID or Touch ID.
*   **Encryption**: It uses CryptoKit to perform AES-256-GCM symmetric encryption on media files. A unique encryption key is generated on the device and stored securely in the system Keychain.
*   **Storage**: The app does not have its own cloud storage. It uses `UIDocumentPickerViewController` to have the user grant access to a specific folder in their iCloud Drive. All encrypted files are stored in this user-owned directory.

### Workflow

1.  **Import**: Media is encrypted in-memory and the resulting ciphertext is written to the user's designated iCloud folder.
2.  **View**: Encrypted files are read from iCloud, decrypted in-memory for display, and then purged. Plaintext data is never written to disk for viewing.
3.  **Export**: Files are decrypted in-memory and written to a user-chosen destination.
