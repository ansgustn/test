import Foundation
import CoreData

@objc(Highlight)
public class Highlight: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var bookID: String
    @NSManaged public var chapterIndex: Int16
    @NSManaged public var selectedText: String
    @NSManaged public var color: String // "yellow", "green", "pink"
    @NSManaged public var createdAt: Date
    @NSManaged public var note: Note?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Highlight> {
        return NSFetchRequest<Highlight>(entityName: "Highlight")
    }
}

extension Highlight: Identifiable {
    
}
