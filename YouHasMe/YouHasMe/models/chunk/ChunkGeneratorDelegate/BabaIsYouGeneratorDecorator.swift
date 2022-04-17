//
//  BabaGeneratorDecorator.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 7/4/22.
//

import Foundation
final class BabaIsYouGeneratorDecorator: IdentityGeneratorDecorator {
    var nounIsPropertyGenerator = NounIsPropertyRuleGenerator(
        noun: .baba, property: .you, shouldGenerateNounInstance: true
    )

    override func generate(dimensions: Rectangle, levelPosition: Point, extremities: Rectangle) -> [[Tile]] {
        var tiles = super.generate(
            dimensions: dimensions, levelPosition: levelPosition, extremities: extremities
        )

        tiles = nounIsPropertyGenerator.generate(
            dimensions: dimensions, levelPosition: levelPosition, extremities: extremities, tiles: tiles
        )

        return tiles
    }
}
