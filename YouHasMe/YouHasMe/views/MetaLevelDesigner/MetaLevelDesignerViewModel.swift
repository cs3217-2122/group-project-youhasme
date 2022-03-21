import Foundation

class MetaLevelDesignerViewModel: ObservableObject {
    var currMetaLevel: MetaLevel
    var viewPosition: Point
    
    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.origin
    }
    
    func getItem(at viewOffset: Vector) -> MetaTile {
        currMetaLevel.layer.getTileAt(point: viewPosition.translate(by: viewOffset))
    }
}

// MARK: Child view models
extension MetaLevelDesignerViewModel {
    func getTileViewModel(at viewOffset: Vector) -> MetaEntityViewModel {
        MetaEntityViewModel(metaEntityType: getItem(at: viewOffset).metaEntity)
    }
}
