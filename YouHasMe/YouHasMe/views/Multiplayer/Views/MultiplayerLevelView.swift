//
//  MultiplayerLevelView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 5/4/22.
//

import SwiftUI

struct MultiplayerLevelView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MultiplayerLevelViewModel
//    @State var gameEngine: GameEngine
//    @State var showingWinAlert = false
//    @State var showingLoopAlert = false

//    init(viewModel: MultiplayerLevelViewModel) {
//        self.levelDesignerViewModel = levelDesignerViewModel
//        self.gameEngine = GameEngine(levelLayer: levelDesignerViewModel.currLevelLayer)
//    }

    func gridSize(proxy: GeometryProxy) -> CGFloat {
        let width = floor(proxy.size.width / CGFloat(viewModel.getWidth()))
        let height = floor(proxy.size.height / CGFloat(viewModel.getHeight()))
        return min(width, height)
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
//                guard case .playing = gameState.state else {
//                    return
//                }
                var action: UpdateAction = .tick
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount < 0 {
                        action = .moveLeft
                    } else {
                        action = .moveRight
                    }

                } else {
                    if verticalAmount < 0 {
                        action = .moveUp
                    } else {
                        action = .moveDown
                    }
                }
                viewModel.sendAction(action: action)
//                gameEngine.apply(action: move)
//                showingWinAlert = viewModel.gameWon
//                showingLoopAlert = viewModel.hasLoop
//                gameEngine.currentGame.gameStatus == .win
//                showingLoopAlert = gameEngine.status == .infiniteLoop
//                levelDesignerViewModel.currLevelLayer = gameEngine.currentGame.levelLayer
            }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                
                if let code = viewModel.levelRoom?.joinCode {
                    Text("Room Code: \(code)")
                }
                
                if let playerNum = viewModel.playerNum {
                    Text("You are player \(playerNum)")
                }
                
//                ForEach((1...levelDesignerViewModel.currLevelLayer.numPlayers), id: \.self) { playerNum in
//                Button(action: {
//                    selectedPlayerNum = playerNum
//                }) {
//                    Text("Player: \(playerNum)")
//                }
//            }
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    ForEach((0..<viewModel.getHeight()), id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach((0..<viewModel.getWidth()), id: \.self) { col in
                                let tileViewModel = viewModel.getTileViewModel(at: Point(x: col, y: row))
                                EntityView(viewModel: tileViewModel)
                                    .frame(width: gridSize(proxy: proxy), height: gridSize(proxy: proxy))
                                    .border(.pink)
                            }
                        }
                    }
                }.alert("You Win!", isPresented: $viewModel.showingWinAlert) {
                    Button("yay!", role: .cancel) {
                        gameState.state = .mainmenu
                        viewModel.deleteRoom()
                    }
                }.alert("No infinite loops allowed!", isPresented: $viewModel.showingLoopAlert) {
                    Button("ok!", role: .cancel) {}
                }
                Spacer()
            }
                HStack {
                    Spacer()
                       Button("Undo") {
                           viewModel.sendAction(action: .undo)
                       }
                }
                Spacer()
            }.gesture(dragGesture)
        }
    }
}

//struct MultiplayerLevelView: View {
//    @ObservedObject var viewModel: MultiplayerLevelViewModel
//
//    var body: some View {
//        if viewModel.levelRoom != nil {
//            VStack {
//                ForEach(viewModel.players, id: \.self) { player in
//                    Text(player)
//                }
//
//                ForEach(viewModel.moves, id: \.self.id) { move in
//                    HStack {
//                        Text(move.player)
//                        Text(move.move.rawValue)
//                            .font(.caption)
//                    }
//
//                }
//
//            }
//
//            Button(action: {
//                viewModel.sendAction(action: UpdateAction.moveUp)
//            }) {
//                Text("Move UP")
//            }
//
//            Button(action: {
//                viewModel.sendAction(action: UpdateAction.moveDown)
//            }) {
//                Text("Move DOWN")
//            }
//
//        } else {
//            Text("Creating Room")
//        }
//    }
//}

//struct MultiplayerLevelView_Previews: PreviewProvider {
//    static var previews: some View {
//        MultiplayerLevelView()
//    }
//}
