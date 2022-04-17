//
//  OnlineDungeonListView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import SwiftUI

struct OnlineDungeonListView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject var viewModel = OnlineDungeonListViewModel()
    var selectAction: (OnlineDungeon) -> Void
    var body: some View {
        List {
            ForEach(viewModel.onlineDungeons) { dungeon in
                Button(action: {
                    selectAction(dungeon)
                }) {
                    HStack {
                        Text(dungeon.persistedDungeon.name)
                    }
                }
            }
        }
    }
}
