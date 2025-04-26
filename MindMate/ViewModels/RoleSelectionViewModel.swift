import Foundation
import SwiftUI

class RoleSelectionViewModel: ObservableObject {
    @Published var availableRoles: [AIRole] = []
    @Published var selectedRole: AIRole?
    
    func loadRoles() {
        // 预定义角色列表
        availableRoles = [
            AIRole(
                id: "therapist",
                name: "心理咨询师",
                description: "专业的心理咨询服务，擅长倾听和理解，帮助您处理情绪问题。",
                prompt: "你是一位专业的心理咨询师，擅长倾听和理解。请用温和、专业的语气与用户交流。",
                iconName: "heart.text.square.fill"
            ),
            AIRole(
                id: "life-coach",
                name: "人生教练",
                description: "个人成长指导，帮助您设定目标并实现自我提升。",
                prompt: "你是一位专业的人生教练，擅长激励和指导。请用积极、鼓励的语气与用户交流。",
                iconName: "person.fill.checkmark"
            ),
            AIRole(
                id: "friend",
                name: "知心朋友",
                description: "像朋友一样倾听和陪伴，分享生活中的喜怒哀乐。",
                prompt: "你是一位知心朋友，擅长倾听和分享。请用亲切、自然的语气与用户交流。",
                iconName: "person.2.fill"
            ),
            AIRole(
                id: "motivator",
                name: "激励者",
                description: "帮助您保持积极心态，克服困难，实现目标。",
                prompt: "你是一位激励者，擅长鼓舞人心。请用充满激情的语气与用户交流。",
                iconName: "flame.fill"
            )
        ]
    }
    
    func selectRole(_ role: AIRole) {
        selectedRole = role
    }
} 