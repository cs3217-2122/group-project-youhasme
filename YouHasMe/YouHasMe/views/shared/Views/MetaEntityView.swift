//
//  MetaEntityView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct MetaEntityView: View {
    @EnvironmentObject var gameState: GameState
    var viewModel: MetaEntityViewModel

    var body: some View {
        CellView(viewModel: viewModel)
            .border(.pink)
            .onTapGesture {
                switch gameState.state {
                case .designingMeta(_):
                    viewModel.addEntity()
                    viewModel.examine()
                case .playing:
                    viewModel.enterLevelIfExists()
                default:
                    return
                }
            }
            .onLongPressGesture {
                switch gameState.state {
                case .designingMeta(_):
                    viewModel.removeEntity()
                default:
                    return
                }
            }
    }
}
