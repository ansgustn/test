import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "BookMark")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, implement proper error recovery
                print("⚠️ CoreData Error: \(error)")
                print("⚠️ Description: \(description)")
                
                // For now, we'll crash in debug but should implement recovery in production
                #if DEBUG
                fatalError("Unable to load persistent stores: \(error)")
                #else
                print("⚠️ Failed to load persistent store. App may not function correctly.")
                #endif
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Create sample data on first launch
        createSampleDataIfNeeded()
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    private func createSampleDataIfNeeded() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Highlight> = Highlight.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // Create sample highlights
                createSampleHighlight(
                    text: "In my younger and more vulnerable years my father gave me some advice",
                    color: "yellow",
                    noteContent: "Great opening line!",
                    context: context
                )
                
                createSampleHighlight(
                    text: "Whenever you feel like criticizing any one",
                    color: "green",
                    noteContent: nil,
                    context: context
                )
                
                createSampleHighlight(
                    text: "all the people in this world haven't had the advantages that you've had",
                    color: "pink",
                    noteContent: "Important life lesson",
                    context: context
                )
                
                try context.save()
                print("Sample highlights created successfully")
            }
        } catch {
            print("Error creating sample data: \(error)")
        }
    }
    
    private func createSampleHighlight(text: String, color: String, noteContent: String?, context: NSManagedObjectContext) {
        let highlight = Highlight(context: context)
        highlight.id = UUID()
        highlight.bookID = "The Great Gatsby"
        highlight.chapterIndex = 0
        highlight.selectedText = text
        highlight.color = color
        highlight.createdAt = Date()
        
        if let noteContent = noteContent {
            let note = Note(context: context)
            note.id = UUID()
            note.content = noteContent
            note.createdAt = Date()
            note.highlight = highlight
        }
    }
}

