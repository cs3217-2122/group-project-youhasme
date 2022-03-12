import Foundation

class MetaLevel {
    var layer: MetaLevelLayer
    init(layer: MetaLevelLayer) {
        self.layer = layer
    }
}

protocol LevelLayerDelegate: AnyObject {
    var dimensions: Rectangle { get }
}

class AbstractLevelLayer {
    weak var delegate: LevelLayerDelegate?
    
    var tiles: [Tile] = []
    func getTileAt(x: Int, y: Int) -> Tile {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        return tiles[x + y * delegate.dimensions.width]
    }
}

class MetaLevelLayer: AbstractLevelLayer {
    var outlets: [Outlet] = []
}
