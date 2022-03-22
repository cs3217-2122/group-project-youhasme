//
//  LevelSelectionView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 20/3/22.
//

import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack {
            Button(action: {
                levelDesignerViewModel.createLevel()
                gameState.state = .designing
            }) {
                Text("Create New Level")
            }.padding()
            Spacer()
            List {
                Section(header: Text("Select an existing level")) {
                    ForEach(levelDesignerViewModel.savedLevels) { level in
                        Button(action: {
                            levelDesignerViewModel.selectLevel(level: level)
                            gameState.state = .designing
                        }) {
                            Text(level.name)
                        }
                    }
                }
            }
        }
    }
}

// struct LevelSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        LevelSelectionView()
//    }
// }
