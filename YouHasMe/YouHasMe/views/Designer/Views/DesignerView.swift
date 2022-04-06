import SwiftUI
import Combine
struct DesignerView: View {
    @ObservedObject var viewModel: DesignerViewModel
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    @State var shouldPresentConditionEvaluableCreator: Bool = false
    @State var lastDragLocation: CGPoint?
    let inverseDragThreshold: Double = 20.0.multiplicativeInverse()
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let currentDragLocation = value.location

                if let lastDragLocation = lastDragLocation {
                    let translation =
                        CGVector(from: currentDragLocation, to: lastDragLocation)
                        .scaleBy(factor: inverseDragThreshold)
                    viewModel.translateView(by: translation)
                }
                lastDragLocation = value.location
            }
            .onEnded { _ in
                lastDragLocation = nil
                viewModel.endTranslateView()
            }
    }
    
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
                PersistenceView(viewModel: viewModel)
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

        }.onAppear {
            achievementsViewModel.setSubscriptionsFor(viewModel.gameEventPublisher)
        }.gesture(dragGesture)
    }
}




