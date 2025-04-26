import Foundation
import Security

class GeminiAPIService: GeminiAPIServicing {
    // MARK: - Properties
    private let baseURL = "https://your-production-domain.com/api" // 生产环境使用 HTTPS
    private let apiKey: String
    private let session: URLSession
    private let maxRetries = 3
    private let timeoutInterval: TimeInterval = 30
    
    // MARK: - Initialization
    init(apiKey: String) {
        self.apiKey = apiKey
        
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
                    "messages": messages.map { message in
                        [
                            "text": message.text,
                            "sender": message.sender == .user ? "user" : "model",
                            "timestamp": ISO8601DateFormatter().string(from: message.timestamp)
                        ]
                    },
                    "roleId": rolePrompt
                ]
                
                // 2. 创建请求
                guard let url = URL(string: "\(baseURL)/chat") else {
                    throw APIError.invalidURL
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                // 3. 发送请求并处理响应
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    // 4. 解析响应
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(ChatResponse.self, from: data)
                    return responseData.text
                    
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
                // 1. 准备请求负载
                let requestBody: [String: Any] = [
                    "messages": userMessagesText
                ]
                
                // 2. 创建请求
                guard let url = URL(string: "\(baseURL)/analyze-emotions") else {
                    throw APIError.invalidURL
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
                // 3. 发送请求并处理响应
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    // 4. 解析响应
                    let decoder = JSONDecoder()
                    let responseData = try decoder.decode(EmotionAnalysisResponse.self, from: data)
                    return EmotionAnalysisResult(
                        emotions: responseData.emotions,
                        dominantEmotion: responseData.dominantEmotion
                    )
                    
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

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case networkError(Error)
    case unauthorized
    case rateLimited
    case maxRetriesExceeded
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "服务器响应无效"
        case .serverError(let statusCode):
            return "服务器错误，状态码：\(statusCode)"
        case .decodingError:
            return "响应解析失败"
        case .networkError(let error):
            return "网络错误：\(error.localizedDescription)"
        case .unauthorized:
            return "未授权访问"
        case .rateLimited:
            return "请求过于频繁，请稍后再试"
        case .maxRetriesExceeded:
            return "超过最大重试次数"
        }
    }
} 