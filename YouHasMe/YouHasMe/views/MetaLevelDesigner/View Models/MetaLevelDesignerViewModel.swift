import Foundation
import CoreGraphics
import Combine

class MetaLevelDesignerViewModel: AbstractMetaLevelGridViewModel, MetaLevelManipulableViewModel {
    @Published var selectedPaletteMetaEntity: MetaEntityType?

    private var metaLevelStorage = MetaLevelStorage()
    var viewableDimensions = Rectangle(
        width: ChunkNode.chunkDimensions,
        height: ChunkNode.chunkDimensions
    )
    @Published var currMetaLevel: MetaLevel
    var hasUnsavedChanges = false
    /// The view position relative to the coordinate system of the current meta level.
    @Published var viewPosition: Point
    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    private var toolbarViewModel: MetaLevelDesignerToolbarViewModel?

    convenience init() {
        self.init(currMetaLevel: MetaLevel())
    }

    convenience init(metaLevelURLData: Loadable) {
        let metaLevelStorage = MetaLevelStorage()
        guard let currMetaLevel: MetaLevel = metaLevelStorage.loadMetaLevel(name: metaLevelURLData.name) else {
            fatalError("should not be nil")
        }

        self.init(currMetaLevel: currMetaLevel)
    }

    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.entryWorldPosition
    }
}

extension MetaLevelDesignerViewModel: MetaLevelViewableDelegate {}

// MARK: Persistence
extension MetaLevelDesignerViewModel {
    func save() throws {
        try currMetaLevel.saveLoadedChunks()
        try metaLevelStorage.saveMetaLevel(currMetaLevel)
    }
}

// MARK: CRUD
extension MetaLevelDesignerViewModel {
    func getTile(at viewOffset: Vector) -> MetaTile? {
        currMetaLevel.getTile(
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

extension MetaLevelDesignerViewModel: MetaEntityViewModelPaletteDelegate {
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
        metaEntityViewModel.paletteDelegate = self
        return metaEntityViewModel
    }
}
