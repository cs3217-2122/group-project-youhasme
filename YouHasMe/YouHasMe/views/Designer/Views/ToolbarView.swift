import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: ToolbarViewModel
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
