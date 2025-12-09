import SwiftUI

struct RecommendationView: View {
    @StateObject private var recommendationService = RecommendationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("오늘의 추천 도서")
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
                    Text("독서 이력 분석 중...")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    Text("새로고침을 눌러 추천을 받으세요")
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
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover Image
            if let imageURL = book.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 140)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        placeholderCover
                    @unknown default:
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }
            
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
                showingDetail = true
            }) {
                Text("상세보기")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 200, height: 320)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingDetail) {
            RecommendedBookDetailView(book: book)
        }
    }
    
    private var placeholderCover: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .frame(height: 140)
            .overlay(
                Image(systemName: "book.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            )
            .cornerRadius(8)
    }
}
