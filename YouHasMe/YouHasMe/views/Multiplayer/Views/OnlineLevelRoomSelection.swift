//
//  OnlineLevelRoomSelection.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 5/4/22.
//

import SwiftUI

struct OnlineLevelRoomSelection: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: LevelRoomViewModel
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Your rooms")) {
                    ForEach(viewModel.rooms, id: \.self.id) { room in
                        Button(action: {
                            gameState.state = .multiplayerLevel(roomId: room.id!)
                        }) {
                            HStack{
                                Text(room.persistedLevel.name)
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

//struct OnlineLevelRoomSelection_Previews: PreviewProvider {
//    static var previews: some View {
//        OnlineLevelRoomSelection()
//    }
//}
