import SwiftUI

struct ViewerSettingsView: View {
    @Binding var settings: ViewerSettings
    
    var body: some View {
        VStack(spacing: 20) {
            Text("뷰어 설정")
                .font(.headline)
                .padding(.top)
            
            Divider()
            
            // Font Size
            VStack(alignment: .leading) {
                Text("글자 크기: \(settings.fontSize)%")
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
                Text("테마")
                Picker("테마", selection: $settings.theme) {
                    ForEach(ViewerTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // Font
            VStack(alignment: .leading) {
                Text("글꼴")
                Picker("글꼴", selection: $settings.font) {
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
