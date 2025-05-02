import SwiftUI
import Charts

struct EmotionLibraryView: View {
    @StateObject private var viewModel = EmotionLibraryViewModel()
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedEmotionBall: EmotionBall?
    @State private var showingDetail = false
    
    enum TimeRange: String, CaseIterable {
        case day = "今天"
        case week = "本週"
        case month = "本月"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 時間範圍選擇器
                Picker("時間範圍", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 情緒趨勢圖表
                EmotionTrendChartView(emotions: viewModel.latestEmotions)
                    .frame(height: 250)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                
                // 情緒球列表
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)
                ], spacing: 16) {
                    ForEach(viewModel.emotionBalls) { ball in
                        EmotionBallCard(emotionBall: ball)
                            .onTapGesture {
                                selectedEmotionBall = ball
                                showingDetail = true
                            }
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("情緒庫")
        .sheet(isPresented: $showingDetail) {
            if let ball = selectedEmotionBall {
                EmotionBallDetailView(emotionBall: ball)
            }
        }
    }
}

struct EmotionBallCard: View {
    let emotionBall: EmotionBall
    
    var body: some View {
        VStack(spacing: 12) {
            // 情緒球視覺化
            EmotionBallView(emotionBall: emotionBall, size: 100)
            
            // 日期和時間
            Text(emotionBall.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 摘要或備註
            if !emotionBall.summary.isEmpty {
                Text(emotionBall.summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            } else if let note = emotionBall.userNote, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 標籤
            if !emotionBall.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(emotionBall.tags), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct EmotionBallDetailView: View {
    let emotionBall: EmotionBall
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 情緒球視覺化
                    EmotionBallView(emotionBall: emotionBall, size: 200)
                    
                    // 情緒分析
                    VStack(alignment: .leading, spacing: 16) {
                        Text("情緒分析")
                            .font(.headline)
                        
                        ForEach(Array(emotionBall.emotionAnalysis.emotions.sorted { $0.value > $1.value }), id: \.key) { emotion in
                            HStack {
                                Text(emotion.key.localizedEmotionName)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(emotion.value * 100))%")
                                    .font(.subheadline)
                            }
                            ProgressView(value: emotion.value)
                                .tint(emotion.key.emotionColor)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 對話內容
                    VStack(alignment: .leading, spacing: 16) {
                        Text("對話記錄")
                            .font(.headline)
                        
                        ForEach(emotionBall.conversation) { message in
                            MessageRow(message: message)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("情緒記錄詳情")
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
        NavigationView {
            EmotionLibraryView()
        }
    }
} 