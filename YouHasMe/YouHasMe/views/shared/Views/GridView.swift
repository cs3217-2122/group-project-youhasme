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
        cellDimensions: Double
    ) {
        self.displayWidth = displayWidth
        self.displayHeight = displayHeight
        self.cellDimensions = cellDimensions
        self.widthInCells = Int(floor(displayWidth / cellDimensions))
        self.heightInCells = Int(floor(displayHeight / cellDimensions))
    }
    
    init(
        displayWidth: Double,
        displayHeight: Double,
        widthInCells: Int,
        heightInCells: Int
    ) {
        self.displayWidth = displayWidth
        self.displayHeight = displayHeight
        self.cellDimensions = floor(displayWidth / Double(widthInCells))
        self.widthInCells = widthInCells
        self.heightInCells = heightInCells
    }

    init(proxy: GeometryProxy, displayMode: GridDisplayMode) {
        switch displayMode {
        case .scaleToFitCellSize(let cellSize):
            self.init(
                displayWidth: proxy.size.width,
                displayHeight: proxy.size.height,
                cellDimensions: cellSize
            )
        case .fixedDimensionsInCells(let dimensions):
            self.init(
                displayWidth: proxy.size.width,
                displayHeight: proxy.size.height,
                widthInCells: dimensions.width,
                heightInCells: dimensions.height
            )
        }
        
    }

    func getViewableDimensions() -> Rectangle {
        Rectangle(width: widthInCells, height: heightInCells)
    }
}



enum GridDisplayMode {
    case scaleToFitCellSize(cellSize: Double)
    case fixedDimensionsInCells(dimensions: Rectangle)
}

extension GridDisplayMode: Hashable {}

extension GridDisplayMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .scaleToFitCellSize:
            return "Scale to fit cellsize"
        case .fixedDimensionsInCells:
            return "Fixed dimensions in cells"
        }
    }
}

protocol AbstractGridViewModel: ObservableObject {
    var viewableDimensions: Rectangle { get set }
    var displayModeOptions: [GridDisplayMode] { get }
    var gridDisplayMode: GridDisplayMode { get set }
    func getTileViewModel(at viewOffset: Vector) -> EntityViewModel
    func translateView(by offset: CGVector)
    func endTranslateView()
}

struct GridView<T: AbstractGridViewModel>: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: T
    
    var body: some View {
        Picker("Display Mode", selection: $viewModel.gridDisplayMode) {
            ForEach(viewModel.displayModeOptions, id: \.self) { displayMode in
                Text(displayMode.description)
            }
        }.pickerStyle(.segmented)
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    let gridViewData = GridViewData(
                        proxy: proxy,
                        displayMode: viewModel.gridDisplayMode
                    )
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
