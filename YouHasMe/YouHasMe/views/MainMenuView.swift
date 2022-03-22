//
//  MainMenuView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 20/3/22.
//

import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameState: GameState
    var body: some View {
        VStack {
            Text("You Has Me")
                .font(.largeTitle)
                .padding()
            Button(action: {
                gameState.state = .selecting
            }) {
                Text("Select A Level")
                    .font(.title2)
            }.padding()
            Button(action: {
                gameState.state = .designing
            }) {
                Text("Design A Level")
                    .font(.title2)
            }.padding()
        }.padding()
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
