import Foundation
import Security

class GeminiAPIService: GeminiAPIServicing {
    // MARK: - Properties
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models" // 修正為 v1beta
    private let apiKey = APIKey.default
    private let session: URLSession
    private let maxRetries = 3
    private let timeoutInterval: TimeInterval = 30
    
    // MARK: - Initialization
    init() {
        // 配置 URLSession
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    func sendMessage(messages: [ChatMessage], rolePrompt: String) async throws -> String {
        var retryCount = 0
        var lastError: Error?
        
        while retryCount < maxRetries {
            do {
                // 1. 准备请求负载
                let requestBody: [String: Any] = [
                    "contents": [
                        [
                            "role": "user",
                            "parts": [
                                ["text": rolePrompt + "\n" + messages.map { $0.text }.joined(separator: "\n")]
                            ]
                        ]
                    ],
                    "generationConfig": [
                        "temperature": 0.7,
                        "topK": 40,
                        "topP": 0.95,
                        "maxOutputTokens": 1024
                    ]
                ]
                
                // 2. 创建请求
                guard let url = URL(string: "\(baseURL)/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
                    throw APIError.invalidURL
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                // 3. 发送请求并处理响应
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    // 4. 解析响应
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        return text
                    }
                    throw APIError.decodingError
                    
                case 401:
                    throw APIError.unauthorized
                    
                case 429:
                    // 处理速率限制
                    if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After") {
                        let delay = Double(retryAfter) ?? 1.0
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        retryCount += 1
                        continue
                    }
                    throw APIError.rateLimited
                    
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
                
            } catch {
                lastError = error
                retryCount += 1
                
                // 如果是网络错误，等待后重试
                if case APIError.networkError = error {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                    continue
                }
                
                // 其他错误直接抛出
                throw error
            }
        }
        
        throw lastError ?? APIError.maxRetriesExceeded
    }
    
    func analyzeEmotions(userMessagesText: [String]) async throws -> EmotionAnalysisResult {
        var retryCount = 0
        var lastError: Error?
        
        while retryCount < maxRetries {
            do {
                // 1. 準備 prompt
                let prompt = """
                請分析以下用戶訊息中的情緒，並返回一個包含以下情緒及其強度的 JSON 格式結果：
                - 快樂 (happiness)
                - 悲傷 (sadness)
                - 憤怒 (anger)
                - 焦慮 (anxiety)
                - 平靜 (calmness)
                
                每個情緒的強度範圍是 0.0 到 1.0。
                
                請**只回傳 JSON，不要加任何說明或標註**，例如：
                {"emotions": {"happiness": 0.7, "sadness": 0.2, "anger": 0.1, "anxiety": 0.3, "calmness": 0.5}, "dominant_emotion": "happiness"}
                
                用戶訊息：
                \(userMessagesText.joined(separator: "\n"))
                """
                
                let requestBody: [String: Any] = [
                    "contents": [
                        [
                            "role": "user",
                            "parts": [
                                ["text": prompt]
                            ]
                        ]
                    ],
                    "generationConfig": [
                        "temperature": 0.7,
                        "topK": 40,
                        "topP": 0.95,
                        "maxOutputTokens": 1024
                    ]
                ]
                
                // 2. 創建請求
                guard let url = URL(string: "\(baseURL)/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
                    throw APIError.invalidURL
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                // 3. 發送請求
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    // 4. 解析 Gemini 回傳內容
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        
                        // 印出提取的文字內容
                        print("提取的文字內容：\(text)")
                        
                        // 嘗試將文字解析為 JSON
                        if let textData = text.data(using: .utf8) {
                            do {
                                let result = try JSONDecoder().decode(EmotionAnalysisResult.self, from: textData)
                                return result
                            } catch {
                                print("JSON 解析錯誤：\(error)")
                                throw APIError.decodingError
                            }
                        } else {
                            throw APIError.decodingError
                        }
                    } else {
                        throw APIError.decodingError
                    }
                    
                case 401:
                    throw APIError.unauthorized
                case 429:
                    if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After") {
                        let delay = Double(retryAfter) ?? 1.0
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        retryCount += 1
                        continue
                    }
                    throw APIError.rateLimited
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            } catch {
                lastError = error
                retryCount += 1
                if case APIError.networkError = error {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                    continue
                }
                throw error
            }
        }
        throw lastError ?? APIError.maxRetriesExceeded
    }

    // 單條訊息情緒分析
    func analyzeSingleMessageEmotion(text: String) async throws -> EmotionAnalysisResult {
        return try await analyzeEmotionsInternal(texts: [text])
    }

    // 整段對話情緒分析
    func analyzeConversationEmotion(messages: [String]) async throws -> EmotionAnalysisResult {
        return try await analyzeEmotionsInternal(texts: messages)
    }

    // 私有共用邏輯
    private func analyzeEmotionsInternal(texts: [String]) async throws -> EmotionAnalysisResult {
        var retryCount = 0
        var lastError: Error?
        let prompt = """
        請分析以下用戶訊息中的情緒，並返回一個包含以下情緒及其強度的 JSON 格式結果：
        - 快樂 (happiness)
        - 悲傷 (sadness)
        - 憤怒 (anger)
        - 焦慮 (anxiety)
        - 平靜 (calmness)
        
        每個情緒的強度範圍是 0.0 到 1.0。
        
        請直接返回純JSON，不要加任何其他格式或標記，例如：
        {\"emotions\":{\"happiness\":0.7,\"sadness\":0.2,\"anger\":0.1,\"anxiety\":0.3,\"calmness\":0.5},\"dominant_emotion\":\"happiness\"}
        
        用戶訊息：
        \(texts.joined(separator: "\n"))
        """
        while retryCount < maxRetries {
            do {
                let requestBody: [String: Any] = [
                    "contents": [
                        [
                            "parts": [
                                ["text": prompt]
                            ]
                        ]
                    ],
                    "generationConfig": [
                        "temperature": 0.7,
                        "topK": 40,
                        "topP": 0.95,
                        "maxOutputTokens": 1024
                    ]
                ]
                guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else {
                    throw APIError.invalidURL
                }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                switch httpResponse.statusCode {
                case 200:
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let text = parts.first?["text"] as? String {
                        var cleanedText = text.replacingOccurrences(of: "```json", with: "")
                        cleanedText = cleanedText.replacingOccurrences(of: "```", with: "")
                        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let jsonData = cleanedText.data(using: .utf8) {
                            let result = try JSONDecoder().decode(EmotionAnalysisResult.self, from: jsonData)
                            return result
                        }
                    }
                    throw APIError.decodingError
                case 401:
                    throw APIError.unauthorized
                case 429:
                    if let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After") {
                        let delay = Double(retryAfter) ?? 1.0
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        retryCount += 1
                        continue
                    }
                    throw APIError.rateLimited
                default:
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
            } catch {
                lastError = error
                retryCount += 1
                if case APIError.networkError = error {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                    continue
                }
                throw error
            }
        }
        throw lastError ?? APIError.maxRetriesExceeded
    }
}

// MARK: - Supporting Types

private struct ChatResponse: Codable {
    let text: String
    let timestamp: String
}

private struct EmotionAnalysisResponse: Codable {
    let emotions: [String: Double]
    let dominantEmotion: String?
} 