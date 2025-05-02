import Foundation

class GeminiAPITester {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func testBasicPrompt() async throws -> String {
        let prompt = "Hello, how are you?"
        
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
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            print("發送請求到URL: \(url)")
            print("請求內容: \(String(data: jsonData, encoding: .utf8) ?? "")")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("收到響應狀態碼: \(httpResponse.statusCode)")
            print("響應內容: \(String(data: data, encoding: .utf8) ?? "")")
            
            if httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let candidates = json?["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    return text
                }
            }
            
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
            
            throw URLError(.badServerResponse)
        } catch {
            print("錯誤: \(error)")
            throw error
        }
    }

    func testEmotionAnalysis(text: String) async throws -> EmotionAnalysisResult {
        let prompt = """
        請分析以下用戶訊息中的情緒，並返回一個包含以下情緒及其強度的 JSON 格式結果：
        - 快樂 (happiness)
        - 悲傷 (sadness)
        - 憤怒 (anger)
        - 焦慮 (anxiety)
        - 平靜 (calmness)
        
        每個情緒的強度範圍是 0.0 到 1.0。
        
        請直接返回純JSON，不要加任何其他格式或標記，例如：
        {"emotions":{"happiness":0.7,"sadness":0.2,"anger":0.1,"anxiety":0.3,"calmness":0.5},"dominant_emotion":"happiness"}
        
        用戶訊息：
        \(text)
        """
        
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
        
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            print("發送情緒分析請求：")
            print("URL: \(url)")
            print("內容: \(text)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            print("收到響應狀態碼: \(httpResponse.statusCode)")
            print("響應內容: \(String(data: data, encoding: .utf8) ?? "")")
            
            if httpResponse.statusCode == 200 {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let candidates = json?["candidates"] as? [[String: Any]],
                   let firstCandidate = candidates.first,
                   let content = firstCandidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    
                    // 清理響應文本，移除可能的Markdown標記
                    var cleanedText = text.replacingOccurrences(of: "```json", with: "")
                    cleanedText = cleanedText.replacingOccurrences(of: "```", with: "")
                    cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    print("清理後的JSON: \(cleanedText)")
                    
                    if let jsonData = cleanedText.data(using: .utf8) {
                        let result = try JSONDecoder().decode(EmotionAnalysisResult.self, from: jsonData)
                        return result
                    }
                }
                throw APIError.decodingError
            }
            
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw NSError(domain: "GeminiAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
            }
            
            throw URLError(.badServerResponse)
        } catch {
            print("錯誤: \(error)")
            throw error
        }
    }
} 