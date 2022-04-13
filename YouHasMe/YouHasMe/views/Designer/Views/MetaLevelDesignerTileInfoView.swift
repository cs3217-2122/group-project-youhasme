//
//  MetaLevelDesignerTileInfoView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct DesignerTileInfoView: View {
    @ObservedObject var viewModel: DesignerTileInfoViewModel
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(0..<viewModel.tile.entities.count, id: \.self) { index in
                    VStack {
                        let entity = viewModel.tile.entities[index]
                        Text(String.init(describing: entity))
                        EntityView(viewModel: viewModel.getTileViewModel())
                            .frame(height: 100, alignment: .leading)
                    }
                }
            }
            
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
          )
          .background(Color.black.opacity(0.7))
    }
}
