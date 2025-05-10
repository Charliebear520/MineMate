import Foundation

class VeoAPIService {
    private let apiKey: String
    private let baseURL = "https://api.google.dev/v1/video/generate"
    private let geminiService = GeminiAPIService()
    
    init(apiKey: String = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"] ?? "") {
        self.apiKey = apiKey
    }
    
    func generateVideo(prompt: String) async throws -> URL {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "veo-2.0-generate-001",
            "prompt": prompt,
            "config": [
                "person_generation": "dont_allow",
                "aspect_ratio": "16:9"
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        // 解析响应获取视频URL
        // TODO: 根据实际API响应格式进行解析
        let videoURL = URL(string: "https://example.com/video.mp4")!
        return videoURL
    }
    
    func generateStoryPrompt(from emotionBalls: [EmotionBall]) async throws -> String {
        // 構建 prompt
        let prompt = """
        請根據以下情緒記錄生成一個溫暖的故事線，用於製作一個情緒回顧影片：\n\n\
        \(emotionBalls.map { ball in
            """
            時間：\(ball.createdAt.formatted())
            情緒：\(ball.dominantEmotions.map { "\($0.emotion)(\(Int($0.strength * 100))%)" }.joined(separator: ", "))
            內容：\(ball.summary)
            """
        }.joined(separator: "\n\n"))
        \n要求：\n1. 故事要有連貫性和情感起伏\n2. 突出情緒變化的過程\n3. 使用溫暖、積極的語氣\n4. 適合製作成影片的形式\n5. 長度控制在200字以內
        """
        let rolePrompt = "你是一位專業的情緒故事腳本生成助手，擅長將多段情緒記錄整合成一段有故事感的影片腳本。請根據用戶的情緒球內容，生成一段溫暖、正向、具備情感起伏的故事線。"
        let chatMessage = ChatMessage(id: UUID(), text: prompt, sender: .user, timestamp: Date())
        let result = try await geminiService.sendMessage(messages: [chatMessage], rolePrompt: rolePrompt)
        return result
    }
} 