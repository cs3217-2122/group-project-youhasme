//
//  GameGridView.swift
//  YouHasMe
//

import SwiftUI

struct GameGridView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    @State var gameEngine : GameEngine
    
    init(levelDesignerViewModel: LevelDesignerViewModel) {
        self.levelDesignerViewModel = levelDesignerViewModel
        self.gameEngine = GameEngine(levelLayer: levelDesignerViewModel.currLevelLayer)
    }

    func gridSize(proxy: GeometryProxy) -> CGFloat {
        let width = floor(proxy.size.width / CGFloat(levelDesignerViewModel.getWidth()))
        let height = floor(proxy.size.height / CGFloat(levelDesignerViewModel.getHeight()))
        return min(width, height)
    }
    
    var dragGesture : some Gesture {
        DragGesture()
            .onEnded { value in
                guard gameState.state == .playing else {
                    return
                }
                var updateAction: UpdateAction = .tick
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
                gameEngine.update(action: updateAction)
                levelDesignerViewModel.currLevelLayer = gameEngine.levelLayer
            }
    }
    

    var body: some View {
        GeometryReader { proxy in
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
                                        if gameState.state == .designing {
                                            levelDesignerViewModel.addEntityToPos(x: col, y: row)
                                        }
                                    }
                                    .onLongPressGesture {
                                        if gameState.state == .designing {
                                            levelDesignerViewModel.removeEntityFromPos(x: col, y: row)
                                        }
                                    }.gesture(dragGesture)
                            }
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
