import Foundation

class EmotionAnalysisService: EmotionAnalysisServicing {
    private let geminiService: GeminiAPIServicing
    
    init() {
        self.geminiService = GeminiAPIService()
    }
    
    func analyzeEmotions(userMessagesText: [String]) async throws -> EmotionAnalysisResult {
        // 构建提示词
        let prompt = """
        请分析以下用户消息中的情绪，并返回一个包含以下情绪及其强度的 JSON 格式结果：
        - 快乐 (happiness)
        - 悲伤 (sadness)
        - 愤怒 (anger)
        - 焦虑 (anxiety)
        - 平静 (calmness)
        
        每个情绪的强度范围是 0.0 到 1.0。
        
        请**只回傳 JSON，不要加任何說明或標註**，例如：\n{"emotions": {"happiness": 0.7, "sadness": 0.2, ...}, "dominant_emotion": "happiness"}
        
        用户消息：
        \(userMessagesText.joined(separator: "\n"))
        """
        
        // 调用 Gemini API
        let response = try await geminiService.sendMessage(
            messages: [ChatMessage(
                id: UUID(),
                text: prompt,
                sender: .user,
                timestamp: Date()
            )],
            rolePrompt: "你是一个专业的情绪分析助手，请分析用户消息中的情绪。"
        )
        
        // 解析响应前先印出內容
        print("Gemini 回傳內容：\(response)")
        
        // 解析响应
        guard let data = response.data(using: .utf8) else {
            throw NSError(domain: "EmotionAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法解析响应数据"])
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(EmotionAnalysisResult.self, from: data)
            return result
        } catch {
            throw NSError(domain: "EmotionAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "解析情绪分析结果失败: \(error.localizedDescription)"])
        }
    }
} 