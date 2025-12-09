import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    rating = index
                }) {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .font(.title3)
                }
            }
        }
    }
}

struct BookCompletionView: View {
    let bookTitle: String
    @State private var rating: Int = 0
    @Binding var isPresented: Bool
    let onComplete: (Int) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("책을 완독하셨습니다!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(bookTitle)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Text("이 책을 평가해주세요")
                        .font(.subheadline)
                    
                    RatingView(rating: $rating)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
                
                Button(action: {
                    onComplete(rating)
                    isPresented = false
                }) {
                    Text("완료")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("독서 완료")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("나중에") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
