import Foundation
final class DesignerConnector {
    var metaLevel: MetaLevel?
    var otherMetaLevel: MetaLevel?
}


final class Connector {
    var metaLevel: MetaLevel
    var otherMetaLevel: MetaLevel
    init(metaLevel: MetaLevel, otherMetaLevel: MetaLevel) {
        self.metaLevel = metaLevel
        self.otherMetaLevel = otherMetaLevel
    }
}

