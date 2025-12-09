import SwiftUI

struct NoteEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var highlight: Highlight
    
    @State private var noteContent: String = ""
    @State private var selectedColor: String = "yellow"
    
    var body: some View {
        Form {
            Section(header: Text("Selected Text")) {
                Text(highlight.selectedText)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Section(header: Text("Highlight Color")) {
                Picker("Color", selection: $selectedColor) {
                    Text("Yellow").tag("yellow")
                    Text("Green").tag("green")
                    Text("Pink").tag("pink")
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Note")) {
                TextEditor(text: $noteContent)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
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
