import Foundation

// MARK: - Reading Goal

struct ReadingGoal: Codable {
    enum GoalType: String, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
    }
    
    var type: GoalType
    var targetMinutes: Int
    var startDate: Date
    
    // Check if goal is achieved based on current statistics
    func isAchieved(totalMinutes: Int) -> Bool {
        return totalMinutes >= targetMinutes
    }
    
    // Progress percentage (0-100)
    func progress(totalMinutes: Int) -> Int {
        guard targetMinutes > 0 else { return 0 }
        let percentage = (Double(totalMinutes) / Double(targetMinutes)) * 100
        return min(Int(percentage), 100)
    }
}

// MARK: - Goal Manager

class ReadingGoalManager {
    static let shared = ReadingGoalManager()
    
    private let dailyGoalKey = "dailyReadingGoal"
    private let weeklyGoalKey = "weeklyReadingGoal"
    
    private init() {}
    
    // Save daily goal
    func saveDailyGoal(targetMinutes: Int) {
        let goal = ReadingGoal(type: .daily, targetMinutes: targetMinutes, startDate: Date())
        if let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: dailyGoalKey)
        }
    }
    
    // Save weekly goal
    func saveWeeklyGoal(targetMinutes: Int) {
        let goal = ReadingGoal(type: .weekly, targetMinutes: targetMinutes, startDate: Date())
        if let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: weeklyGoalKey)
        }
    }
    
    // Load daily goal
    func loadDailyGoal() -> ReadingGoal? {
        guard let data = UserDefaults.standard.data(forKey: dailyGoalKey),
              let goal = try? JSONDecoder().decode(ReadingGoal.self, from: data) else {
            return nil
        }
        return goal
    }
    
    // Load weekly goal
    func loadWeeklyGoal() -> ReadingGoal? {
        guard let data = UserDefaults.standard.data(forKey: weeklyGoalKey),
              let goal = try? JSONDecoder().decode(ReadingGoal.self, from: data) else {
            return nil
        }
        return goal
    }
}
