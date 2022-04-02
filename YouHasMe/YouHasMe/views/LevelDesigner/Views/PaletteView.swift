//
//  PaletteView.swift
//  YouHasMe
//

import SwiftUI

struct PaletteView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(levelDesignerViewModel.availableEntityTypes, id: \.self) { entityType in
                    EntityView(viewModel: levelDesignerViewModel.getTileViewModel(for: entityType))
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            levelDesignerViewModel.selectEntityType(type: entityType)
                        }
                        .border(levelDesignerViewModel.selectedEntityType == entityType ? .red : .black)
                }
            }
        }
    }
}

// struct PaletteView_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteView()
//    }
// }
