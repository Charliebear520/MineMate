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
            let geminiHistory: [ModelContent] = try history.map {
                try ModelContent(parts: [$0.text])
            }
            let chat = model.startChat(history: geminiHistory)
            Task {
                do {
                    let response = try await chat.sendMessage([try ModelContent(parts: [userInput])])
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