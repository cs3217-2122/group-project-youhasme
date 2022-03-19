import XCTest
@testable import YouHasMe

fileprivate class SimpleLevelLayerDelegate: LevelLayerDelegate {
    var dimensions: Rectangle
    init(dimensions: Rectangle) {
        self.dimensions = dimensions
    }
}

class LevelLayerTests: XCTestCase {
    var dimensions: Rectangle!
    fileprivate var levelLayerDelegate: SimpleLevelLayerDelegate!
    var levelLayer: LevelLayer!
    var ruleParser = RuleParser()
    
    override func setUpWithError() throws {
        dimensions = Rectangle(width: 6, height: 6)
        levelLayer = LevelLayer()
        levelLayerDelegate = SimpleLevelLayerDelegate(dimensions: dimensions)
        levelLayer.delegate = levelLayerDelegate
    }

    override func tearDownWithError() throws {
        dimensions = nil
        levelLayerDelegate = nil
        levelLayer = nil
    }

    func testParse() throws {
        levelLayer.tiles = Array(repeatingFactory: {Tile()}, count: dimensions.numCells)
        levelLayer.tiles[0].entities.append(Entity(entityType: EntityTypes.Nouns.baba))
        levelLayer.tiles[1].entities.append(Entity(entityType: EntityTypes.Verbs.vIs))
        levelLayer.tiles[2].entities.append(Entity(entityType: EntityTypes.Properties.you))
        levelLayer.tiles[3].entities.append(Entity(entityType: EntityTypes.Connectives.and))
        levelLayer.tiles[4].entities.append(Entity(entityType: EntityTypes.Nouns.wall))
        levelLayer.tiles[6].entities.append(Entity(entityType: EntityTypes.Verbs.vHas))
        levelLayer.tiles[12].entities.append(Entity(entityType: EntityTypes.Nouns.skull))
        levelLayer.tiles[13].entities.append(Entity(entityType: EntityTypes.Verbs.vIs))
        levelLayer.tiles[14].entities.append(Entity(entityType: EntityTypes.Nouns.flag))
        levelLayer.tiles[15].entities.append(Entity(entityType: EntityTypes.Connectives.and))
        levelLayer.tiles[16].entities.append(Entity(entityType: EntityTypes.Verbs.vHas))
        levelLayer.tiles[17].entities.append(Entity(entityType: EntityTypes.Nouns.wall))
        let rules = ruleParser.parse(block: levelLayer.getAbstractRepresentation())
        print(rules)
    }
}
