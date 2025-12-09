import SwiftUI
import CoreData

enum GroupBy: String, CaseIterable, Identifiable {
    case none = "None"
    case book = "Book"
    case date = "Date"
    
    var id: String { self.rawValue }
}

struct NotesListView: View {
    @State private var searchText = ""
    @State private var selectedTags: Set<String> = []
    @State private var groupBy: GroupBy = .none
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TagFilterView(selectedTags: $selectedTags)
                
                FilteredNotesList(filter: searchText, tags: selectedTags, groupBy: groupBy)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("My Highlights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Group By", selection: $groupBy) {
                            ForEach(GroupBy.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
}

struct FilteredNotesList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var highlights: FetchedResults<Highlight>
    let groupBy: GroupBy
    
    init(filter: String, tags: Set<String>, groupBy: GroupBy) {
        self.groupBy = groupBy
        let sortDescriptors = [NSSortDescriptor(keyPath: \Highlight.createdAt, ascending: false)]
        
        var predicates: [NSPredicate] = []
        
        if !filter.isEmpty {
            predicates.append(NSPredicate(format: "selectedText CONTAINS[cd] %@ OR note.content CONTAINS[cd] %@ OR bookID CONTAINS[cd] %@", filter, filter, filter))
        }
        
        if !tags.isEmpty {
            let tagPredicates = tags.map { tag in
                NSPredicate(format: "note.tags CONTAINS[cd] %@", tag)
            }
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: tagPredicates))
        }
        
        if predicates.isEmpty {
            _highlights = FetchRequest(sortDescriptors: sortDescriptors, animation: .default)
        } else {
            _highlights = FetchRequest(sortDescriptors: sortDescriptors, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates), animation: .default)
        }
    }
    
    var body: some View {
        List {
            if highlights.isEmpty {
                Text("No highlights found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                if groupBy == .none {
                    ForEach(highlights) { highlight in
                        HighlightRow(highlight: highlight)
                    }
                    .onDelete(perform: deleteHighlights)
                } else {
                    ForEach(groupedHighlights.keys.sorted(), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(groupedHighlights[key] ?? []) { highlight in
                                HighlightRow(highlight: highlight)
                            }
                            .onDelete { offsets in
                                deleteHighlightsInGroup(offsets: offsets, key: key)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var groupedHighlights: [String: [Highlight]] {
        Dictionary(grouping: highlights) { highlight in
            switch groupBy {
            case .book:
                return highlight.bookID
            case .date:
                return formatDate(highlight.createdAt)
            case .none:
                return ""
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func deleteHighlights(offsets: IndexSet) {
        withAnimation {
            offsets.map { highlights[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func deleteHighlightsInGroup(offsets: IndexSet, key: String) {
        withAnimation {
            if let group = groupedHighlights[key] {
                offsets.map { group[$0] }.forEach(viewContext.delete)
                saveContext()
            }
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error deleting highlights: \(error)")
        }
    }
}

struct HighlightRow: View {
    let highlight: Highlight
    
    var body: some View {
        NavigationLink(destination: NoteEditView(highlight: highlight)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(colorForString(highlight.color))
                        .frame(width: 12, height: 12)
                    
                    Text(highlight.selectedText)
                        .font(.body)
                        .lineLimit(2)
                }
                
                if let note = highlight.note {
                    if !note.content.isEmpty {
                        Text(note.content)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                    }
                    
                    if let tags = note.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags.components(separatedBy: ","), id: \.self) { tag in
                                    Text("#\(tag.trimmingCharacters(in: .whitespaces))")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                        .padding(.leading, 20)
                    }
                }
                
                HStack {
                    Text(highlight.bookID)
                        .fontWeight(.bold)
                    
                    Text(highlight.createdAt, style: .date)
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func colorForString(_ colorString: String) -> Color {
        switch colorString {
        case "yellow": return .yellow
        case "green": return .green
        case "pink": return .pink
        default: return .yellow
        }
    }
}
