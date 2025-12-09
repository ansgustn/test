import Foundation

class GeminiService {
    static let shared = GeminiService()
    
    private init() {}
    
    // MARK: - API Request Models
    
    struct GeminiRequest: Codable {
        let contents: [Content]
        
        struct Content: Codable {
            let parts: [Part]
            
            struct Part: Codable {
                let text: String
            }
        }
    }
    
    struct GeminiResponse: Codable {
        let candidates: [Candidate]
        
        struct Candidate: Codable {
            let content: Content
            
            struct Content: Codable {
                let parts: [Part]
                
                struct Part: Codable {
                    let text: String
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Summarize text using Gemini API
    func summarize(text: String) async throws -> String {
        let prompt = """
        다음 텍스트를 한국어로 간결하게 요약해주세요. 핵심 내용만 3-5문장으로 정리해주세요:
        
        \(text)
        """
        
        return try await generateContent(prompt: prompt)
    }
    
    /// Ask a question about the text
    func askQuestion(question: String, context: String) async throws -> String {
        let prompt = """
        다음 텍스트를 읽고 질문에 한국어로 답변해주세요:
        
        텍스트:
        \(context)
        
        질문: \(question)
        """
        
        return try await generateContent(prompt: prompt)
    }
    
    /// Generate tags for highlighted text
    func generateTags(text: String) async throws -> [String] {
        let prompt = """
        다음 하이라이트된 텍스트에 적합한 태그를 3개 생성해주세요. 
        태그는 쉼표로 구분하고, #을 붙이지 마세요:
        
        \(text)
        """
        
        let response = try await generateContent(prompt: prompt)
        let tags = response.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        return Array(tags.prefix(3))
    }
    
    // MARK: - Private Methods
    
    func generateContent(prompt: String) async throws -> String {
        guard Config.isAPIKeyConfigured else {
            throw GeminiError.apiKeyNotConfigured
        }
        
        guard let url = URL(string: "\(Config.geminiAPIEndpoint)?key=\(Config.geminiAPIKey)") else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiRequest.Content(
                    parts: [GeminiRequest.Content.Part(text: prompt)]
                )
            ]
        )
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        // Log error details for debugging
        if httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error message"
            print("❌ Gemini API Error (\(httpResponse.statusCode)):")
            print("URL: \(url)")
            print("Response: \(errorBody)")
            
            // Check if it's a 404 error
            if httpResponse.statusCode == 404 {
                throw GeminiError.endpointNotFound(message: errorBody)
            }
            
            throw GeminiError.httpError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let firstCandidate = geminiResponse.candidates.first,
              let firstPart = firstCandidate.content.parts.first else {
            throw GeminiError.noContent
        }
        
        return firstPart.text
    }
    
    // MARK: - Error Types
    
    enum GeminiError: LocalizedError {
        case apiKeyNotConfigured
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case endpointNotFound(message: String)
        case noContent
        
        var errorDescription: String? {
            switch self {
            case .apiKeyNotConfigured:
                return "Gemini API Key가 설정되지 않았습니다. Config.swift에서 API Key를 설정해주세요."
            case .invalidURL:
                return "잘못된 API URL입니다."
            case .invalidResponse:
                return "서버 응답이 올바르지 않습니다."
            case .httpError(let statusCode, let message):
                return "HTTP 오류 (\(statusCode)): \(message)"
            case .endpointNotFound(let message):
                return "API 엔드포인트를 찾을 수 없습니다 (404). API URL이 올바른지 확인하세요.\n\(message)"
            case .noContent:
                return "응답 내용이 없습니다."
            }
        }
    }
}
