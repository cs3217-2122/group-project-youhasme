//
//  GameView.swift
//  YouHasMe
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject var achievementsViewModel = AchievementsViewModel()
    @StateObject var levelDesignerViewModel = LevelDesignerViewModel()

    init() {
//        achievementsViewModel.setSubscriptionsFor(<#T##gameEventPublisher: AnyPublisher<GameEvent, Never>##AnyPublisher<GameEvent, Never>#>)
    }

    var body: some View {
        NavigationFrame(verticalAlignment: .center, horizontalAlignment: .center, backHandler: gameState.state == .mainmenu ? nil : ({
            switch gameState.state {
            case .mainmenu:
                break
            case .selecting, .selectingMeta, .designing, .designingMeta, .playing, .achievements:
                gameState.state = .mainmenu
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                LevelSelectView(levelDesignerViewModel: levelDesignerViewModel, achievementsViewModel: achievementsViewModel)
            case .designing:
                LevelDesignerView(levelDesignerViewModel: levelDesignerViewModel, achievementsViewModel: achievementsViewModel)
            case .designingMeta:
                MetaLevelDesignerView(viewModel: gameState.getMetaLevelDesignerViewModel())
            case .playing:
                LevelPlayView(levelDesignerViewModel: levelDesignerViewModel, achievementsViewModel: achievementsViewModel)
            case .selectingMeta:
                MetaLevelSelectView(viewModel: gameState.getMetaLevelSelectViewModel())
            case .achievements:
                AchievementMainView(achievementsViewModel: achievementsViewModel)
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
