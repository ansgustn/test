import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let settings: ViewerSettings
    let highlights: [Highlight]
    @Binding var selectedText: String
    @Binding var showHighlightMenu: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Add message handler for text selection
        userContentController.add(context.coordinator, name: "textSelected")
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load content if URL changed
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
        
        // Apply settings via JS
        let js = """
        document.body.style.fontSize = '\(settings.fontSize)%';
        document.body.style.backgroundColor = '\(settings.theme.backgroundColor)';
        document.body.style.color = '\(settings.theme.textColor)';
        document.body.style.fontFamily = '\(settings.font.cssValue)';
        """
        
        uiView.evaluateJavaScript(js, completionHandler: nil)
        
        // Apply highlights
        applyHighlights(uiView)
    }
    
    private func applyHighlights(_ webView: WKWebView) {
        // Define highlight function
        let highlightJS = """
        function highlightText(text, color) {
            // Simple implementation using window.find
            // Note: This might scroll the view, which is not ideal.
            // A better implementation would use Range and TreeWalker.
            
            // Reset selection to start search from beginning
            // But this loses user's current position/selection
            // So we just try to find.
            
            // This is a very basic implementation and has limitations.
            // It highlights the first occurrence found from current position.
            // To highlight all, we need to loop.
            
            // Ideally, we should use a library like Mark.js or similar logic.
            
            // For now, let's try to find and highlight.
            if (window.find(text)) {
                var selection = window.getSelection();
                if (selection.rangeCount > 0) {
                    var range = selection.getRangeAt(0);
                    
                    // Check if already highlighted
                    if (range.startContainer.parentNode.className === 'bookmark-highlight') {
                        selection.removeAllRanges();
                        return;
                    }
                    
                    var span = document.createElement("span");
                    span.style.backgroundColor = color;
                    span.className = "bookmark-highlight";
                    
                    try {
                        range.surroundContents(span);
                    } catch (e) {
                        console.log("Error highlighting: " + e);
                    }
                    
                    selection.removeAllRanges();
                }
            }
        }
        """
        
        webView.evaluateJavaScript(highlightJS, completionHandler: nil)
        
        // Apply each highlight
        for highlight in highlights {
            let colorCode = colorCodeForString(highlight.color)
            // Escape single quotes in text
            let escapedText = highlight.selectedText.replacingOccurrences(of: "'", with: "\\'")
            let applyJS = "highlightText('\(escapedText)', '\(colorCode)');"
            webView.evaluateJavaScript(applyJS, completionHandler: nil)
        }
    }
    
    private func colorCodeForString(_ color: String) -> String {
        switch color {
        case "yellow": return "#FFFF00"
        case "green": return "#00FF00"
        case "pink": return "#FFC0CB"
        default: return "#FFFF00"
        }
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "textSelected", let text = message.body as? String {
                DispatchQueue.main.async {
                    self.parent.selectedText = text
                    self.parent.showHighlightMenu = true
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Inject JavaScript for text selection
            let selectionJS = """
            document.addEventListener('selectionchange', function() {
                var selection = window.getSelection();
                var selectedText = selection.toString().trim();
                if (selectedText.length > 0) {
                    window.webkit.messageHandlers.textSelected.postMessage(selectedText);
                }
            });
            """
            webView.evaluateJavaScript(selectionJS, completionHandler: nil)
            
            // Apply viewer settings after page load
            applySettings(to: webView)
        }
        
        private func applySettings(to webView: WKWebView) {
            let settings = parent.settings
            let js = """
            document.body.style.fontSize = '\(settings.fontSize)%';
            document.body.style.backgroundColor = '\(settings.theme.backgroundColor)';
            document.body.style.color = '\(settings.theme.textColor)';
            document.body.style.fontFamily = '\(settings.font.cssValue)';
            document.body.style.lineHeight = '\(settings.lineHeight)';
            """
            
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("❌ Error applying settings: \(error)")
                } else {
                    print("✅ Settings applied: fontSize=\(settings.fontSize)%")
                }
            }
        }
    }
}
