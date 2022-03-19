//
//  GameEngineTests.swift
//  YouHasMeTests
//
//  Created by wayne on 20/3/22.
//

import XCTest
@testable import YouHasMe

class GameEngineTests: XCTestCase {

    func test() throws {
        var levelLayer = LevelLayer(dimensions: Rectangle(width: 5, height: 5))
        levelLayer.add(entity: Entity(entityType: EntityTypes.Nouns.baba), x: 0, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Verbs.vIs), x: 1, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.Properties.you), x: 2, y: 0)
        levelLayer.add(entity: Entity(entityType: EntityTypes.NounInstances.baba), x: 2, y: 3)
        levelLayer = RuleEngine().applyRules(to: levelLayer)
        print(levelLayer)
        var ge = GameEngine(levelLayer: levelLayer)
        ge.update(action: .moveDown)
        print(ge.levelLayer)
    }
}
