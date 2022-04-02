//
//  GameView.swift
//  YouHasMe
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        NavigationFrame(backHandler: gameState.state == .mainmenu ? nil : ({
            switch gameState.state {
            case .mainmenu:
                break
            case .selecting, .selectingMeta, .designing, .designingMeta, .playing:
                gameState.stateStack.removeLast()
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                LevelSelectView(levelDesignerViewModel: gameState.getLevelDesignerViewModel())
            case .designing:
                LevelDesignerView(levelDesignerViewModel: gameState.getLevelDesignerViewModel())
            case .designingMeta:
                MetaLevelDesignerView(viewModel: gameState.getMetaLevelDesignerViewModel())
            case .playing:
                LevelPlayView(levelDesignerViewModel: gameState.getLevelPlayViewModel())
            case .selectingMeta:
                MetaLevelSelectView(viewModel: gameState.getMetaLevelSelectViewModel())
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
