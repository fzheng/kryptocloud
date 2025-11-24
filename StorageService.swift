import Foundation
import UIKit

class StorageService {
    
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
