//
//  PaletteEntityView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct PaletteEntityView: View {
    var viewModel: PaletteEntityViewModel
    @State var borderColor: Color = .black
    var body: some View {
        
        CellView(backupDisplayColor: .gray, viewModel: viewModel)
            .onTapGesture {
                viewModel.select()
            }
            .onReceive(viewModel.shouldHighlightPublisher, perform: { shouldHighlight in
                borderColor = shouldHighlight ? .red : .black
            })
            .border(borderColor)
    }
}
