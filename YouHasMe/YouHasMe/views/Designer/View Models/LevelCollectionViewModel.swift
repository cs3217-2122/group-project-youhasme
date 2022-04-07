//
//  LevelCollectionViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 7/4/22.
//

import Foundation
import CoreGraphics

struct LevelMetadata: Identifiable {
    var id: Point
    var name: String
}

class LevelCollectionViewModel: ObservableObject {
    var dungeonDimensions: Rectangle
    var levelNames: [LevelMetadata]
    var itemsPerRow: CGFloat {
        CGFloat(dungeonDimensions.width)
    }

    init(dungeonDimensions: Rectangle, levelNames: [LevelMetadata]) {
        self.dungeonDimensions = dungeonDimensions
        self.levelNames = levelNames
    }

}
