//
//  MetaLevelDesignerPaletteView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI

struct MetaLevelDesignerPaletteView: View {
    @ObservedObject var viewModel: MetaLevelDesignerViewModel
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(viewModel.getPaletteMetaEntityViewModels(), id: \.self) { paletteMetaEntityViewModel in
                    PaletteMetaEntityView(viewModel: paletteMetaEntityViewModel)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

struct MetaLevelDesignerPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelDesignerPaletteView(viewModel: MetaLevelDesignerViewModel())
    }
}
