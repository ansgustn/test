import SwiftUI

struct HighlightMenuView: View {
    let selectedText: String
    let onHighlight: (String) -> Void
    let onNote: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var noteText: String = ""
    @State private var isAddingNote = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Selected Text")
                .font(.headline)
            
            Text(selectedText)
                .font(.body)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .lineLimit(3)
            
            Divider()
            
            if isAddingNote {
                VStack(alignment: .leading) {
                    Text("Note")
                        .font(.subheadline)
                    
                    TextField("Enter your note here...", text: $noteText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom)
                    
                    Button(action: {
                        onNote(noteText)
                        dismiss()
                    }) {
                        Text("Save Note")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text("Highlight Color")
                        .font(.subheadline)
                    
                    HStack(spacing: 20) {
                        ColorButton(color: .yellow, name: "yellow") {
                            onHighlight("yellow")
                            dismiss()
                        }
                        
                        ColorButton(color: .green, name: "green") {
                            onHighlight("green")
                            dismiss()
                        }
                        
                        ColorButton(color: .pink, name: "pink") {
                            onHighlight("pink")
                            dismiss()
                        }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        withAnimation {
                            isAddingNote = true
                        }
                    }) {
                        Label("Add Note", systemImage: "note.text")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            Button("Cancel") {
                dismiss()
            }
            .padding(.bottom)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

struct ColorButton: View {
    let color: Color
    let name: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                )
        }
    }
}
