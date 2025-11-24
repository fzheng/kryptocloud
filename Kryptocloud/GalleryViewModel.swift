import Foundation
import SwiftUI

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
    let guidance: String
}

class GalleryViewModel: ObservableObject {
    @Published var mediaItems: [MediaItem] = []
    @Published var errorWrapper: ErrorWrapper?
    
    private let cryptoService = CryptoService()
    private let storageService = StorageService()

    public var getCryptoService: CryptoService {
        return cryptoService
    }
    
    // The view will now be responsible for updating this property via the DocumentPicker.
    @AppStorage("iCloudDirectoryURL") var directoryURLString: String = ""

    var directoryURL: URL? {
        get { URL(string: directoryURLString) }
        set {
            directoryURLString = newValue?.absoluteString ?? ""
            // When the URL is set, load the media items.
            loadMediaItems()
        }
    }

    func onAppear() {
        // When the view appears, if we already have a directory URL, load the items.
        if directoryURL != nil {
            loadMediaItems()
        }
    }

    func loadMediaItems() {
        guard let directoryURL = directoryURL else { return }
        
        let shouldStopAccessing = directoryURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                directoryURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let fileURLs = storageService.listFiles(in: directoryURL)
        
        self.mediaItems = fileURLs.map { url in
            let data = (try? Data(contentsOf: url)) ?? Data()
            return MediaItem(fileName: url.lastPathComponent, encryptedData: data)
        }
    }
    
    func importData(_ data: Data) {
        guard let directoryURL = directoryURL else { return }
        guard let encryptedData = cryptoService.encrypt(data: data) else {
            self.errorWrapper = ErrorWrapper(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Encryption failed."]), guidance: "Could not encrypt the selected file.")
            return
        }
        
        let fileName = "\(UUID().uuidString).krypto"
        
        let shouldStopAccessing = directoryURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                directoryURL.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            try storageService.save(data: encryptedData, to: directoryURL, with: fileName)
            // Refresh the list
            loadMediaItems()
        } catch {
            self.errorWrapper = ErrorWrapper(error: error, guidance: "Could not save the encrypted file to your iCloud Drive folder. Please check your device's connection and iCloud storage.")
        }
    }
}
