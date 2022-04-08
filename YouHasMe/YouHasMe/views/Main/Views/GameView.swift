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
            case .selecting, .designing, .playing, .achievements:
                gameState.stateStack.removeLast()
            }
        })) {
            switch gameState.state {
            case .mainmenu:
                MainMenuView()
            case .selecting:
                DungeonSelectView(viewModel: gameState.getSelectViewModel())
            case .choosingDimensions:
                DimensionSelectView()
            case .designing:
                DesignerView(viewModel: gameState.getDesignerViewModel())
            case .playing:
                PlayView(viewModel: gameState.getPlayViewModel())
            case .achievements:
                AchievementMainView(achievementsViewModel: gameState.getAchievementsViewModel(),
                notificationsViewModel: GameNotificationsViewModel())
            }
        }
    }
}

struct DimensionSelectView: View {
    @EnvironmentObject var gameState: GameState
    @State var widthSelection: Int = 0
    @State var heightSelection: Int = 0
    let widthRange = 2..<9
    let heightRange = 2..<9
    var body: some View {
        VStack {
            Text("Dungeon Height")
            Picker("Dungeon Height", selection: $heightSelection) {
                ForEach(heightRange) {
                    Text("\($0) levels")
                }
            }.padding()

            Text("Dungeon Width")
            Picker("Dungeon Width", selection: $widthSelection) {
                ForEach(widthRange) {
                    Text("\($0) levels")
                }
            }.padding()
           
            
            Button("Confirm") {
                gameState.state = .designing(
                    designableDungeon: .newDungeonDimensions(
                        Rectangle(
                            width: widthRange.index(widthRange.startIndex, offsetBy: widthSelection),
                            height: heightRange.index(heightRange.startIndex, offsetBy: heightSelection)
                        )
                    )
                )
            }.padding()
            
            Button("Cancel") {
                gameState.state = .mainmenu
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
