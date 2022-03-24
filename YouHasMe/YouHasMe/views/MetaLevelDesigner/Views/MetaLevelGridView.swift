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
    init(displayWidth: Double, displayHeight: Double, cellDimensions: Double = ViewConstants.gridCellDimensions) {
        self.displayWidth = displayWidth
        self.displayHeight = displayHeight
        self.cellDimensions = cellDimensions
        self.widthInCells = Int(floor(displayWidth / cellDimensions))
        self.heightInCells = Int(floor(displayHeight / cellDimensions))
    }

    init(proxy: GeometryProxy) {
        self.init(displayWidth: proxy.size.width, displayHeight: proxy.size.height)
    }
}

struct MetaLevelGridView: View {
    @ObservedObject var viewModel: MetaLevelDesignerViewModel

    @State var lastDragLocation: CGPoint?

    var body: some View {
        Group {
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    VStack(spacing: 0) {
                        let gridViewData = GridViewData(proxy: proxy)
                        ForEach(0..<gridViewData.heightInCells, id: \.self) { y in
                            HStack(spacing: 0) {
                                ForEach(0..<gridViewData.widthInCells, id: \.self) { x in
                                    MetaEntityView(
                                        viewModel: viewModel.getTileViewModel(at: Vector(dx: x, dy: y))
                                    )
                                    .frame(width: gridViewData.cellWidth, height: gridViewData.cellHeight)
                                    .border(.pink)
                                    .onTapGesture {

                                    }
                                    .onLongPressGesture {

                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let currentDragLocation = value.location

                    if let lastDragLocation = lastDragLocation {
                        let translation = CGVector(from: lastDragLocation, to: currentDragLocation)
                        viewModel.translateView(by: translation)
                    }
                    lastDragLocation = value.location
                }
        )

    }
}

// struct MetaLevelGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetaLevelGridView()
//    }
// }
