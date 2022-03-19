import Foundation
class DesignerConnector {
    var metaLevel: MetaLevel?
    var otherMetaLevel: MetaLevel?
}

class Connector {
    var metaLevel: MetaLevel
    var otherMetaLevel: MetaLevel
    init(metaLevel: MetaLevel, otherMetaLevel: MetaLevel) {
        self.metaLevel = metaLevel
        self.otherMetaLevel = otherMetaLevel
    }
}
