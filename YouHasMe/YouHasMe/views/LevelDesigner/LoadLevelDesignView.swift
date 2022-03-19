//
//  LoadLevelDesignView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 19/3/22.
//

import Foundation

import SwiftUI

struct LoadLevelDesignView: View {
    var levels: [Level] = StorageUtil.loadSavedLevels()

    var body: some View {
        List {
            ForEach(levels, id: \.self.name) { level in
                NavigationLink(level.name, destination: LevelDesignerView(level: level))
            }
        }
    }
}
