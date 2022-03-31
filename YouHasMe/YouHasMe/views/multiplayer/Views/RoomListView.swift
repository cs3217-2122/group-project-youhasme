//
//  RoomListView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 31/3/22.
//

import SwiftUI

struct RoomListView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: RoomListViewModel
    @State var inputCode: String = ""
    var body: some View {
        VStack {
            TextField("Join A Room", text: $inputCode)
                .onSubmit {
                    guard inputCode.isEmpty == false else {
                        return
                    }
                    viewModel.joinRoom(code: inputCode)
                }
            List {
                Section(header: Text("Your rooms")) {
                    ForEach(viewModel.rooms, id: \.self.id) { room in
                        Button(action: {
                            gameState.state = .metaLevelMultiplayer
                        }) {
                            HStack {
                                Text(room.metaLevel.name)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RoomListView_Previews: PreviewProvider {
    static var previews: some View {
        RoomListView(viewModel: RoomListViewModel())
    }
}
