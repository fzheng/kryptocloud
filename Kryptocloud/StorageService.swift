import Foundation
import UIKit

class StorageService: NSObject, UIDocumentPickerDelegate {
    
    private var completion: ((URL) -> Void)?
    
    func pickDirectory(completion: @escaping (URL) -> Void) {
        self.completion = completion
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self
        
        // This requires access to the view controller hierarchy.
        // We will need to integrate this with our SwiftUI view.
        // For now, this is a placeholder for the logic.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        rootViewController.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        completion?(url)
    }
    
    func save(data: Data, to directory: URL, with fileName: String) throws {
        let fileURL = directory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }
    
    func load(from directory: URL, with fileName: String) throws -> Data {
        let fileURL = directory.appendingPathComponent(fileName)
        return try Data(contentsOf: fileURL)
    }
    
    func listFiles(in directory: URL) -> [URL] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            print("Error listing files: \(error)")
            return []
        }
    }
}
