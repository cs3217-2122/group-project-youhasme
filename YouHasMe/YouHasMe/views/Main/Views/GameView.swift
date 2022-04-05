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
            case .selecting, .designing, .playing:
                gameState.stateStack.removeLast()
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                DungeonSelectView(viewModel: gameState.getSelectViewModel())
            
            case .designing:
                DesignerView(viewModel: gameState.getDesignerViewModel())
            
            case .playing:
                PlayView(viewModel: gameState.getPlayViewModel())
            
            }
        }
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
