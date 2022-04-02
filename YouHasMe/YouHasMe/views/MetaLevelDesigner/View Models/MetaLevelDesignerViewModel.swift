import Foundation
import CoreGraphics
import Combine

enum MetaLevelDesignerState {
    case normal
    case choosingLevel(tile: MetaTile)
    case choosingMetaLevel
}

class MetaLevelDesignerViewModel: AbstractMetaLevelGridViewModel, MetaLevelManipulableViewModel {
    @Published var selectedPaletteMetaEntity: MetaEntityType?
    @Published var selectedTile: MetaTile?
    private var levelStorage = LevelStorage()
    private var metaLevelStorage = MetaLevelStorage()
    var viewableDimensions = Rectangle(
        width: ChunkNode.chunkDimensions,
        height: ChunkNode.chunkDimensions
    )
    @Published var currMetaLevel: MetaLevel

    /// The view position relative to the coordinate system of the current meta level.
    @Published var viewPosition: Point
    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    private var toolbarViewModel: MetaLevelDesignerToolbarViewModel?

    @Published var state: MetaLevelDesignerState = .normal

    var editorMode: EditorMode? {
        toolbarViewModel?.editorMode
    }

    convenience init() {
        self.init(currMetaLevel: MetaLevel())
    }

    convenience init(metaLevelLoadable: Loadable) {
        let metaLevelStorage = MetaLevelStorage()
        guard let currMetaLevel: MetaLevel = metaLevelStorage.loadMetaLevel(name: metaLevelLoadable.name) else {
            fatalError("should not be nil")
        }

        self.init(currMetaLevel: currMetaLevel)
    }

    init(currMetaLevel: MetaLevel) {
        self.currMetaLevel = currMetaLevel
        viewPosition = currMetaLevel.entryWorldPosition
    }

    func deselectTile() {
        selectedTile = nil
    }

    func getPlayableMetaLevel() -> PlayableMetaLevel {
        guard let metaLevel = metaLevelStorage.loadMetaLevel(name: currMetaLevel.name) else {
            fatalError("Failed to load current meta level")
        }
        return .metaLevel(metaLevel)
    }

    func getAllLoadableMetaLevels() -> [Loadable] {
        metaLevelStorage.getAllLoadables()
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

extension MetaLevelDesignerViewModel: MetaEntityViewModelBasicCRUDDelegate {
    func addSelectedEntity(to tile: MetaTile) {
        guard editorMode == .addAndRemove else {
            return
        }

        guard let selectedPaletteMetaEntity = selectedPaletteMetaEntity else {
            return
        }

        if case .level = selectedPaletteMetaEntity {
            state = .choosingLevel(tile: tile)
            return
        }

        tile.metaEntities.append(selectedPaletteMetaEntity)
    }

    func removeEntity(from tile: MetaTile) {
        guard editorMode == .addAndRemove else {
            return
        }

        tile.metaEntities.removeAll()
    }
}

extension MetaLevelDesignerViewModel: MetaEntityViewModelExaminableDelegate {
    func examineTile(_ tile: MetaTile) {
        guard editorMode == .select else {
            return
        }

        selectedTile = tile
    }
}

extension MetaLevelDesignerViewModel: LevelSelectorViewModelDelegate {
    func selectLevel(_ loadable: Loadable) {
        guard case .choosingLevel(tile: let tile) = state else {
            return
        }
        tile.metaEntities.append(.level(levelLoadable: loadable))
        state = .normal
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
        metaEntityViewModel.basicCRUDDelegate = self
        metaEntityViewModel.examinableDelegate = self
        return metaEntityViewModel
    }

    func getTileInfoViewModel(tile: MetaTile) -> MetaLevelDesignerTileInfoViewModel {
        MetaLevelDesignerTileInfoViewModel(tile: tile)
    }

    func getLevelSelectorViewModel() -> LevelSelectorViewModel {
        let levelSelectorViewModel = LevelSelectorViewModel()
        levelSelectorViewModel.delegate = self
        return levelSelectorViewModel
    }

    func getNameButtonViewModel() -> MetaLevelNameButtonViewModel {
        MetaLevelNameButtonViewModel(namePublisher: currMetaLevel.$name.eraseToAnyPublisher())
    }
}
