import SwiftUI

struct GridViewData {
    var displayWidth: Double
    var displayHeight: Double
    var widthInCells: Int
    var heightInCells: Int
    var cellDimensions: Double
    var cellWidth: Double {
        cellDimensions
    }
    var cellHeight: Double {
        cellDimensions
    }
    
    
    init(
        displayWidth: Double,
        displayHeight: Double,
        cellDimensions: Double = ViewConstants.gridCellDimensions
    ) {
        self.displayWidth = displayWidth
        self.displayHeight = displayHeight
        self.cellDimensions = cellDimensions
        self.widthInCells = Int(floor(displayWidth / cellDimensions))
        self.heightInCells = Int(floor(displayHeight / cellDimensions))
    }

    init(proxy: GeometryProxy) {
        self.init(displayWidth: proxy.size.width, displayHeight: proxy.size.height)
    }

    func getViewableDimensions() -> Rectangle {
        Rectangle(width: widthInCells, height: heightInCells)
    }
}

protocol AbstractGridViewModel: ObservableObject {
    var viewableDimensions: Rectangle { get set }
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel
    func translateView(by offset: CGVector)
    func endTranslateView()
}

struct GridView<T: AbstractGridViewModel>: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: T
    
    var body: some View {
        Group {
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        let gridViewData = GridViewData(proxy: proxy)
                        let _ = (viewModel.viewableDimensions = gridViewData.getViewableDimensions())
                        ForEach(0..<gridViewData.heightInCells, id: \.self) { y in
                            HStack(spacing: 0) {
                                ForEach(0..<gridViewData.widthInCells, id: \.self) { x in
                                    EntityView(
                                        viewModel: viewModel.getTileViewModel(at: Vector(dx: x, dy: y))
                                    )
                                    .frame(width: gridViewData.cellWidth, height: gridViewData.cellHeight)
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}
