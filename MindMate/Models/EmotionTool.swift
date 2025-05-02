import SwiftUI

struct EmotionTool: Hashable, Identifiable {
    var id: String { title }
    let title: String
    let description: String
    let iconName: String
    let color: Color
} 