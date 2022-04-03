//
//  LevelInfoView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import SwiftUI
struct LevelInfoView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: LevelInfoViewModel
    
    func getConditionStatusImage(_ condition: Condition) -> Image {
        condition.isConditionMet() ? Image.checkmark : Image.cross
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(viewModel.levelInfo, id: \.self) { levelInfo in
                    Text(levelInfo.level.name)
                    
                    if let unlockCondition = levelInfo.unlockCondition {
                        getConditionStatusImage(unlockCondition)
                        Text(unlockCondition.description)
                    }
                    
                    if levelInfo.isLevelUnlocked {
                        Button("Enter Level") {
                            let _ = globalLogger.info("Entering level")
                            gameState.stateStack.append(
                                .playing(playableLevel: .levelLoadable(levelInfo.loadable))
                            )
                        }
                    }
                }
            }
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
          )
          .background(Color.black.opacity(0.7))
    }
}
