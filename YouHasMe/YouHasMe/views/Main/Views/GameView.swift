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
            case .selecting, .selectingMeta, .designing, .designingMeta, .playing, .playingMeta, .achievements:
                gameState.stateStack.removeLast()
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                LevelSelectView(levelDesignerViewModel: gameState.getLevelDesignerViewModel(),
                                achievementsViewModel: gameState.getAchievementsViewModel())
            case .selectingMeta:
                MetaLevelSelectView(viewModel: gameState.getMetaLevelSelectViewModel())
            
            case .designing:
                LevelDesignerView(levelDesignerViewModel: gameState.getLevelDesignerViewModel(),
                                  achievementsViewModel: gameState.getAchievementsViewModel())
            case .designingMeta:
                MetaLevelDesignerView(viewModel: gameState.getMetaLevelDesignerViewModel())
            case .playing:
                LevelPlayView(levelDesignerViewModel: gameState.getLevelPlayViewModel(),
                              achievementsViewModel: gameState.getAchievementsViewModel())
            case .playingMeta:
                MetaLevelPlayView(viewModel: gameState.getMetaLevelPlayViewModel())
            case .achievements:
                AchievementMainView(achievementsViewModel: gameState.getAchievementsViewModel())
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
