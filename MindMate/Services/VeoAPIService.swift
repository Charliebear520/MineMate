import Foundation

class VeoAPIService {
    private let apiKey: String
    private let baseURL = "https://api.google.dev/v1/video/generate"
    
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
        // 构建提示
        let prompt = """
        请根据以下情绪记录生成一个温暖的故事线，用于制作一个情绪回顾视频：
        
        \(emotionBalls.map { ball in
            """
            时间：\(ball.createdAt.formatted())
            情绪：\(ball.dominantEmotions.map { "\($0.emotion)(\(Int($0.strength * 100))%)" }.joined(separator: ", "))
            内容：\(ball.summary)
            """
        }.joined(separator: "\n\n"))
        
        要求：
        1. 故事要有连贯性和情感起伏
        2. 突出情绪变化的过程
        3. 使用温暖、积极的语气
        4. 适合制作成视频的形式
        5. 长度控制在200字以内
        """
        
        // TODO: 调用Gemini API生成故事线
        return "这是一个关于你情绪变化的故事..."
    }
} 