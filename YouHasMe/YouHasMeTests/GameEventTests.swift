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
        XCTAssertTrue(moveEvent1.containsGameEvent(event: moveEvent2))
        XCTAssertTrue(moveEvent1.isContainedBy(gameEvent: moveEvent2))
        XCTAssertTrue(moveEvent2.containsGameEvent(event: moveEvent1))
        XCTAssertTrue(moveEvent2.isContainedBy(gameEvent: moveEvent1))
    }

    func testDifferentSingleLayerEvent() {
        let moveEvent = GameEvent(type: .move)
        let winEvent = GameEvent(type: .win)
        XCTAssertFalse(moveEvent.containsGameEvent(event: winEvent))
        XCTAssertFalse(moveEvent.isContainedBy(gameEvent: winEvent))
        XCTAssertFalse(winEvent.containsGameEvent(event: moveEvent))
        XCTAssertFalse(winEvent.isContainedBy(gameEvent: moveEvent))
    }

    func testMultiSingleLayerEvents() {
        let moveEvent = GameEvent(type: .move)
        let multiLayerEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .move),
                                                  levelName: "Test")
        XCTAssertTrue(multiLayerEvent.containsGameEvent(event: moveEvent))
        XCTAssertFalse(multiLayerEvent.isContainedBy(gameEvent: moveEvent))
        XCTAssertFalse(moveEvent.containsGameEvent(event: multiLayerEvent))
        XCTAssertTrue(moveEvent.isContainedBy(gameEvent: multiLayerEvent))
    }

    func testSameLevelDifferentTypeEvents() {
        let winEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .win), levelName: "Test")
        let moveEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .move), levelName: "Test")
        XCTAssertFalse(winEvent.isContainedBy(gameEvent: moveEvent))
        XCTAssertFalse(moveEvent.isContainedBy(gameEvent: winEvent))
    }

    func testSameMultiMultiLayerEvents() {
        // testing different order of decorators
        let entityLevelMoveEvent = EntityEventDecorator(
            wrappedEvent: LevelEventDecorator(wrappedEvent: GameEvent(type: .move), levelName: "Test"),
            entityType: EntityTypes.NounInstances.baba)
        let levelEntityMoveEvent = LevelEventDecorator(
            wrappedEvent: EntityEventDecorator(wrappedEvent: GameEvent(type: .move),
                                               entityType: EntityTypes.NounInstances.baba),
            levelName: "Test")
        XCTAssertTrue(entityLevelMoveEvent.isContainedBy(gameEvent: levelEntityMoveEvent))
        XCTAssertTrue(entityLevelMoveEvent.containsGameEvent(event: levelEntityMoveEvent))
        XCTAssertTrue(levelEntityMoveEvent.isContainedBy(gameEvent: entityLevelMoveEvent))
        XCTAssertTrue(levelEntityMoveEvent.containsGameEvent(event: entityLevelMoveEvent))

        let entityWrappedEvent = EntityEventDecorator(wrappedEvent: entityLevelMoveEvent,
                                                      entityType: EntityTypes.NounInstances.box)
        XCTAssertTrue(entityWrappedEvent.containsGameEvent(event: entityLevelMoveEvent))
        XCTAssertFalse(entityWrappedEvent.isContainedBy(gameEvent: entityLevelMoveEvent))
    }
}
