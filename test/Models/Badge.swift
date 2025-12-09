import Foundation

// MARK: - Badge Type

enum BadgeType: String, Codable, CaseIterable {
    // Streak badges
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case streak100 = "streak_100"
    
    // Reading time badges
    case time10 = "time_10"
    case time50 = "time_50"
    case time100 = "time_100"
    
    // Books finished badges
    case books1 = "books_1"
    case books5 = "books_5"
    case books10 = "books_10"
    
    var title: String {
        switch self {
        case .streak3: return "불타는 시작"
        case .streak7: return "일주일의 힘"
        case .streak30: return "한 달의 헌신"
        case .streak100: return "백일의 기적"
        case .time10: return "초보 독서가"
        case .time50: return "열정적인 독서가"
        case .time100: return "독서 마스터"
        case .books1: return "첫 번째 책"
        case .books5: return "책벌레"
        case .books10: return "독서광"
        }
    }
    
    var description: String {
        switch self {
        case .streak3: return "3일 연속 독서 달성"
        case .streak7: return "7일 연속 독서 달성"
        case .streak30: return "30일 연속 독서 달성"
        case .streak100: return "100일 연속 독서 달성"
        case .time10: return "총 10시간 독서 달성"
        case .time50: return "총 50시간 독서 달성"
        case .time100: return "총 100시간 독서 달성"
        case .books1: return "첫 번째 책 완독"
        case .books5: return "5권의 책 완독"
        case .books10: return "10권의 책 완독"
        }
    }
    
    var icon: String {
        switch self {
        case .streak3, .streak7, .streak30, .streak100: return "flame.fill"
        case .time10, .time50, .time100: return "clock.fill"
        case .books1, .books5, .books10: return "book.fill"
        }
    }
    
    var requirement: Int {
        switch self {
        case .streak3: return 3
        case .streak7: return 7
        case .streak30: return 30
        case .streak100: return 100
        case .time10: return 600  // 10 hours in minutes
        case .time50: return 3000  // 50 hours in minutes
        case .time100: return 6000  // 100 hours in minutes
        case .books1: return 1
        case .books5: return 5
        case .books10: return 10
        }
    }
}

// MARK: - Badge

struct Badge: Codable, Identifiable {
    let type: BadgeType
    let earnedDate: Date?
    
    var id: String { type.rawValue }
    
    var isEarned: Bool {
        return earnedDate != nil
    }
}

// MARK: - Badge Manager

class BadgeManager {
    static let shared = BadgeManager()
    
    private let badgesKey = "earnedBadges"
    
    private init() {}
    
    // Get all badges (earned and not earned)
    func getAllBadges() -> [Badge] {
        let earnedBadges = loadEarnedBadges()
        
        return BadgeType.allCases.map { type in
            if let earnedBadge = earnedBadges.first(where: { $0.type == type }) {
                return earnedBadge
            } else {
                return Badge(type: type, earnedDate: nil)
            }
        }
    }
    
    // Check and award new badges
    func checkAndAwardBadges(currentStreak: Int, totalMinutes: Int, finishedBooks: Int) -> [Badge] {
        var newBadges: [Badge] = []
        var earnedBadges = loadEarnedBadges()
        
        // Check streak badges
        for streakBadge in [BadgeType.streak3, .streak7, .streak30, .streak100] {
            if currentStreak >= streakBadge.requirement && !hasBadge(streakBadge) {
                let badge = Badge(type: streakBadge, earnedDate: Date())
                earnedBadges.append(badge)
                newBadges.append(badge)
            }
        }
        
        // Check time badges
        for timeBadge in [BadgeType.time10, .time50, .time100] {
            if totalMinutes >= timeBadge.requirement && !hasBadge(timeBadge) {
                let badge = Badge(type: timeBadge, earnedDate: Date())
                earnedBadges.append(badge)
                newBadges.append(badge)
            }
        }
        
        // Check books finished badges
        for booksBadge in [BadgeType.books1, .books5, .books10] {
            if finishedBooks >= booksBadge.requirement && !hasBadge(booksBadge) {
                let badge = Badge(type: booksBadge, earnedDate: Date())
                earnedBadges.append(badge)
                newBadges.append(badge)
            }
        }
        
        // Save updated badges
        if !newBadges.isEmpty {
            saveEarnedBadges(earnedBadges)
        }
        
        return newBadges
    }
    
    // Private helpers
    
    private func loadEarnedBadges() -> [Badge] {
        guard let data = UserDefaults.standard.data(forKey: badgesKey),
              let badges = try? JSONDecoder().decode([Badge].self, from: data) else {
            return []
        }
        return badges
    }
    
    private func saveEarnedBadges(_ badges: [Badge]) {
        if let encoded = try? JSONEncoder().encode(badges) {
            UserDefaults.standard.set(encoded, forKey: badgesKey)
        }
    }
    
    private func hasBadge(_ type: BadgeType) -> Bool {
        return loadEarnedBadges().contains(where: { $0.type == type })
    }
}
