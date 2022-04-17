//
//  GameView.swift
//  YouHasMe
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        NavigationFrame(
            backHandler: gameState.state == .mainmenu || gameState.state == .choosingDimensions ? nil : ({
            switch gameState.state {
            case .mainmenu, .choosingDimensions:
                break
            case .selecting, .designing, .playing, .achievements, .multiplayerEntry, .multiplayer:
                gameState.stateStack.removeLast()
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                DungeonSelectView(viewModel: gameState.getSelectViewModel())
            case .choosingDimensions:
                DimensionSelectView(viewModel: gameState.getDimensionSelectViewModel())
            case .designing:
                DesignerView(viewModel: gameState.getDesignerViewModel())
            case .playing:
                PlayView(viewModel: gameState.getPlayViewModel())
            case .achievements:
                AchievementMainView(achievementsViewModel: gameState.getAchievementsViewModel())
            case .multiplayerEntry:
                MultiplayerEntryView()
            case .multiplayer:
                MultiplayerRoomView(viewModel: gameState.getMultiplayerRoomViewModel())
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
