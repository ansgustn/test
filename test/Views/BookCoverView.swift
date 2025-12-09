import SwiftUI

struct BookCoverView: View {
    let book: EPUBBook
    
    var readingProgress: ReadingProgress? {
        ReadingProgressManager.shared.getProgress(for: book.title)
    }
    
    var bookMetadata: BookMetadata? {
        BookMetadataManager.shared.getMetadata(for: book.title)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(2/3, contentMode: .fit)
                        .cornerRadius(8)
                    
                    if let coverURL = book.coverImage,
                       let imageData = try? Data(contentsOf: coverURL),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                    } else {
                        Image(systemName: "book.closed")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
                .shadow(radius: 2)
                
                // Completion badge
                if let metadata = bookMetadata, metadata.isFinished {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .background(Circle().fill(Color.white))
                        .offset(x: 8, y: -8)
                }
            }
            
            // Rating
            if let metadata = bookMetadata, metadata.rating > 0 {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= metadata.rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(index <= metadata.rating ? .yellow : .gray)
                    }
                }
            }
            
            // Progress bar
            if let progress = readingProgress, let metadata = bookMetadata, !metadata.isFinished {
                VStack(spacing: 4) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * progress.progress, height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                    
                    Text("\(progress.progressPercentage)%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(book.title)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
        }
    }
}
