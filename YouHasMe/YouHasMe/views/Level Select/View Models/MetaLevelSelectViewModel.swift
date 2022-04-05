//
//  MetaLevelSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import Foundation

class DungeonSelectViewModel: ObservableObject {
    var dungeonStorage = DungeonStorage()

    func getAllDungeons() -> [Loadable] {
        return dungeonStorage.getAllLoadables()
    }
}
