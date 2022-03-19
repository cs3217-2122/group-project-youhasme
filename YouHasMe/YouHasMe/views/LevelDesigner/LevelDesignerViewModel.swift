//
//  LevelDesignerViewModel.swift
//  YouHasMe
//

import Foundation

class LevelDesignerViewModel: ObservableObject {
    var currLevel: Level
    @Published var currLevelLayer: LevelLayer
    @Published var selectedEntityType: EntityType? = nil
    @Published var availableEntityTypes: [EntityType] = allAvailableEntityTypes
    
    init(currLevel: Level) {
        self.currLevel = Level()
        self.currLevelLayer = LevelLayer(dimensions: Rectangle(width: 30, height: 30))
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
            return tile.entities[0].classification
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
        
        let newEntity = Entity(classification: entityType)
        var tile = currLevelLayer.getTileAt(x: x, y: y)
        
        guard tile.entities.isEmpty else {
            return
        }
        
        tile.entities.append(newEntity)
        currLevelLayer.setTileAt(x: x, y: y, tile: tile)
    }
}
