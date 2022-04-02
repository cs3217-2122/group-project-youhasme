//
//  YouHasMeApp.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import SwiftUI
import Firebase

@main
struct YouHasMeApp: App {
    @StateObject var gameState = GameState()
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(gameState)
        }
    }
}
