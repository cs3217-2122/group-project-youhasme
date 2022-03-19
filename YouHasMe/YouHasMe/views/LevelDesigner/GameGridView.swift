//
//  GameGridView.swift
//  YouHasMe
//

import SwiftUI

struct GameGridView: View {
    @ObservedObject var levelDesignerViewModel: LevelDesignerViewModel

    func gridSize(proxy: GeometryProxy) -> CGFloat {
        let width = floor(proxy.size.width / CGFloat(levelDesignerViewModel.getWidth()))
        let height = floor(proxy.size.height / CGFloat(levelDesignerViewModel.getHeight()))
        return min(width, height)
    }

    var body: some View {
        GeometryReader { proxy in
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    ForEach((0..<levelDesignerViewModel.getHeight()), id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach((0..<levelDesignerViewModel.getWidth()), id: \.self) { col in
                                EntityView(entityType: levelDesignerViewModel.getEntityTypeAtPos(x: col, y: row))
                                    .frame(width: gridSize(proxy: proxy), height: gridSize(proxy: proxy))
                                    .border(.pink)
                                    .onTapGesture {
                                        levelDesignerViewModel.addEntityToPos(x: col, y: row)
                                    }
                                    .onLongPressGesture {
                                        levelDesignerViewModel.removeEntityFromPos(x: col, y: row)
                                    }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

//struct GameGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameGridView()
//    }
//}
