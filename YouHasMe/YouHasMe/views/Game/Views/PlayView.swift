//
//  MetaLevelPlayView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import SwiftUI
import Combine

struct PlayView: View {
    @ObservedObject var viewModel: PlayViewModel

    var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                guard viewModel.state == .normalPlay else {
                    return
                }
                
                var actionType : ActionType  = .tick
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount < 0 {
                        actionType = .moveLeft
                    } else {
                        actionType = .moveRight
                    }
                } else {
                    if verticalAmount < 0 {
                        actionType = .moveUp
                    } else {
                        actionType = .moveDown
                    }
                }
                viewModel.playerMove(actionType: actionType)
            }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Current Lvl: \(viewModel.currentLevelName)")
                    .font(.title2)
                GridView(viewModel: viewModel)
                    .gesture(dragGesture)
                Spacer()
                
                ActiveRulesView(viewModel: viewModel.getActiveRulesViewModel())
                
                Button("Undo") {
                    viewModel.playerUndo()
                }.disabled(viewModel.state != .normalPlay)
            }
            .alert("You Win!", isPresented: $viewModel.hasWon) {
                                Button("yay!", role: .cancel) {}
            }.alert("No infinite loops allowed!", isPresented: $viewModel.isLoopingInfinitely) {
                Button("ok!", role: .cancel) {}
            }
        }.overlay(alignment: .top, content: {
            GameNotificationsView(gameNotificationsViewModel: viewModel.notificationsViewModel)
        })
    }
}
