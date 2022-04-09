//
//  DimensionSelectView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 9/4/22.
//

import SwiftUI

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
