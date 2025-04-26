import Foundation

struct Conversation: Identifiable {
    let id: UUID
    let role: AIRole
    var messages: [ChatMessage]
    let startTime: Date
    var endTime: Date?
    
    init(id: UUID = UUID(),
         role: AIRole,
         messages: [ChatMessage] = [],
         startTime: Date = Date(),
         endTime: Date? = nil) {
        self.id = id
        self.role = role
        self.messages = messages
        self.startTime = startTime
        self.endTime = endTime
    }
} 