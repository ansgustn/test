import SwiftUI

struct PDFReaderView: View {
    let url: URL
    
    var body: some View {
        PDFKitView(url: url)
            .edgesIgnoringSafeArea(.all)
            .navigationTitle(url.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
    }
}
