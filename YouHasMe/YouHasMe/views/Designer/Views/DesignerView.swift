import SwiftUI
import Combine
struct DesignerView: View {
    @ObservedObject var viewModel: DungeonDesignerViewModel
    @State var shouldPresentConditionEvaluableCreator: Bool = false
    
    
    var body: some View {
        ZStack {
            VStack {
                ToolbarView(viewModel: viewModel.getToolbarViewModel())
                    .padding()
                DungeonDesignerPaletteView(viewModel: viewModel)
                    .padding()
                GridView(viewModel: viewModel)
                    .padding()
                Spacer()
                DungeonDesignerPersistenceView(viewModel: viewModel)
            }
            .onReceive(viewModel.$state, perform: {
                guard case .choosingConditionEvaluable = $0 else {
                    shouldPresentConditionEvaluableCreator = false
                }
                shouldPresentConditionEvaluableCreator = true
            })
            .fullScreenCover(isPresented: $shouldPresentConditionEvaluableCreator) {
                ConditionEvaluableCreatorView(
                    viewModel: viewModel.getConditionEvaluableCreatorViewModel()
                )
            }
            
//            if let selectedTile = viewModel.selectedTile {
//                NavigationFrame(backHandler: {
//                    viewModel.deselectTile()
//                }) {
//                    MetaLevelDesignerTileInfoView(
//                        viewModel: viewModel.getTileInfoViewModel(tile: selectedTile)
//                    )
//                }
//            }

        }
    }
}




