//
//  DungeonDesignerPersistenceView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI
import Combine

struct PersistenceView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: DesignerViewModel
    
    @State var showSaveLevelAlert = false
    @State var saveMessage = ""
    var saveErrorMessage = "Save Error"
    @State var showSaveErrorAlert = false
    @State var loadSuccess = false
    @State var isChangingDungeonName = false
    @State var dungeonButtonText: String = ""
    @State var unconfirmedDungeonName = ""

    var body: some View {
        HStack {
            Button("Load") {
                gameState.state = .selecting
            }

            Button("Save") {
                do {
                    try viewModel.save()
                } catch {
                    showSaveErrorAlert = true
                }
            }.alert(isPresented: $showSaveLevelAlert) {
                Alert(title: Text(saveMessage), dismissButton: .cancel(Text("close")))
            }.alert(isPresented: $showSaveErrorAlert) {
                Alert(title: Text(saveErrorMessage), dismissButton: .cancel(Text("close")))
            }
            
            if isChangingDungeonName {
                TextField("", text: $unconfirmedDungeonName)
                Button("Confirm new name") {
                    viewModel.dungeon.renameDungeon(to: unconfirmedDungeonName)
                    isChangingDungeonName = false
                }
            } else {
                DungeonNameButton(viewModel: viewModel.getNameButtonViewModel()) {
                    unconfirmedDungeonName = viewModel.dungeon.name
                    isChangingDungeonName = true
                }
            }
            
            Spacer()
            
            Button("Play") {
                do {
                    try viewModel.save()
                    gameState.stateStack.append(
                        .playing(playableDungeon: viewModel.getPlayableDungeon())
                    )
                } catch {
                    showSaveErrorAlert = true
                }
            }
        }
        .padding([.leading, .trailing], 10.0)
    }
}

struct DungeonNameButton: View {
    @ObservedObject var viewModel: DungeonNameButtonViewModel
    let onTapHandler: () -> Void
    
    var body: some View {
        Button(viewModel.name, action: onTapHandler)
    }
}
