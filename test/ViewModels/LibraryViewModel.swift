import Foundation
import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case recentlyRead = "Recently Read"
    case title = "Title"
    case author = "Author"
    
    var id: String { self.rawValue }
}

class LibraryViewModel: ObservableObject {
    @Published var books: [EPUBBook] = []
    @Published var isLoading = false
    @Published var sortOption: SortOption = .recentlyRead {
        didSet {
            sortBooks()
        }
    }
    
    private let fileManager = FileManager.default
    private let parser = EPUBParser()
    
    var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    init() {
        copySampleBookIfNeeded()
        loadBooks()
    }
    
    private func copySampleBookIfNeeded() {
        SampleBookGenerator.createSampleBookIfNeeded(in: documentsDirectory)
    }
    
    func loadBooks() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            var loadedBooks: [EPUBBook] = []
            
            do {
                let fileURLs = try self.fileManager.contentsOfDirectory(at: self.documentsDirectory, includingPropertiesForKeys: nil)
                
                for url in fileURLs {
                    var isDirectory: ObjCBool = false
                    if self.fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            // Try to parse as EPUB directory
                            if let book = self.parser.parse(bookDirectory: url) {
                                loadedBooks.append(book)
                                
                                // Create or update BookMetadata
                                BookMetadataManager.shared.createOrUpdateMetadata(
                                    bookID: book.title,
                                    title: book.title,
                                    author: book.author,
                                    genre: book.genre
                                )
                            }
                        } else if url.pathExtension.lowercased() == "pdf" {
                            // Handle PDF (Create a dummy EPUBBook wrapper or separate model)
                            // For now, let's focus on EPUB folders as per current parser
                            // TODO: Support PDF in Library
                        }
                    }
                }
            } catch {
                print("Error loading books: \(error)")
            }
            
            DispatchQueue.main.async {
                self.books = loadedBooks
                self.sortBooks()
                self.isLoading = false
            }
        }
    }
    
    func sortBooks() {
        switch sortOption {
        case .recentlyRead:
            books.sort { book1, book2 in
                let lastRead1 = getLastReadTime(for: book1.title)
                let lastRead2 = getLastReadTime(for: book2.title)
                return lastRead1 > lastRead2
            }
        case .title:
            books.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .author:
            books.sort { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending }
        }
    }
    
    private func getLastReadTime(for bookID: String) -> Date {
        let key = "lastRead_\(bookID)"
        if let timestamp = UserDefaults.standard.object(forKey: key) as? Date {
            return timestamp
        }
        return Date.distantPast
    }
    
    func importBook(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let destinationURL = self.documentsDirectory.appendingPathComponent(url.lastPathComponent)
                
                if self.fileManager.fileExists(atPath: destinationURL.path) {
                    try self.fileManager.removeItem(at: destinationURL)
                }
                
                try self.fileManager.copyItem(at: url, to: destinationURL)
                
                DispatchQueue.main.async {
                    self.loadBooks()
                }
            } catch {
                print("Error importing book: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func deleteBook(at offsets: IndexSet) {
        offsets.forEach { index in
            let book = books[index]
            do {
                try fileManager.removeItem(at: book.directory)
            } catch {
                print("Error deleting book: \(error)")
            }
        }
        books.remove(atOffsets: offsets)
    }
}
