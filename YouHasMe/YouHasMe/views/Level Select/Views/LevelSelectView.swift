//
//  LevelSelectionView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 20/3/22.
//

import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    @EnvironmentObject var gameState: GameState
    @State private var code = ""
    var body: some View {
        VStack {
            Button(action: {
                gameState.state = .designing()
            }) {
                Text("Create New Level")
            }.padding()
            Spacer()
            List {
                Section(header: Text("Select an existing level")) {
                    ForEach(levelDesignerViewModel.levelLoadables) { levelLoadable in
                        Button(action: {
                            gameState.state = .designing(
                                playableLevel: .levelLoadable(levelLoadable)
                            )
                        }) {
                            Text(levelLoadable.name)
                        }
                    }
                }
            }
            
            TextField("Code", text: $code)
                .onSubmit {
                    levelDesignerViewModel.joinRoom(code: code)
                    gameState.state = .selectingOnlineLevel
                }
        }
    }
}

// struct LevelSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        LevelSelectionView()
//    }
// }
