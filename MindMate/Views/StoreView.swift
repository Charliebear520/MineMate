import SwiftUI

struct StoreView: View {
    struct StoreItem: Identifiable {
        let id = UUID()
        let name: String
        let desc: String
        let price: Int
        let isPurchased: Bool
    }
    @State private var items: [StoreItem] = [
        StoreItem(name: "深色主題", desc: "解鎖深色模式", price: 500, isPurchased: false),
        StoreItem(name: "彩虹主題", desc: "解鎖彩虹主題", price: 1000, isPurchased: false),
        StoreItem(name: "煙花效果", desc: "解鎖煙花動畫", price: 300, isPurchased: true)
    ]
    var body: some View {
        NavigationView {
            List(items) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name).font(.headline)
                        Text(item.desc).font(.subheadline)
                    }
                    Spacer()
                    if item.isPurchased {
                        Text("已購買").foregroundColor(.green)
                    } else {
                        Button("購買") {}
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("商店")
        }
    }
}

#Preview {
    StoreView()
} 