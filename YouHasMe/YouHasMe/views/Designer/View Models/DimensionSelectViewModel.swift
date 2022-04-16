//
//  DimensionSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/4/22.
//

import Foundation
class DimensionSelectViewModel: ObservableObject {
    @Published var widthSelection: Int = 0
    @Published var heightSelection: Int = 0
    let widthRange = 1..<6
    let heightRange = 1..<6
    @Published var dungeonName: String = ""
    @Published var requiresOverwrite = false
    var dungeonStorage = DungeonStorage()
    func aboutToCreateLevel() {
        if dungeonStorage.existsDungeon(name: dungeonName) {
            requiresOverwrite = true
        }
    }

    func getDungeon() -> DesignableDungeon {
        do {
            try dungeonStorage.deleteDungeon(name: dungeonName)
        } catch {
            globalLogger.error("Failed to delete dungeon")
        }

        return .newDungeon(
            name: dungeonName,
            dimensions: Rectangle(
                width: widthRange.index(widthRange.startIndex, offsetBy: widthSelection),
                height: heightRange.index(heightRange.startIndex, offsetBy: heightSelection)
            )
        )
    }
}
