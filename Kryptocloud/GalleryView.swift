import SwiftUI

struct GalleryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Encrypted Files")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                // Placeholder for the gallery grid
                Text("No items yet.")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Kryptocloud")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Import action
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
