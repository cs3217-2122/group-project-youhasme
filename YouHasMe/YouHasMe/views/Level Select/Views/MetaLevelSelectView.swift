//
//  MetaLevelSelectView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import SwiftUI

struct MetaLevelSelectView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelSelectViewModel
    var body: some View {
        VStack {
            Button(action: {
                gameState.state = .designingMeta()
            }) {
                Text("Create New Meta Level")
            }.padding()
            Spacer()
            List {
                Section(header: Text("Select an existing Meta Level")) {
                    ForEach(viewModel.getAllMetaLevels(), id: \.self) { urlListObject in
                        Button(action: {
                            gameState.state = .designingMeta(metaLevelLoadable: urlListObject)
                        }) {
                            Text(urlListObject.name)
                        }
                    }
                }
            }
        }
    }
}

struct MetaLevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelSelectView(viewModel: MetaLevelSelectViewModel())
    }
}
