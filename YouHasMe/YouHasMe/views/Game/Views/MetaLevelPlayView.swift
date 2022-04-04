//
//  MetaLevelPlayView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import SwiftUI
import Combine

struct MetaLevelPlayView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelPlayViewModel
    
    let inverseDragThreshold: Double = 5.0.multiplicativeInverse()
    @State var lastDragLocation: CGPoint?

    var body: some View {
        ZStack {
            VStack {
                Group {
                    MetaLevelGridView(viewModel: viewModel)
                    Spacer()
                    HStack(alignment: .center) {
                        ForEach(viewModel.contextualData) { data in
                            Button(data.description, action: data.action)
                        }
                    }
                }
            }
            if viewModel.state != .normal {
                NavigationFrame(
                    backHandler: { viewModel.closeOverlay() }) {
                    Group {
                        switch viewModel.state {
                        case .messages:
                            MessagesView(viewModel: viewModel.getMessagesViewModel())
                        case .travel:
                            MetaLevelInfoView(viewModel: viewModel.getMetaLevelInfoViewModel())
                        case .level:
                            LevelInfoView(viewModel: viewModel.getLevelInfoViewModel())
                        default:
                            EmptyView()
                        }
                    }
                    
                }
            }
        }
    }
}
