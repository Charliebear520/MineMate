import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            RoleSelectionView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("首頁")
                }
            EmotionLibraryView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("情緒庫")
                }
            AchievementView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("成就")
                }
            StoreView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("商店")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("我的")
                }
        }
    }
}

#Preview {
    MainTabView()
} 