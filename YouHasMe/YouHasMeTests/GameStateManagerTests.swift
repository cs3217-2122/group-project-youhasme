//
//  GameStateManagerTests.swift
//  YouHasMeTests
//
//  Created by Neo Jing Xuan on 20/3/22.
//

import XCTest
@testable import YouHasMe

class GameStateManagerTests: XCTestCase {
    var levelLayer: LevelLayer!
    var gameEngine: GameEngine!

    override func setUpWithError() throws {
        levelLayer = LevelLayer(dimensions: Rectangle(width: 5, height: 5))
        levelLayer.add(entity: Entity(entityType: EntityTypes.Nouns.baba), x: 0, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Verbs.vIs), x: 1, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 2, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 2, y: 3)
        levelLayer = RuleEngine().applyRules(to: levelLayer)
        gameEngine = GameEngine(levelLayer: levelLayer)
    }

    func testSingleUndo() throws {
        gameEngine.update(action: .moveDown)
        print(gameEngine.levelLayer)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 4).entities.count, 1)
        gameEngine.update(action: .undo)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 4).entities.count, 0)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 3).entities.count, 1)
    }

    func testMultipleUndo() throws {
        let state0 = levelLayer
        gameEngine.update(action: .moveUp)
        let state1 = gameEngine.levelLayer
        gameEngine.update(action: .moveRight)
        let state2 = gameEngine.levelLayer
        gameEngine.update(action: .moveDown)

        gameEngine.update(action: .undo)
        XCTAssertEqual(gameEngine.levelLayer, state2)

        gameEngine.update(action: .undo)
        XCTAssertEqual(gameEngine.levelLayer, state1)

        gameEngine.update(action: .undo)
        XCTAssertEqual(gameEngine.levelLayer, state0)
    }

    func testMultipleSameStateUndo() throws {
        gameEngine.update(action: .moveDown)
        // test that if user doesn't move for a few ticks, undo still returns previous state
        // with changes, not just the same state
        gameEngine.update(action: .tick)
        gameEngine.update(action: .tick)
        gameEngine.update(action: .tick)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 4).entities.count, 1)
        gameEngine.update(action: .undo)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 4).entities.count, 0)
        XCTAssertEqual(gameEngine.levelLayer.getTileAt(x: 2, y: 3).entities.count, 1)
    }

    func testUndoAtOldestLayer() throws {
        let oldestLayer = levelLayer
        gameEngine.update(action: .moveDown)
        gameEngine.update(action: .undo)
        gameEngine.update(action: .undo)
        gameEngine.update(action: .undo)
        XCTAssertEqual(gameEngine.levelLayer, oldestLayer)
    }
}
