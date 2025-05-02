import SwiftUI

struct EmotionBallView: View {
    let emotionBall: EmotionBall
    let size: CGFloat
    
    init(emotionBall: EmotionBall, size: CGFloat = 100) {
        self.emotionBall = emotionBall
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // 情緒球外觀
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: emotionColors),
                        center: .center,
                        startRadius: 0,
                        endRadius: size/2
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: emotionColors.first?.opacity(0.3) ?? .clear, radius: 10)
            
            // 情緒標籤
            VStack(spacing: 4) {
                ForEach(Array(emotionBall.tags.prefix(2)), id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var emotionColors: [Color] {
        let colorMap: [String: Color] = [
            "happiness": .yellow,
            "sadness": .blue,
            "anger": .red,
            "anxiety": .orange,
            "calmness": .green
        ]
        
        return emotionBall.dominantEmotions.map { emotion in
            colorMap[emotion.emotion]?.opacity(emotion.strength) ?? .gray
        }
    }
}

// 預覽
struct EmotionBallView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionBallView(
            emotionBall: EmotionBall(
                conversation: [],
                emotionAnalysis: EmotionAnalysisResult(
                    emotions: [
                        "happiness": 0.7,
                        "sadness": 0.2,
                        "anger": 0.1
                    ],
                    dominantEmotion: "happiness"
                ),
                tags: ["開心時刻", "放鬆"]
            )
        )
    }
} 