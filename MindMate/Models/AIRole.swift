import Foundation

struct AIRole: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let prompt: String
    let iconName: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AIRole, rhs: AIRole) -> Bool {
        lhs.id == rhs.id
    }
} 