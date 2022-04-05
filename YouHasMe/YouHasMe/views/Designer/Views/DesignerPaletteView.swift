//
//  DungeonDesignerPaletteView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI

struct DesignerPaletteView: View {
    @ObservedObject var viewModel: DesignerViewModel
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.getPaletteEntityViewModels(), id: \.self) { paletteEntityViewModel in
                    PaletteEntityView(viewModel: paletteEntityViewModel)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}
