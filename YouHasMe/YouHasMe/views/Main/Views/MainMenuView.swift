//
//  MainMenuView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 20/3/22.
//

import SwiftUI

struct MainMenuView: View {
    private let titleFont: Font = .largeTitle
    private let transitionButtonFont: Font = .title2
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack {
            Text("You Has Me")
                .font(titleFont)
                .padding()
            Group {
                Button(action: {
                    gameState.state = .selecting
                }) {
                    Text("Dungeon Select")
                }.padding()
                Button(action: {
                    gameState.state = .choosingDimensions
                }) {
                    Text("Design")
                }.padding()
                Button(action: {
                    gameState.state = .achievements
                }) {
                    Text("View Achievements")
                }.padding()
            }.font(transitionButtonFont)
        }.padding()
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
