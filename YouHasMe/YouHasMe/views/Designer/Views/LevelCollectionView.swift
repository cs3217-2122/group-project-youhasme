//
//  LevelCollectionView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 7/4/22.
//

import SwiftUI

// reference: https://betterprogramming.pub/the-swiftui-equivalents-to-uicollectionview-60415e3c1bbe
struct LevelCollectionView: View {
    @ObservedObject var viewModel: LevelCollectionViewModel
    let horizontalSpacing: CGFloat = 16
    let height: CGFloat = 300
    
    var body: some View {
        GeometryReader { geometry in
           ScrollView {
               VStack(alignment: .leading, spacing: 8) {
                   ForEach(0..<viewModel.levelNames.count) { i in
                       if i % Int(viewModel.itemsPerRow) == 0 {
                           buildView(rowIndex: i, geometry: geometry)
                       }
                   }
               }
           }
       }
    }
    
    func buildView(rowIndex: Int, geometry: GeometryProxy) -> RowView? {
        var rowItems = [LevelMetadata]()
        for itemIndex in 0..<Int(viewModel.itemsPerRow) {
            if rowIndex + itemIndex < viewModel.levelNames.count {
                rowItems.append(viewModel.levelNames[rowIndex + itemIndex])
            }
        }
        if !rowItems.isEmpty {
            return RowView(
                viewModel: viewModel,
                rowItems: rowItems,
                width: getWidth(geometry: geometry),
                height: height,
                horizontalSpacing: horizontalSpacing
            )
        }
        
        return nil
    }
    
    func getWidth(geometry: GeometryProxy) -> CGFloat {
        let width: CGFloat = (geometry.size.width - horizontalSpacing * (viewModel.itemsPerRow + 1)) / viewModel.itemsPerRow
        return width
    }
}

struct RowView: View {
    @ObservedObject var viewModel: LevelCollectionViewModel
    let rowItems: [LevelMetadata]
    let width: CGFloat
    let height: CGFloat
    let horizontalSpacing: CGFloat
    var body: some View {
        HStack(spacing: horizontalSpacing) {
            ForEach(rowItems) { rowItem in
                LevelMetadataView(levelMetadata: rowItem)
                    .frame(width: width, height: height)
            }
        }
        .padding()
    }
}

struct LevelMetadataView: View {
    var levelMetadata: LevelMetadata
    var body: some View {
        VStack {
            Text(levelMetadata.id.description).padding()
            Text(levelMetadata.name).padding()
            Button("Edit") {
                
            }
        }
    }
}
