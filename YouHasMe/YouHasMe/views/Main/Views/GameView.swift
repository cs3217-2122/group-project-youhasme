//
//  GameView.swift
//  YouHasMe
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject var levelDesignerViewModel = LevelDesignerViewModel()

    var body: some View {
        NavigationFrame(verticalAlignment: .center, horizontalAlignment: .center, backHandler: gameState.state == .mainmenu ? nil : ({
            switch gameState.state {
            case .mainmenu:
                break
            case .selecting, .selectingMeta, .designing, .designingMeta, .playing:
                gameState.state = .mainmenu
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                LevelSelectView(levelDesignerViewModel: levelDesignerViewModel)
            case .designing:
                LevelDesignerView(levelDesignerViewModel: levelDesignerViewModel)
            case .designingMeta:
                MetaLevelDesignerView(viewModel: gameState.getMetaLevelDesignerViewModel())
            case .playing:
                LevelPlayView(levelDesignerViewModel: levelDesignerViewModel)
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
