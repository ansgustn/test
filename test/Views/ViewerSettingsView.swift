import SwiftUI

struct ViewerSettingsView: View {
    @Binding var settings: ViewerSettings
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Viewer Settings")
                .font(.headline)
                .padding(.top)
            
            Divider()
            
            // Font Size
            VStack(alignment: .leading) {
                Text("Font Size: \(settings.fontSize)%")
                HStack {
                    Button(action: { if settings.fontSize > 50 { settings.fontSize -= 10 } }) {
                        Image(systemName: "textformat.size.smaller")
                    }
                    Slider(value: Binding(
                        get: { Double(settings.fontSize) },
                        set: { settings.fontSize = Int($0) }
                    ), in: 50...200, step: 10)
                    Button(action: { if settings.fontSize < 200 { settings.fontSize += 10 } }) {
                        Image(systemName: "textformat.size.larger")
                    }
                }
            }
            .padding(.horizontal)
            
            // Theme
            VStack(alignment: .leading) {
                Text("Theme")
                Picker("Theme", selection: $settings.theme) {
                    ForEach(ViewerTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // Font
            VStack(alignment: .leading) {
                Text("Font")
                Picker("Font", selection: $settings.font) {
                    ForEach(ViewerFont.allCases) { font in
                        Text(font.rawValue).tag(font)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.medium, .fraction(0.4)])
    }
}
