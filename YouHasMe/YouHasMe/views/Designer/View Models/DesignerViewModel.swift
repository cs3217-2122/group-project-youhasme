import Foundation
import CoreGraphics
import Combine

enum DesignerState {
    case normal
    case choosingConditionEvaluable(worldPosition: Point)
}

enum PlayMode {
    case normal
    case endlessWrap
    
    func getConfig() -> DungeonPlayParams? {
        switch self {
        case .normal:
            return nil
        case .endlessWrap:
            return DungeonPlayParams(neighborFinder: ImmediateNeighborhoodChunkNeighborFinder().decorateWith(ChunkNeighborFinderWrapAroundDecorator.self)
            )
        }
    }
}

class DesignerViewModel: AbstractGridViewModel, DungeonManipulableViewModel {
    let baseViewOffset: Vector = .zero
    @Published var gridDisplayMode: GridDisplayMode = .scaleToFitCellSize(
        cellSize: ViewConstants.gridCellDimensions
    )
    var displayModeOptions: [GridDisplayMode] {
        [
            .scaleToFitCellSize(cellSize: ViewConstants.gridCellDimensions),
            .fixedDimensionsInCells(dimensions: dungeon.levelDimensions)
        ]
    }

    @Published var selectedPaletteEntityType: EntityType?
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

    private var achievementsViewModel: AchievementsViewModel
    private(set) var gameNotificationsViewModel: GameNotificationsViewModel

    @Published var state: DesignerState = .normal

    @Published var levelsUpdated = false

    var isExistingLevel = true

    private var subscriptions: Set<AnyCancellable> = []


    var gameEventPublisher: AnyPublisher<AbstractGameEvent, Never> {
        gameEventSubject.eraseToAnyPublisher()
    }

    private let gameEventSubject = PassthroughSubject<AbstractGameEvent, Never>()

    convenience init(achievementsViewModel: AchievementsViewModel,
                     gameNotificationsViewModel: GameNotificationsViewModel) {
        self.init(dungeon: Dungeon(), achievementsViewModel: achievementsViewModel,
                  gameNotificationsViewModel: gameNotificationsViewModel)
        isExistingLevel = false
    }

    convenience init(designableDungeon: DesignableDungeon, achievementsViewModel: AchievementsViewModel,
                     gameNotificationsViewModel: GameNotificationsViewModel) {
        self.init(dungeon: designableDungeon.getDungeon(), achievementsViewModel: achievementsViewModel,
                  gameNotificationsViewModel: gameNotificationsViewModel)
        if case .newDungeon = designableDungeon {
            isExistingLevel = false
        }
    }

    init(dungeon: Dungeon, achievementsViewModel: AchievementsViewModel,
         gameNotificationsViewModel: GameNotificationsViewModel) {
        self.dungeon = dungeon
        self.achievementsViewModel = achievementsViewModel
        self.gameNotificationsViewModel = gameNotificationsViewModel
        viewPosition = dungeon.entryWorldPosition
        setupBindings()
    }

    func getPlayableDungeon(_ playMode: PlayMode) -> PlayableDungeon {
        guard let dungeon: Dungeon = dungeonStorage.loadDungeon(name: dungeon.name) else {
            fatalError("Failed to load current meta level")
        }
        if let config = playMode.getConfig() {
            dungeon.levelNeighborFinder = config.neighborFinder
        }
        return .dungeon(dungeon)
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
        gameNotificationsViewModel.setSubscriptionsFor(achievementsViewModel.gameNotifPublisher)
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
        objectWillChange.send()
    }

    func removeEntity(from worldPosition: Point) {
        dungeon.setTile(Tile(), at: worldPosition)
        objectWillChange.send()
    }
}

extension DesignerViewModel: ConditionEvaluableCreatorViewModelDelegate {
    func getLevelNameToPositionMap() -> [String: Point] {
        dungeon.levelNameToPositionMap
    }

    func getConditionEvaluableDelegate() -> ConditionEvaluableDungeonDelegate {
        dungeon
    }

    func addConditionEvaluable(conditionEvaluable: ConditionEvaluable) {
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
    }

    func finishCreation() {
        state = .normal
    }
}

extension DesignerViewModel: LevelCollectionViewModelDelegate {
    func renameLevel(with oldName: String, to newName: String) {
        dungeon.renameLevel(with: oldName, to: newName)
    }
}

// MARK: Child view models
extension DesignerViewModel {
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
        return entityViewModel
    }

    func getConditionEvaluableCreatorViewModel() -> ConditionEvaluableCreatorViewModel {
        let conditionEvaluableCreatorViewModel = ConditionEvaluableCreatorViewModel()
        conditionEvaluableCreatorViewModel.delegate = self
        return conditionEvaluableCreatorViewModel
    }

    func getNameButtonViewModel() -> DungeonNameButtonViewModel {
        DungeonNameButtonViewModel(namePublisher: dungeon.$name.eraseToAnyPublisher())
    }

    func getLevelCollectionViewModel() -> LevelCollectionViewModel {
        let levelCollectionViewModel = LevelCollectionViewModel(
            dungeonDimensions: dungeon.dimensions,
            levelNameToPositionMapPublisher:
                dungeon
                .$levelNameToPositionMap
                .eraseToAnyPublisher()
        )
        levelCollectionViewModel.delegate = self
        return levelCollectionViewModel
    }
}
