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
        try super.setUpWithError()
    }

    func testSingleUndo() throws {
        gameEngine.apply(action: .moveDown)
        print(gameEngine.currentGame.levelLayer)
        XCTAssertEqual(gameEngine.currentGame.levelLayer.getTileAt(x: 2, y: 4).entities.count, 1)
        gameEngine.undo()
        XCTAssertEqual(gameEngine.currentGame.levelLayer.getTileAt(x: 2, y: 4).entities.count, 0)
        XCTAssertEqual(gameEngine.currentGame.levelLayer.getTileAt(x: 2, y: 3).entities.count, 1)
    }

    func testMultipleUndo() throws {
        let state0 = levelLayer
        gameEngine.apply(action: .moveUp)
        let state1 = gameEngine.currentGame.levelLayer
        gameEngine.apply(action: .moveRight)
        let state2 = gameEngine.currentGame.levelLayer
        gameEngine.apply(action: .moveDown)

        gameEngine.undo()
        XCTAssertEqual(gameEngine.currentGame.levelLayer, state2)

        gameEngine.undo()
        XCTAssertEqual(gameEngine.currentGame.levelLayer, state1)

        gameEngine.undo()
        XCTAssertEqual(gameEngine.currentGame.levelLayer, state0)
    }

    func testMultipleSameStateUndo() throws {
        gameEngine.apply(action: .moveDown)
        // test that if user doesn't move for a few ticks, undo still returns previous state
        // with changes, not just the same state
        gameEngine.apply(action: .tick)
        gameEngine.apply(action: .tick)
        gameEngine.apply(action: .tick)
        XCTAssertEqual(gameEngine.currentGame.levelLayer.getTileAt(x: 2, y: 4).entities.count, 1)
        gameEngine.undo()
        XCTAssertEqual(gameEngine.currentGame.levelLayer.getTileAt(x: 2, y: 4).entities.count, 0)
        XCTAssertEqual(gameEngine.currentGame.levelLayer.getTileAt(x: 2, y: 3).entities.count, 1)
    }

    func testUndoAtOldestLayer() throws {
        let oldestLayer = levelLayer
        gameEngine.apply(action: .moveDown)
        gameEngine.undo()
        gameEngine.undo()
        gameEngine.undo()
        XCTAssertEqual(gameEngine.currentGame.levelLayer, oldestLayer)
    }
}
