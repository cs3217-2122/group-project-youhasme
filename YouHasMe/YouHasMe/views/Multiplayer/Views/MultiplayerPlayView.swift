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
//                guard viewModel.state == .normalPlay else {
//                    return
//                }
                
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
        VStack {
            Spacer()
            GridView(viewModel: viewModel)
                .gesture(dragGesture)
            Spacer()
        }
        
    }
}
