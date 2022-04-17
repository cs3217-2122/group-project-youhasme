//
//  MultiplayerRoomView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 17/4/22.
//

import SwiftUI

struct MultiplayerRoomView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MultiplayerRoomViewModel
    var body: some View {
        switch viewModel.playerStatus {
        case .waiting:
            MultiplayerWaitRoomView(viewModel: viewModel)
        case .playing(roomId: let roomId, dungeonRoomId: let dungeonRoomId):
            MultiplayerPlayView(viewModel: MultiplayerPlayViewModel(roomId: roomId, dungeonRoomId: dungeonRoomId))
        }
    }
}
