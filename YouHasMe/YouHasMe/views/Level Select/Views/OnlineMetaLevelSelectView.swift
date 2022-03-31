//
//  OnlineMetaLevelSelectView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 31/3/22.
//

import SwiftUI

struct OnlineMetaLevelSelectView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelSelectViewModel
    var body: some View {
        VStack {
            List {
                Section(header: Text("Coummunity Meta Levels")) {
                    ForEach(viewModel.onlineMetaLevels, id: \.self.id) { onlineMetaLevel in
                        HStack {
                            Text(onlineMetaLevel.metaLevel.name)
                            Spacer()
                            Button(action: {
                                viewModel.createRoom(onlineMetaLevel: onlineMetaLevel)
                            }) {
                                Text("Create a room")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct OnlineMetaLevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        OnlineMetaLevelSelectView(viewModel: MetaLevelSelectViewModel())
    }
}
