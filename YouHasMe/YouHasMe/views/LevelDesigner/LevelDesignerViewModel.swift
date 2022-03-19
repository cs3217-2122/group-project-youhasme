//
//  LevelDesignerViewModel.swift
//  YouHasMe
//

import Foundation

class LevelDesignerViewModel: ObservableObject {
    private var savedLevels: [Level]

    private(set) var currLevel: Level
    @Published private(set) var currLevelLayer: LevelLayer
    @Published private(set) var selectedEntityType: EntityType? = nil
    @Published private(set) var availableEntityTypes: [EntityType] = allAvailableEntityTypes

    init(currLevel: Level) {
        self.currLevel = Level()
        self.currLevelLayer = currLevel.baseLevel
        self.savedLevels = StorageUtil.loadSavedLevels()
    }

    func getWidth() -> Int  {
        return currLevelLayer.dimensions.width
    }

    func getHeight() -> Int  {
        return currLevelLayer.dimensions.height
    }

    func selectEntityType(type: EntityType) {
        selectedEntityType = type
    }

    func getEntityTypeAtPos(x: Int, y: Int) -> EntityType? {
        let tile = currLevelLayer.getTileAt(x: x, y: y)
        if tile.entities.isEmpty {
            return nil
        } else {
            return tile.entities[0].entityType
        }
    }

    func removeEntityFromPos(x: Int, y: Int) {
        var tile = currLevelLayer.getTileAt(x: x, y: y)
        tile.entities = []
        currLevelLayer.setTileAt(x: x, y: y, tile: tile)
    }

    func addEntityToPos(x: Int, y: Int) {
        guard let entityType = selectedEntityType else {
            return
        }

        let newEntity = Entity(entityType: entityType)
        var tile = currLevelLayer.getTileAt(x: x, y: y)

        guard tile.entities.isEmpty else {
            return
        }

        tile.entities.append(newEntity)
        currLevelLayer.setTileAt(x: x, y: y, tile: tile)
    }

    func reset() {
        self.currLevelLayer = LevelLayer(dimensions: currLevelLayer.dimensions)
    }

    func loadLevel(levelName: String) -> Bool {
        for level in savedLevels where level.name == levelName {
            currLevel = level
            currLevelLayer = level.baseLevel
            return true
        }

        return false
    }

    func saveLevel(levelName: String) -> String {
        if levelName.isEmpty {
            return "Please input a non-empty level name."
        }

        do {
            // TODO: updateSavedLevels, updateJsonFileSavedLevels
//            updateSavedLevels(levelName: levelName)
//            try StorageUtil.updateJsonFileSavedLevels(dataFileName: StorageUtil.defaultFileStorageName,
//                                                      savedLevels: savedLevels)
            return "Successfully saved level: \(levelName)"
        } catch {
            return "error saving level: \(error)"
        }
    }
}
