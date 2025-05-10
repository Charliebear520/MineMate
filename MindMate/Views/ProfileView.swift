import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var libraryViewModel: EmotionLibraryViewModel
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("金幣：\(libraryViewModel.userProfile?.coins ?? 0)")
                        Text("連續登入：\(libraryViewModel.userProfile?.currentStreak ?? 0) 天")
                        Text("情緒球數：\(libraryViewModel.emotionBalls.count)")
                        // 你可以根據需要顯示更多資料
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle("我的")
            .onAppear {
                libraryViewModel.fetchUserProfile(context: context)
            }
        }
    }
}

#Preview {
    ProfileView().environmentObject(EmotionLibraryViewModel())
} 