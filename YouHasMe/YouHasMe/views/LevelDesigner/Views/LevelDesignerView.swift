//
//  LevelDesignerView.swift
//  YouHasMe
//

import SwiftUI

struct LevelDesignerView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    
    var body: some View {
        VStack {
            PaletteView(levelDesignerViewModel: levelDesignerViewModel)
                .padding()
            GameGridView(levelDesignerViewModel: levelDesignerViewModel, achievementsViewModel: achievementsViewModel)
            
                .padding()
            LevelPersistenceView(viewModel: levelDesignerViewModel)
                .padding()
        }.onAppear {
            achievementsViewModel.setSubscriptionsFor(levelDesignerViewModel.gameEventPublisher)
        }
    }
}

// struct LevelDesignerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LevelDesignerView()
//    }
// }
