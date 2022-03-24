import Foundation
import CoreGraphics

class MetaLevelDesignerViewModel: ObservableObject {
    var currMetaLevel: MetaLevel
    /// The view position relative to the coordinate system of the current meta level.
    var viewPosition: Point
    private var cumulativeTranslation: CGVector = .zero {
        didSet {
            let floor = cumulativeTranslation.absoluteFloor()
            guard floor != .zero else {
                return
            }
            viewPosition = viewPosition.translate(by: floor)
            cumulativeTranslation = cumulativeTranslation.subtract(with: CGVector(floor))
        }
    }
    private var toolbarViewModel: MetaLevelDesignerToolbarViewModel?

    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.entryWorldPosition
    }

    func translateView(by offset: CGVector) {
        cumulativeTranslation = cumulativeTranslation.add(with: offset)
    }

    func getItem(at viewOffset: Vector) -> MetaTile {
        currMetaLevel.layer.getTileAt(point: viewPosition.translate(by: viewOffset))
    }

    func setTile(_ tile: MetaTile, at viewOffset: Vector) {
        currMetaLevel.layer.setTile(tile, at: viewPosition.translate(by: viewOffset))
    }
}

extension MetaLevelDesignerViewModel: MetaLevelDesignerToolbarViewModelDelegate {}

// MARK: Child view models
extension MetaLevelDesignerViewModel {
    func getToolbarViewModel() -> MetaLevelDesignerToolbarViewModel {
        if toolbarViewModel == nil {
            let toolbarViewModel = MetaLevelDesignerToolbarViewModel()
            toolbarViewModel.delegate = self
            self.toolbarViewModel = toolbarViewModel
        }

        guard let toolbarViewModel = self.toolbarViewModel else {
            fatalError("should not be nil")
        }

        return toolbarViewModel
    }

    func getTileViewModel(at viewOffset: Vector) -> MetaEntityViewModel {
        MetaEntityViewModel(metaEntityType: getItem(at: viewOffset).metaEntity)
    }
}
