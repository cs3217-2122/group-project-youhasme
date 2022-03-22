//
//  YouHasMeApp.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import SwiftUI

@main
struct YouHasMeApp: App {
    @StateObject var gameState = GameState()
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(gameState)
        }
    }
}
