import Foundation

class BookCoverService {
    static let shared = BookCoverService()
    
    private init() {}
    
    /// Fetch book cover image URL from Google Books API
    func fetchBookCover(title: String, author: String) async -> String? {
        let query = "\(title) \(author)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=1"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for book search")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let items = json["items"] as? [[String: Any]],
               let firstItem = items.first,
               let volumeInfo = firstItem["volumeInfo"] as? [String: Any],
               let imageLinks = volumeInfo["imageLinks"] as? [String: Any] {
                
                // Try to get highest quality image available
                if let thumbnail = imageLinks["thumbnail"] as? String {
                    // Replace http with https and upgrade to higher resolution
                    let httpsUrl = thumbnail.replacingOccurrences(of: "http://", with: "https://")
                    let largeImage = httpsUrl.replacingOccurrences(of: "zoom=1", with: "zoom=2")
                    print("✅ Found book cover: \(largeImage)")
                    return largeImage
                }
            }
            
            print("⚠️ No book cover found for: \(title)")
            return nil
            
        } catch {
            print("❌ Error fetching book cover: \(error)")
            return nil
        }
    }
}
