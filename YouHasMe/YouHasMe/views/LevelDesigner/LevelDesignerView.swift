//
//  LevelDesignerView.swift
//  YouHasMe
//

import SwiftUI

struct LevelDesignerView: View {
    @StateObject var levelDesignerViewModel = LevelDesignerViewModel(currLevel: Level())
    var body: some View {
        VStack {
            PaletteView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            GameGridView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
        }
    }
}

struct LevelDesignerView_Previews: PreviewProvider {
    static var previews: some View {
        LevelDesignerView()
    }
}
