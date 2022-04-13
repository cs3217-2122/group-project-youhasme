//
//  DungeonSelectView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import SwiftUI

struct DungeonSelectView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: DungeonSelectViewModel
    var body: some View {
        VStack {
            Button(action: {
                gameState.state = .choosingDimensions
            }) {
                Text("Create New Dungeon")
            }.padding()
            Spacer()
            List {
                Section(header: Text("Select an existing dungeon")) {
                    ForEach(viewModel.getAllDungeons(), id: \.self) { loadable in
                        Button(action: {
                            gameState.state = .designing(designableDungeon: .dungeonLoadable(loadable))
                        }) {
                            Text(loadable.name)
                        }
                    }
                }
            }
        }
    }
}
