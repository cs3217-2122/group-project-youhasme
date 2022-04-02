//
//  UploadedMetaLevelViewModel.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 2/4/22.
//

import Foundation
import Combine

class UploadedMetaLevelSelectionViewModel: ObservableObject {
    @Published var uploadedMetaLevels : [UploadedMetaLevel] = []
    
    var metaLevelStorage = FirebaseUploadedMetaLevelStorage()
    var roomsStorage = FirebaseOpenWorldRoomStorage()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        metaLevelStorage.$uploadedMetaLevels
            .assign(to: \.uploadedMetaLevels, on: self)
            .store(in: &cancellables)
    }
    
    func createRoom(uploadedMetaLevel: UploadedMetaLevel, name: String) {
        roomsStorage.createRoom(from: uploadedMetaLevel, name: name)
    }
}
