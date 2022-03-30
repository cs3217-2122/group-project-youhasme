import SwiftUI
import Combine

struct CellView: View {
    var backupDisplay: some View {
        SwiftUI.Rectangle().fill(.gray)
    }
    @ObservedObject var viewModel: CellViewModel
    var body: some View {
        if let image = viewModel.image {
            image.resizable()
                .scaledToFit()
        } else {
            backupDisplay
        }
    }
}

enum Imageable {
    case string(String)
    case uiImage(UIImage)
    case cgImage(CGImage)
}

extension Imageable {
    func toImage() -> Image {
        switch self {
        case .string(let string):
            return Image(string)
        case .uiImage(let uiImage):
            return Image(uiImage: uiImage)
        case .cgImage(let cgImage):
            return Image(uiImage: UIImage(cgImage: cgImage))
        }
    }
}

class CellViewModel: ObservableObject {
    @Published var imageSource: Imageable?
    // Remark: Not quite sure how swiftui magic works, as publishers act like a willSet instead
    // of a didSet, it is unknown how image updates correctly when imageSource updates
    var image: Image? {
        imageSource?.toImage()
    }

    init(imageSource: Imageable? = nil) {
        self.imageSource = imageSource
    }
}

struct EntityView: View {
    var viewModel: EntityViewModel
    var body: some View {
        CellView(viewModel: viewModel)
    }
}

class EntityViewModel: CellViewModel {
    init(entityType: EntityType?) {
        guard let entityType = entityType else {
            super.init()
            return
        }

        super.init(imageSource: .string(entityTypeToImageString(type: entityType)))
    }
}

struct MetaEntityView: View {
    @EnvironmentObject var gameState: GameState
    var viewModel: MetaEntityViewModel

    var body: some View {
        CellView(viewModel: viewModel)
            .border(.pink)
            .onTapGesture {
                switch gameState.state {
                case .designingMeta(_):
                    viewModel.addEntity()
                    viewModel.examine()
                case .playing:
                    viewModel.enterLevelIfExists()
                default:
                    return
                }
            }
            .onLongPressGesture {
                switch gameState.state {
                case .designingMeta(_):
                    viewModel.removeEntity()
                default:
                    return
                }
            }
    }
}

protocol MetaEntityViewModelBasicCRUDDelegate: AnyObject {
    func addSelectedEntity(to tile: MetaTile)
    func removeEntity(from tile: MetaTile)
}

protocol MetaEntityViewModelDetailedUpdateDelegate: AnyObject {
    func examineTile(_ tile: MetaTile)
}

protocol MetaEntityViewModelLevelDelegate: AnyObject {
    func getLevelInfo(_ loadable: Loadable)
    func enterLevel(_ loadable: Loadable)
}

class MetaEntityViewModel: CellViewModel {
    weak var basicCRUDDelegate: MetaEntityViewModelBasicCRUDDelegate?
    weak var detailedUpdateDelegate: MetaEntityViewModelDetailedUpdateDelegate?
    weak var levelDelegate: MetaEntityViewModelLevelDelegate?
    var tile: MetaTile?
    var worldPosition: Point?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    convenience init(tile: MetaTile?) {
        self.init(tile: tile, worldPosition: nil)
    }
    
    init(tile: MetaTile?, worldPosition: Point?) {
        self.tile = tile
        self.worldPosition = worldPosition
        
        guard let tile = tile else {
            super.init()
            return
        }

        if tile.metaEntities.isEmpty {
            super.init()
        } else {
            // TODO: Allow stacking of multiple images
            super.init(imageSource: metaEntityTypeToImageable(type: tile.metaEntities[0]))
        }
        setupBindings()
    }
    
    private func setupBindings() {
        guard let tile = tile else {
            return
        }

        tile.$metaEntities.sink { [weak self] metaEntities in
            guard !metaEntities.isEmpty else {
                self?.imageSource = nil
                return
            }
            self?.imageSource = metaEntityTypeToImageable(type: metaEntities[0])
        }
        .store(in: &subscriptions)
    }
    
    func addEntity() {
        guard let delegate = basicCRUDDelegate, let tile = tile else {
            return
        }

        delegate.addSelectedEntity(to: tile)
    }
    
    func removeEntity() {
        guard let delegate = basicCRUDDelegate, let tile = tile else {
            return
        }
        
        delegate.removeEntity(from: tile)
    }
    
    func examine() {
        guard let delegate = detailedUpdateDelegate, let tile = tile else {
            return
        }
        
        delegate.examineTile(tile)
    }
    
    func enterLevelIfExists() {
        guard
            let levelDelegate = levelDelegate,
            let tile = tile,
            let levelLoadable = tile.getLevelLoadable()
            else {
            return
        }

        levelDelegate.enterLevel(levelLoadable)
    }
}

struct PaletteMetaEntityView: View {
    var viewModel: PaletteMetaEntityViewModel
    @State var borderColor: Color = .black
    var body: some View {
        
        CellView(viewModel: viewModel)
            .onTapGesture {
                viewModel.select()
            }
            .onReceive(viewModel.shouldHighlightPublisher, perform: { shouldHighlight in
                borderColor = shouldHighlight ? .red : .black
            })
            .border(borderColor)
    }
}

protocol PaletteMetaEntityViewModelDelegate: AnyObject {
    func selectPaletteMetaEntity(_ metaEntity: MetaEntityType)
    var selectedPaletteMetaEntityPublisher: AnyPublisher<MetaEntityType?, Never> { get }
}

class PaletteMetaEntityViewModel: CellViewModel {
    weak var delegate: PaletteMetaEntityViewModelDelegate? {
        didSet {
            guard delegate != nil else {
                return
            }
            setupBindingsWithDelegate()
        }
    }
    private var metaEntity: MetaEntityType
    var shouldHighlightPublisher: AnyPublisher<Bool, Never> {
        shouldHighlight.eraseToAnyPublisher()
    }
    private var shouldHighlight: PassthroughSubject<Bool, Never> = PassthroughSubject()
    private var subscriptions: Set<AnyCancellable> = []
    
    init(metaEntity: MetaEntityType) {
        self.metaEntity = metaEntity
        super.init(imageSource: metaEntityTypeToImageable(type: metaEntity))
    }
    
    func select() {
        guard let delegate = delegate else {
            return
        }
        delegate.selectPaletteMetaEntity(metaEntity)
    }
    
    func setupBindingsWithDelegate() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }
        
        delegate.selectedPaletteMetaEntityPublisher
            .sink { [weak self] selectedPaletteMetaEntity in
                guard let self = self else {
                    return
                }
                
                self.shouldHighlight.send(selectedPaletteMetaEntity == self.metaEntity)
            }
            .store(in: &subscriptions)
    }
}

extension PaletteMetaEntityViewModel: Hashable {
    static func == (lhs: PaletteMetaEntityViewModel, rhs: PaletteMetaEntityViewModel) -> Bool {
        lhs.metaEntity == rhs.metaEntity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(metaEntity)
    }
}

// struct EntityView_Previews: PreviewProvider {
//    static var previews: some View {
//        EntityView()
//    }
// }
