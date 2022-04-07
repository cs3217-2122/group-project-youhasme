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
    private var achievementsViewModel: AchievementsViewModel

    @Published var state: DesignerState = .normal

    @Published var levelsUpdated = false

    var isExistingLevel = true

    private var subscriptions: Set<AnyCancellable> = []

    var editorMode: EditorMode? {
        toolbarViewModel?.editorMode
    }

    var gameEventPublisher: AnyPublisher<AbstractGameEvent, Never> {
        gameEventSubject.eraseToAnyPublisher()
    }

    private let gameEventSubject = PassthroughSubject<AbstractGameEvent, Never>()

    convenience init(achievementsViewModel: AchievementsViewModel) {
        self.init(dungeon: Dungeon(), achievementsViewModel: achievementsViewModel)
        isExistingLevel = false
    }

    convenience init(designableDungeon: DesignableDungeon, achievementsViewModel: AchievementsViewModel) {
        self.init(dungeon: designableDungeon.getDungeon(), achievementsViewModel: achievementsViewModel)
        if case .newDungeonDimensions = designableDungeon {
            isExistingLevel = false
        }
    }

    init(dungeon: Dungeon, achievementsViewModel: AchievementsViewModel) {
        self.dungeon = dungeon
        self.achievementsViewModel = achievementsViewModel
        viewPosition = dungeon.entryWorldPosition
        setupBindings()
    }

    func deselectTile() {
        selectedTile = nil
    }

    func getPlayableDungeon() -> PlayableDungeon {
        guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: dungeon.name) else {
            fatalError("Failed to load current meta level")
        }
        return .dungeon(dungeon)
    }

    func getAllLoadableDungeons() -> [Loadable] {
        dungeonStorage.getAllLoadables()
    }

    func setupBindings() {
        dungeon.$loadedLevels.sink { [weak self] loadedLevels in
            guard let self = self else {
                return
            }
            self.subscriptions.removeAll()
            for (_, loadedLevel) in loadedLevels {
                loadedLevel.$layer.sink { _ in
                    self.levelsUpdated = true
                }.store(in: &self.subscriptions)
            }
        }
        .store(in: &subscriptions)
        achievementsViewModel.setSubscriptionsFor(gameEventPublisher)
    }
}

// MARK: Persistence
extension DesignerViewModel {
    func save() throws {
        if !isExistingLevel {
            gameEventSubject.send(GameEvent(type: .designLevel))
        }
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

        guard var tile = dungeon.getTile(at: worldPosition, loadNeighboringLevels: false) else {
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

        guard let tile = dungeon.getTile(at: worldPosition, loadNeighboringLevels: false) else {
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

        guard var tile = dungeon.getTile(at: worldPosition, loadNeighboringLevels: false) else {
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

    func getConditionEvaluableCreatorViewModel() -> ConditionEvaluableCreatorViewModel {
        ConditionEvaluableCreatorViewModel()
    }

    func getNameButtonViewModel() -> DungeonNameButtonViewModel {
        DungeonNameButtonViewModel(namePublisher: dungeon.$name.eraseToAnyPublisher())
    }
}
