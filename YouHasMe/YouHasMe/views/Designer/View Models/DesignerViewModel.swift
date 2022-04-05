import Foundation
import CoreGraphics
import Combine

enum DesignerState {
    case normal
    case choosingConditionEvaluable(worldPosition: Point)
}

class DesignerViewModel: AbstractGridViewModel, DungeonManipulableViewModel {
    @Published var selectedPaletteEntityType: EntityType?
    @Published var selectedTile: Tile?
    private var levelStorage: LevelStorage? {
        try? dungeonStorage.getLevelStorage(for: dungeon.name)
    }
    private var dungeonStorage = DungeonStorage()
    var viewableDimensions = Dungeon.defaultLevelDimensions
    @Published var dungeon: Dungeon

    /// The view position relative to the coordinate system of the current meta level.
    @Published var viewPosition: Point
    var cumulativeTranslation: CGVector = .zero {
        didSet {
            applyCumulativeTranslationToViewPosition()
        }
    }

    private var toolbarViewModel: ToolbarViewModel?

    @Published var state: DesignerState = .normal

    var editorMode: EditorMode? {
        toolbarViewModel?.editorMode
    }

    convenience init() {
        self.init(dungeon: Dungeon())
    }

    convenience init(dungeonLoadable: Loadable) {
        let dungeonStorage = DungeonStorage()
        guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: dungeonLoadable.name) else {
            fatalError("should not be nil")
        }

        self.init(dungeon: dungeon)
    }

    init(dungeon: Dungeon) {
        self.dungeon = dungeon
        viewPosition = dungeon.entryWorldPosition
    }

    func deselectTile() {
        selectedTile = nil
    }

    func getPlayableMetaLevel() -> PlayableDungeon {
        guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: dungeon.name) else {
            fatalError("Failed to load current meta level")
        }
        return .dungeon(dungeon)
    }

    func getAllLoadableDungeons() -> [Loadable] {
        dungeonStorage.getAllLoadables()
    }
}

// MARK: Persistence
extension DesignerViewModel {
    func save() throws {
        try dungeon.saveLoadedLevels()
        try dungeonStorage.saveDungeon(dungeon)
    }
}

extension DesignerViewModel: PaletteEntityViewModelDelegate {
    func selectPaletteEntityType(_ entityType: EntityType) {
        selectedPaletteEntityType = entityType
    }
    
    var selectedPaletteEntityTypePublisher: AnyPublisher<EntityType?, Never> {
        $selectedPaletteEntityType.eraseToAnyPublisher()
    }
}

extension DesignerViewModel: EntityViewModelBasicCRUDDelegate {
    func addSelectedEntity(to worldPosition: Point) {
        guard editorMode == .addAndRemove else {
            return
        }

        guard let selectedPaletteEntityType = selectedPaletteEntityType else {
            return
        }

        if case .conditionEvaluable = selectedPaletteEntityType.classification {
            state = .choosingConditionEvaluable(worldPosition: worldPosition)
            return
        }

        guard var tile = dungeon.getTile(at: worldPosition, loadNeighboringChunks: false) else {
            return
        }
        tile.entities.append(Entity(entityType: selectedPaletteEntityType))
        dungeon.setTile(tile, at: worldPosition)
    }

    func removeEntity(from worldPosition: Point) {
        guard editorMode == .addAndRemove else {
            return
        }

        dungeon.setTile(Tile(), at: worldPosition)
    }
}

extension DesignerViewModel: EntityViewModelExaminableDelegate {
    func examineTile(at worldPosition: Point) {
        guard editorMode == .select else {
            return
        }

        guard let tile = dungeon.getTile(at: worldPosition, loadNeighboringChunks: false) else {
            return
        }
        
        selectedTile = tile
    }
}

extension DesignerViewModel: ConditionEvaluableCreatorViewModelDelegate {
    func buildConditionEvaluable(conditionEvaluable: ConditionEvaluable) {
        guard case .choosingConditionEvaluable(worldPosition: let worldPosition) = state else {
            return
        }
        
        guard var tile = dungeon.getTile(at: worldPosition, loadNeighboringChunks: false) else {
            return
        }
        tile.entities.append(
            Entity(entityType: EntityType(classification: .conditionEvaluable(conditionEvaluable)))
        )
        dungeon.setTile(tile, at: worldPosition)
        state = .normal
    }
}

// MARK: Child view models
extension DesignerViewModel {
    func getToolbarViewModel() -> ToolbarViewModel {
        if toolbarViewModel == nil {
            let toolbarViewModel = ToolbarViewModel()
            self.toolbarViewModel = toolbarViewModel
        }

        guard let toolbarViewModel = self.toolbarViewModel else {
            fatalError("should not be nil")
        }

        return toolbarViewModel
    }

    func getPaletteEntityViewModels() -> [PaletteEntityViewModel] {
        allAvailableEntityTypes.map {
            let viewModel = PaletteEntityViewModel(entityType: $0)
            viewModel.delegate = self
            return viewModel
        }
    }

    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel {
        let entityViewModel = EntityViewModel(
            tile: getTile(at: viewOffset, loadNeighboringChunks: false),
            worldPosition: getWorldPosition(at: viewOffset)
        )
        entityViewModel.basicCRUDDelegate = self
        entityViewModel.examinableDelegate = self
        return entityViewModel
    }

//    func getTileInfoViewModel(tile: Tile) -> MetaLevelDesignerTileInfoViewModel {
//        MetaLevelDesignerTileInfoViewModel(tile: tile)
//    }

    func getConditionEvaluableCreatorViewModel() -> ConditionEvaluableCreatorViewModel {
        ConditionEvaluableCreatorViewModel()
    }

    func getNameButtonViewModel() -> DungeonNameButtonViewModel {
        DungeonNameButtonViewModel(namePublisher: dungeon.$name.eraseToAnyPublisher())
    }
}
