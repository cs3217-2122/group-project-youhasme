//
//  LevelDesignerViewModel.swift
//  YouHasMe
//

import Combine
import Foundation

class LevelDesignerViewModel: GameEventPublisher, ObservableObject {

    private var levelStorage = LevelStorage()
    var levelLoadables: [Loadable] {
        levelStorage.getAllLoadables()
    }
    @Published var currLevel: Level
    @Published private(set) var currLevelLayerIndex: Int = 0
    var currLevelLayer: LevelLayer {
        get {
            currLevel.layers.getAtIndex(currLevelLayerIndex)! // TODO: Remove level layers maybe?
        }
        set {
            currLevel.layers.setAtIndex(currLevelLayerIndex, value: newValue)
        }
    }
    @Published private(set) var selectedEntityType: EntityType?
    @Published private(set) var availableEntityTypes: [EntityType] = demoTypes
    var gameEventPublisher: AnyPublisher<AbstractGameEvent, Never> {
        gameEventSubject.eraseToAnyPublisher()
    }

    private let gameEventSubject = PassthroughSubject<AbstractGameEvent, Never>()

    convenience init() {
        self.init(currLevel: Level())
    }

    convenience init(playableLevel: PlayableLevel) {
        self.init(currLevel: playableLevel.getLevel())
    }

    init(currLevel: Level) {
        self.currLevel = currLevel
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

    func getEntityTypeAtPos(point: Point) -> EntityType? {
        getEntityTypeAtPos(x: point.x, y: point.y)
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

    var unsavedChanges: Bool {
        currLevelLayer != currLevel.getLayerAtIndex(currLevelLayerIndex)
    }

    func saveLevel() -> String {
        let levelName = currLevel.name
        if levelName.isEmpty {
            return "Please input a non-empty level name."
        }

        do {
            let isExistingLevel = (levelStorage.loadLevel(name: currLevel.name) != nil)
            try levelStorage.saveLevel(currLevel)
            if !isExistingLevel {
                gameEventSubject.send(GameEvent(type: .designLevel))
            }
            return "Successfully saved level: \(levelName)"
        } catch {
            return "error saving level: \(error)"
        }
    }
}

// MARK: View model factories
extension LevelDesignerViewModel {
    func getTileViewModel(for entityType: EntityType) -> EntityViewModel {
        EntityViewModel(entityType: entityType)
    }

    func getTileViewModel(at point: Point) -> EntityViewModel {
        EntityViewModel(entityType: getEntityTypeAtPos(point: point))
    }
}
