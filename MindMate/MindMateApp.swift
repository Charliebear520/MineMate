//
//  MindMateApp.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/4/26.
//

import SwiftUI

@main
struct MindMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RoleSelectionView()
        }
    }
}
