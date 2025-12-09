import Foundation

struct ReadingProgress: Codable {
    let bookID: String
    var currentChapter: Int
    let totalChapters: Int
    
    var progress: Double {
        guard totalChapters > 0 else { return 0.0 }
        return Double(currentChapter + 1) / Double(totalChapters)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
}

class ReadingProgressManager {
    static let shared = ReadingProgressManager()
    
    private let progressKey = "reading_progress"
    
    private init() {}
    
    func saveProgress(_ progress: ReadingProgress) {
        var allProgress = loadAllProgress()
        allProgress[progress.bookID] = progress
        
        if let data = try? JSONEncoder().encode(allProgress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }
    
    func getProgress(for bookID: String) -> ReadingProgress? {
        let allProgress = loadAllProgress()
        return allProgress[bookID]
    }
    
    private func loadAllProgress() -> [String: ReadingProgress] {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode([String: ReadingProgress].self, from: data) else {
            return [:]
        }
        return progress
    }
}
