//
//  MetaLevelSelectorView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import SwiftUI
struct MetaLevelSelectorView: View {
    @ObservedObject var viewModel: MetaLevelSelectorViewModel
    var body: some View {
        NavigationView {
            List(viewModel.loadableLevels, selection: $viewModel.selectedMetaLevelId) { loadable in
                Text(loadable.name).foregroundColor(.white)
            }.navigationTitle("Level")
                .toolbar {
                    EditButton()
                }
        }
        
        Button("Confirm") {
            viewModel.confirmSelectMetaLevel()
        }.disabled(viewModel.selectedMetaLevelId == nil)
    }
}
