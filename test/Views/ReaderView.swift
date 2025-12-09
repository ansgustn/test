import SwiftUI
import CoreData

struct ReaderView: View {
    @StateObject private var viewModel = ReaderViewModel()
    @State private var isSettingsPresented = false
    @State private var isNotesPresented = false
    @State private var isAISummaryPresented = false
    @State private var isAIQuestionPresented = false
    @State private var showCompletionView = false
    @Environment(\.managedObjectContext) private var viewContext
    let bookDirectory: URL // Passed from parent
    
    var body: some View {
        VStack {
            if viewModel.isBookLoaded {
                if let url = viewModel.currentChapterURL {
                    WebView(
                        url: url,
                        settings: viewModel.settings,
                        highlights: viewModel.highlights,
                        selectedText: $viewModel.selectedText,
                        showHighlightMenu: $viewModel.showHighlightMenu
                    )
                    .edgesIgnoringSafeArea(.all)
                } else {
                    Text("챕터를 불러올 수 없습니다")
                }
            } else {
                ProgressView("책 불러오는 중...")
            }
        }
        .background(Color(hex: viewModel.settings.theme.backgroundColor))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { isAISummaryPresented = true }) {
                        Label("AI 요약", systemImage: "sparkles.rectangle.stack")
                    }
                    
                    Button(action: { isAIQuestionPresented = true }) {
                        Label("AI에게 질문", systemImage: "bubble.left.and.bubble.right")
                    }
                } label: {
                    Image(systemName: "sparkles")
                }
                
                Button(action: { isNotesPresented = true }) {
                    Image(systemName: "book.pages")
                }
                
                Button(action: { isSettingsPresented = true }) {
                    Image(systemName: "textformat.size")
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: { viewModel.previousChapter() }) {
                    Image(systemName: "chevron.left")
                }
                .disabled(viewModel.currentChapterIndex == 0)
                
                Spacer()
                
                Text("\(viewModel.currentChapterIndex + 1) / \(viewModel.book?.chapters.count ?? 0)")
                    .font(.caption)
                
                Spacer()
                
                Button(action: { 
                    if let book = viewModel.book, viewModel.currentChapterIndex == book.chapters.count - 1 {
                        // Last chapter - show completion view
                        showCompletionView = true
                    } else {
                        viewModel.nextChapter()
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
                .disabled(viewModel.book == nil || viewModel.currentChapterIndex == (viewModel.book!.chapters.count - 1))
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            ViewerSettingsView(settings: $viewModel.settings)
        }
        .sheet(isPresented: $isNotesPresented) {
            NotesListView()
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $isAISummaryPresented) {
            if let url = viewModel.currentChapterURL,
               let content = try? String(contentsOf: url, encoding: .utf8) {
                AISummaryView(chapterContent: content)
            } else {
                Text("챕터 내용을 불러올 수 없습니다.")
            }
        }
        .sheet(isPresented: $isAIQuestionPresented) {
            if let url = viewModel.currentChapterURL,
               let content = try? String(contentsOf: url, encoding: .utf8) {
                AIQuestionView(chapterContent: content)
            } else {
                Text("챕터 내용을 불러올 수 없습니다.")
            }
        }
        .sheet(isPresented: $viewModel.showHighlightMenu) {
            HighlightMenuView(
                selectedText: viewModel.selectedText,
                onHighlight: { color in
                    saveHighlight(color: color, withNote: nil)
                },
                onNote: { noteContent in
                    saveHighlight(color: "yellow", withNote: noteContent)
                }
            )
        }
        .sheet(isPresented: $showCompletionView) {
            if let book = viewModel.book {
                BookCompletionView(
                    bookTitle: book.title,
                    isPresented: $showCompletionView,
                    onComplete: { rating in
                        BookMetadataManager.shared.markAsFinished(
                            bookID: book.title,
                            rating: Int16(rating)
                        )
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadBook(from: bookDirectory)
        }
        .onDisappear {
            StatisticsManager.shared.endSession()
        }
        .navigationTitle(viewModel.book?.title ?? "독서")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveHighlight(color: String, withNote noteContent: String?) {
        guard let book = viewModel.book else { return }
        
        let highlight = Highlight(context: viewContext)
        highlight.id = UUID()
        highlight.bookID = book.title
        highlight.chapterIndex = Int16(viewModel.currentChapterIndex)
        highlight.selectedText = viewModel.selectedText
        highlight.color = color
        highlight.createdAt = Date()
        
        var note: Note?
        
        if let noteContent = noteContent {
            note = Note(context: viewContext)
            note?.id = UUID()
            note?.content = noteContent
            note?.createdAt = Date()
            note?.highlight = highlight
        } else {
            // If no note content, create a note just for tags if needed?
            // For now, only generate tags if there is a note or maybe always?
            // Requirement says "Highlight Auto Tagging", so we should create a note or store tags on highlight?
            // The schema has tags on Note. So we need a Note object.
            // Let's create a Note even if content is empty, or just for tags.
            // But if noteContent is nil, user didn't click "Add Note".
            // Let's create a note with empty content if we want tags.
            // Or maybe we should only generate tags if user adds a note?
            // Task.md says "Highlight Auto Tagging".
            // Let's create a note automatically for every highlight to store tags.
            
            let autoNote = Note(context: viewContext)
            autoNote.id = UUID()
            autoNote.content = "" // Empty content for pure highlight
            autoNote.createdAt = Date()
            autoNote.highlight = highlight
            note = autoNote
        }
        
        do {
            try viewContext.save()
            print("Highlight saved successfully")
            viewModel.loadHighlights() // Refresh highlights
        } catch {
            print("Error saving highlight: \(error)")
        }
        
        // Generate Tags asynchronously
        if let savedNote = note {
            Task {
                do {
                    let tags = try await GeminiService.shared.generateTags(text: viewModel.selectedText)
                    let tagsString = tags.joined(separator: ", ")
                    
                    // Update note with tags
                    savedNote.tags = tagsString
                    try viewContext.save()
                    print("Tags generated and saved: \(tagsString)")
                } catch {
                    print("Error generating tags: \(error)")
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
