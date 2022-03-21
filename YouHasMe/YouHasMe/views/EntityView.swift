import SwiftUI

struct CellView: View {
    var backupDisplay: SwiftUI.Rectangle = SwiftUI.Rectangle().fill(.gray) as! SwiftUI.Rectangle
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
    init(metaEntityType: MetaEntityType?) {
        guard let metaEntityType = metaEntityType else {
            super.init()
            return
        }
        
        super.init(imageSource: metaEntityTypeToImageable(type: metaEntityType))
    }
}

// struct EntityView_Previews: PreviewProvider {
//    static var previews: some View {
//        EntityView()
//    }
// }
