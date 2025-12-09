import SwiftUI

struct RecommendationView: View {
    @StateObject private var recommendationService = RecommendationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Recommendations")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if recommendationService.isLoading {
                    ProgressView()
                } else {
                    Button(action: {
                        Task {
                            await recommendationService.generateRecommendations()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding(.horizontal)
            
            if recommendationService.recommendations.isEmpty {
                if recommendationService.isLoading {
                    Text("Analyzing your reading history...")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    Text("Tap refresh to get recommendations")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recommendationService.recommendations) { book in
                            RecommendationCard(book: book)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            if recommendationService.recommendations.isEmpty {
                Task {
                    await recommendationService.generateRecommendations()
                }
            }
        }
    }
}

struct RecommendationCard: View {
    let book: RecommendedBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover Placeholder
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(height: 140)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                )
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Text(book.reason)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: {
                // TODO: Implement book details or search
            }) {
                Text("Details")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 200, height: 320)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
