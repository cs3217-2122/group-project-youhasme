import SwiftUI
import Combine

struct CellView: View {
    var backupDisplay: some View {
        SwiftUI.Rectangle().fill(.gray)
    }
    @ObservedObject var viewModel: CellViewModel
    var body: some View {
        if let image = viewModel.image {
            image.interpolation(.none).resizable().scaledToFit().background(Color.gray)
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
