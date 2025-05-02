import SwiftUI

struct EmotionLibraryView: View {
    @StateObject private var viewModel = EmotionLibraryViewModel()
    @State private var selectedEmotionBall: EmotionBall?
    @State private var showingDetail = false
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.emotionBalls) { ball in
                        EmotionBallView(emotionBall: ball)
                            .onTapGesture {
                                selectedEmotionBall = ball
                                showingDetail = true
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("情緒庫")
            .sheet(isPresented: $showingDetail) {
                if let ball = selectedEmotionBall {
                    EmotionBallDetailView(emotionBall: ball)
                }
            }
        }
    }
}

struct EmotionBallDetailView: View {
    let emotionBall: EmotionBall
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 情緒球大圖
                    EmotionBallView(emotionBall: emotionBall, size: 200)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    
                    // 日期
                    Text(emotionBall.createdAt.formatted(date: .long, time: .shortened))
                        .foregroundColor(.secondary)
                    
                    // 標籤
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(emotionBall.tags), id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                    }
                    
                    // 摘要或筆記
                    if !emotionBall.summary.isEmpty {
                        VStack(alignment: .leading) {
                            Text("AI摘要")
                                .font(.headline)
                            Text(emotionBall.summary)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    if let userNote = emotionBall.userNote {
                        VStack(alignment: .leading) {
                            Text("我的筆記")
                                .font(.headline)
                            Text(userNote)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    // 對話內容
                    VStack(alignment: .leading) {
                        Text("對話內容")
                            .font(.headline)
                        ForEach(emotionBall.conversation) { message in
                            MessageRow(message: message)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("情緒記錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 預覽
struct EmotionLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionLibraryView()
    }
} 