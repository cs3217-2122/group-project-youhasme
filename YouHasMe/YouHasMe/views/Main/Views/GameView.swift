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
            case .selecting, .selectingMeta, .designing, .designingMeta, .playing, .playingMeta, .roomselection,
                    .selectingOnlineMeta, .multiplayerMetaLevel, .multiplayerLevel, .selectingOnlineLevel:
                gameState.stateStack.removeLast()
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                LevelSelectView(levelDesignerViewModel: gameState.getLevelDesignerViewModel())
            case .selectingMeta:
                MetaLevelSelectView(viewModel: gameState.getMetaLevelSelectViewModel())
            
            case .designing:
                LevelDesignerView(levelDesignerViewModel: gameState.getLevelDesignerViewModel())
            case .designingMeta:
                MetaLevelDesignerView(viewModel: gameState.getMetaLevelDesignerViewModel())
            case .playing:
                LevelPlayView(levelDesignerViewModel: gameState.getLevelPlayViewModel())
            case .playingMeta:
                MetaLevelPlayView(viewModel: gameState.getMetaLevelPlayViewModel())
            case .roomselection:
                RoomListView(viewModel: gameState.getRoomListViewModel())
            case .selectingOnlineMeta:
                OnlineMetaLevelSelectionView(viewModel: gameState.getOnlineMetaLevelSelectViewModel())
            case .selectingOnlineLevel:
                OnlineLevelRoomSelection(viewModel: gameState.getLevelRoomListViewModel())
            case .multiplayerMetaLevel:
                MetaLevelPlayView(viewModel: gameState.getMultiplayerMetaLevelViewModel())
            case .multiplayerLevel:
                MultiplayerLevelView(viewModel: gameState.getMultiplayerLevelViewModel())
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
