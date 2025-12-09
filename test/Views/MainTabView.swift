import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            LibraryView()
                .tabItem {
                    Label("서재", systemImage: "books.vertical")
                }
            
            StatsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar")
                }
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
}
