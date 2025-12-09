import Foundation
import Combine

class AISummaryViewModel: ObservableObject {
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let geminiService = GeminiService.shared
    
    func summarizeText(_ text: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await geminiService.summarize(text: text)
                await MainActor.run {
                    self.summary = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func askQuestion(_ question: String, context: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await geminiService.askQuestion(question: question, context: context)
                await MainActor.run {
                    self.summary = result
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
