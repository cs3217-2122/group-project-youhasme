import Foundation

protocol MetaLevelDesignerToolbarViewModelDelegate: AnyObject {

}

enum EditorMode: String {
    case panOnly = "Pan only"

    /// Allows basic add and removal operations.
    case addAndRemove = "Add and remove"

    /// Enables editing of selected tiles that support editing.
    case select = "Select"
}

extension EditorMode: CaseIterable, Hashable {}

class MetaLevelDesignerToolbarViewModel: ObservableObject {
    weak var delegate: MetaLevelDesignerToolbarViewModelDelegate?

    @Published var editorMode: EditorMode = .panOnly

}
