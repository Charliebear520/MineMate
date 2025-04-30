import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    let selectedRole: AIRole
    @Published var messages: [ChatMessage] = []
    @Published var currentInputText: String = ""
    @Published var isAIReplying: Bool = false
    @Published var isRecording: Bool = false
    
    // 新增情緒分析相關屬性
    @Published var showEmotionAnalysisOption: Bool = true
    @Published var shouldNavigateToAnalysis: Bool = false
    @Published var emotionAnalysisResult: EmotionAnalysisResult? = nil
    @Published var conversationEmotionResult: EmotionAnalysisResult? = nil // 整段對話情緒
    
    private let geminiService = GeminiAPIService()
    private let speechService: SpeechRecognitionServicing
    
    init(
        selectedRole: AIRole,
        speechService: SpeechRecognitionServicing = SpeechRecognitionService()
    ) {
        self.selectedRole = selectedRole
        self.speechService = speechService
    }
    
    func sendMessage(text: String) {
        let userMessage = ChatMessage(
            id: UUID(),
            text: text,
            sender: .user,
            timestamp: Date()
        )
        messages.append(userMessage)
        currentInputText = ""
        isAIReplying = true

        let userMessageId = userMessage.id
        Task {
            do {
                let emotion = try await geminiService.analyzeSingleMessageEmotion(text: text)
                await MainActor.run {
                    if let idx = self.messages.lastIndex(where: { $0.id == userMessageId }) {
                        self.messages[idx].emotionResult = emotion
                    }
                }
            } catch {
                print("單條訊息情緒分析失敗: \(error)")
            }
        }

        let systemMessage = ChatMessage(
            id: UUID(),
            text: selectedRole.prompt,
            sender: .ai,
            timestamp: Date()
        )
        var messagesWithSystemPrompt = [systemMessage]
        messagesWithSystemPrompt.append(contentsOf: messages)

        Task {
            do {
                let response = try await geminiService.sendMessage(messages: messagesWithSystemPrompt, rolePrompt: selectedRole.prompt)
                await MainActor.run {
                    let aiMessage = ChatMessage(
                        id: UUID(),
                        text: response,
                        sender: .ai,
                        timestamp: Date()
                    )
                    self.messages.append(aiMessage)
                    self.isAIReplying = false
                }
            } catch {
                print("AI 回覆失敗: \(error)")
                await MainActor.run {
                    let errorMessage = ChatMessage(
                        id: UUID(),
                        text: "[AI 回覆失敗：\(error.localizedDescription)]",
                        sender: .ai,
                        timestamp: Date()
                    )
                    self.messages.append(errorMessage)
                    self.isAIReplying = false
                }
            }
        }
    }
    
    func startVoiceInput() {
        guard !isRecording else { return }
        speechService.requestAuthorization { [weak self] authorized in
            guard authorized else {
                print("未获得语音识别权限")
                return
            }
            Task { @MainActor in
                self?.isRecording = true
            }
            self?.speechService.startRecording(
                updateHandler: { [weak self] text in
                    Task { @MainActor in
                        self?.currentInputText = text
                    }
                },
                completionHandler: { [weak self] result in
                    Task { @MainActor in
                        switch result {
                        case .success(let text):
                            self?.currentInputText = text
                        case .failure(let error):
                            print("语音识别错误: \(error)")
                        }
                        self?.isRecording = false
                    }
                }
            )
        }
    }
    
    func stopVoiceInput() {
        speechService.stopRecording()
        isRecording = false
    }
    
    // 整段對話情緒分析（用戶主動觸發）
    func requestEmotionAnalysis() {
        Task {
            let userMessages = messages.filter { $0.sender == .user }.map { $0.text }
            do {
                let result = try await geminiService.analyzeConversationEmotion(messages: userMessages)
                await MainActor.run {
                    self.conversationEmotionResult = result
                    self.shouldNavigateToAnalysis = true
                }
            } catch {
                print("情緒分析失敗: \(error)")
            }
        }
    }
} 