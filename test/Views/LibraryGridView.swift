import SwiftUI

struct LibraryGridView: View {
    @ObservedObject var viewModel: LibraryViewModel
    let columns: [GridItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("내 서재")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView("서재 불러오는 중...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.books.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("아직 책이 없습니다")
                        .font(.headline)
                    Text("+ 버튼을 눌러 EPUB 폴더를 추가하세요")
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
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
