//
//  LevelSelectorView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import SwiftUI
struct LevelSelectorView: View {
    @ObservedObject var viewModel: LevelSelectorViewModel
    var body: some View {
        NavigationView {
            List(viewModel.loadableLevels, selection: $viewModel.selectedLevelId) { loadable in
                Text(loadable.name)
            }.navigationTitle("Level")
                .toolbar {
                    EditButton()
                }
        }
        
        Button("Confirm") {
            viewModel.confirmSelectLevel()
        }.disabled(viewModel.selectedLevelId == nil)
        
    }
}
