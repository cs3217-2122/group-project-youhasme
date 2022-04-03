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
                LevelSelectorView(viewModel: viewModel.getLevelSelectorViewModel())
            case .choosingMetaLevel:
                MetaLevelSelectorView(viewModel: viewModel.getMetaLevelSelectorViewModel())
            }
        }
    }
}




