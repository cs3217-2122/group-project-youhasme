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
            if (viewModel.selectedDungeon != nil) {
                Text("Selected Dungeon: \(viewModel.selectedDungeon?.persistedDungeon.name ?? "")")
            }
            
            Button(action: {
                selectingDungeon = true
            }) {
                Text("Select a online dungeon")
            }
            
            Section("Join Code") {
                Text(viewModel.joinCode)
            }
            
            Section("Players") {
                List {
                    ForEach(viewModel.players, id: \.self.id) { player in
                        Text(player.displayName)
                    }
                }
            }
            
            if(viewModel.isHost) {
                Button(action: {
                    viewModel.startGame()
                }) {
                    Text("Start Dungeon")
                }
            }
        }
    }
}
