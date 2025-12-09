import Foundation
import CoreData

struct RecommendedBook: Identifiable, Codable {
    var id = UUID()
    let title: String
    let author: String
    let description: String
    let reason: String
    let genre: String
    
    // Exclude 'id' from JSON decoding since API doesn't provide it
    enum CodingKeys: String, CodingKey {
        case title, author, description, reason, genre
    }
}

@MainActor
class RecommendationService: ObservableObject {
    static let shared = RecommendationService()
    
    @Published var recommendations: [RecommendedBook] = []
    @Published var isLoading = false
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    private init() {}
    
    func generateRecommendations() async {
        self.isLoading = true
        
        do {
            // 1. Fetch reading history
            let request: NSFetchRequest<BookMetadata> = BookMetadata.fetchRequest()
            let books = try viewContext.fetch(request)
            
            if books.isEmpty {
                // Cold start: Recommend popular books
                let defaultRecommendations = [
                    RecommendedBook(title: "The Great Gatsby", author: "F. Scott Fitzgerald", description: "A classic novel of the Jazz Age.", reason: "많은 독자들이 사랑하는 고전 명작입니다.", genre: "Classic"),
                    RecommendedBook(title: "1984", author: "George Orwell", description: "A dystopian social science fiction novel.", reason: "디스토피아 장르의 대표작입니다.", genre: "Sci-Fi"),
                    RecommendedBook(title: "Sapiens", author: "Yuval Noah Harari", description: "A brief history of humankind.", reason: "인류의 역사를 통찰력 있게 다룬 베스트셀러입니다.", genre: "History")
                ]
                self.recommendations = defaultRecommendations
                self.isLoading = false
                return
            }
            
            // 2. Construct prompt
            let readBooksInfo = books.map { "\($0.title ?? "") (Genre: \($0.genre ?? "Unknown"), Rating: \($0.rating))" }.joined(separator: ", ")
            
            let prompt = """
            사용자가 읽은 책 목록: \(readBooksInfo)
            
            이 사용자의 취향을 분석하여 읽을만한 책 3권을 추천해주세요.
            다음 JSON 형식으로 응답해주세요:
            [
                {
                    "title": "책 제목",
                    "author": "저자",
                    "description": "간단한 책 설명",
                    "reason": "추천 이유 (한국어로, '회원님이 읽으신 ...과 비슷하여' 형식)",
                    "genre": "장르"
                }
            ]
            JSON 외의 다른 텍스트는 포함하지 마세요.
            """
            
            // 3. Call Gemini API
            let jsonString = try await GeminiService.shared.generateContent(prompt: prompt)
            
            // 4. Parse response (clean markdown code blocks if present)
            let cleanedJSON = cleanJSONResponse(jsonString)
            
            if let data = cleanedJSON.data(using: String.Encoding.utf8) {
                let recommendedBooks = try JSONDecoder().decode([RecommendedBook].self, from: data)
                self.recommendations = recommendedBooks
                self.isLoading = false
            }
            
        } catch {
            print("Error generating recommendations: \(error)")
            self.isLoading = false
        }
    }
    
    /// Clean JSON response by removing markdown code blocks
    private func cleanJSONResponse(_ response: String) -> String {
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks (```json ... ``` or ``` ... ```)
        if cleaned.hasPrefix("```") {
            // Remove opening ```json or ```
            if let firstNewline = cleaned.firstIndex(of: "\n") {
                cleaned = String(cleaned[cleaned.index(after: firstNewline)...])
            }
            // Remove closing ```
            if cleaned.hasSuffix("```") {
                cleaned = String(cleaned.dropLast(3))
            }
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return cleaned
    }
}
