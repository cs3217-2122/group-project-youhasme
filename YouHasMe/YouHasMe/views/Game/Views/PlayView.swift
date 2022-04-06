//
//  MetaLevelPlayView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import SwiftUI
import Combine

struct PlayView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: PlayViewModel
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    let inverseDragThreshold: Double = 5.0.multiplicativeInverse()
    @State var lastDragLocation: CGPoint?


    var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                guard case .playing = gameState.state else {
                    return
                }
                var updateAction: UpdateType = .tick
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount < 0 {
                        updateAction = .moveLeft
                    } else {
                        updateAction = .moveRight
                    }

                } else {
                    if verticalAmount < 0 {
                        updateAction = .moveUp
                    } else {
                        updateAction = .moveDown
                    }
                }
                viewModel.playerMove(updateAction: updateAction)
            }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Group {
                    GridView(viewModel: viewModel)
                        .gesture(dragGesture)
                    Spacer()
                    HStack(alignment: .center) {
                        ForEach(viewModel.contextualData) { data in
                            Button(data.description, action: data.action)
                        }
                    }
                }
            }
            .alert("You Win!", isPresented: $viewModel.hasWon) {
                                Button("yay!", role: .cancel) {}
            }.alert("No infinite loops allowed!", isPresented: $viewModel.isLoopingInfinitely) {
                Button("ok!", role: .cancel) {}
            }
            if viewModel.state != .normal {
                NavigationFrame(
                    backHandler: { viewModel.closeOverlay() }) {
                    Group {
                        switch viewModel.state {
                        case .messages:
                            MessagesView(viewModel: viewModel.getMessagesViewModel())
                        default:
                            EmptyView()
                        }
                    }
                    
                }
            }
        }.onAppear {
            achievementsViewModel.setSubscriptionsFor(viewModel.gameEngine.gameEventPublisher)
        }
    }
}
