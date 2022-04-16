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
        HStack{
            Spacer()
            VStack {
                Text("Dungeon Height")
                Picker("Dungeon Height", selection: $viewModel.heightSelection) {
                    ForEach(viewModel.heightRange) {
                        Text("\($0) levels high")
                    }
                }.padding()

                Text("Dungeon Width")
                Picker("Dungeon Width", selection: $viewModel.widthSelection) {
                    ForEach(viewModel.widthRange) {
                        Text("\($0) levels wide")
                    }
                }.padding()
               
                Text("Dungeon name")
                TextField("Dungeon name", text: $viewModel.dungeonName)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                
                Button("Confirm") {
                    guard !viewModel.dungeonName.isEmpty else {
                        return
                    }
                    
                    viewModel.aboutToCreateLevel()
                    
                    if !viewModel.requiresOverwrite {
                        gameState.state = .designing(designableDungeon: viewModel.getDungeon())
                    }
                }.padding()
                
                Button("Cancel") {
                    gameState.state = .mainmenu
                }
            }.frame(maxWidth: 300)
            .alert("Dungeon Already Exists", isPresented: $viewModel.requiresOverwrite) {
                Button(role: .destructive) {
                    gameState.state = .designing(designableDungeon: viewModel.getDungeon())
                } label: {
                    Text("Overwrite")
                }
            } message: {
                Text("There is already a dungeon with this name, are you sure you wish to replace it?")
            }
            Spacer()
        }
    }
}
