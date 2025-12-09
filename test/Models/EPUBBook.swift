import Foundation

struct EPUBBook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let genre: String?
    let coverImage: URL?
    let chapters: [EPUBChapter]
    let directory: URL // The directory where the book is unzipped
}

struct EPUBChapter: Identifiable {
    let id = UUID()
    let title: String
    let contentPath: String // Relative path to the HTML/XHTML file
}
