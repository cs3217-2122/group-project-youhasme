//
//  LocalMetaLevelSelectView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 31/3/22.
//

import SwiftUI

struct LocalMetaLevelSelectView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelSelectViewModel
    var body: some View {
        VStack {
            Button(action: {
                gameState.state = .designingMeta(metaLevelURLData: nil)
            }) {
                Text("Create New Meta Level")
            }.padding()
            Spacer()
            List {
                Section(header: Text("Select an existing Meta Level")) {
                    ForEach(viewModel.getAllMetaLevels(), id: \.self) { urlListObject in
                        HStack {
                            Button(action: {
                                gameState.state = .designingMeta(metaLevelURLData: urlListObject)
                            }) {
                                Text(urlListObject.name)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.uploadMetaLevel(urlListObject: urlListObject)
                            }) {
                                Text("Upload")
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

struct LocalMetaLevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        LocalMetaLevelSelectView(viewModel: MetaLevelSelectViewModel())
    }
}
