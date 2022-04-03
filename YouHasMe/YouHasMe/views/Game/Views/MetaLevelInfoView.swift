//
//  MetaLevelInfoView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import SwiftUI

struct MetaLevelInfoView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelInfoViewModel
    
    func getConditionStatusImage(_ condition: Condition) -> Image {
        condition.isConditionMet() ? Image.checkmark : Image.cross
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(viewModel.metaLevelInfo) { metaLevelInfo in
                    Text(metaLevelInfo.metaLevel.name)
                        .foregroundColor(.white)
                    
                    if let unlockCondition = metaLevelInfo.unlockCondition {
                        getConditionStatusImage(unlockCondition)
                        Text(unlockCondition.description)
                            .foregroundColor(.white)
                    }
                    
                    if metaLevelInfo.isLevelUnlocked {
                        Button("Enter Level") {
                            let _ = globalLogger.info("Entering meta level")
                            gameState.stateStack.append(
                                .playingMeta(playableMetaLevel: .metaLevelLoadable(metaLevelInfo.loadable))
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
