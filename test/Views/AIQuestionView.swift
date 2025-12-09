import SwiftUI

struct AIQuestionView: View {
    @StateObject private var viewModel = AISummaryViewModel()
    let chapterContent: String
    @State private var question: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages area
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !viewModel.summary.isEmpty {
                            // AI Response
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AI 답변")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(viewModel.summary)
                                        .font(.body)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                Text("AI가 답변을 생성하고 있습니다...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        
                        if let error = viewModel.errorMessage {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                Divider()
                
                // Input area
                HStack(spacing: 12) {
                    TextField("질문을 입력하세요...", text: $question)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.isLoading)
                    
                    Button(action: sendQuestion) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(question.isEmpty || viewModel.isLoading ? Color.gray : Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(question.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("AI에게 질문하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendQuestion() {
        let currentQuestion = question
        question = ""
        viewModel.askQuestion(currentQuestion, context: chapterContent)
    }
}
