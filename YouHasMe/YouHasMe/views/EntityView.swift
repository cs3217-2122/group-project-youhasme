import SwiftUI

struct CellView: View {
    var backupDisplay: some View {
        SwiftUI.Rectangle().fill(.gray)
    }
    var viewModel: CellViewModel
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

class CellViewModel {
    var imageSource: Imageable?
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
    var viewModel: MetaEntityViewModel

    var body: some View {
        CellView(viewModel: viewModel)
    }
}

class MetaEntityViewModel: CellViewModel {
    init(metaEntities: [MetaEntityType]) {
        guard !metaEntities.isEmpty else {
            super.init()
            return
        }

        super.init(imageSource: metaEntityTypeToImageable(type: metaEntities[0]))
    }
}

protocol PaletteMetaEntityViewModelDelegate: AnyObject {
    func selectPaletteMetaEntity(_ metaEntity: MetaEntityType)
    func getSelectedPaletteMetaEntity() -> MetaEntityType?
}


struct PaletteMetaEntityView: View {
    var viewModel: PaletteMetaEntityViewModel

    var body: some View {
        CellView(viewModel: viewModel)
            .onTapGesture {
                viewModel.select()
            }
            .border(viewModel.shouldHighlight() ? .red : .black)
    }
}

class PaletteMetaEntityViewModel: CellViewModel {
    weak var delegate: PaletteMetaEntityViewModelDelegate?
    private var metaEntity: MetaEntityType
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
    
    func shouldHighlight() -> Bool {
        guard let delegate = delegate else {
            return false
        }
        
        return delegate.getSelectedPaletteMetaEntity() == metaEntity
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
