import Foundation
import Combine
import CoreData

class ReaderViewModel: ObservableObject {
    @Published var book: EPUBBook?
    @Published var currentChapterIndex: Int = 0
    @Published var isBookLoaded = false
    @Published var settings = ViewerSettings.load() {
        didSet {
            settings.save()
        }
    }
    @Published var selectedText: String = ""
    @Published var showHighlightMenu = false
    
    @Published var highlights: [Highlight] = []
    
    private let parser = EPUBParser()
    private let viewContext = PersistenceController.shared.container.viewContext
    
    func loadBook(from directory: URL) {
        // Run on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            if let parsedBook = self.parser.parse(bookDirectory: directory) {
                DispatchQueue.main.async {
                    self.book = parsedBook
                    self.isBookLoaded = true
                    self.loadReadingProgress() // Load saved progress
                    self.loadHighlights()
                    StatisticsManager.shared.startSession(bookID: parsedBook.title)
                }
            } else {
                print("Failed to parse book at \(directory)")
            }
        }
    }
    
    var currentChapterURL: URL? {
        guard let book = book, book.chapters.indices.contains(currentChapterIndex) else { return nil }
        let chapter = book.chapters[currentChapterIndex]
        return book.directory.appendingPathComponent(chapter.contentPath)
    }
    
    func nextChapter() {
        guard let book = book else { return }
        if currentChapterIndex < book.chapters.count - 1 {
            currentChapterIndex += 1
            saveReadingProgress()
            updateReadingProgress()
            loadHighlights()
        }
    }
    
    func previousChapter() {
        if currentChapterIndex > 0 {
            currentChapterIndex -= 1
            saveReadingProgress()
            updateReadingProgress()
            loadHighlights()
        }
    }
    
    private func updateReadingProgress() {
        guard let book = book else { return }
        let progress = ReadingProgress(
            bookID: book.title,
            currentChapter: currentChapterIndex,
            totalChapters: book.chapters.count
        )
        ReadingProgressManager.shared.saveProgress(progress)
        
        // Update last read time for sorting
        let key = "lastRead_\(book.title)"
        UserDefaults.standard.set(Date(), forKey: key)
    }
    
    // MARK: - Reading Progress
    
    private func saveReadingProgress() {
        guard let book = book else { return }
        UserDefaults.standard.set(currentChapterIndex, forKey: "progress_\(book.title)")
    }
    
    private func loadReadingProgress() {
        guard let book = book else { return }
        let savedIndex = UserDefaults.standard.integer(forKey: "progress_\(book.title)")
        if book.chapters.indices.contains(savedIndex) {
            currentChapterIndex = savedIndex
        }
    }
    
    func loadHighlights() {
        guard let book = book else { return }
        
        let request: NSFetchRequest<Highlight> = Highlight.fetchRequest()
        request.predicate = NSPredicate(format: "bookID == %@ AND chapterIndex == %d", book.title, currentChapterIndex)
        
        do {
            highlights = try viewContext.fetch(request)
        } catch {
            print("Error fetching highlights: \(error)")
        }
    }
}
