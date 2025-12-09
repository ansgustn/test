import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var tags: String?
    @NSManaged public var highlight: Highlight?
}

extension Note: Identifiable {
    
}
