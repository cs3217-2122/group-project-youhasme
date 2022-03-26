//
//  GameView.swift
//  YouHasMe
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject var levelDesignerViewModel = LevelDesignerViewModel()
    @StateObject var metaLevelDesignerViewModel = MetaLevelDesignerViewModel()

    var body: some View {
        NavigationFrame(verticalAlignment: .middle, horizontalAlignment: .middle, backHandler: {
            switch gameState.state {
            case .mainmenu:
                break
            case .selecting, .selectingMeta, .designing, .designingMeta, .playing:
                gameState.state = .mainmenu
            }
        }) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                LevelSelectionView(levelDesignerViewModel: levelDesignerViewModel)
            case .designing:
                LevelDesignerView(levelDesignerViewModel: levelDesignerViewModel)
            case .designingMeta:
                MetaLevelDesignerView(viewModel: metaLevelDesignerViewModel)
            case .playing:
                LevelPlayView(levelDesignerViewModel: levelDesignerViewModel)
            case .selectingMeta:
                // TODO
                LevelSelectionView(levelDesignerViewModel: levelDesignerViewModel)
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
