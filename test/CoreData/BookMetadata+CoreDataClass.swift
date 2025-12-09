import Foundation
import CoreData

@objc(BookMetadata)
public class BookMetadata: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookMetadata> {
        return NSFetchRequest<BookMetadata>(entityName: "BookMetadata")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var bookID: String?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var genre: String?
    @NSManaged public var keywords: String?
    @NSManaged public var isFinished: Bool
    @NSManaged public var rating: Int16
    @NSManaged public var lastReadAt: Date?
}

extension BookMetadata : Identifiable {

}
