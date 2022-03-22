//
//  LevelDesignerView.swift
//  YouHasMe
//

import SwiftUI

struct LevelDesignerView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    var body: some View {
        VStack {
            PaletteView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            GameGridView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            LevelEditRowView(viewModel: levelDesignerViewModel)
                .padding()
        }
    }
}

// struct LevelDesignerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LevelDesignerView()
//    }
// }
