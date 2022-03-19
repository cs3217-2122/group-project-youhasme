//
//  PalletteView.swift
//  YouHasMe
//

import SwiftUI

struct PalletteView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(levelDesignerViewModel.availableEntityTypes, id: \.self) { entityType in
                    EntityView(entityType: entityType)
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

//struct PalletteView_Previews: PreviewProvider {
//    static var previews: some View {
//        PalletteView()
//    }
//}
