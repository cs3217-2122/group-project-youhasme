//
//  MultiplayerWaitRoomView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import SwiftUI

struct MultiplayerWaitRoomView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MultiplayerRoomViewModel
    @State var selectedDungeon: OnlineDungeon? = nil
    @State var selectingDungeon: Bool = false
    
    func selectDungeon(onlineDungeon: OnlineDungeon) {
        viewModel.selectDungeon(onlineDungeon: onlineDungeon)
        selectingDungeon = false
    }
    
    var body: some View {
        if(selectingDungeon) {
            OnlineDungeonListView(selectAction: selectDungeon)
        } else {
            roomView
        }
    }
    
    var roomView: some View {
        VStack {
            Text("Join Code: \(viewModel.joinCode)")
                .font(.title)

            List {
                Section("Players") {
                    ForEach(viewModel.players, id: \.self.id) { player in
                        Text(player.displayName)
                    }
                }
                
                Section("Select a dungeon") {
                    if (viewModel.selectedDungeon != nil) {
                        Text("Selected Dungeon: \(viewModel.selectedDungeon?.persistedDungeon.name ?? "")")
                    }
                    Button(action: {
                        selectingDungeon = true
                    }) {
                        Text("Select a online dungeon")
                    }
                }
                
                Section("Start dungeon") {
                    if(viewModel.isHost) {
                        Button(action: {
                            viewModel.startGame()
                        }) {
                            Text("Start Dungeon")
                        }.disabled(viewModel.selectedDungeon == nil)
                    }
                }
            }
        }
    }
}
