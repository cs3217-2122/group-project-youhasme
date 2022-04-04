//
//  LevelSelectorViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
protocol LevelSelectorViewModelDelegate: AnyObject {
    func selectLevel(_ loadable: Loadable)
}

class LevelSelectorViewModel: ObservableObject {
    weak var delegate: LevelSelectorViewModelDelegate?
    private var levelStorage = LevelStorage()
    @Published var selectedLevelId: String?
    var loadableLevels: [Loadable]

    init() {
        loadableLevels = levelStorage.getAllLoadables()
    }

    func confirmSelectLevel() {
        guard let selectedLevelId = selectedLevelId else {
            return
        }

        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard let loadable = loadableLevels.first(where: { $0.id == selectedLevelId }) else {
            fatalError("should not be nil")
        }

        delegate.selectLevel(loadable)
    }
}
