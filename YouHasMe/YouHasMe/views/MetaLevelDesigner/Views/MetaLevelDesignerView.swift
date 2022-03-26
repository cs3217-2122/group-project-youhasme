import SwiftUI

struct MetaLevelDesignerView: View {
    @ObservedObject var viewModel: MetaLevelDesignerViewModel
    var body: some View {
        VStack {
            MetaLevelDesignerToolbarView(viewModel: viewModel.getToolbarViewModel())
                .padding()
            MetaLevelDesignerPaletteView(viewModel: viewModel)
                .padding()
            MetaLevelDesignerGridView(viewModel: viewModel)
                .padding()
            Spacer()
            MetaLevelDesignerPersistenceView(viewModel: viewModel)
        }
    }
}

// struct MetaLevelDesignerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetaLevelDesignerView().previewDevice(
//            PreviewDevice(rawValue: "iPad (9th generation")
//        )
//    }
// }
