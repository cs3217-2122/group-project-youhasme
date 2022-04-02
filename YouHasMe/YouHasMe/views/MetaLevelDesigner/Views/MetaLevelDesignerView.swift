import SwiftUI

struct MetaLevelDesignerView: View {
    @ObservedObject var viewModel: MetaLevelDesignerViewModel
    var body: some View {
        ZStack {
            VStack {
                MetaLevelDesignerToolbarView(viewModel: viewModel.getToolbarViewModel())
                    .padding()
                MetaLevelDesignerPaletteView(viewModel: viewModel)
                    .padding()
                MetaLevelGridView(viewModel: viewModel)
                    .padding()
                Spacer()
                MetaLevelDesignerPersistenceView(viewModel: viewModel)
            }
            
            if let selectedTile = viewModel.selectedTile {
                NavigationFrame(backHandler: {
                    viewModel.deselectTile()
                }) {
                    MetaLevelDesignerTileInfoView(
                        viewModel: viewModel.getTileInfoViewModel(tile: selectedTile)
                    )
                }
            }
            
            switch viewModel.state {
            case .normal:
                EmptyView()
            case .choosingLevel:
                LevelSelector(viewModel: viewModel.getLevelSelectorViewModel())
            case .choosingMetaLevel:
                EmptyView() // TODO
            }
        }
    }
}

struct LevelSelector: View {
    @ObservedObject var viewModel: LevelSelectorViewModel
    var body: some View {
        NavigationView {
            List(viewModel.loadableLevels, selection: $viewModel.selectedLevelId) { loadable in
                Text(loadable.name)
            }.navigationTitle("Level")
                .toolbar {
                    EditButton()
                }
        }
        
        Button("Confirm") {
            viewModel.confirmSelectLevel()
        }.disabled(viewModel.selectedLevelId == nil)
        
    }
}

// struct MetaLevelDesignerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetaLevelDesignerView().previewDevice(
//            PreviewDevice(rawValue: "iPad (9th generation")
//        )
//    }
// }
