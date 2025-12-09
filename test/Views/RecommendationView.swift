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
        GeometryReader { geometry in
            ZStack {
                // Generate unique color based on book title
                LinearGradient(
                    colors: generateBookColors(for: book.title),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Book cover design
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Genre icon at top
                    genreIcon(for: book.genre)
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.3))
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Title section (like real book cover)
                    VStack(spacing: 6) {
                        Text(book.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .padding(.horizontal, 16)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                        
                        Rectangle()
                            .fill(.white.opacity(0.8))
                            .frame(width: 40, height: 2)
                            .padding(.vertical, 4)
                        
                        Text(book.author)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.9))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 20)
                }
                
                // Decorative border
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            }
        }
        .frame(height: 140)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
    
    // Generate unique colors based on title
    private func generateBookColors(for title: String) -> [Color] {
        let hash = abs(title.hashValue)
        let hue = Double(hash % 360) / 360.0
        let saturation = 0.6 + Double((hash / 360) % 20) / 100.0
        
        return [
            Color(hue: hue, saturation: saturation, brightness: 0.7),
            Color(hue: hue + 0.1, saturation: saturation - 0.1, brightness: 0.5)
        ]
    }
    
    // Genre-specific icons
    private func genreIcon(for genre: String) -> Image {
        let genreLower = genre.lowercased()
        
        if genreLower.contains("역사") || genreLower.contains("history") {
            return Image(systemName: "clock.fill")
        } else if genreLower.contains("과학") || genreLower.contains("science") {
            return Image(systemName: "atom")
        } else if genreLower.contains("소설") || genreLower.contains("문학") || genreLower.contains("fiction") {
            return Image(systemName: "text.book.closed.fill")
        } else if genreLower.contains("sf") || genreLower.contains("공상") {
            return Image(systemName: "sparkles")
        } else if genreLower.contains("자기계발") || genreLower.contains("self") {
            return Image(systemName: "star.fill")
        } else if genreLower.contains("비즈니스") || genreLower.contains("business") {
            return Image(systemName: "chart.line.uptrend.xyaxis")
        } else if genreLower.contains("철학") || genreLower.contains("philosophy") {
            return Image(systemName: "brain.head.profile")
        } else {
            return Image(systemName: "book.closed.fill")
        }
    }
}
