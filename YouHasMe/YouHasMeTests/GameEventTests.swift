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
                                                  levelName: "Test")
        XCTAssertTrue(multiLayerEvent.containsGameEvent(otherGameEvent: moveEvent))
        XCTAssertFalse(multiLayerEvent.isContainedBy(otherGameEvent: moveEvent))
        XCTAssertFalse(moveEvent.containsGameEvent(otherGameEvent: multiLayerEvent))
        XCTAssertTrue(moveEvent.isContainedBy(otherGameEvent: multiLayerEvent))
    }

    func testSameLevelDifferentTypeEvents() {
        let winEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .win), levelName: "Test")
        let moveEvent = LevelEventDecorator(wrappedEvent: GameEvent(type: .move), levelName: "Test")
        XCTAssertFalse(winEvent.isContainedBy(otherGameEvent: moveEvent))
        XCTAssertFalse(moveEvent.isContainedBy(otherGameEvent: winEvent))
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
        XCTAssertTrue(entityLevelMoveEvent.isContainedBy(otherGameEvent: levelEntityMoveEvent))
        XCTAssertTrue(entityLevelMoveEvent.containsGameEvent(otherGameEvent: levelEntityMoveEvent))
        XCTAssertTrue(levelEntityMoveEvent.isContainedBy(otherGameEvent: entityLevelMoveEvent))
        XCTAssertTrue(levelEntityMoveEvent.containsGameEvent(otherGameEvent: entityLevelMoveEvent))

        let entityWrappedEvent = EntityEventDecorator(wrappedEvent: entityLevelMoveEvent,
                                                      entityType: EntityTypes.NounInstances.box)
        XCTAssertTrue(entityWrappedEvent.containsGameEvent(otherGameEvent: entityLevelMoveEvent))
        XCTAssertFalse(entityWrappedEvent.isContainedBy(otherGameEvent: entityLevelMoveEvent))
    }
}