import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("일반")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section(header: Text("데이터")) {
                    Button("모든 데이터 초기화", role: .destructive) {
                        showResetAlert = true
                    }
                }
            }
            .navigationTitle("설정")
            .alert("모든 데이터 초기화", isPresented: $showResetAlert) {
                Button("취소", role: .cancel) { }
                Button("초기화", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("모든 하이라이트, 메모, 독서 기록이 삭제됩니다. 이 작업은 취소할 수 없습니다.")
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
