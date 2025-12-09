import Foundation
import CoreData

@objc(ReadingSession)
public class ReadingSession: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadingSession> {
        return NSFetchRequest<ReadingSession>(entityName: "ReadingSession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var bookID: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var duration: Double
    @NSManaged public var pagesRead: Int16
}

extension ReadingSession : Identifiable {

}
