//
//  DimensionSelectView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 9/4/22.
//

import SwiftUI

struct DimensionSelectView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: DimensionSelectViewModel
    var body: some View {
        VStack {
            Text("Dungeon Height")
            Picker("Dungeon Height", selection: $viewModel.heightSelection) {
                ForEach(viewModel.heightRange) {
                    Text("\($0) levels")
                }
            }.padding()

            Text("Dungeon Width")
            Picker("Dungeon Width", selection: $viewModel.widthSelection) {
                ForEach(viewModel.widthRange) {
                    Text("\($0) levels")
                }
            }.padding()
           
            Text("Dungeon name")
            TextField("Dungeon name", text: $viewModel.dungeonName)
            
            Button("Confirm") {
                let needsOverwrite = viewModel.aboutToCreateLevel()
                if !needsOverwrite {
                    gameState.state = .designing(designableDungeon: viewModel.getDungeon())
                }
            }.padding()
            
            Button("Cancel") {
                gameState.state = .mainmenu
            }
        }.alert("Dungeon Already Exists", isPresented: $viewModel.requiresOverwrite) {
            Button(role: .destructive) {
                gameState.state = .designing(designableDungeon: viewModel.getDungeon())
            } label: {
                Text("Overwrite")
            }
        } message: {
            Text("There is already a dungeon with this name, are you sure you wish to replace it?")
        }
    }
}
