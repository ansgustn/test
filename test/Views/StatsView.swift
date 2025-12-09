import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var statsManager = StatisticsManager.shared
    @State private var badges: [Badge] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Cards
                    HStack(spacing: 16) {
                        SummaryCard(
                            title: "총 독서 시간",
                            value: formatTime(statsManager.totalReadingTime),
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "현재 연속",
                            value: "\(statsManager.currentStreak) 🔥",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Streak Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("연속 독서 정보")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("현재 연속 일수")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(statsManager.currentStreak)일")
                                    .fontWeight(.bold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text("최장 연속 일수")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(statsManager.longestStreak)일")
                                    .fontWeight(.bold)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Weekly Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("주간 활동")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(0..<7, id: \.self) { index in
                                BarMark(
                                    x: .value("Day", dayName(for: index)),
                                    y: .value("Hours", statsManager.weeklyReadingTime[index] / 3600.0)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Badges Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("뱃지")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                            ForEach(badges) { badge in
                                BadgeView(badge: badge)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Books (Placeholder)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("최근 읽은 책")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("최근 읽은 책이 없습니다")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("독서 통계")
            .onAppear {
                statsManager.calculateStatistics()
                loadBadges()
            }
        }
    }
    
    private func loadBadges() {
        badges = BadgeManager.shared.getAllBadges()
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func dayName(for index: Int) -> String {
        let days = ["월", "화", "수", "목", "금", "토", "일"]
        return days[index]
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.type.icon)
                .font(.system(size: 40))
                .foregroundStyle(badge.isEarned ? .yellow : .gray)
            
            Text(badge.type.title)
                .font(.caption2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(badge.isEarned ? .primary : .secondary)
        }
        .frame(width: 100, height: 100)
        .background(badge.isEarned ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .opacity(badge.isEarned ? 1.0 : 0.5)
    }
}

#Preview {
    StatsView()
}
