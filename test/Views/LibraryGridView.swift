import SwiftUI

struct LibraryGridView: View {
    @ObservedObject var viewModel: LibraryViewModel
    let columns: [GridItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Library")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView("Loading Library...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.books.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("No books yet")
                        .font(.headline)
                    Text("Tap + to add EPUB folder")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.books) { book in
                        NavigationLink(destination: ReaderView(bookDirectory: book.directory)) {
                            BookCoverView(book: book)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = viewModel.books.firstIndex(where: { $0.id == book.id }) {
                                    viewModel.deleteBook(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
