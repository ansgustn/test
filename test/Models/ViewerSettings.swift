import SwiftUI

enum ViewerTheme: String, CaseIterable, Identifiable, Codable {
    case light = "Light"
    case dark = "Dark"
    case sepia = "Sepia"
    
    var id: String { self.rawValue }
    
    var backgroundColor: String {
        switch self {
        case .light: return "#ffffff"
        case .dark: return "#1c1c1e"
        case .sepia: return "#f8f1e3"
        }
    }
    
    var textColor: String {
        switch self {
        case .light: return "#000000"
        case .dark: return "#ffffff"
        case .sepia: return "#5f4b32"
        }
    }
}

enum ViewerFont: String, CaseIterable, Identifiable, Codable {
    case serif = "Serif"
    case sansSerif = "Sans-Serif"
    case system = "System"
    
    var id: String { self.rawValue }
    
    var cssValue: String {
        switch self {
        case .serif: return "serif"
        case .sansSerif: return "sans-serif"
        case .system: return "-apple-system"
        }
    }
}

struct ViewerSettings: Codable {
    var fontSize: Int = 100 // Percentage
    var theme: ViewerTheme = .light
    var font: ViewerFont = .serif
    var lineHeight: Double = 1.5
    
    private static let key = "viewerSettings"
    
    // Save to UserDefaults
    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: ViewerSettings.key)
            print("✅ Viewer settings saved")
        }
    }
    
    // Load from UserDefaults
    static func load() -> ViewerSettings {
        if let data = UserDefaults.standard.data(forKey: key),
           let settings = try? JSONDecoder().decode(ViewerSettings.self, from: data) {
            print("✅ Viewer settings loaded")
            return settings
        }
        print("ℹ️ Using default viewer settings")
        return ViewerSettings()
    }
}
