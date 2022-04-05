//
//  MetaEntityView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct EntityView: View {
    @EnvironmentObject var gameState: GameState
    var viewModel: EntityViewModel

    var body: some View {
        CellView(backupDisplayColor: .black, viewModel: viewModel)
            .border(.pink)
            .onTapGesture {
                switch gameState.state {
                case .designingMeta:
                    viewModel.addEntity()
                    viewModel.examine()
                case .playingMeta:
                    viewModel.examine()
                default:
                    return
                }
            }
            .onLongPressGesture {
                switch gameState.state {
                case .designingMeta:
                    viewModel.removeEntity()
                default:
                    return
                }
            }
    }
}
