import SwiftUI
import AVKit

struct DetailView: View {
    let mediaItem: MediaItem
    let cryptoService: CryptoService
    
    @State private var decryptedData: Data?
    @State private var image: UIImage?
    @State private var videoPlayer: AVPlayer?
    @State private var isExporting = false
    @State private var exportURL: URL?
    @State private var showDecryptionError = false
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if let player = videoPlayer {
                VideoPlayer(player: player)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: decryptMedia)
        .alert("Decryption Failed", isPresented: $showDecryptionError) {
            Button("OK") {}
        } message: {
            Text("The file could not be decrypted. It may be corrupted or the encryption key has changed.")
        }
        .sheet(isPresented: $isExporting, onDismiss: cleanupExport) {
            if let url = exportURL {
                ActivityView(activityItems: [url])
            }
        }
        .navigationTitle(mediaItem.fileName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: prepareForExport) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(decryptedData == nil)
            }
        }
    }
    
    private func decryptMedia() {
        if let data = cryptoService.decrypt(data: mediaItem.encryptedData) {
            self.decryptedData = data
            // Simple check for image content type.
            if let uiImage = UIImage(data: data) {
                self.image = uiImage
            } else {
                // Assume it's a video. This is a simplification.
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(mediaItem.fileName)
                try? data.write(to: tempURL)
                self.videoPlayer = AVPlayer(url: tempURL)
            }
        } else {
            self.showDecryptionError = true
        }
    }
    
    private func prepareForExport() {
        guard let data = decryptedData else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(mediaItem.fileName)
        
        do {
            try data.write(to: tempURL)
            self.exportURL = tempURL
            self.isExporting = true
        } catch {
            print("Failed to write temporary file for export: \(error)")
            // Optionally, show an alert to the user.
        }
    }
    
    private func cleanupExport() {
        if let url = exportURL {
            try? FileManager.default.removeItem(at: url)
            self.exportURL = nil
        }
    }
}
