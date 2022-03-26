import SwiftUI

struct MetaLevelDesignerToolbarView: View {
    @ObservedObject var viewModel: MetaLevelDesignerToolbarViewModel
    var body: some View {
        VStack {
            HStack {
                Picker("", selection: $viewModel.editorMode) {
                    ForEach(EditorMode.allCases, id: \.self) { editorMode in
                        Text(editorMode.rawValue).tag(editorMode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

struct MetaLevelDesignerToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelDesignerToolbarView(
            viewModel: MetaLevelDesignerToolbarViewModel()
        )
    }
}
