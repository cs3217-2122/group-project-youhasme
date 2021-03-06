import SwiftUI
import Combine

struct CellView: View {
    let backupDisplayColor: Color
    
    @ObservedObject var viewModel: CellViewModel
    var body: some View {
        if let image = viewModel.image {
            image.interpolation(.none).resizable().scaledToFit().background(Color.gray)
        } else {
            backupDisplayColor
        }
    }
}



enum Imageable {
    case string(String)
    case sfSymbol(String)
    case uiImage(UIImage)
    case cgImage(CGImage)
    case uiColor(UIColor)
}

extension Imageable {
    func toImage() -> Image {
        switch self {
        case .string(let string):
            return Image(string)
        case .sfSymbol(let string):
            return Image(systemName: string)
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
