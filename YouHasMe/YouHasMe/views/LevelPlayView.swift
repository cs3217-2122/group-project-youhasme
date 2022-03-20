//
//  LevelPlayView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 20/3/22.
//

import SwiftUI

struct LevelPlayView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    var body: some View {
        VStack {
            GameGridView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            HStack {
                Button(action: {
                    levelDesignerViewModel.resetFromPlay()
                    gameState.state = .designing
                }) {
                    Text("Back to Designing")
                }
                Spacer()
            }.padding()
        }
    }
        
}

//struct LevelPlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        LevelPlayView()
//    }
//}
