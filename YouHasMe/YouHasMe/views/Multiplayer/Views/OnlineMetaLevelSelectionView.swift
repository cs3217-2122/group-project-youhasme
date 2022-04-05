//
//  OnlineMetaLevelSelectionView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 4/4/22.
//

import SwiftUI

struct OnlineMetaLevelSelectionView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: OnlineMetaLevelSelectionViewModel
    var body: some View {
        List {
            Section(header: Text("Community Meta Levels")) {
                ForEach(viewModel.onlineMetaLevels, id: \.self.id) { onlineMetaLevel in
                    Button(action: {
                        viewModel.createRoom(metaLevel: onlineMetaLevel)
                        gameState.stateStack.popLast()
                    }) {
                        HStack {
                            Text(onlineMetaLevel.persistedMetaLevel.name)
                        }
                    }
                }
            }
        }
    }
}

struct OnlineMetaLevelSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineMetaLevelSelectionView(viewModel: OnlineMetaLevelSelectionViewModel())
    }
}
