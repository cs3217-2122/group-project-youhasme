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
    @State var startGame = false

    var body: some View {
        HStack {
            NavigationLink("Load", destination: LazyNavigationView(LoadLevelDesignView()))

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
                .onAppear {
                    levelName = viewModel.currLevel.name.isEmpty ? levelName
                                                                 : viewModel.currLevel.name
                }

            // TODO: implement game view
//            NavigationLink(destination:
//                            LazyNavigationView(
//                                GameView(level: viewModel.currLevel)
//            )) {
//                Text("Start")
//            }

        }
        .padding([.leading, .trailing], 10.0)
    }

    private func save() {
        showSaveLevelAlert = true
        saveMessage = viewModel.saveLevel(levelName: levelName)
    }
}
