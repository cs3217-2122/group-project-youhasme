//
//  LevelDesignerView.swift
//  YouHasMe
//

import SwiftUI

struct LevelDesignerView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel

    init() {
        levelDesignerViewModel = LevelDesignerViewModel()
    }

    init(level: Level) {
        levelDesignerViewModel = LevelDesignerViewModel(currLevel: level)
    }

    var body: some View {
        VStack {
            PalletteView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            GameGridView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            LevelEditRowView(viewModel: levelDesignerViewModel)
                .padding()
        }
    }
}

struct LevelDesignerView_Previews: PreviewProvider {
    static var previews: some View {
        LevelDesignerView()
    }
}
