import Foundation
import GoogleGenerativeAI

class GeminiChatService {
    private let model: GenerativeModel

    init() {
        self.model = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: APIKey.default
        )
    }

    func sendMessage(history: [ChatMessage], userInput: String, completion: @escaping (String?) -> Void) {
        do {
            // 確保系統提示詞在第一個位置
            let systemMessage = history.first { $0.sender == .ai }
            let userMessages = history.filter { $0.sender == .user }
            
            // 構建 Gemini 歷史消息
            var geminiHistory: [ModelContent] = []
            
            // 如果有系統提示詞，先添加
            if let systemMessage = systemMessage {
                geminiHistory.append(try ModelContent(parts: ["system", systemMessage.text]))
            }
            
            // 添加用戶消息
            for message in userMessages {
                geminiHistory.append(try ModelContent(parts: ["user", message.text]))
            }
            
            let chat = model.startChat(history: geminiHistory)
            Task {
                do {
                    let response = try await chat.sendMessage([try ModelContent(parts: ["user", userInput])])
                    completion(response.text)
                } catch {
                    print("Gemini 回覆錯誤: \(error)")
                    completion(nil)
                }
            }
        } catch {
            print("建立 ModelContent 歷史訊息失敗: \(error)")
            completion(nil)
        }
    }
} 