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

    func getConditionStatusView(_ condition: Condition) -> some View {
        if condition.isConditionMet() {
            return Group {
                Image.checkmark
                Text(condition.description)
                    .foregroundColor(.green)
            }
        } else {
            return Group {
                Image.cross
                Text(condition.description)
                    .foregroundColor(.red)
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(viewModel.levelInfo, id: \.self) { levelInfo in
                    Text(levelInfo.level.name)
                        .foregroundColor(.white)
                    
                    if let unlockCondition = levelInfo.unlockCondition {
                        getConditionStatusView(unlockCondition)
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
