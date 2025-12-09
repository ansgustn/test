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
                            title: "Total Time",
                            value: formatTime(statsManager.totalReadingTime),
                            icon: "clock.fill",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "Current Streak",
                            value: "\(statsManager.currentStreak) 🔥",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Streak Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Streak Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("Current Streak")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(statsManager.currentStreak) days")
                                    .fontWeight(.bold)
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text("Longest Streak")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(statsManager.longestStreak) days")
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
                        Text("Weekly Activity")
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
                        Text("Badges")
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
                        Text("Recent Books")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("No recent books")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
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
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
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
