import SwiftUI

struct ProfileView: View {
    @State private var coins: Int = 1200
    @State private var exp: Int = 350
    @State private var level: Int = 5
    @State private var streak: Int = 4
    @State private var emotionBallCount: Int = 18
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("金幣：\(coins)")
                        Text("經驗值：\(exp)")
                        Text("等級：\(level)")
                        Text("連續登入：\(streak) 天")
                        Text("情緒球數：\(emotionBallCount)")
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
} 