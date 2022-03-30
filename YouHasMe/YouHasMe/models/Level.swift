import Foundation

struct Level {
    var name: String
    private(set) var layers: BidirectionalArray<LevelLayer>

    init(name: String = "") {
        self.name = name
        layers = BidirectionalArray()
        layers.append(LevelLayer(dimensions: Rectangle(width: 10, height: 10)))
    }

    /// Level zero.
    var baseLevel: LevelLayer {
        getLayerAtIndex(0)
    }

    mutating func resetLayerAtIndex(_ index: Int) {
        guard let originalLayer = layers.getAtIndex(index) else {
            assert(false, "Level does not have layer at index \(index)")
        }

        let emptyLayer = LevelLayer(dimensions: originalLayer.dimensions)
        layers.setAtIndex(index, value: emptyLayer)
    }

    mutating func setName(_ name: String) {
        self.name = name
    }

    mutating func setLevelLayerAtIndex(_ index: Int, value: LevelLayer) {
        layers.setAtIndex(index, value: value)
    }

    func getLayerAtIndex(_ index: Int) -> LevelLayer {
        guard let layer = layers.getAtIndex(index) else {
            assert(false, "Level does not have layer at index \(index)")
        }

        return layer
    }
}

extension Level: Identifiable {
    var id: String {
        name
    }
}

extension Level: KeyPathExposable {
    typealias PathRoot = Level
    
    static var exposedNumericKeyPaths: [String: KeyPath<Level, Int>] {
        [
            "Name length": \.name.count
        ]
    }
    
    func evaluate(given keyPath: NamedKeyPath<Level, Int>) -> Int {
        self[keyPath: keyPath.keyPath]
    }
}

extension Level: Codable {}

struct Tile {
    var entities: [Entity] = []
}

extension Tile: Codable {}
extension Tile: Equatable {}
