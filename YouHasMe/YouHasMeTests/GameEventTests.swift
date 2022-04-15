//
//  GameEventTests.swift
//  YouHasMeTests
//
//  Created by Neo Jing Xuan on 3/4/22.
//

import XCTest
@testable import YouHasMe

class GameEventTests: XCTestCase {
    func testSameSingleLayerEvent() {
        let moveEvent1 = GameEvent(type: .move)
        let moveEvent2 = GameEvent(type: .move)
        XCTAssertTrue(moveEvent1.containsGameEvent(otherGameEvent: moveEvent2))
        XCTAssertTrue(moveEvent1.isContainedBy(otherGameEvent: moveEvent2))
        XCTAssertTrue(moveEvent2.containsGameEvent(otherGameEvent: moveEvent1))
        XCTAssertTrue(moveEvent2.isContainedBy(otherGameEvent: moveEvent1))
    }

    func testDifferentSingleLayerEvent() {
        let moveEvent = GameEvent(type: .move)
        let winEvent = GameEvent(type: .win)
        XCTAssertFalse(moveEvent.containsGameEvent(otherGameEvent: winEvent))
        XCTAssertFalse(moveEvent.isContainedBy(otherGameEvent: winEvent))
        XCTAssertFalse(winEvent.containsGameEvent(otherGameEvent: moveEvent))
        XCTAssertFalse(winEvent.isContainedBy(otherGameEvent: moveEvent))
    }

    func testMultiSingleLayerEvents() {
        let moveEvent = GameEvent(type: .move)
        let multiLayerEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .move),
                                                  levelId: Point(x: 0, y: 0))
        XCTAssertTrue(multiLayerEvent.containsGameEvent(otherGameEvent: moveEvent))
        XCTAssertFalse(multiLayerEvent.isContainedBy(otherGameEvent: moveEvent))
        XCTAssertFalse(moveEvent.containsGameEvent(otherGameEvent: multiLayerEvent))
        XCTAssertTrue(moveEvent.isContainedBy(otherGameEvent: multiLayerEvent))
    }

    func testSameLevelDifferentTypeEvents() {
        let winEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .win), levelId: Point(x: 0, y: 0))
        let moveEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .move), levelId: Point(x: 0, y: 0))
        XCTAssertFalse(winEvent.isContainedBy(otherGameEvent: moveEvent))
        XCTAssertFalse(moveEvent.isContainedBy(otherGameEvent: winEvent))
    }

    func testSameMultiMultiLayerEvents() {
        // testing different order of decorators
        let entityLevelMoveEvent = EntityEventDecorator(
            wrappedEvent: LevelEventDecorator(wrappedEvent: GameEvent(type: .move), levelId: Point(x: 0, y: 0)),
            entityType: EntityTypes.NounInstances.baba)
        let levelEntityMoveEvent = LevelEventDecorator(
            wrappedEvent: EntityEventDecorator(wrappedEvent: GameEvent(type: .move),
                                               entityType: EntityTypes.NounInstances.baba),
            levelId: Point(x: 0, y: 0))
        XCTAssertTrue(entityLevelMoveEvent.isContainedBy(otherGameEvent: levelEntityMoveEvent))
        XCTAssertTrue(entityLevelMoveEvent.containsGameEvent(otherGameEvent: levelEntityMoveEvent))
        XCTAssertTrue(levelEntityMoveEvent.isContainedBy(otherGameEvent: entityLevelMoveEvent))
        XCTAssertTrue(levelEntityMoveEvent.containsGameEvent(otherGameEvent: entityLevelMoveEvent))

        let entityWrappedEvent = EntityEventDecorator(wrappedEvent: entityLevelMoveEvent,
                                                      entityType: EntityTypes.NounInstances.box)
        XCTAssertTrue(entityWrappedEvent.containsGameEvent(otherGameEvent: entityLevelMoveEvent))
        XCTAssertFalse(entityWrappedEvent.isContainedBy(otherGameEvent: entityLevelMoveEvent))
    }

    func testDungeonEvent() {
        // testing different order of decorators
        let entityDungeonMoveEvent = EntityEventDecorator(
            wrappedEvent: DungeonEventDecorator(wrappedEvent: GameEvent(type: .move), dungeonId: "Dungeon1"),
            entityType: EntityTypes.NounInstances.baba)
        let dungeonEntityMoveEvent = DungeonEventDecorator(
            wrappedEvent: EntityEventDecorator(wrappedEvent: GameEvent(type: .move),
                                               entityType: EntityTypes.NounInstances.baba),
            dungeonId: "Dungeon1")
        XCTAssertTrue(entityDungeonMoveEvent.isContainedBy(otherGameEvent: dungeonEntityMoveEvent))
        XCTAssertTrue(entityDungeonMoveEvent.containsGameEvent(otherGameEvent: dungeonEntityMoveEvent))
        XCTAssertTrue(dungeonEntityMoveEvent.isContainedBy(otherGameEvent: entityDungeonMoveEvent))
        XCTAssertTrue(dungeonEntityMoveEvent.containsGameEvent(otherGameEvent: entityDungeonMoveEvent))
    }
}
