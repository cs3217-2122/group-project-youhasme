//
//  MultiplayerPlayView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import SwiftUI

struct MultiplayerPlayView: View {
    @ObservedObject var viewModel: MultiplayerPlayViewModel
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
                viewModel.sendAction(actionType: actionType)
            }
    }
    var body: some View {
        if(viewModel.levelLayer == nil) {
            ProgressView()
        } else {
            VStack {
                Spacer()
                if let playerNum = viewModel.playerNum {
                    Text("You are player \(playerNum)")
                }
                GridView(viewModel: viewModel)
                    .gesture(dragGesture)
                    .alert("You Win!", isPresented: $viewModel.showingWinAlert) {
                        Button("yay!", role: .cancel) {
                        }
                    }.alert("No infinite loops allowed!", isPresented: $viewModel.showingLoopAlert) {
                        Button("ok!", role: .cancel) {}
                    }
                
                Spacer()
            }
        }
    }
}
