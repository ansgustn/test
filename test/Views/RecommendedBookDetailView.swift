import SwiftUI

struct RecommendedBookDetailView: View {
    let book: RecommendedBook
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Book Cover
                    if let imageURL = book.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 300)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "book.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.gray)
                                    .frame(height: 300)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Rectangle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "book.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.blue)
                            )
                            .cornerRadius(12)
                    }
                    
                    // Book Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(book.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(book.author)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(book.genre)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("책 소개")
                            .font(.headline)
                        
                        Text(book.description)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal)
                    
                    // Recommendation Reason
                    VStack(alignment: .leading, spacing: 8) {
                        Text("추천 이유")
                            .font(.headline)
                        
                        Text(book.reason)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // External Links
                    VStack(spacing: 12) {
                        if let purchaseURL = book.purchaseURL, let url = URL(string: purchaseURL) {
                            Link(destination: url) {
                                HStack {
                                    Image(systemName: "safari")
                                    Text("알라딘에서 보기")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Additional search links
                        HStack(spacing: 12) {
                            searchLinkButton(
                                title: "교보문고",
                                url: "https://search.kyobobook.co.kr/search?keyword=\(book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                            )
                            
                            searchLinkButton(
                                title: "예스24",
                                url: "https://www.yes24.com/Product/Search?query=\(book.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("추천 도서")
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
    
    @ViewBuilder
    private func searchLinkButton(title: String, url: String) -> some View {
        if let linkURL = URL(string: url) {
            Link(destination: linkURL) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.caption)
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                .foregroundStyle(.blue)
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    RecommendedBookDetailView(
        book: RecommendedBook(
            title: "위대한 개츠비",
            author: "F. Scott Fitzgerald",
            description: "재즈 시대를 배경으로 한 고전 명작",
            reason: "많은 독자들이 사랑하는 미국 문학의 걸작입니다.",
            genre: "고전문학",
            imageURL: "https://image.aladin.co.kr/product/293/61/cover/8937460788_1.jpg",
            purchaseURL: "https://www.aladin.co.kr/search/wsearchresult.aspx?SearchTarget=All&SearchWord=위대한+개츠비"
        )
    )
}
