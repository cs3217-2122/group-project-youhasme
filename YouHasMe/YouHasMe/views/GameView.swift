//
//  GameView.swift
//  YouHasMe
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @StateObject var levelDesignerViewModel = LevelDesignerViewModel(currLevel: Level())
    var body: some View {
        switch gameState.state {
        case ScreenState.mainmenu:
             MainMenuView()
        case ScreenState.selecting:
             LevelSelectionView(levelDesignerViewModel: levelDesignerViewModel)
        case ScreenState.designing:
             LevelDesignerView(levelDesignerViewModel: levelDesignerViewModel)
        case ScreenState.playing:
             LevelPlayView(levelDesignerViewModel: levelDesignerViewModel)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
