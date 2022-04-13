import SwiftUI
import Combine

struct CellView: View {
    let backupDisplayColor: Color
    
    var backupDisplay: some View {
        SwiftUI.Rectangle().fill(backupDisplayColor)
    }
    
    @ObservedObject var viewModel: CellViewModel
    var body: some View {
        if let image = viewModel.image {
            image.interpolation(.none).resizable().scaledToFit().background(Color.black)
        } else {
            backupDisplay
        }
    }
}



enum Imageable {
    case string(String)
    case uiImage(UIImage)
    case cgImage(CGImage)
    case uiColor(UIColor)
}

extension Imageable {
    func toImage() -> Image {
        switch self {
        case .string(let string):
            return Image(string)
        case .uiImage(let uiImage):
            return Image(uiImage: uiImage).renderingMode(.original)
        case .cgImage(let cgImage):
            return Image(uiImage: UIImage(cgImage: cgImage)).renderingMode(.original)
        case .uiColor(let uiColor):
            return Image(uiImage: uiColor.toImage()).renderingMode(.original)
        }
    }
}

class CellViewModel: ObservableObject {
    @Published var imageSource: Imageable?
    var image: Image? {
        imageSource?.toImage()
    }

    init(imageSource: Imageable?) {
        self.imageSource = imageSource
    }
}

struct EntityView: View {
    var viewModel: EntityViewModel
    var body: some View {
        CellView(backupDisplayColor: .black, viewModel: viewModel)
    }
}

class EntityViewModel: CellViewModel {
    init(entityType: EntityType?) {
        guard let entityType = entityType else {
            super.init(imageSource: nil)
            return
        }

        super.init(imageSource: entityTypeToImageable(type: entityType))
    }
}
