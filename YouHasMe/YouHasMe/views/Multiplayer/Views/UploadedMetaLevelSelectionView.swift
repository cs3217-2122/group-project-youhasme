//
//  UploadedMetaLevelView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import SwiftUI

struct UploadedMetaLevelSelectionView: View {
    @ObservedObject var viewModel: UploadedMetaLevelSelectionViewModel
    var body: some View {
        List {
            Section(header: Text("Community Meta Levels")) {
                ForEach(viewModel.uploadedMetaLevels, id: \.self.id) { uploadedMetaLevel in
                    Button(action: {
                        
                    }) {
                        HStack {
                            Text(uploadedMetaLevel.persistedMetaLevel.name)
                            Text("Uploaded by: \(uploadedMetaLevel.uploaderId)")
                        }
                    }
                }
            }
        }
    }
}

struct UploadedMetaLevelSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UploadedMetaLevelSelectionView(viewModel: UploadedMetaLevelSelectionViewModel())
    }
}
