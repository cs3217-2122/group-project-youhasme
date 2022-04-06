import SwiftUI
import Combine
struct DesignerView: View {
    @ObservedObject var viewModel: DesignerViewModel
    @State var shouldPresentConditionEvaluableCreator: Bool = false
    
    
    var body: some View {
        ZStack {
            VStack {
                ToolbarView(viewModel: viewModel.getToolbarViewModel())
                    .padding()
                PaletteView(viewModel: viewModel)
                    .padding()
                GridView(viewModel: viewModel)
                    .padding()
                Spacer()
                DesignerPersistenceView(viewModel: viewModel)
            }
            .onReceive(viewModel.$state, perform: {
                guard case .choosingConditionEvaluable = $0 else {
                    shouldPresentConditionEvaluableCreator = false
                    return
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




