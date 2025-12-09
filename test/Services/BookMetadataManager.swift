import Foundation
import CoreData

class BookMetadataManager {
    static let shared = BookMetadataManager()
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    private init() {}
    
    func createOrUpdateMetadata(
        bookID: String,
        title: String,
        author: String,
        genre: String? = nil,
        keywords: String? = nil
    ) {
        let fetchRequest: NSFetchRequest<BookMetadata> = BookMetadata.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bookID == %@", bookID)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            let metadata: BookMetadata
            
            if let existing = results.first {
                metadata = existing
            } else {
                metadata = BookMetadata(context: viewContext)
                metadata.id = UUID()
                metadata.bookID = bookID
            }
            
            metadata.title = title
            metadata.author = author
            metadata.genre = genre
            metadata.keywords = keywords
            metadata.lastReadAt = Date()
            
            try viewContext.save()
            print("BookMetadata saved for: \(title)")
        } catch {
            print("Error creating/updating metadata: \(error)")
        }
    }
    
    func getMetadata(for bookID: String) -> BookMetadata? {
        let fetchRequest: NSFetchRequest<BookMetadata> = BookMetadata.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bookID == %@", bookID)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching metadata: \(error)")
            return nil
        }
    }
    
    func markAsFinished(bookID: String, rating: Int16 = 0) {
        guard let metadata = getMetadata(for: bookID) else { return }
        
        metadata.isFinished = true
        if rating > 0 {
            metadata.rating = rating
        }
        
        do {
            try viewContext.save()
            print("Book marked as finished: \(bookID)")
        } catch {
            print("Error marking book as finished: \(error)")
        }
    }
    
    func updateRating(bookID: String, rating: Int16) {
        guard let metadata = getMetadata(for: bookID) else { return }
        
        metadata.rating = rating
        
        do {
            try viewContext.save()
            print("Rating updated for: \(bookID)")
        } catch {
            print("Error updating rating: \(error)")
        }
    }
}
