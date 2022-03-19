//
//  LevelEditRowView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 19/3/22.
//

import Foundation
import SwiftUI

struct LevelEditRowView: View {
    @ObservedObject var viewModel: LevelDesignerViewModel
    @State var levelName = ""
    @State var showSaveLevelAlert = false
    @State var saveMessage = ""
    @State var showLoadLevelAlert = false
    @State var loadSuccess = false
    @State var startGame = false

    var body: some View {
        HStack {
            Button(action: load) {
                Text("Load")
            }.alert(isPresented: $showLoadLevelAlert) {
                let alertText = getLoadLevelAlert(loadSuccess: loadSuccess, levelName: levelName)

                return Alert(title: Text(alertText), dismissButton: .cancel(Text("close")))
            }

            Button(action: save) {
                Text("Save")
            }.alert(isPresented: $showSaveLevelAlert) {
                Alert(title: Text(saveMessage), dismissButton: .cancel(Text("close")))
            }

            Button(action: viewModel.reset) {
                Text("Reset")
            }

            TextField("Level Name", text: $levelName)
                .padding([.trailing, .leading], 5.0)
                .disableAutocorrection(true)
        }
        .padding([.leading, .trailing], 10.0)
    }

    private func load() {
        loadSuccess = viewModel.loadLevel(levelName: levelName)
        if loadSuccess {
            levelName = viewModel.currLevel.name
        }
        showLoadLevelAlert = true
    }

    private func save() {
        showSaveLevelAlert = true
        saveMessage = viewModel.saveLevel(levelName: levelName)
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
