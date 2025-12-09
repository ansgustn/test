import SwiftUI

struct NoteEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var highlight: Highlight
    
    @State private var noteContent: String = ""
    @State private var selectedColor: String = "yellow"
    
    var body: some View {
        Form {
            Section(header: Text("선택된 텍스트")) {
                Text(highlight.selectedText)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Section(header: Text("하이라이트 색상")) {
                Picker("색상", selection: $selectedColor) {
                    Text("노란색").tag("yellow")
                    Text("초록색").tag("green")
                    Text("분홍색").tag("pink")
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("메모")) {
                TextEditor(text: $noteContent)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("메모 편집")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("저장") {
                    saveChanges()
                    dismiss()
                }
            }
        }
        .onAppear {
            selectedColor = highlight.color
            noteContent = highlight.note?.content ?? ""
        }
    }
    
    private func saveChanges() {
        highlight.color = selectedColor
        
        if let note = highlight.note {
            note.content = noteContent
            note.createdAt = Date() // Update timestamp
        } else if !noteContent.isEmpty {
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.content = noteContent
            newNote.createdAt = Date()
            newNote.highlight = highlight
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
