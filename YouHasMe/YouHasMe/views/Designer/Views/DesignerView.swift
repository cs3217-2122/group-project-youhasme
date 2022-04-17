import SwiftUI
import Combine
struct DesignerView: View {
    @ObservedObject var viewModel: DesignerViewModel
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
        TabView {
            ZStack {
                VStack {
                    PaletteView(viewModel: viewModel)
                        .padding()
                    GridView(viewModel: viewModel)
                        .padding()
                    Spacer()
                    PersistenceView(viewModel: viewModel)
                }
                .onReceive(viewModel.$state, perform: {
                    guard case .choosingConditionEvaluable = $0 else {
                        return
                    }
                    shouldPresentConditionEvaluableCreator = true
                })
                .fullScreenCover(isPresented: $shouldPresentConditionEvaluableCreator) {
                    ConditionEvaluableCreatorView(
                        viewModel: viewModel.getConditionEvaluableCreatorViewModel()
                    )
                }
            }
                .gesture(dragGesture)
                .tabItem {
                    Label("Grid View", systemImage: "grid")
                }
            
            LevelCollectionView(viewModel: viewModel.getLevelCollectionViewModel())
                .tabItem {
                    Label("Level View", systemImage: "note")
                }
        }.overlay(alignment: .top, content: {
            GameNotificationsView(gameNotificationsViewModel: viewModel.gameNotificationsViewModel)
        })
    }
}




