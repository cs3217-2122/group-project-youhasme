import Foundation

protocol MetaLevelDesignerToolbarViewModelDelegate: AnyObject {

}

enum EditorMode: String {
    case pan = "Pan"
    case select = "Select"
}

extension EditorMode: CaseIterable, Hashable {}

class MetaLevelDesignerToolbarViewModel: ObservableObject {
    weak var delegate: MetaLevelDesignerToolbarViewModelDelegate?

    @Published var editorMode: EditorMode = .pan

}
