//
//  RoomListView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import SwiftUI

struct RoomListView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: RoomListViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    gameState.append(state: .onlineMetaLevelSelection)
                }) {
                    Text("Create a new room")
                }.padding()
                Spacer()
                Button(action: {
                    
                }) {
                    Text("Join a room")
                }.padding()
            }.padding()
            Spacer()
            List {
                Section(header: Text("Your rooms")) {
                    ForEach(viewModel.rooms, id: \.self.id) { room in
                        Button(action: {
                            
                        }) {
                            HStack {
                                Text(room.name)
                                Text(room.joinCode)
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
