import Foundation
import CoreData

struct RecommendedBook: Identifiable, Codable {
    var id = UUID()
    let title: String
    let author: String
    let description: String
    let reason: String
    let genre: String
    let imageURL: String?
    let purchaseURL: String?
    
    // Exclude 'id' from JSON decoding since API doesn't provide it
    enum CodingKeys: String, CodingKey {
        case title, author, description, reason, genre, imageURL, purchaseURL
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
                    RecommendedBook(
                        title: "위대한 개츠비",
                        author: "F. Scott Fitzgerald",
                        description: "재즈 시대를 배경으로 한 고전 명작",
                        reason: "많은 독자들이 사랑하는 미국 문학의 걸작입니다.",
                        genre: "고전문학",
                        imageURL: "https://image.aladin.co.kr/product/293/61/cover/8937460788_1.jpg",
                        purchaseURL: "https://www.aladin.co.kr/search/wsearchresult.aspx?SearchTarget=All&SearchWord=위대한+개츠비"
                    ),
                    RecommendedBook(
                        title: "1984",
                        author: "George Orwell",
                        description: "디스토피아 소설의 대표작",
                        reason: "현대 사회를 되돌아보게 하는 통찰력 있는 작품입니다.",
                        genre: "SF",
                        imageURL: "https://image.aladin.co.kr/product/2893/41/cover/8949121018_1.jpg",
                        purchaseURL: "https://www.aladin.co.kr/search/wsearchresult.aspx?SearchTarget=All&SearchWord=1984"
                    ),
                    RecommendedBook(
                        title: "사피엔스",
                        author: "유발 하라리",
                        description: "인류의 역사와 미래에 대한 통찰",
                        reason: "인류의 역사를 새로운 관점에서 바라볼 수 있는 베스트셀러입니다.",
                        genre: "역사",
                        imageURL: "https://image.aladin.co.kr/product/6935/32/cover/8934972467_1.jpg",
                        purchaseURL: "https://www.aladin.co.kr/search/wsearchresult.aspx?SearchTarget=All&SearchWord=사피엔스"
                    )
                ]
                self.recommendations = defaultRecommendations
                self.isLoading = false
                return
            }
            
            // 2. Construct prompt
            let readBooksInfo = books.map { "\($0.title ?? "") (Genre: \($0.genre ?? "Unknown"), Rating: \($0.rating))" }.joined(separator: ", ")
            
            let prompt = """
            사용자가 읽은 책 목록: \(readBooksInfo)
            
            이 사용자의 취향을 분석하여 읽을만한 한국 도서 3권을 추천해주세요.
            다음 JSON 형식으로 응답해주세요:
            [
                {
                    "title": "책 제목 (한국어로 번역된 제목)",
                    "author": "저자명",
                    "description": "책 소개 (2-3문장, 한국어)",
                    "reason": "추천 이유 (한국어로, '회원님이 읽으신 ...과 비슷하여' 형식)",
                    "genre": "장르 (한국어)",
                    "imageURL": null,
                    "purchaseURL": null
                }
            ]
            
            주의사항:
            - 한국에서 출판된 책이나 한국어로 번역된 유명한 책을 추천하세요
            - JSON만 반환하고 다른 텍스트는 포함하지 마세요
            - imageURL과 purchaseURL은 null로 설정하세요 (자동 생성됩니다)
            """
            
            // 3. Call Gemini API
            let jsonString = try await GeminiService.shared.generateContent(prompt: prompt)
            
            // 4. Parse response (clean markdown code blocks if present)
            let cleanedJSON = cleanJSONResponse(jsonString)
            
            if let data = cleanedJSON.data(using: String.Encoding.utf8) {
                var recommendedBooks = try JSONDecoder().decode([RecommendedBook].self, from: data)
                
                // Fetch real book covers from Google Books API
                for i in 0..<recommendedBooks.count {
                    let book = recommendedBooks[i]
                    
                    // Fetch book cover image
                    if let coverURL = await BookCoverService.shared.fetchBookCover(title: book.title, author: book.author) {
                        recommendedBooks[i] = RecommendedBook(
                            title: book.title,
                            author: book.author,
                            description: book.description,
                            reason: book.reason,
                            genre: book.genre,
                            imageURL: coverURL,
                            purchaseURL: book.purchaseURL
                        )
                    }
                    
                    // Generate purchase URL if missing
                    if recommendedBooks[i].purchaseURL == nil || recommendedBooks[i].purchaseURL?.isEmpty == true {
                        let encodedTitle = book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? book.title
                        recommendedBooks[i] = RecommendedBook(
                            title: recommendedBooks[i].title,
                            author: recommendedBooks[i].author,
                            description: recommendedBooks[i].description,
                            reason: recommendedBooks[i].reason,
                            genre: recommendedBooks[i].genre,
                            imageURL: recommendedBooks[i].imageURL,
                            purchaseURL: "https://www.aladin.co.kr/search/wsearchresult.aspx?SearchTarget=All&SearchWord=\(encodedTitle)"
                        )
                    }
                }
                
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
