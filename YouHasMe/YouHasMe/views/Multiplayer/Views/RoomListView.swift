//
//  RoomListView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 4/4/22.
//

import SwiftUI

import SwiftUI

struct RoomListView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: RoomListViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    gameState.stateStack.append(.selectingOnlineMeta) 
                }) {
                    Text("Create a new room")
                }.padding()
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Join a room")
                }
            }
            
            List {
                Section(header: Text("Your rooms")) {
                    ForEach(viewModel.rooms, id: \.self.id) { room in
                        Button(action: {
                            gameState.state = .multiplayerMetaLevel(openWorldRoom: room)
                        }) {
                            HStack{
                                Text(room.name)
                                Text(room.joinCode)
                            }
                        }
                    }
                }
            }
        }
//        }.onAppear(perform: {
//            viewModel.subscribe()
//        }).onDisappear(perform: {
//            viewModel.unsubscribe()
//        })
    }
 }

 struct RoomListView_Previews: PreviewProvider {
     static var previews: some View {
         RoomListView(viewModel: RoomListViewModel())
     }
 }
