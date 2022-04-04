//
//  MetaLevelDesignerTileInfoView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct MetaLevelDesignerTileInfoView: View {
    @ObservedObject var viewModel: MetaLevelDesignerTileInfoViewModel
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(0..<viewModel.metaEntities.count, id: \.self) { index in
                    VStack {
                        let metaEntity = viewModel.metaEntities[index]
                        Text(metaEntity.description)
                        MetaEntityView(viewModel: viewModel.getMetaEntityViewModel())
                            .frame(height: 100, alignment: .leading)
                        if case .level(levelLoadable: let levelLoadable, unlockCondition: _) = metaEntity {
                            if let levelLoadable = levelLoadable {
                                Text(levelLoadable.name)
                            }
                            ConditionCreatorView(
                                viewModel: viewModel.getConditionCreatorViewModel(with: index)
                            )
                        }
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
