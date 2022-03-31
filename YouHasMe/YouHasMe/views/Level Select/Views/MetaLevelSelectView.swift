//
//  MetaLevelSelectView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import SwiftUI

struct MetaLevelSelectView: View {
//    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelSelectViewModel
    var body: some View {
        TabView {
            LocalMetaLevelSelectView(viewModel: viewModel)
                .tabItem {
                    Text("Local Meta Levels")
                }
            OnlineMetaLevelSelectView(viewModel: viewModel)
                .tabItem {
                    Text("Online Meta Levels")
                }
        }
    }
}

struct MetaLevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelSelectView(viewModel: MetaLevelSelectViewModel())
    }
}
