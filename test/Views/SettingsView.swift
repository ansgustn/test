import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("General")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section(header: Text("Data")) {
                    Button("Reset All Data", role: .destructive) {
                        showResetAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all your highlights, notes, and reading history. This action cannot be undone.")
            }
        }
    }
    
    private func resetAllData() {
        // Reset UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Reset CoreData
        let context = PersistenceController.shared.container.viewContext
        let entities = ["Highlight", "Note", "Book", "BookMetadata", "ReadingSession"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                print("✅ Deleted all \(entityName) entities")
            } catch {
                print("❌ Error deleting entity \(entityName): \(error)")
            }
        }
        
        // Refresh Statistics
        StatisticsManager.shared.calculateStatistics()
        
        print("✅ All data has been reset")
    }
}

#Preview {
    SettingsView()
}
