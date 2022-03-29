//
//  GameEngineTests.swift
//  YouHasMeTests
//
//  Created by wayne on 20/3/22.
//

import XCTest
@testable import YouHasMe

class GameEngineTests: XCTestCase {

    func testSimple() throws {
        var levelLayer = LevelLayer(dimensions: Rectangle(width: 5, height: 5))
        levelLayer.add(entity: Entity(entityType: EntityTypes.Nouns.baba), x: 0, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Verbs.vIs), x: 1, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 2, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 2, y: 3)
        levelLayer = RuleEngine().applyRules(to: levelLayer)
        // print(levelLayer)
        var gameEngine = GameEngine(levelLayer: levelLayer)
        gameEngine.step(action: .moveDown)
        // print(gameEngine.levelLayer)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 4).entities.count, 1)
    }

    func testComplex() throws {
        var levelLayer = LevelLayer(dimensions: Rectangle(width: 5, height: 5))
        levelLayer.add(entity: Entity(entityType: EntityTypes.Nouns.baba), x: 0, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Verbs.vIs), x: 1, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 2, y: 0)

        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 2, y: 1)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 3, y: 1)
        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 4, y: 1)

        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 2, y: 2)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 3, y: 2)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 4, y: 2)

        levelLayer = RuleEngine().applyRules(to: levelLayer)
        // print(levelLayer)
        var gameEngine = GameEngine(levelLayer: levelLayer)
        gameEngine.step(action: .moveRight)
        // print(gameEngine.levelLayer)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 4, y: 1).entities.count, 2)
    }

    func testWin() throws {
        var levelLayer = LevelLayer(dimensions: Rectangle(width: 5, height: 5))
        levelLayer.add(entity: Entity(entityType: EntityTypes.Nouns.baba), x: 0, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Verbs.vIs), x: 1, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 2, y: 0)

        levelLayer.add(entity: Entity(entityType: EntityTypes.Nouns.flag), x: 0, y: 1)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Verbs.vIs), x: 1, y: 1)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.win), x: 2, y: 1)

        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.flag), x: 2, y: 3)
        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 2, y: 3)

        levelLayer = RuleEngine().applyRules(to: levelLayer)
        // print(levelLayer)
        var gameEngine = GameEngine(levelLayer: levelLayer)
        gameEngine.step(action: .tick)
        XCTAssertEqual(gameEngine.gameStatus, .win)
    }
}
