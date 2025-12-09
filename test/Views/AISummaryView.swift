import SwiftUI

struct AISummaryView: View {
    @StateObject private var viewModel = AISummaryViewModel()
    let chapterContent: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                            Text("AI가 요약을 생성하고 있습니다...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("오류 발생")
                                .font(.headline)
                            
                            Text(error)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("다시 시도") {
                                viewModel.summarizeText(chapterContent)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    } else if !viewModel.summary.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("AI 요약", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Text(viewModel.summary)
                                .font(.body)
                                .lineSpacing(6)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding()
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text("챕터 요약 준비")
                                .font(.headline)
                            
                            Text("AI가 이 챕터의 핵심 내용을 요약해드립니다.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("요약 생성") {
                                viewModel.summarizeText(chapterContent)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("AI 요약")
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
}
