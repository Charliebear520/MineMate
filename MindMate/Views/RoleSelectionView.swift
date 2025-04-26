import SwiftUI

struct RoleSelectionView: View {
    @StateObject private var viewModel = RoleSelectionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(viewModel.availableRoles) { role in
                        NavigationLink(destination: ChatView(selectedRole: role)) {
                            RoleCard(role: role, isSelected: false)
                                .frame(height: 180)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("选择对话角色")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadRoles()
            }
        }
    }
}

// 角色卡片
struct RoleCard: View {
    let role: AIRole
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标
            Image(systemName: role.iconName ?? "person.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 角色名称
            Text(role.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 描述
            Text(role.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // 选择指示器
            if isSelected {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    RoleSelectionView()
} 