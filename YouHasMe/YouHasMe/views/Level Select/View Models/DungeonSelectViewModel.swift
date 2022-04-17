//
//  MetaLevelSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import Foundation

class DungeonSelectViewModel: ObservableObject {
    var dungeonStorage = DungeonStorage()
    var dungeonOnlineStorage = OnlineDungeonStorage()

    func getAllDungeons() -> [Loadable] {
        dungeonStorage.getAllLoadables()
    }

    func upload(loadable: Loadable) {
        guard let dungeon = dungeonStorage.loadDungeon(name: loadable.name) else {
            return
        }
        do {
            try dungeonOnlineStorage.upload(dungeon: dungeon)
        } catch {
            print("Failed upload")
        }
    }
}
