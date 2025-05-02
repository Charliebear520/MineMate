import Foundation
import SwiftUI

class EmotionAnalysisViewModel: ObservableObject {
    let analysisResult: EmotionAnalysisResult
    
    init(analysisResult: EmotionAnalysisResult) {
        self.analysisResult = analysisResult
    }
    
    // 获取排序后的情绪数据
    var sortedEmotions: [(String, Double)] {
        analysisResult.emotions.sorted { $0.value > $1.value }
    }
    
    // 将情绪强度转换为百分比字符串
    func percentageString(for value: Double) -> String {
        let percentage = Int(value * 100)
        return "\(percentage)%"
    }
    
    // 获取情绪的中文名称
    func chineseName(for emotion: String) -> String {
        switch emotion {
        case "happiness": return "快樂"
        case "sadness": return "悲傷"
        case "anger": return "憤怒"
        case "anxiety": return "焦慮"
        case "calmness": return "平靜"
        default: return emotion
        }
    }
    
    // 获取情绪的颜色
    func color(for emotion: String) -> Color {
        switch emotion {
        case "happiness": return .yellow
        case "sadness": return .blue
        case "anger": return .red
        case "anxiety": return .orange
        case "calmness": return .green
        default: return .gray
        }
    }
    
    // 获取主导情绪的中文名称
    var dominantEmotionChineseName: String {
        return chineseName(for: analysisResult.dominantEmotion)
    }
} 