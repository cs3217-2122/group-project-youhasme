//
//  MetaEntityView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct EntityView: View {
    @EnvironmentObject var gameState: GameState
    @State var shouldShowPopover: Bool = false
    @ObservedObject var viewModel: EntityViewModel
    var foregroundColor: Color {
        switch viewModel.status {
        case .active:
            return .clear
        case .inactiveAndComplete:
            return .gray
        case .inactiveAndIncomplete:
            return .black
        }
    }
    var body: some View {
        ZStack {
            CellView(backupDisplayColor: .black, viewModel: viewModel)
                .onReceive(viewModel.$tileDescription, perform: { description in
                    shouldShowPopover = description != nil
                })
                .popover(isPresented: $shouldShowPopover) {
                    if let tileDescription = viewModel.tileDescription {
                        Text(tileDescription)
                        Button("Close") {
                            shouldShowPopover = false
                        }
                    }
                }
                .border(.pink)
                .onTapGesture {
                    switch gameState.state {
                    case .designing:
                        viewModel.addEntity()
                        viewModel.examine()
                    case .playing:
                        viewModel.examine()
                    default:
                        return
                    }
                }
                .onLongPressGesture {
                    switch gameState.state {
                    case .designing:
                        viewModel.removeEntity()
                    default:
                        return
                    }
                }
            foregroundColor.opacity(0.5)
        }
    }
}
