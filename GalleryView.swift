import SwiftUI

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @State private var isPickingDirectory = false
    @State private var isPickingPhoto = false
    @State private var selectedPhotoData: Data?

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.directoryURL == nil {
                    Button("Select iCloud Drive Folder") {
                        isPickingDirectory = true
                    }
                } else {
                    if viewModel.mediaItems.isEmpty {
                        Text("No items yet. Tap '+' to add.")
                            .foregroundColor(.gray)
                    } else {
                        List(viewModel.mediaItems) { item in
                            NavigationLink(destination: DetailView(mediaItem: item, cryptoService: viewModel.getCryptoService)) {
                                Text(item.fileName)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isPickingDirectory) {
                DocumentPicker(directoryURL: $viewModel.directoryURL)
            }
            .sheet(isPresented: $isPickingPhoto) {
                PhotoPicker(selectedData: $selectedPhotoData)
            }
            .onChange(of: selectedPhotoData) { newData in
                if let data = newData {
                    viewModel.importData(data)
                    // Reset the selected data
                    selectedPhotoData = nil
                }
            }
            .alert(item: $viewModel.errorWrapper) { wrapper in
                Alert(title: Text("An Error Occurred"),
                      message: Text(wrapper.guidance),
                      dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.onAppear()
            }
            .navigationTitle("Kryptocloud")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.directoryURL == nil {
                            isPickingDirectory = true
                        } else {
                            isPickingPhoto = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
