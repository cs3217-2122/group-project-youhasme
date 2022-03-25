import Foundation
import CoreGraphics
import Combine

class MetaLevelDesignerViewModel: ObservableObject {
    // MARK: Palette
    @Published var selectedPaletteMetaEntity: MetaEntityType?
    
    private var metaLevelStorage = MetaLevelStorage()
    var viewableDimensions = Rectangle(
        width: ChunkNode.chunkDimensions,
        height: ChunkNode.chunkDimensions
    )
    @Published var currMetaLevel: MetaLevel
    var hasUnsavedChanges = false
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

    convenience init() {
        self.init(currMetaLevel: MetaLevel())
    }

    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.entryWorldPosition
    }

    func translateView(by offset: CGVector) {
        cumulativeTranslation = cumulativeTranslation.add(with: offset)
    }
    
    func getWorldPosition(at viewOffset: Vector) -> Point {
        viewPosition.translate(by: viewOffset)
    }
}

extension MetaLevelDesignerViewModel: MetaLevelViewableDelegate {
    func getViewableRegion() -> PositionedRectangle {
        PositionedRectangle(rectangle: viewableDimensions, topLeft: viewPosition)
    }
}

// MARK: Persistence
extension MetaLevelDesignerViewModel {
    func save() throws {
        try metaLevelStorage.saveMetaLevel(currMetaLevel)
    }
}

// MARK: CRUD
extension MetaLevelDesignerViewModel {
    func getTile(at viewOffset: Vector) -> MetaTile? {
        return currMetaLevel.getTile(
            at: viewPosition.translate(by: viewOffset),
            createChunkIfNotExists: true
        )
    }

    func setTile(_ tile: MetaTile, at viewOffset: Vector) {
        currMetaLevel.setTile(tile, at: getWorldPosition(at: viewOffset))
    }
}

extension MetaLevelDesignerViewModel: MetaLevelDesignerToolbarViewModelDelegate {}

extension MetaLevelDesignerViewModel: PaletteMetaEntityViewModelDelegate {
    func selectPaletteMetaEntity(_ metaEntity: MetaEntityType) {
        selectedPaletteMetaEntity = metaEntity
    }
    
    var selectedPaletteMetaEntityPublisher: AnyPublisher<MetaEntityType?, Never> {
        $selectedPaletteMetaEntity.eraseToAnyPublisher()
    }
}

extension MetaLevelDesignerViewModel: MetaEntityViewModelDelegate {
    func addSelectedEntity(to tile: MetaTile) {
        guard let selectedPaletteMetaEntity = selectedPaletteMetaEntity else {
            return
        }
        
        tile.metaEntities.append(selectedPaletteMetaEntity)
    }
    
    func removeEntity(from tile: MetaTile) {
        tile.metaEntities.removeAll()
    }
}

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
    
    func getPaletteMetaEntityViewModels() -> [PaletteMetaEntityViewModel] {
        MetaEntityType.allCases.map {
            let viewModel = PaletteMetaEntityViewModel(metaEntity: $0)
            viewModel.delegate = self
            return viewModel
        }
    }

    func getTileViewModel(at viewOffset: Vector) -> MetaEntityViewModel {
        let metaEntityViewModel = MetaEntityViewModel(
            tile: getTile(at: viewOffset),
            worldPosition: getWorldPosition(at: viewOffset)
        )
        metaEntityViewModel.delegate = self
        return metaEntityViewModel
    }
}
