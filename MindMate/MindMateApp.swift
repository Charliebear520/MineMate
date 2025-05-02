//
//  MindMateApp.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/4/26.
//

import SwiftUI

@main
struct MindMateApp: App {
    @StateObject private var emotionLibraryViewModel = EmotionLibraryViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                RoleSelectionView()
                    .tabItem {
                        Label("主頁", systemImage: "house")
                    }
                
                EmotionLibraryView()
                    .tabItem {
                        Label("情緒庫", systemImage: "heart.circle")
                    }
            }
            .environmentObject(emotionLibraryViewModel)
        }
    }
}
