//
//  DungeonDesignerPaletteView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI

struct PaletteView: View {
    @ObservedObject var viewModel: DesignerViewModel
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.getPaletteEntityViewModels(), id: \.self) { paletteEntityViewModel in
                        PaletteEntityView(viewModel: paletteEntityViewModel)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.getPlayerEntityViewModels(), id: \.self) { playerEntityViewModel in
                        PaletteEntityView(viewModel: playerEntityViewModel)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            
            Stepper(value: $viewModel.dungeon.numberOfPlayers, step: 1) {
                Text("Num Players: \(viewModel.dungeon.numberOfPlayers)")
            }
        }
        
    }
}
