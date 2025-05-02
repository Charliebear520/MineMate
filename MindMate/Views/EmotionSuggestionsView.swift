import SwiftUI

struct EmotionSuggestionsView: View {
    let emotions: [String: Double]
    
    private var dominantEmotions: [(String, Double)] {
        emotions.sorted { $0.value > $1.value }.prefix(2).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("情緒舒緩建議")
                .font(.headline)
            
            // 主要情緒提示
            HStack {
                ForEach(dominantEmotions, id: \.0) { emotion in
                    EmotionBadge(
                        emotion: emotion.0,
                        percentage: Int(emotion.1 * 100)
                    )
                }
            }
            
            // 即時舒緩建議
            VStack(alignment: .leading, spacing: 12) {
                Text("立即舒緩")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(suggestionsForEmotions(dominantEmotions.map { $0.0 }), id: \.self) { suggestion in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(suggestion)
                            .font(.subheadline)
                    }
                }
            }
            
            Divider()
            
            // 工具和資源
            VStack(alignment: .leading, spacing: 12) {
                Text("推薦工具")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(toolsForEmotions(dominantEmotions.map { $0.0 }), id: \.title) { tool in
                            ToolCard(tool: tool)
                        }
                    }
                }
            }
        }
    }
    
    private func suggestionsForEmotions(_ emotions: [String]) -> [String] {
        var suggestions: [String] = []
        for emotion in emotions {
            switch emotion {
            case "sadness":
                suggestions += [
                    "進行15分鐘輕度運動",
                    "與親友聊天分享感受",
                    "聆聽愉快的音樂"
                ]
            case "anxiety":
                suggestions += [
                    "做幾次深呼吸練習",
                    "寫下當前的擔憂",
                    "放鬆肌肉練習"
                ]
            case "anger":
                suggestions += [
                    "暫時離開壓力環境",
                    "數到10冷靜一下",
                    "喝一杯溫水"
                ]
            case "happiness":
                suggestions += [
                    "分享快樂給他人",
                    "記錄美好時刻",
                    "保持感恩的心"
                ]
            case "calmness":
                suggestions += [
                    "保持當前的平靜",
                    "享受寧靜時刻",
                    "進行冥想練習"
                ]
            default:
                break
            }
        }
        return Array(Set(suggestions)).prefix(3).map { $0 }
    }
    
    private func toolsForEmotions(_ emotions: [String]) -> [EmotionTool] {
        var tools: [EmotionTool] = []
        for emotion in emotions {
            switch emotion {
            case "sadness", "anxiety":
                tools += [
                    EmotionTool(
                        title: "呼吸練習",
                        description: "引導式呼吸放鬆",
                        iconName: "lungs.fill",
                        color: .blue
                    ),
                    EmotionTool(
                        title: "正念冥想",
                        description: "10分鐘正念練習",
                        iconName: "brain.head.profile",
                        color: .purple
                    )
                ]
            case "anger":
                tools += [
                    EmotionTool(
                        title: "情緒日記",
                        description: "記錄和理解憤怒",
                        iconName: "book.fill",
                        color: .red
                    )
                ]
            default:
                tools += [
                    EmotionTool(
                        title: "心情追蹤",
                        description: "記錄情緒變化",
                        iconName: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                ]
            }
        }
        return Array(Set(tools))
    }
}

struct EmotionBadge: View {
    let emotion: String
    let percentage: Int
    
    var body: some View {
        HStack {
            Image(systemName: emotion.emotionIcon)
                .foregroundColor(emotion.emotionColor)
            VStack(alignment: .leading) {
                Text(emotion.localizedEmotionName)
                    .font(.subheadline)
                Text("\(percentage)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(emotion.emotionColor.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ToolCard: View {
    let tool: EmotionTool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: tool.iconName)
                .font(.title2)
                .foregroundColor(tool.color)
            Text(tool.title)
                .font(.subheadline)
                .bold()
            Text(tool.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 120)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 情緒圖標擴展
extension String {
    var emotionIcon: String {
        switch self {
        case "happiness": return "sun.max.fill"
        case "sadness": return "cloud.rain.fill"
        case "anger": return "flame.fill"
        case "anxiety": return "tornado"
        case "calmness": return "leaf.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

// 預覽
struct EmotionSuggestionsView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionSuggestionsView(emotions: [
            "sadness": 0.6,
            "anxiety": 0.5,
            "anger": 0.3,
            "calmness": 0.1,
            "happiness": 0.05
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 