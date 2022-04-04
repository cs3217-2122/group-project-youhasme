//
//  MetaLevelSelectorViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
protocol MetaLevelSelectorViewModelDelegate: AnyObject {
    func selectMetaLevel(_ loadable: Loadable)
}

class MetaLevelSelectorViewModel: ObservableObject {
    weak var delegate: MetaLevelSelectorViewModelDelegate?
    private var levelStorage = MetaLevelStorage()
    @Published var selectedMetaLevelId: String?
    var loadableLevels: [Loadable]

    init() {
        loadableLevels = levelStorage.getAllLoadables()
    }

    func confirmSelectMetaLevel() {
        guard let selectedMetaLevelId = selectedMetaLevelId else {
            return
        }

        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        guard let loadable = loadableLevels.first(where: { $0.id == selectedMetaLevelId }) else {
            fatalError("should not be nil")
        }

        delegate.selectMetaLevel(loadable)
    }
}
