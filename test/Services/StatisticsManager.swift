import Foundation
import CoreData

class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    
    @Published var weeklyReadingTime: [Double] = Array(repeating: 0, count: 7) // Mon-Sun
    @Published var totalReadingTime: TimeInterval = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    private var currentSession: ReadingSession?
    private let viewContext = PersistenceController.shared.container.viewContext
    
    private init() {
        calculateStatistics()
    }
    
    func startSession(bookID: String) {
        let session = ReadingSession(context: viewContext)
        session.id = UUID()
        session.bookID = bookID
        session.startTime = Date()
        session.duration = 0
        session.pagesRead = 0
        
        currentSession = session
        
        saveContext()
    }
    
    func endSession() {
        guard let session = currentSession, let startTime = session.startTime else { return }
        session.endTime = Date()
        session.duration = session.endTime!.timeIntervalSince(startTime)
        
        saveContext()
        currentSession = nil
        calculateStatistics()
        
        // Check for new badges
        checkAndAwardBadges()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving statistics context: \(error)")
        }
    }
    
    private func loadSessions() -> [ReadingSession] {
        let request: NSFetchRequest<ReadingSession> = ReadingSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching reading sessions: \(error)")
            return []
        }
    }
    
    func calculateStatistics() {
        let sessions = loadSessions()
        
        // Total Reading Time
        totalReadingTime = sessions.reduce(0) { $0 + $1.duration }
        
        // Weekly Reading Time
        var weeklyTime = Array(repeating: 0.0, count: 7)
        let calendar = Calendar.current
        let today = Date()
        
        // Find start of current week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday + 5) % 7 // Convert to 0 (Mon) - 6 (Sun)
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: today)) else { return }
        
        for session in sessions {
            guard let endTime = session.endTime else { continue }
            
            // Check if session is in current week
            if endTime >= startOfWeek {
                let dayComponent = calendar.component(.weekday, from: endTime)
                // Convert Sunday(1)...Saturday(7) to Monday(0)...Sunday(6)
                let index = (dayComponent + 5) % 7
                if index >= 0 && index < 7 {
                    weeklyTime[index] += session.duration
                }
            }
        }
        
        DispatchQueue.main.async {
            self.weeklyReadingTime = weeklyTime
        }
        
        // Calculate Streaks
        let (current, longest) = calculateStreaks(sessions: sessions)
        DispatchQueue.main.async {
            self.currentStreak = current
            self.longestStreak = longest
        }
    }
    
    private func calculateStreaks(sessions: [ReadingSession]) -> (current: Int, longest: Int) {
        let calendar = Calendar.current
        
        // Get unique reading days
        let readingDays = Set(
            sessions.compactMap { $0.endTime }
                .map { calendar.startOfDay(for: $0) }
        ).sorted(by: >)
        
        guard !readingDays.isEmpty else { return (0, 0) }
        
        // Calculate current streak
        var currentStreak = 0
        let today = calendar.startOfDay(for: Date())
        
        // Check if we read today or yesterday
        if let mostRecentDay = readingDays.first {
            let daysDiff = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? 0
            
            if daysDiff > 1 {
                // Streak is broken
                currentStreak = 0
            } else {
                // Count consecutive days
                var previousDay = mostRecentDay
                for day in readingDays {
                    let diff = calendar.dateComponents([.day], from: day, to: previousDay).day ?? 0
                    if diff == 0 || diff == 1 {
                        currentStreak += 1
                        previousDay = day
                    } else {
                        break
                    }
                }
            }
        }
        
        // Calculate longest streak
        var longestStreak = 0
        var tempStreak = 0
        var previousDay: Date?
        
        for day in readingDays.reversed() {
            if let prev = previousDay {
                let diff = calendar.dateComponents([.day], from: prev, to: day).day ?? 0
                if diff == 1 {
                    tempStreak += 1
                } else {
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            previousDay = day
        }
        longestStreak = max(longestStreak, tempStreak)
        
        return (currentStreak, longestStreak)
    }
    
    private func checkAndAwardBadges() {
        let totalMinutes = Int(totalReadingTime / 60)
        let finishedBooks = getFinishedBooksCount()
        
        let newBadges = BadgeManager.shared.checkAndAwardBadges(
            currentStreak: currentStreak,
            totalMinutes: totalMinutes,
            finishedBooks: finishedBooks
        )
        
        // Could show notification for new badges here
        if !newBadges.isEmpty {
            print("🏆 New badges earned: \(newBadges.map { $0.type.title }.joined(separator: ", "))")
        }
    }
    
    private func getFinishedBooksCount() -> Int {
        let request: NSFetchRequest<BookMetadata> = BookMetadata.fetchRequest()
        request.predicate = NSPredicate(format: "isFinished == YES")
        
        do {
            return try viewContext.count(for: request)
        } catch {
            print("Error counting finished books: \(error)")
            return 0
        }
    }
}
