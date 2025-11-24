import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedData: Data?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            // This is a simplification. A real app would need to handle different
            // content types and potential errors more robustly.
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage else { return }
                    DispatchQueue.main.async {
                        self.parent.selectedData = image.jpegData(compressionQuality: 1.0)
                    }
                }
            } else {
                // Handle other types like videos
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                     guard let url = url else { return }
                     
                     // To handle the file, you might need to move it to a temporary directory
                     // before you can get the data from it.
                     let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                     try? FileManager.default.copyItem(at: url, to: tempDir)

                     DispatchQueue.main.async {
                        self.parent.selectedData = try? Data(contentsOf: tempDir)
                        try? FileManager.default.removeItem(at: tempDir)
                     }
                 }
            }
        }
    }
}
