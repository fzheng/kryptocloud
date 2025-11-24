import Foundation
import SwiftUI

struct MediaItem: Identifiable {
    let id = UUID()
    let fileName: String
    let encryptedData: Data
    
    // The decrypted image, loaded on demand.
    @State var image: Image?
}
