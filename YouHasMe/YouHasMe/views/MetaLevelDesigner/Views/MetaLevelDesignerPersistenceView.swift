//
//  MetaLevelDesignerPersistenceView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI

struct MetaLevelDesignerPersistenceView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelDesignerViewModel
    @State var showSaveLevelAlert = false
    @State var saveMessage = ""
    var saveErrorMessage = "Save Error"
    @State var showSaveErrorAlert = false
    @State var showUnsavedChangesPrompt = false
    @State var loadSuccess = false

    var body: some View {
        HStack {
            Button(action: {
                guard !viewModel.hasUnsavedChanges else {
                    showUnsavedChangesPrompt = true
                    return
                }
                gameState.state = .selectingMeta
            }) {
                Text("Load")
            }.confirmationDialog("You have unsaved changes that will be lost.",
                                 isPresented: $showUnsavedChangesPrompt,
                                 titleVisibility: .visible) {
                Button("Continue") {
                    gameState.state = .selectingMeta
                }
                Button("Cancel") {
                }
            }

            Button(action: {
                do {
                    try viewModel.save()
                } catch {
                    showSaveErrorAlert = true
                }
            }) {
                Text("Save Locally")
            }.alert(isPresented: $showSaveLevelAlert) {
                Alert(title: Text(saveMessage), dismissButton: .cancel(Text("close")))
            }.alert(isPresented: $showSaveErrorAlert) {
                Alert(title: Text(saveErrorMessage), dismissButton: .cancel(Text("close")))
            }
            
            TextField("Meta Level Name", text: $viewModel.currMetaLevel.name)
                .padding([.trailing, .leading], 5.0)
                .disableAutocorrection(true)
            Spacer()
        }
        .padding([.leading, .trailing], 10.0)
    }
}

struct MetaLevelDesignerPersistenceView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelDesignerPersistenceView(
            viewModel: MetaLevelDesignerViewModel()
        )
    }
}
