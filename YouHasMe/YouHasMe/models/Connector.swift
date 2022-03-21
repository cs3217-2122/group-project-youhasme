import Foundation
final class DesignerConnector {
    var metaLevel: MetaLevel?
    var otherMetaLevel: MetaLevel?
}

extension DesignerConnector: Codable {}

final class Connector {
    var metaLevel: MetaLevel
    var otherMetaLevel: MetaLevel
    init(metaLevel: MetaLevel, otherMetaLevel: MetaLevel) {
        self.metaLevel = metaLevel
        self.otherMetaLevel = otherMetaLevel
    }
}

extension Connector: Codable {}
