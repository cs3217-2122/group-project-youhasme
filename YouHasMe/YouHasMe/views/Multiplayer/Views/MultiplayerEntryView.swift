//
//  MultiplayerRoomView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 16/4/22.
//

import SwiftUI

struct MultiplayerEntryView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject var viewModel = MultiplayerEntryViewModel()
    @State var displayName: String = ""
    @State var joinCode: String = ""
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                TextField("Display Name", text: $viewModel.displayName)
                    .disableAutocorrection(true)
                    .frame(width: 500)
                TextField("Join Code", text: $viewModel.joinCode)
                    .disableAutocorrection(true)
                    .frame(width: 500)
                HStack {
                    Button(action: {
                        Task {
                            let roomId = await viewModel.createRoom()
                            if let roomId = roomId {
                                gameState.state = .multiplayer(roomId: roomId)
                            }
                        }
                       
                    }){
                        Text("Create New Room")
                    }.disabled(!viewModel.createRoomAllowed)
                    
                    Button(action: {
                        Task {
                            let roomId = await viewModel.joinRoom()
                            if let roomId = roomId {
                                gameState.state = .multiplayer(roomId: roomId)
                            }
                        }
                    }){
                        Text("Join A Room")
                    }.disabled(!viewModel.joinRoomAllowed)
                }
            }.textFieldStyle(.roundedBorder)
            Spacer()
        }
    }
}
