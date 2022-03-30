//
//  IntegerViewTranslatable.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
import CoreGraphics

protocol IntegerViewTranslatable: AnyObject {
    var cumulativeTranslation: CGVector { get set }
    var viewPosition: Point { get set }
    var viewableDimensions: Rectangle { get }
    func getViewableRegion() -> PositionedRectangle
    func getWorldPosition(at viewOffset: Vector) -> Point
    func translateView(by offset: CGVector)
    func endTranslateView()
}

extension IntegerViewTranslatable {
    func getViewableRegion() -> PositionedRectangle {
        PositionedRectangle(rectangle: viewableDimensions, topLeft: viewPosition)
    }

    func applyCumulativeTranslationToViewPosition() {
        let floor = cumulativeTranslation.absoluteFloor()
        guard floor != .zero else {
            return
        }
        viewPosition = viewPosition.translate(by: floor)
        cumulativeTranslation = cumulativeTranslation.subtract(with: CGVector(floor))
    }

    func endTranslateView() {
        cumulativeTranslation = .zero
    }

    func translateView(by offset: CGVector) {
        cumulativeTranslation = cumulativeTranslation.add(with: offset)
    }

    func getWorldPosition(at viewOffset: Vector) -> Point {
        viewPosition.translate(by: viewOffset)
    }
}
