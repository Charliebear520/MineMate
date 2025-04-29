import SwiftUI

struct EmotionAnalysisView: View {
    @StateObject private var viewModel: EmotionAnalysisViewModel
    
    init(result: EmotionAnalysisResult) {
        _viewModel = StateObject(wrappedValue: EmotionAnalysisViewModel(analysisResult: result))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 主导情绪展示
                if let dominantEmotion = viewModel.dominantEmotionChineseName {
                    VStack(spacing: 8) {
                        Text("主導情緒")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(dominantEmotion)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.color(for: viewModel.analysisResult.dominantEmotion ?? ""))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // 情绪强度列表
                VStack(alignment: .leading, spacing: 16) {
                    Text("情绪强度分析")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(viewModel.sortedEmotions, id: \.0) { emotion, value in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(viewModel.chineseName(for: emotion))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text(viewModel.percentageString(for: value))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // 进度条
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .frame(width: geometry.size.width, height: 8)
                                        .opacity(0.3)
                                        .foregroundColor(Color(.systemGray4))
                                    
                                    Rectangle()
                                        .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: 8)
                                        .foregroundColor(viewModel.color(for: emotion))
                                }
                                .cornerRadius(4)
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("情绪分析结果")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        EmotionAnalysisView(result: EmotionAnalysisResult(
            emotions: [
                "happiness": 0.7,
                "sadness": 0.2,
                "anger": 0.1,
                "anxiety": 0.3,
                "calmness": 0.5
            ],
            dominantEmotion: "happiness"
        ))
    }
} 
