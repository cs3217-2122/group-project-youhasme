//
//  LevelEditRowView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 19/3/22.
//

import Foundation
import SwiftUI

struct LevelEditRowView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: LevelDesignerViewModel
    @State var showSaveLevelAlert = false
    @State var saveMessage = ""
    @State var showUnsavedChangesPrompt = false
    @State var loadSuccess = false
    @State var startGame = false

    var body: some View {
        HStack {
            Button(action: {
                guard !viewModel.unsavedChanges else {
                    showUnsavedChangesPrompt = true
                    return
                }
                gameState.state = .selecting
            }) {
                Text("Load")
            }.confirmationDialog("You have unsaved changes that will be lost.",
                                 isPresented: $showUnsavedChangesPrompt,
                                 titleVisibility: .visible) {
                Button("Continue") {
                    gameState.state = .selecting
                }
                Button("Cancel") {
                }
            }

            Button(action: save) {
                Text("Save")
            }.alert(isPresented: $showSaveLevelAlert) {
                Alert(title: Text(saveMessage), dismissButton: .cancel(Text("close")))
            }

            Button(action: viewModel.reset) {
                Text("Reset")
            }

            TextField("Level Name", text: $viewModel.currLevel.name)
                .padding([.trailing, .leading], 5.0)
                .disableAutocorrection(true)
            Spacer()
            Button(action: {
                gameState.stateStack.append(.playing(playableLevel: .level(viewModel.currLevel)))
            }) {
                Text("Play")
            }.disabled(viewModel.unsavedChanges)
        }
        .padding([.leading, .trailing], 10.0)
    }

//    private func load() {
//        loadSuccess = viewModel.loadLevel(levelName: levelName)
//        if loadSuccess {
//            levelName = viewModel.currLevel.name
//        }
//        showLoadLevelAlert = true
//    }

    private func save() {
        showSaveLevelAlert = true
        saveMessage = viewModel.saveLevel()
    }

    private func getLoadLevelAlert(loadSuccess: Bool, levelName: String) -> String {
        if loadSuccess {
            return "Successfully loaded level \(levelName)."
        } else if levelName.isEmpty {
            return "Please key in a non-empty level name."
        } else {
            return "No level called \(levelName) exists."
        }
    }
}
