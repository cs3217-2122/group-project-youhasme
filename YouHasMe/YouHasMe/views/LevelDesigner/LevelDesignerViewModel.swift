//
//  LevelDesignerViewModel.swift
//  YouHasMe
//

import Foundation

class LevelDesignerViewModel: ObservableObject {
    private(set) var savedLevels: [Level]

    var currLevel: Level
    private(set) var currLevelLayerIndex: Int
    @Published var currLevelLayer: LevelLayer
    @Published private(set) var selectedEntityType: EntityType?
    @Published private(set) var availableEntityTypes: [EntityType] = demoTypes

    init(currLevel: Level) {
        self.currLevel = Level()
        self.currLevelLayer = currLevel.baseLevel
        self.currLevelLayerIndex = 0
        self.savedLevels = StorageUtil.loadSavedLevels()
    }

    func getWidth() -> Int {
        currLevelLayer.dimensions.width
    }

    func getHeight() -> Int {
        currLevelLayer.dimensions.height
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
        self.currLevel.resetLayerAtIndex(currLevelLayerIndex)
        self.currLevelLayer = currLevel.getLayerAtIndex(currLevelLayerIndex)
    }
    
    func selectLevel(level: Level) {
        self.currLevel = level
        self.currLevelLayer = level.baseLevel
        self.currLevelLayerIndex = 0
//        currentlySelectedLevel.dirty = false
//        state = .designing
    }
    
    func createLevel() {
        self.currLevel = Level()
        self.currLevelLayerIndex = 0
        self.currLevelLayer = self.currLevel.baseLevel

    }
    
    func resetFromPlay() {
        self.currLevelLayer = self.currLevel.baseLevel
    }

    func loadLevel(levelName: String) -> Bool {
        for level in savedLevels where level.name == levelName {
            currLevel = level
            currLevelLayer = level.baseLevel
            return true
        }

        return false
    }

    func saveLevel() -> String {
        let levelName = currLevel.name
        if levelName.isEmpty {
            return "Please input a non-empty level name."
        }

        do {
            savedLevels = getUpdatedSavedLevels(levelName: levelName)
            try StorageUtil.updateJsonFileSavedLevels(dataFileName: StorageUtil.defaultFileStorageName,
                                                      savedLevels: savedLevels)
            return "Successfully saved level: \(levelName)"
        } catch {
            return "error saving level: \(error)"
        }
    }
    
//    func playLevel() {
//        
//    }

    func getUpdatedSavedLevels(levelName: String) -> [Level] {
        // remove level with outdated data if it exists
        var updatedLevels = savedLevels.filter { $0.name != levelName }
        currLevel.setName(levelName)
        currLevel.setLevelLayerAtIndex(currLevelLayerIndex, value: currLevelLayer)
        updatedLevels.append(currLevel)
        return updatedLevels
    }
}
