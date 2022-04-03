//
//  GameGridView.swift
//  YouHasMe
//

import SwiftUI

struct GameGridView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    @State var gameEngine: GameEngine
    @State var showingWinAlert = false
    @State var showingLoopAlert = false

    init(levelDesignerViewModel: LevelDesignerViewModel) {
        self.levelDesignerViewModel = levelDesignerViewModel
        self.gameEngine = GameEngine(levelLayer: levelDesignerViewModel.currLevelLayer)
    }

    func gridSize(proxy: GeometryProxy) -> CGFloat {
        let width = floor(proxy.size.width / CGFloat(levelDesignerViewModel.getWidth()))
        let height = floor(proxy.size.height / CGFloat(levelDesignerViewModel.getHeight()))
        return min(width, height)
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                guard case .playing = gameState.state else {
                    return
                }
                var updateAction: UpdateType = .tick
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount < 0 {
                        updateAction = .moveLeft
                    } else {
                        updateAction = .moveRight
                    }

                } else {
                    if verticalAmount < 0 {
                        updateAction = .moveUp
                    } else {
                        updateAction = .moveDown
                    }
                }
                gameEngine.apply(action: updateAction)
                showingWinAlert = gameEngine.currentGame.gameStatus == .win
                showingLoopAlert = gameEngine.status == .infiniteLoop
                levelDesignerViewModel.currLevelLayer = gameEngine.currentGame.levelLayer
            }
    }

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    ForEach((0..<levelDesignerViewModel.getHeight()), id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach((0..<levelDesignerViewModel.getWidth()), id: \.self) { col in
                                let tileViewModel = levelDesignerViewModel.getTileViewModel(at: Point(x: col, y: row))
                                EntityView(viewModel: tileViewModel)
                                    .frame(width: gridSize(proxy: proxy), height: gridSize(proxy: proxy))
                                    .border(.pink)
                                    .onTapGesture {
                                        if case .designing = gameState.state {
                                            levelDesignerViewModel.addEntityToPos(x: col, y: row)
                                        }
                                    }
                                    .onLongPressGesture {
                                        if case .designing = gameState.state {
                                            levelDesignerViewModel.removeEntityFromPos(x: col, y: row)
                                        }
                                    }.gesture(dragGesture)
                            }
                        }
                    }
                }.alert("You Win!", isPresented: $showingWinAlert) {
                    Button("yay!", role: .cancel) {}
                }.alert("No infinite loops allowed!", isPresented: $showingLoopAlert) {
                    Button("ok!", role: .cancel) {}
                }
                Spacer()
            }
                HStack {
                    Spacer()
                   if gameState.state == .playing {
                       Button("Undo") {
                           gameEngine.undo()
                           levelDesignerViewModel.currLevelLayer = gameEngine.currentGame.levelLayer
                       }
                   }
                }
                Spacer()
            }
        }
    }
}

// struct GameGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameGridView()
//    }
// }
