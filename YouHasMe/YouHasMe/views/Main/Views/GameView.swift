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
            default:
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
            case .roomSelection:
                RoomListView(viewModel: gameState.getRoomListViewModel())
            case .onlineMetaLevelSelection:
                UploadedMetaLevelSelectionView(viewModel: gameState.getUploadedMetaLevelViewModel())
            }
            
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
